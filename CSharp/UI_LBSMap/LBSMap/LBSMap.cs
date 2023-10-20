using ClientData;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//using UnitySlippyMap.Helpers;

public abstract class LBSMap : MonoBehaviour
{
    const int SearchRadiusMeters = 50000;           // 最大为50000米
    const int SearchNearbyInterval = 1;             // 周边检索间隔

    protected IMarkable m_markable;
    Action<bool, Vector2> m_onLocationFinishedEvent;

    protected LBSWebService_fbxm m_webService = new LBSWebService_fbxm();
    Vector2 m_lastCenter;
    List<Vector2> m_searchedCenter = new List<Vector2>();
    float m_lastSearchNearbyTime;

    // 接口
    public interface IMarkable
    {
        void OnAddMarker(uint roleId, GameObject markerObj);
    }

    public enum MapType
    {
        GaoDe,
        Google,
    }


    public abstract Camera Camera { get; }          // 摄像机
    public abstract bool InputEnable { set; }       // 开关地图是否可以输入，如拖动，缩放

    public abstract void SetCenter(Vector2 lnglat);        // 设置地图中心
    protected abstract void AddOrUpdateMarker(uint roleId, Vector2 lnglat);


    public static LBSMap Create(GameObject source, IMarkable markable)
    {
        MapType type = MapType.Google; //PackageConfig.Singleton.GetPackageInfo().MapType; // [fb]
        switch (type)
        {
            case MapType.GaoDe:
                return Create<LBSGaoDeMap>(source, markable);

            case MapType.Google:
                return Create<LBSGoogleMap>(source, markable);

            default:
                throw new InvalidOperationException("Unknown map type: " + type);
        }
    }

    static LBSMap Create<T>(GameObject source, IMarkable markable) where T : LBSMap
    {
        LBSMap map = source.GetComponent<T>();
        if (!map)
            map = source.AddComponent<T>();
        map.Initialize(markable);
        return map;
    }

    public static string GetLanguageString()
    {
		return "zh_cn";
    }


    // 初始化
    protected void Initialize(IMarkable markable)
    {
        m_markable = markable;
    }


    // 周边检索 {
    // 周边检索，搜索完后添加点标记
    protected void SearchNearby(Vector2 center)
    {
        if (m_lastCenter == center)
            return;

        m_lastCenter = center;

        // 判断该点有没有搜索过
        double[] cenerMetres = null;// GeoHelpers.WGS84ToMeters(center.x, center.y);
        Vector2 v2CenerMetres = new Vector2((float)cenerMetres[0], (float)cenerMetres[1]);
        for (int i = 0; i < m_searchedCenter.Count; i++)
        {
            double dis = Vector2.Distance(m_searchedCenter[i], v2CenerMetres);
            if (dis < SearchRadiusMeters)       // 已经搜索过了
                return;
        }

        // 操作若过于频繁限制周边检索次数
        if (Time.time - m_lastSearchNearbyTime < SearchNearbyInterval)
            return;
        m_lastSearchNearbyTime = Time.time;

        // 周边检索
        LBSWebService_fbxm.SearchNearbyResult r = m_webService.SearchNearby(center.x, center.y, SearchRadiusMeters);
        if (!r.Succeed)
            return;

        // 缓存已经搜索过的区域
        m_searchedCenter.Add(v2CenerMetres);

        // 搜索过的name， 为了过滤重复name
        List<string> searchedNames = new List<string>();

        // 添加点标记
        for (int i = 0; i < r.Items.Count; i++)
        {
            var item = r.Items[i];
            uint roleId;

            if (!uint.TryParse(item.Name, out roleId) || searchedNames.Contains(item.Name))
            {
                m_webService.DeleteData(item.ID);     // 删除重复或无用的数据
            }
            else if (roleId != ClientPlayer_fbxm.Singleton.RoleInfo.RoleID)
            {
                searchedNames.Add(item.Name);
                AddOrUpdateMarker(roleId, new Vector2((float)item.Location[0], (float)item.Location[1]));       // 添加或更新点标记
            }
        }
    }
    // }


    // 定位 {
    public void LocationAsync(Action<bool, Vector2> onFinished)
    {
        m_onLocationFinishedEvent = onFinished;
        GameDefine.Mono.StartCoroutine(LocationEtor());
    }

    IEnumerator LocationEtor()
    {
#if UNITY_EDITOR
        UIMessageMgr_fbxm.ShowMsgWait(true);
        yield return new WaitForSeconds(2);
        float lng = UnityEngine.Random.Range(121f, 121.6f);
        float lat = UnityEngine.Random.Range(30.8f, 31.3f);
        OnLocationFinished(true, new Vector2(lng, lat));
        UIMessageMgr_fbxm.ShowMsgWait(false);
        yield break;
#endif

        LocationService loc = Input.location;

        if (!loc.isEnabledByUser)
        {
            loc.Stop();
            UIMessageMgr_fbxm.ShowMessageBoxOnlyOK(Localization.Get("未打开定位功能，无法定位"), null);
            OnLocationFinished(false, Vector2.zero);
            yield break;
        }

        UIMessageMgr_fbxm.ShowMsgWait(true);

        loc.Stop();
        loc.Start(5, 5);

        int timeout = 10;
        while (loc.status == LocationServiceStatus.Initializing)
        {
            if (timeout > 0)
            {
                timeout--;
                yield return new WaitForSeconds(1);
            }
            else
                break;
        }

        if (loc.status == LocationServiceStatus.Running)
        {
            OnLocationFinished(true, new Vector2((float)loc.lastData.longitude, (float)loc.lastData.latitude));
        }
        else if (loc.status == LocationServiceStatus.Initializing)
        {
            UIMessageMgr_fbxm.ShowMessageBoxOnlyOK(Localization.Get("定位超时"), null);
            OnLocationFinished(false, Vector2.zero);
        }
        else if (loc.status == LocationServiceStatus.Failed)
        {
            UIMessageMgr_fbxm.ShowMessageBoxOnlyOK(Localization.Get("定位失败"), null);
            OnLocationFinished(false, Vector2.zero);
        }

        loc.Stop();

        UIMessageMgr_fbxm.ShowMsgWait(false);
    }

    // 定位结束回调
    void OnLocationFinished(bool succeed, Vector2 lnglat)
    {
        Debug.Log(string.Format("定位成功 {0}， 位置： {1}", succeed, lnglat));

        if (m_onLocationFinishedEvent != null)
        {
            m_onLocationFinishedEvent(succeed, lnglat);
            m_onLocationFinishedEvent = null;
        }

        if (!succeed)
            return;

        OnLocationSucceed(lnglat);
    }

    protected virtual void OnLocationSucceed(Vector2 lnglat)
    {
        // 我的标记
        AddOrUpdateMarker(ClientPlayer_fbxm.Singleton.RoleInfo.RoleID, lnglat);

        // 地图中心
        SetCenter(lnglat);

        // 定位成功则更新云数据或插入云数据
        bool updateSuccess = false;
        uint roleid = ClientPlayer_fbxm.Singleton.RoleInfo.RoleID;
        string saveIDKey = string.Format("Unity_Dance_{0}_CloudDataKey", roleid);
        int cloudDataID = PlayerPrefs.GetInt(saveIDKey, -1);

        if (cloudDataID > 0)
        {
            var updateR = m_webService.UpdateData(cloudDataID, roleid.ToString(), lnglat.x, lnglat.y);
            if (updateR.Succeed)
                updateSuccess = true;
        }

        if (!updateSuccess)
        {
            var insertR = m_webService.InsertData(roleid.ToString(), lnglat.x, lnglat.y);
            if (insertR.Succeed)
            {
                // 将云数据 id 则在本地
                PlayerPrefs.SetInt(saveIDKey, insertR.ID);
                PlayerPrefs.Save();
            }
            else
            {
                Debug.LogError(string.Format("insert cloud data failed, name: {0}, lnglat: {1}", roleid, lnglat));
            }
        }
    }
    // }

    // 行政划分检索，如搜索关键字“上海市”
    public LBSWebService_fbxm.SearchDistrictResult SearchDistrict(string keywords)
    {
        return m_webService.SearchDistrict(keywords);
    }

    // 根据经纬度查询其所在行政区域
    public LBSWebService_fbxm.SearchDistrictByLnglatResult SearchDistrict(Vector2 lnglat)
    {
        return m_webService.SearchDistrict(lnglat.x, lnglat.y);
    }
}

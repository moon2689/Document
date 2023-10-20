using ClientData;
using Common;
using System;
using System.Collections.Generic;
using System.Linq;
using UIAnimation.Actions;
using UnityEngine;
//using UnitySlippyMap.Layers;
using Common.Messenger;
namespace Modules.UI
{
    public class UI_LBSMapWnd_fbxm : UIWndBase, UI_LBSDistrictWidget.IHandler, LBSMapInput.IHandler, LBSMap.IMarkable
    {
        [SerializeField]
        GameObject m_btnClose;
        [SerializeField]
        GameObject m_btnLocation;
        [SerializeField]
        GameObject m_objDistrctRoot;
        [SerializeField]
        UI_LBSDistrictWidget m_provinceWidget;
        [SerializeField]
        Transform m_cityParent;
        [SerializeField]
        Transform m_districtParent;
        [SerializeField]
        LBSMapInput m_input;
        [SerializeField]
        ActionRunner m_animWindow;
        [SerializeField]
        Transform m_transMarkers;
        [SerializeField]
        LBSMapMarker m_markerTemplate;

        LBSMap m_lbsMap;
        UI_LBSDistrictWidget m_cityWidget;
        UI_LBSDistrictWidget m_districtWidget;

        List<LBSWebService_fbxm.DistrictItem> m_provinces = new List<LBSWebService_fbxm.DistrictItem>();
        Dictionary<string, List<LBSWebService_fbxm.DistrictItem>> m_cities = new Dictionary<string, List<LBSWebService_fbxm.DistrictItem>>();
        Dictionary<string, List<LBSWebService_fbxm.DistrictItem>> m_districts = new Dictionary<string, List<LBSWebService_fbxm.DistrictItem>>();
        List<GameObject> m_needHideObjs = new List<GameObject>();
        List<LBSMapMarker> m_markers = new List<LBSMapMarker>();

        Queue<LBSMapMarker> m_toGetDataMarkers = new Queue<LBSMapMarker>();
        bool m_msgWaitShowing = false;
        bool m_gettingPlayerData;


        bool ShowDistrict
        {
            get { return false; }
        }


        #region override

        protected sealed override void Awake()
        {
            base.Awake();
            m_lbsMap = LBSMap.Create(gameObject, this);
            m_objDistrctRoot.SetActive(ShowDistrict);
            if (ShowDistrict)
            {
                m_cityWidget = m_provinceWidget.Instantiate(m_cityParent);
                m_districtWidget  = m_provinceWidget.Instantiate(m_districtParent);
            }
        }

        public sealed override void InitWndOnStart()
        {
            base.InitWndOnStart();
            UIEventListener.Get(m_btnClose).onClick = OnClickClose;
            UIEventListener.Get(m_btnLocation).onClick = OnClickLocation;
            ClientTask_fbxm.Singleton.SendMsgGetQuestAction(UnityGMClient.EQuestAction.EQuestAction_UseLBS);
            m_input.Initialize(this);
        }

        public sealed override void OnShowWnd(UIWndData wndData)
        {
            base.OnShowWnd(wndData);

            // close world map, and need hide objs
            AppInterface.GUIModule_fbxm.WorldMapCtrl.SetActive(false);

            GetNeedHideObjs();
            for (int i = 0; i < m_needHideObjs.Count; i++)
            {
                m_needHideObjs[i].SetActive(false);
            }

            // 定位
            StartLocation();
        }

        void GetNeedHideObjs()
        {
            UIRoot uiroot = GameObject.FindObjectOfType<UIRoot>();
            if (!uiroot)
                return;

            foreach (Transform c in uiroot.transform)
            {
                if (!c.gameObject.activeSelf)
                    continue;

                if (!c.GetComponent<Camera>())
                {
                    m_needHideObjs.Add(c.gameObject);
                    continue;
                }

                foreach (Transform ui in c)
                {
                    GameObject uiobj = ui.gameObject;
                    UIWndBase wnd = uiobj.GetComponent<UIWndBase>();
                    if (uiobj.activeSelf
                        && uiobj != gameObject
                        && uiobj != UIManager_fbxm.SingleUIMgr.MsgWaitObj
                        && uiobj != UIManager_fbxm.SingleUIMgr.MessageTipsObj
                        && uiobj != UIManager_fbxm.SingleUIMgr.MessageBoxObj
                        && uiobj != UIManager_fbxm.SingleUIMgr.LoadingObj
                        && uiobj != UIManager_fbxm.SingleUIMgr.MarqueeObj
                        && (wnd == null || (wnd != null && wnd.UIID != UIFlag.ui_novice_guide)))
                    {
                        m_needHideObjs.Add(uiobj);
                    }
                }
            }

        }

        public sealed override void OnHideWnd()
        {
            base.OnHideWnd();

            // open need hide obj
            for (int i = 0; i < m_needHideObjs.Count; i++)
            {
                if (m_needHideObjs[i])
                    m_needHideObjs[i].SetActive(true);
            }
            m_needHideObjs.Clear();

            AppInterface.GUIModule_fbxm.WorldMapCtrl.SetActive(true);
        }

        protected sealed override void SetWndFlag()
        {
            base.m_UIID = UIFlag.ui_lbsmap;
        }

        #endregion


        #region 按钮点击事件

        void OnClickClose(GameObject go)
        {
            UIManager_fbxm.HideUIWnd(this.UIID);
        }

        void OnClickLocation(GameObject go)
        {
            StartLocation();
        }

        #endregion


        void Update()
        {
            // get player data
            if (m_toGetDataMarkers.Count > 0 && !m_gettingPlayerData)
            {
                m_gettingPlayerData = true;
                var marker = m_toGetDataMarkers.Peek();
				Messenger<OtherPlayerInfo>.AddListener(ClientPlayer_fbxm.Str_OnGetOtherPlayerInfoHandle, OnGetPlayerInfoRes);
				ClientPlayer_fbxm.Singleton.GetOtherPlayerInfoAsync(marker.RoleId);
            }

            // 当拉取玩家数据时，转菊花
            if (m_toGetDataMarkers.Count > 0)
            {
                if (!m_msgWaitShowing)
                {
                    UIMessageMgr_fbxm.ShowMsgWait(true);
                    m_msgWaitShowing = true;
                }
            }
            else
            {
                if (m_msgWaitShowing)
                {
                    UIMessageMgr_fbxm.ShowMsgWait(false);
                    m_msgWaitShowing = false;
                }
            }
        }
		void OnGetPlayerInfoRes(OtherPlayerInfo info)
		{
			Messenger<OtherPlayerInfo>.RemoveListener(ClientPlayer_fbxm.Str_OnGetOtherPlayerInfoHandle, OnGetPlayerInfoRes);
			var marker = m_toGetDataMarkers.Dequeue();
			marker.Reset(info);
			marker.IsShow = true;

			m_gettingPlayerData = false;
			SortMarkers();
		}

        #region 定位 & 行政检索

        // 定位
        void StartLocation()
        {
            m_lbsMap.LocationAsync(OnLocationFinished);
        }

        // 定位结束回调
        void OnLocationFinished(bool succeed, Vector2 lnglat)
        {
            m_animWindow.Run();

            if (!ShowDistrict)
                return;

            // 省
            var provinces = SearchDistrict(UI_LBSDistrictWidget.Type.Province, null);

            if (!succeed)
            {
                m_provinceWidget.Reset(provinces, UI_LBSDistrictWidget.Type.Province, this);
                return;
            }

            var r = m_lbsMap.SearchDistrict(lnglat);
            int provinceIndex = provinces.FindIndex(p => p.Name == r.Province);
            if (provinceIndex < 0)
                return;

            m_provinceWidget.Reset(provinces, UI_LBSDistrictWidget.Type.Province, this, provinceIndex, false);
            m_cityWidget.Clear();
            m_districtWidget.Clear();

            // 市
            var cities = SearchDistrict(UI_LBSDistrictWidget.Type.City, r.Province);
            if (cities.Count < 1)
                return;

            int cityIndex = cities.FindIndex(c => c.CityCode == r.CityCode);
            if (cityIndex < 0)
                return;

            string cityName = cityIndex > -1 ? cities[cityIndex].Name : null;
            m_cityWidget.Reset(cities, UI_LBSDistrictWidget.Type.City, this, cityIndex, false);

            // 区
            if (cityName == null)
                return;

            var districts = SearchDistrict(UI_LBSDistrictWidget.Type.District, cityName);
            if (districts.Count < 1)
                return;

            int districtIndex = districts.FindIndex(d => d.Name == r.District);
            m_districtWidget.Reset(districts, UI_LBSDistrictWidget.Type.District, this, districtIndex, false);
        }

        // 行政检索
        public List<LBSWebService_fbxm.DistrictItem> SearchDistrict(UI_LBSDistrictWidget.Type type, string keywords)
        {
            List<LBSWebService_fbxm.DistrictItem> list;
            switch (type)
            {
                case UI_LBSDistrictWidget.Type.Province:
                    if (m_provinces.Count < 1)
                    {
                        string countryName = Localization.Get("中国");
                        var r = m_lbsMap.SearchDistrict(countryName);
                        m_provinces = r.Districts;
                    }
                    list = m_provinces;
                    break;

                case UI_LBSDistrictWidget.Type.City:
                    if (!m_cities.TryGetValue(keywords, out list))
                    {
                        var r = m_lbsMap.SearchDistrict(keywords);
                        m_cities.Add(keywords, r.Districts);
                        list = r.Districts;
                    }
                    break;

                case UI_LBSDistrictWidget.Type.District:
                    if (!m_districts.TryGetValue(keywords, out list))
                    {
                        var r = m_lbsMap.SearchDistrict(keywords);
                        m_districts.Add(keywords, r.Districts);
                        list = r.Districts;
                    }
                    break;

                default:
                    throw new InvalidOperationException("Unknown district: " + type);
            }

            return list;
        }

        #endregion


        #region UI_LBSDistrictWidget.IHandler

        void UI_LBSDistrictWidget.IHandler.OnChange(LBSWebService_fbxm.DistrictItem district, UI_LBSDistrictWidget.Type type)
        {
            if (district == null)
                return;

            switch (type)
            {
                case UI_LBSDistrictWidget.Type.Province:
                    var cities = SearchDistrict(UI_LBSDistrictWidget.Type.City, district.Name);
                    if (cities.Count > 0)
                    {
                        m_cityWidget.Reset(cities, UI_LBSDistrictWidget.Type.City, this);
                    }
                    else
                    {
                        m_cityWidget.Clear();
                        m_districtWidget.Clear();

                        // 地图中心设为当前省份中心
                        if (m_provinceWidget.CurrentDistrict != null)
                            m_lbsMap.SetCenter(m_provinceWidget.CurrentDistrict.CenterLnglat);
                    }
                    break;

                case UI_LBSDistrictWidget.Type.City:
                    var districts = SearchDistrict(UI_LBSDistrictWidget.Type.District, district.Name);
                    if (districts.Count > 0)
                    {
                        m_districtWidget.Reset(districts, UI_LBSDistrictWidget.Type.District, this);
                    }
                    else
                    {
                        m_districtWidget.Clear();

                        // 地图中心设为当前城市中心
                        if (m_cityWidget.CurrentDistrict != null)
                            m_lbsMap.SetCenter(m_cityWidget.CurrentDistrict.CenterLnglat);
                    }
                    break;

                case UI_LBSDistrictWidget.Type.District:
                    // 地图中心设为当前市k中心
                    if (m_districtWidget.CurrentDistrict != null)
                        m_lbsMap.SetCenter(m_districtWidget.CurrentDistrict.CenterLnglat);
                    break;

                default:
                    throw new InvalidOperationException("Unknown district: " + type);
            }
        }

        #endregion


        #region LBSMapInput.IHandler

        void LBSMapInput.IHandler.OnPress(bool pressed)
        {
            m_lbsMap.InputEnable = pressed;
        }

        #endregion


        #region 标志

        // 点标记排序
        void SortMarkers()
        {
            var markers = from m in m_markers
                          orderby m.transform.position.y descending
                          select m;
            int order = 1;

            foreach (var m in markers)
            {
                m.SetOrder(order++);
            }
        }

        void LBSMap.IMarkable.OnAddMarker(uint roleId, GameObject markerObj)
        {
            LBSMapMarker marker = m_markers.Find(m => m.RoleId == roleId);
            if (marker == null)
            {
                marker = m_markerTemplate.Copy<LBSMapMarker>(m_transMarkers);
                marker.RemoveMarker = RemoveMarker;
                m_markers.Add(marker);
                marker.IsShow = false;
                m_toGetDataMarkers.Enqueue(marker);
            }
            marker.Initialize(m_lbsMap, roleId, markerObj);
            marker.IsShow = true;
        }

        void RemoveMarker(LBSMapMarker obj)
        {
            obj.IsShow = false;
        }

        #endregion
    }
}

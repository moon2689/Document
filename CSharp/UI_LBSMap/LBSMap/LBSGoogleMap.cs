using Common;
using System;
using System.Collections.Generic;
using UnityEngine;

public class LBSGoogleMap : LBSMap
{
    OnlineMaps m_map;
    Camera m_camera;
    OnlineMapsTileSetControl m_control;
    List<OnlineMapsMarker> m_markers = new List<OnlineMapsMarker>();
    Vector2 m_lastSearchedPos;
    NGUIAssetItem m_asset;


    public override Camera Camera
    {
        get { return m_camera; }
    }

    public override bool InputEnable
    {
        set
        {
            m_control.allowUserControl = value;           // 在手机上缩放有问题。
        }
    }


    #region mono

    void Awake()
    {
        if (m_map)
            return;

        m_asset = new NGUIAssetItem("common", "google_map");
        m_asset.Load(() =>
        {
            GameObject obj = (GameObject)GameObject.Instantiate(m_asset.Prefab, Vector3.zero, Quaternion.identity, null);
            obj.SetActive(true);

            m_map = obj.GetComponent<OnlineMaps>();
            m_camera = obj.transform.Find("camera").GetComponent<Camera>();
            m_control = obj.GetComponent<OnlineMapsTileSetControl>();
            m_control.OnAddMarkerBillboard = OnAddMarkerBillboard;
            m_map.zoomRange = new OnlineMapsRange(10);
        });
    }

    void OnAddMarkerBillboard(OnlineMapsMarker marker, OnlineMapsMarkerBillboard obj)
    {
        obj.transform.parent.gameObject.SetActive(false);
        m_markable.OnAddMarker(marker.RoleID, obj.gameObject);
    }

    void OnEnable()
    {
        if (m_map)
        {
            m_map.gameObject.SetActive(true);
            m_map.language = LanguageSetting.GetLBSString();
        }
    }

    void OnDisable()
    {
        if (m_map)
            m_map.gameObject.SetActive(false);
    }

    void OnDestroy()
    {
        if (m_map)
            GameObject.Destroy(m_map.gameObject);

        if (m_asset != null)
        {
            m_asset.Destroy();
            m_asset = null;
        }
    }

    void Update()
    {
        if (m_lastSearchedPos != m_map.position)
        {
            m_lastSearchedPos = m_map.position;
            SearchNearby(m_map.position);
        }
    }

    #endregion


    public override void SetCenter(Vector2 lnglat)
    {
        m_map.position = lnglat;
    }

    protected override void AddOrUpdateMarker(uint roleId, Vector2 lnglat)
    {
        OnlineMapsMarker marker = m_markers.Find(m => m.RoleID == roleId);
        if (marker == null)
        {
            marker = m_map.AddMarker(lnglat);
            marker.RoleID = roleId;
            m_markers.Add(marker);
        }
        marker.position = lnglat;
    }

    protected override void OnLocationSucceed(Vector2 lnglat)
    {
        double mglat, mglng;
        LBSMapHelper_fbxm.Transform2Mars(lnglat.y, lnglat.x, out mglat, out mglng);
        base.OnLocationSucceed(new Vector2((float)mglng, (float)mglat));
    }
	
    public override Camera Camera
    {
        get { throw new NotImplementedException(); }
    }

    public override bool InputEnable
    {
        set { throw new NotImplementedException(); }
    }

    public override void SetCenter(Vector2 lnglat)
    {
        throw new NotImplementedException();
    }

    protected override void AddOrUpdateMarker(uint roleId, Vector2 lnglat)
    {
        throw new NotImplementedException();
    }
}

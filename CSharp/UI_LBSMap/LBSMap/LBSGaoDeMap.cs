using System.Collections.Generic;
using UnityEngine;
using UnitySlippyMap.Input;
using UnitySlippyMap.Layers;
using UnitySlippyMap.Map;
using UnitySlippyMap.Markers;

public class LBSGaoDeMap : LBSMap
{
    MapBehaviour m_map;
    GaoDeTileLayerBehaviour m_layer;
    Camera m_camera;

    Dictionary<uint, GameObject> m_markers = new Dictionary<uint, GameObject>();


    // 属性 {
    public override Camera Camera
    {
        get { return m_camera; }
    }

    // 开关地图是否可以输入，如拖动，缩放
    public override bool InputEnable
    {
        set { m_map.InputsEnabled = value; }
    }
    // }


    // Mono {
    void Awake()
    {
        // camera
        GameObject camGo = new GameObject("[LBSMapCamera]");
        m_camera = camGo.AddComponent<Camera>();
        m_camera.nearClipPlane = 0.01f;
        m_camera.farClipPlane = 100;
        m_camera.depth = -1;
        m_camera.useOcclusionCulling = false;
        m_camera.allowHDR = false;
        m_camera.allowMSAA = false;
        m_camera.cullingMask = 1 << (int)Common.CameraLayer.LBSMap;
        m_camera.clearFlags = CameraClearFlags.SolidColor;
        m_camera.backgroundColor = Color.white;
        m_camera.fieldOfView = 20;

        // map
        m_map = MapBehaviour.Instance;
        m_map.gameObject.layer = (int)Common.CameraLayer.LBSMap;
        m_map.CurrentCamera = m_camera;
        m_map.InputDelegate += MapInput.BasicTouchAndKeyboard;
        m_map.CurrentZoom = 14;
        m_map.MinZoom = 10;
        m_map.MaxZoom = 19;
        m_map.CenterWGS84 = new double[2] { 116.407394, 39.904211 };        // 默认地设为北京
        m_map.UsesLocation = false;
        m_map.InputsEnabled = false;

        // layer
        m_layer = m_map.CreateLayer<GaoDeTileLayerBehaviour>("GaoDe");
    }

    void OnEnable()
    {
        if (m_map)
            m_map.gameObject.SetActive(true);
        if (m_camera)
            m_camera.gameObject.SetActive(true);
    }

    void OnDisable()
    {
        if (m_map)
            m_map.gameObject.SetActive(false);
        if (m_camera)
            m_camera.gameObject.SetActive(false);
    }

    void OnDestroy()
    {
        if (m_map)
            GameObject.Destroy(m_map.gameObject);
        if (m_camera)
            GameObject.Destroy(m_camera.gameObject);

        var tileTemplateObj = GameObject.Find("[Tile Template]");
        if (tileTemplateObj)
            GameObject.Destroy(tileTemplateObj);
    }

    void Update()
    {
        // 周边检索，若摄像机中心变化
        if (!m_map.HasMoved)
            SearchNearby(new Vector2((float)m_map.CenterWGS84[0], (float)m_map.CenterWGS84[1]));
    }

    // }


    // 设置地图中心
    public override void SetCenter(Vector2 lnglat)
    {
        m_map.CenterWGS84 = new double[2] { lnglat.x, lnglat.y };
    }

    protected override void AddOrUpdateMarker(uint roleId, Vector2 lnglat)
    {
        GameObject marker;
        double[] center = new double[2] { lnglat.x, lnglat.y };

        if (m_markers.TryGetValue(roleId, out marker))
        {
            MarkerBehaviour markerBeh = marker.transform.parent.GetComponent<MarkerBehaviour>();
            markerBeh.CoordinatesWGS84 = center;
        }
        else
        {
            marker = new GameObject("Marker");
            m_markers.Add(roleId, marker);
            m_map.CreateMarker<MarkerBehaviour>(roleId.ToString(), center, marker);
            m_markable.OnAddMarker(roleId, marker);
        }
    }

    public override Camera Camera
    {
        get { throw new System.NotImplementedException(); }
    }

    public override bool InputEnable
    {
        set { throw new System.NotImplementedException(); }
    }

    public override void SetCenter(Vector2 lnglat)
    {
        throw new System.NotImplementedException();
    }

    protected override void AddOrUpdateMarker(uint roleId, Vector2 lnglat)
    {
        throw new System.NotImplementedException();
    }
}

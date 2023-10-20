using ClientData;
using Common;
using Modules.UI;
using System;
using UnityEngine;
//using UnitySlippyMap.Markers;

public class LBSMapMarker : UI_BaseWidget
{
    public Action<LBSMapMarker> RemoveMarker;

    [SerializeField]
    UILabel m_labelName;
    [SerializeField]
    UITexture m_icon;
    [SerializeField]
    UISprite m_spriteFrame;

    ImageAssetItem m_iconAsset;
    uint m_roleId;
    GameObject m_posInMap;
    LBSMap m_lbsMap;
    OtherPlayerInfo m_playerInfo;

    public uint RoleId
    {
        get { return m_roleId; }
    }

    public OtherPlayerInfo PlayerInfo
    {
        get { return m_playerInfo; }
    }


    void Start()
    {
        UIEventListener.Get(gameObject).onClick = OnClickMarker;
    }

    void OnClickMarker(GameObject go)
    {
        Vector3 localPos = transform.parent.InverseTransformPoint(m_icon.transform.position);
        var content = new UI_LBSMapQuickActionWnd_fbxm.Content()
        {
            PlayerInfo = m_playerInfo,
            NGUIPos = localPos,
        };
        UIManager_fbxm.ShowUISync(UIFlag.ui_quick_action, UIFlag.ui_lbsmap_quick_action, UIFlag.none, false, content, UIFlag.none);
    }

    void OnDestroy()
    {
        if (m_iconAsset != null)
        {
            m_iconAsset.Destroy();
            m_iconAsset = null;
            m_icon.material.mainTexture = null;
        }
    }

    public void Initialize(LBSMap map, uint roleid, GameObject posInMap)
    {
        m_lbsMap = map;
        m_roleId = roleid;
        m_posInMap = posInMap;
    }

    public void Reset(OtherPlayerInfo playerInfo)
    {
        m_playerInfo = playerInfo;

        PhotoLoadHelp.instance.LoadPhotoHeadItem(playerInfo.SereverID, m_roleId, playerInfo.RoleSex, (_data) =>
        {
            m_icon.mainTexture = _data.texture;
        });

        bool isMale = playerInfo.RoleSex == Sex_Type.Boy;
        m_spriteFrame.spriteName = isMale ? "LBSMarkerMale" : "LBSMarkerFemale";
        transform.name = m_roleId + "_marker";

        m_labelName.text = playerInfo.Name;
    }

    public void SetOrder(int order)
    {
        int offset = order * 2;
        m_icon.depth = 1 + offset;
        m_spriteFrame.depth = 2 + offset;
        m_labelName.depth = 2 + offset;
    }

    void LateUpdate()
    {
        RefreshPosition();
    }

    void RefreshPosition()
    {
        if (m_posInMap)
        {
            Vector3 screenPos = m_lbsMap.Camera.WorldToScreenPoint(m_posInMap.transform.position);
            Vector3 nguiPos = GameHelper.TransformScreenPosToNGUIPos(screenPos);
            transform.localPosition = nguiPos;
        }
        else
        {
            RemoveMarker(this);
        }
    }
}

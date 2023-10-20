using ClientData;
using Common;
using Common.Messenger;
using System;
using UnityEngine;

namespace Modules.UI
{
    class UI_LBSMapQuickActionItem : UI_BaseWidget
    {
        [SerializeField]
        GameObject m_Btn;
        [SerializeField]
        UISprite m_Icon;
        [SerializeField]
        UILabel actionText;
        [SerializeField]
        QuickActionType m_ActionType = QuickActionType.None;

        UI_LBSMapQuickActionWnd_fbxm m_parentWnd;

        public QuickActionType ActionType
        {
            get { return m_ActionType; }
        }

        GameObject mObj = null;
        public GameObject CacheObj
        {
            get
            {
                if (null == mObj) mObj = this.gameObject;
                return mObj;
            }
        }

        OtherPlayerInfo m_RoomPlayerData;

        BoxCollider boxCollider = null;
        UISprite btnSpr = null;
        string canClick = "canbg", cantClick = "cantbg";
        //icon资源名称

        void Start()
        {
            UIEventListener.Get(m_Btn).onClick = OnClickBtn;
        }

        public void InitInfo(UI_LBSMapQuickActionWnd_fbxm parentWnd, OtherPlayerInfo data, QuickActionType actionType, Vector3 pos)
        {
            m_parentWnd = parentWnd;

            if (null == data) return;
            if (null == boxCollider)
                boxCollider = m_Btn.GetComponent<BoxCollider>();
            if (null == btnSpr)
                btnSpr = m_Btn.GetComponent<UISprite>();
            m_RoomPlayerData = data;
            m_ActionType = actionType;

            //打开自己的快捷操作面板
            if (data.RoleID == ClientPlayer_fbxm.Singleton.RoleInfo.RoleID)
            {
                if (actionType == QuickActionType.Personal || actionType == QuickActionType.Action)
                    SetBtnState(true);
                else
                    SetBtnState(false);
            }
            else if (actionType == QuickActionType.SayLove)
            {
                if (!ClientCouple_fbxm.Singleton.Single) //操作按钮不可点击
                {
                    SetBtnState(false);
                }
                else                                //操作按钮可点击
				{
					SetBtnState(data.IsSingle);
                }
            }
            else
            {
                SetBtnState(true);
            }

            switch (actionType)
            {
                case QuickActionType.None:
                    break;
                case QuickActionType.Personal:
                    actionText.text = Localization.Get("个人资料");
                    break;
                case QuickActionType.Host:
                    actionText.text = Localization.Get("roomAppointHost");
                    break;
                case QuickActionType.Kick:
                    actionText.text = Localization.Get("roomKickout");
                    break;
                //case QuickActionType.Club:
                //    actionText.text = Localization.Get("roomClubInvite");
                //    break;
                case QuickActionType.Chat:
                    actionText.text = Localization.Get("roomPersonalChat");
                    break;
                case QuickActionType.Action:
                    actionText.text = Localization.Get("roomAction");
                    break;
                case QuickActionType.Gift:
                    actionText.text = Localization.Get("赠送礼物");
                    break;
                case QuickActionType.Friend:
                    actionText.text = Localization.Get("roomAddFriend");
                    break;
                case QuickActionType.SayLove:
                    actionText.text = Localization.Get("向TA表白");
                    break;
                default:
                    break;
            }
            CacheObj.transform.localPosition = pos;

            CacheObj.SetActive(true);
        }

        void OnClickBtn(GameObject go)
        {
            string strName = m_RoomPlayerData.Name;
            switch (m_ActionType)
            {
                case QuickActionType.None:
                    break;
                case QuickActionType.Personal:
                    CheckPersonalInfo();
                    break;
                //case QuickActionType.Club:
                //    Debug.Log("社团邀请");
                //    break;
                case QuickActionType.Chat:
                    ChatParam param = new ChatParam(m_RoomPlayerData.RoleID, m_RoomPlayerData.Name, m_RoomPlayerData.VipLevel, m_RoomPlayerData.IsHideVIP, m_RoomPlayerData.RoleSex);
                    UIManager_fbxm.ShowUISync(UIFlag.ui_world, UIFlag.ui_chat, UIFlag.ui_world, false, param, UIFlag.none);
                    break;
                case QuickActionType.Gift:
                    var content = new UI_PresentGiftWnd_fbxm.Content(m_RoomPlayerData.RoleID, strName);
                    UIManager_fbxm.ShowUISync(UIFlag.ui_personal_info_new, UIFlag.ui_present_gift, UIFlag.ui_world, false, content, UIFlag.none);
                    break;
                case QuickActionType.Friend:
                    m_parentWnd.AddFriend(m_RoomPlayerData);
                    break;
                case QuickActionType.SayLove:
                    UIManager_fbxm.ShowUISync(UIFlag.ui_personal_info_new, UIFlag.ui_express_love, UIFlag.ui_world, false, m_RoomPlayerData.RoleID, UIFlag.none);
                    break;
                default:
                    throw new InvalidOperationException("Unknown action type: " + m_ActionType);
            }
            if (QuickActionType.Host != m_ActionType)
                Messenger.Broadcast(MessengerEventDef.RoomHideQuickOperationPanel);

            m_parentWnd.HidePanel();
        }

        public void SetBtnState(bool isCanClick)
        {
            if (null != btnSpr && null != boxCollider)
            {
                btnSpr.spriteName = isCanClick ? canClick : cantClick;
                boxCollider.enabled = isCanClick;
                string iconName = m_ActionType.ToString().ToLower() + (isCanClick ? "_can" : "_cant");
                m_Icon.spriteName = iconName;
            }
        }

        #region 查看个人信息
        void CheckPersonalInfo()
        {
            if (null != m_RoomPlayerData)
            {
                if (m_RoomPlayerData.RoleID == ClientPlayer_fbxm.Singleton.RoleInfo.RoleID)
                    UIManager_fbxm.ShowUISync(UIFlag.ui_personal_info_new, UIFlag.ui_lbsmap, null, UIFlag.none);
                else
                    UI_OtherPlayerInfoNewWnd_fbxm.Create(UIFlag.ui_lbsmap, m_RoomPlayerData.RoleID, UIFlag.none);
            }
        }
        #endregion

        public void Hide()
        {
            Destroy(CacheObj);
        }
    }
}

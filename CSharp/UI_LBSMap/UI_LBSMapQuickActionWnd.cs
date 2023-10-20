using ClientData;
using Common;
using Common.Messenger;
using System.Collections.Generic;
using UnityEngine;

namespace Modules.UI
{
    class UI_LBSMapQuickActionWnd_fbxm : UIWndBase
    {
        [SerializeField]
        BackAndForthWindow m_animWindow;
        [SerializeField]
        GameObject m_bgBtn;
        [SerializeField]
        UI_LBSMapQuickActionItem m_template;
        [SerializeField]
        Transform m_root;

        bool m_isShow = true;
        Content m_content;
        EffectAssetItem m_effectAsset;
        GameObject m_effectObj;
        List<UI_LBSMapQuickActionItem> m_listWidget = new List<UI_LBSMapQuickActionItem>();


        public class Content
        {
            public Vector3 NGUIPos;
            public OtherPlayerInfo PlayerInfo;
        }


        protected override void SetWndFlag()
        {
            base.m_UIID = UIFlag.ui_lbsmap_quick_action;
        }

        public override void InitWndOnAwake()
        {
            base.InitWndOnAwake();
            UIEventListener.Get(m_bgBtn).onClick = OnCickBgBtn;
            UIEventListener.Get(m_bgBtn).onPress = OnPressBgBtn;
        }

        private void OnPressBgBtn(GameObject go, bool state)
        {
            AnimHide();
        }

        public override void OnReadShow()
        {
            base.OnReadShow();
            m_root.localScale = Vector3.zero;
            m_animWindow.Show();
        }

        public override void OnShowWnd(UIWndData wndData)
        {
            base.OnShowWnd(wndData);
            m_content = (Content)wndData.ExData;

            if (m_effectAsset == null)
            {
                m_effectAsset = new EffectAssetItem(EffectAssetHelp.Subfolder_UI_WaitRoom, "uifx_jiesuan");
                m_effectAsset.Load(LoadEffectCallback);
            }

            ShowItems();

            m_root.localPosition = m_content.NGUIPos;
        }

        void LoadEffectCallback()
        {
            m_effectObj = NGUITools.AddChild(m_root.gameObject, m_effectAsset.Prefab);
            m_effectObj.transform.localPosition = new Vector3(49, -135, 0);
            m_effectObj.transform.localScale = new Vector3(135, 135, 135);
            m_effectObj.SetActive(true);
        }

        public override void OnHideWnd()
        {
            base.OnHideWnd();
            m_isShow = false;
            if (null != m_effectAsset)
            {
                m_effectAsset.Destroy();
                m_effectAsset = null;
            }
            Destroy(m_effectObj);
            m_effectObj = null;
            for (int i = 0, iMax = m_listWidget.Count; i < iMax; ++i)
                m_listWidget[i].Hide();
            m_listWidget.Clear();
        }

		public override void RegisterMessage()
		{
			base.RegisterMessage();
		}

		public override void RemoveMessage()
		{
			base.RemoveMessage();
		}

        void HideGameWnd()
        {
            if (!m_isShow)
                UIManager_fbxm.HideUIWnd(this.UIID);
        }

        List<QuickActionType> GetQuickOperationList()
        {
            List<QuickActionType> list = new List<QuickActionType>();
            list.Add(QuickActionType.Chat);
            list.Add(QuickActionType.Friend);
            list.Add(QuickActionType.Gift);
            list.Add(QuickActionType.Personal);
            list.Add(QuickActionType.SayLove);
            return list;
        }

        void ShowItems()
        {
            if (m_listWidget.Count == 0)
            {
                List<QuickActionType> actionList = GetQuickOperationList();
                float radius = 160.0f;
                Vector3 centerPos = Vector3.zero;
                int itemCount = actionList.Count == 0 ? 1 : actionList.Count;
                float copies = (360.0f / itemCount) * Mathf.Deg2Rad;

                for (int i = 0; i < actionList.Count; i++)
                {
                    QuickActionType type = actionList[i];
                    GameObject item = NGUITools.AddChild(m_root.gameObject, m_template.gameObject);
                    item.name = type.ToString().ToLower();
                    UI_LBSMapQuickActionItem itemCtrl = item.GetComponent<UI_LBSMapQuickActionItem>();
                    float x = radius * Mathf.Cos(copies * i);
                    float y = radius * Mathf.Sin(copies * i);
                    Vector3 posVec3 = new Vector3(x, y, 0) + centerPos;
                    itemCtrl.InitInfo(this, m_content.PlayerInfo, type, posVec3);
                    m_listWidget.Add(itemCtrl);
                }
            }
        }

        void OnCickBgBtn(GameObject go)
        {
            AnimHide();
        }

        void AnimHide()
        {
            m_animWindow.Hide();
            m_animWindow.OnHide = HidePanel;
        }

        public void HidePanel()
        {
            m_isShow = false;
            HideGameWnd();
        }

        #region 加好友
        public void AddFriend(OtherPlayerInfo player)
        {
            ClientFriend_fbxm.Singleton.FriendApply(player.RoleID, player.RoleSex, player.Name);
        }
        #endregion
    }
}


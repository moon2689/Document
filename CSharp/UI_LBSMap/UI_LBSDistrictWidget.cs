using System.Collections.Generic;
using UIAnimation.Actions;
using UnityEngine;

public class UI_LBSDistrictWidget : UI_BaseWidget, UI_LBSDistrictItem.IHandler
{
    [SerializeField]
    GameObject m_btnDropMenu;
    [SerializeField]
    UILabel m_labelSelected;
    [SerializeField]
    UI_LBSDistrictItem m_itemTemplate;
    [SerializeField]
    UIScrollView m_scroll;
    [SerializeField]
    UIGrid m_grid;
    [SerializeField]
    ActionRunner m_actionShowMenu;
    [SerializeField]
    ActionRunner m_actionHideMenu;

    List<LBSWebService_fbxm.DistrictItem> m_districts;
    List<UI_LBSDistrictItem> m_items = new List<UI_LBSDistrictItem>();
    bool m_dropMenuShowing;
    LBSWebService_fbxm.DistrictItem m_currentDistrict;
    IHandler m_handler;
    Type m_type;


    public interface IHandler
    {
        void OnChange(LBSWebService_fbxm.DistrictItem district, Type type);
    }

    public enum Type
    {
        Province,
        City,
        District,
    }

    void Start()
    {
        UIEventListener.Get(m_btnDropMenu).onClick = OnClickDropMenu;
    }

    public UI_LBSDistrictWidget Instantiate(Transform parent)
    {
        return base.Copy<UI_LBSDistrictWidget>(parent);
    }

    public void Reset(List<LBSWebService_fbxm.DistrictItem> districts, Type type, IHandler handler, int defaultIndex = 0, bool triggerOnChangeEvent = true)
    {
        m_districts = districts;
        m_type = type;
        m_handler = handler;

        // 无任何区域
        if (districts == null || districts.Count < 1)
        {
            m_currentDistrict = null;
            m_labelSelected.text = "";
            return;
        }

        // 默认选择
        defaultIndex = Mathf.Clamp(defaultIndex, 0, districts.Count);
        m_currentDistrict = districts[defaultIndex];
        m_labelSelected.text = districts[defaultIndex].Name;
        if (handler != null && triggerOnChangeEvent)
            handler.OnChange(m_currentDistrict, type);

        // 刷新子区域
        for (int i = 0; i < districts.Count; i++)
        {
            UI_LBSDistrictItem item;
            if (i < m_items.Count)
            {
                item = m_items[i];
            }
            else
            {
                item = m_itemTemplate.Instantiate(m_grid.transform);
                m_items.Add(item);
            }

            item.IsShow = true;
            item.Reset(districts[i], this);
        }

        for (int i = districts.Count; i < m_items.Count; i++)
        {
            m_items[i].IsShow = false;
        }

        m_grid.Reposition();
        m_scroll.ResetPosition();

        // drop
        ShowDropMenu(false);
    }

    public void ShowDropMenu(bool show)
    {
        if (show)
        {
            m_actionShowMenu.Run();

            m_grid.Reposition();
            m_scroll.ResetPosition();
        }
        else
            m_actionHideMenu.Run();

        m_dropMenuShowing = show;
    }

    public void Clear()
    {
        m_labelSelected.text = "";
        m_districts = null;

        for (int i = 0; i < m_items.Count; i++)
        {
            m_items[i].IsShow = false;
        }

        ShowDropMenu(false);
    }

    void OnClickDropMenu(GameObject obj)
    {
        if (m_districts == null || m_districts.Count < 1)
            return;

        ShowDropMenu(!m_dropMenuShowing);
    }

    void UI_LBSDistrictItem.IHandler.OnClick(LBSWebService_fbxm.DistrictItem district)
    {
        ShowDropMenu(false);

        if (district == null)
            return;

        if (m_currentDistrict == district)
            return;

        m_currentDistrict = district;
        m_labelSelected.text = district.Name;
        if (m_handler != null)
            m_handler.OnChange(district, m_type);
    }

    public LBSWebService_fbxm.DistrictItem CurrentDistrict
    {
        get { return m_currentDistrict; }
    }
}

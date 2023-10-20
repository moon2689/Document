using UnityEngine;

public class UI_LBSDistrictItem : UI_BaseWidget
{
    [SerializeField]
    UILabel m_labelName;

    IHandler m_handler;
    LBSWebService_fbxm.DistrictItem m_data;

    public interface IHandler
    {
        void OnClick(LBSWebService_fbxm.DistrictItem district);
    }

    void Start()
    {
        UIEventListener.Get(gameObject).onClick = OnClickObj;
    }

    public UI_LBSDistrictItem Instantiate(Transform parent)
    {
        return base.Copy<UI_LBSDistrictItem>(parent);
    }

    public void Reset(LBSWebService_fbxm.DistrictItem district, IHandler handler)
    {
        m_handler = handler;
        m_data = district;
        m_labelName.text = district.Name;
    }

    void OnClickObj(GameObject obj)
    {
        if (m_handler != null)
            m_handler.OnClick(m_data);
    }
}

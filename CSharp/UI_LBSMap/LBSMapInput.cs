using UnityEngine;

public class LBSMapInput : MonoBehaviour
{
    IHandler m_handler;

    public interface IHandler
    {
        void OnPress(bool pressed);
    }

    public void Initialize(IHandler handler)
    {
        m_handler = handler;
    }

    void OnPress(bool pressed)
    {
        if (m_handler != null)
            m_handler.OnPress(pressed);
    }
}

using System.IO;
using System.Net;
using System.Text;

// 参考： http://www.cnblogs.com/xssxss/archive/2012/07/03/2574554.html
public static class HttpRequest_fbxm
{
    public static string SendPost(string url, string args)
    {
        byte[] argsBuffer = Encoding.UTF8.GetBytes(args);

        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
        request.Method = "POST";
        request.ContentType = "application/x-www-form-urlencoded";
        request.ContentLength = argsBuffer.Length;

        using (Stream reqStream = request.GetRequestStream())
        {
            reqStream.Write(argsBuffer, 0, argsBuffer.Length);
        }

        HttpWebResponse response = (HttpWebResponse)request.GetResponse();
        string retString;
        using (Stream resStream = response.GetResponseStream())
        {
            using (StreamReader streamReader = new StreamReader(resStream, Encoding.UTF8))
            {
                retString = streamReader.ReadToEnd();
            }
        }

        return retString;
    }

    public static string SendGet(string url, string args)
    {
        if (!string.IsNullOrEmpty(args))
            url += "?" + args;
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
        request.Method = "GET";
        request.ContentType = "text/html;charset=UTF-8";

        HttpWebResponse response = (HttpWebResponse)request.GetResponse();
        string retString;
        using (Stream responseStream = response.GetResponseStream())
        {
            using (StreamReader myStreamReader = new StreamReader(responseStream, Encoding.UTF8))
            {
                retString = myStreamReader.ReadToEnd();
            }
        }

        return retString;
    }
}

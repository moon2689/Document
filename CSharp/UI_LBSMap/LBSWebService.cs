//#define DebugMode
using SimpleJSON;
using System.Collections.Generic;
using UnityEngine;
using ClientData;
public class LBSWebService_fbxm
{
    #region Result

    // 插入云数据结果
    public class InsertDataResult
    {
        public int Status;
        public int ID;
        public string Info;
        public string InfoCode;

        public bool Succeed
        {
            get { return Status == 1; }
        }
    }

    // 更新云数据结果
    public class UpdateDataResult
    {
        public int Status;
        public string Info;

        public bool Succeed
        {
            get { return Status == 1; }
        }
    }

    // 删除云数据结果
    public class DeleteDataResult
    {
        public int Status;
        public string Info;
        public int SucceedCount;
        public int FailCount;

        public bool Succeed
        {
            get { return Status == 1; }
        }
    }

    // 周边检索结果
    public class SearchNearbyResult
    {
        public int Status;
        public string Info;
        public int Count;
        public List<SearchNearbyItem> Items;

        public bool Succeed
        {
            get { return Status == 1; }
        }
    }

    // 周边检索元素
    public class SearchNearbyItem
    {
        public int ID;
        public string Name;
        public Vector2 Location;
        public string Address;
        public float Distance;
        public string Province;
        public string City;
        public string District;
    }

    // 行政区域搜索结果
    public class SearchDistrictResult
    {
        public int Status;
        public string Info;
        public string Infocode;
        public int Count;
        public List<DistrictItem> Districts;

        public bool Success
        {
            get { return Status == 1; }
        }
    }

    // 行政区域元素
    public class DistrictItem
    {
        public string Name;
        public Vector2 CenterLnglat;
        public string CityCode;
    }

    // 行政逆编码查询
    public class SearchDistrictByLnglatResult
    {
        public int Status;
        public string Info;
        public string InfoCode;

        public string Province;
        public string CityCode;
        public string District;

        public bool Succeed
        {
            get { return Status == 1; }
        }
    }

    #endregion

    // 插入数据
    public InsertDataResult InsertData(string name, float lng, float lat)
    {
        string url = "http://yuntuapi.amap.com/datamanage/data/create";
        string data = string.Format("\"_name\":\"{0}\",\"_location\":\"{1},{2}\"", name, lng, lat);
        string args = string.Format("key={0}&tableid={1}&data={{{2}}}", Key, TableID, data);
        string result = HttpRequest_fbxm.SendPost(url, args);

#if DebugMode
        Debug.Log(string.Format("LBS, insert data, url: {0}, args: {1}, result: {2}", url, args, result));
#endif

        // eg: {"info":"OK","infocode":"10000","status":1,"_id":"5"}
        var root = JSON.Parse(result);
        InsertDataResult r = new InsertDataResult();
        r.ID = root["_id"].AsInt;
        r.Info = root["info"];
        r.InfoCode = root["infocode"];
        r.Status = root["status"].AsInt;

        return r;
    }

    // 更新数据
    public UpdateDataResult UpdateData(int id, string name, float lng, float lat)
    {
        string url = "http://yuntuapi.amap.com/datamanage/data/update";
        string data = string.Format("\"_id\":\"{0}\",\"name\":\"{1}\",\"location\":\"{2},{3}\"", id, name, lng, lat);
        string args = string.Format("key={0}&tableid={1}&data={{{2}}}", Key, TableID, data);
        string result = HttpRequest_fbxm.SendPost(url, args);

#if DebugMode
        Debug.Log(string.Format("LBS, update data, url: {0}, args: {1}, result: {2}", url, args, result));
#endif

        UpdateDataResult r = new UpdateDataResult();
        var root = JSON.Parse(result);
        r.Info = root["info"];
        r.Status = root["status"].AsInt;
        return r;
    }

    // 删除数据
    public DeleteDataResult DeleteData(int id)
    {
        string url = "http://yuntuapi.amap.com/datamanage/data/delete";
        string args = string.Format("key={0}&tableid={1}&ids={2}", Key, TableID, id);
        string result = HttpRequest_fbxm.SendPost(url, args);

#if DebugMode
        Debug.Log(string.Format("LBS, delete data, url: {0}, args: {1}, result: {2}", url, args, result));
#endif

        DeleteDataResult r = new DeleteDataResult();
        var root = JSON.Parse(result);
        r.FailCount = root["fail"].AsInt;
        r.Info = root["info"];
        r.Status = root["status"].AsInt;
        r.SucceedCount = root["success"].AsInt;

        return r;
    }

    // 周边检索
    public SearchNearbyResult SearchNearby(double lng, double lat, int radius)
    {
        string url = "http://yuntuapi.amap.com/datasearch/around";
        string args = string.Format("key={0}&tableid={1}&center={2},{3}&radius={4}", Key, TableID, lng, lat, radius);
        string result = HttpRequest_fbxm.SendGet(url, args);

#if DebugMode
        Debug.Log(string.Format("LBS, search nearby, url: {0}, args: {1}, result: {2}", url, args, result));
#endif

        JSONNode root = JSON.Parse(result);
        SearchNearbyResult r = new SearchNearbyResult();
        r.Status = root["status"].AsInt;
        r.Info = root["info"];
        r.Count = root["count"].AsInt;
        r.Items = new List<SearchNearbyItem>();

        var items = root["datas"].AsArray;
        for (int i = 0; i < items.Count; i++)
        {
            var item = items[i];
            SearchNearbyItem si = new SearchNearbyItem();
            si.Address = item["_address"];
            si.City = item["_city"];
            si.Distance = item["_distance"].AsFloat;
            si.District = item["_district"];
            si.ID = item["_id"].AsInt;
            si.Name = item["_name"];
            si.Province = item["_province"];

            string strLocation = item["_location"];
            string[] words = strLocation.Split(',');
            if (words.Length > 1)
            {
                FBGameHelper.TryParseFloat(words[0], out si.Location.x);
                FBGameHelper.TryParseFloat(words[1], out si.Location.y);
            }

            r.Items.Add(si);
        }

        return r;
    }

    // 行政区域检索
    public SearchDistrictResult SearchDistrict(string keywords)
    {
        string url = "http://restapi.amap.com/v3/config/district";
        string args = string.Format("key={0}&keywords={1}&subdistrict=1", Key, keywords);
        string result = HttpRequest_fbxm.SendGet(url, args);

#if DebugMode
        Debug.Log(string.Format("LBS, search district, url: {0}, args: {1}, result: {2}", url, args, result));
#endif

        JSONNode root = JSON.Parse(result);
        SearchDistrictResult r = new SearchDistrictResult();
        r.Count = root["count"].AsInt;
        r.Info = root["info"];
        r.Infocode = root["infocode"];
        r.Status = root["status"].AsInt;
        r.Districts = new List<DistrictItem>();

        JSONArray districtRoot = root["districts"].AsArray;
        if (districtRoot.Count > 0)
        {
            JSONArray districtArray = districtRoot[0]["districts"].AsArray;
            for (int i = 0; i < districtArray.Count; i++)
            {
                JSONNode disNode = districtArray[i];
                DistrictItem disItem = new DistrictItem();
                disItem.Name = disNode["name"];

                string strCenter = disNode["center"];
                string[] centerWords = strCenter.Split(',');
                if (centerWords.Length > 1)
                {
                    FBGameHelper.TryParseFloat(centerWords[0], out disItem.CenterLnglat.x);
                    FBGameHelper.TryParseFloat(centerWords[1], out disItem.CenterLnglat.y);
                }

                disItem.CityCode = disNode["citycode"];

                r.Districts.Add(disItem);
            }
        }

        return r;
    }

    // 根据经纬度查询地区信息
    public SearchDistrictByLnglatResult SearchDistrict(float lng, float lat)
    {
        string url = "http://restapi.amap.com/v3/geocode/regeo";
        string args = string.Format("key={0}&location={1},{2}&radius=0", Key, lng, lat);
        string result = HttpRequest_fbxm.SendGet(url, args);

#if DebugMode
        Debug.Log(string.Format("LBS, search district, url: {0}, args: {1}, result: {2}", url, args, result));
#endif

        JSONNode root = JSON.Parse(result);
        SearchDistrictByLnglatResult r = new SearchDistrictByLnglatResult();
        r.Info = root["info"];
        r.InfoCode = root["infocode"];
        r.Status = root["status"].AsInt;

        var regeocode = root["regeocode"];
        if (regeocode != null)
        {
            var address = regeocode["addressComponent"];
            r.Province = address["province"];
            r.CityCode = address["citycode"];
            r.District = address["district"];
        }

        return r;
    }

    // 高德地图web服务申请的key，见： http://lbs.amap.com/dev/key/app
    static string Key
    {
        get { return ClientServer_fbxm.Singleton.GetSelectServer().lbsWebServiceKey; }
    }

    // 我创建的地图的id，见： http://yuntu.amap.com/datamanager/
    static string TableID
    {
        get { return ClientServer_fbxm.Singleton.GetSelectServer().lbsTableID; }
    }
}

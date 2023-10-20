using System;

public static class LBSMapHelper_fbxm
{
    const double PI = 3.14159265358979324;
    const double A = 6378245.0;
    const double EE = 0.00669342162296594323;
    const double X_PI = 3.14159265358979324 * 3000.0 / 180.0;

    static bool OutOfChina(double lat, double lon)
    {
        if (lon < 72.004 || lon > 137.8347)
            return true;
        if (lat < 0.8293 || lat > 55.8271)
            return true;
        return false;
    }

    static double TransformLat(double x, double y)
    {
        double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * Math.Sqrt(Math.Abs(x));
        ret += (20.0 * Math.Sin(6.0 * x * PI) + 20.0 * Math.Sin(2.0 * x * PI)) * 2.0 / 3.0;
        ret += (20.0 * Math.Sin(y * PI) + 40.0 * Math.Sin(y / 3.0 * PI)) * 2.0 / 3.0;
        ret += (160.0 * Math.Sin(y / 12.0 * PI) + 320 * Math.Sin(y * PI / 30.0)) * 2.0 / 3.0;
        return ret;
    }

    static double TransformLon(double x, double y)
    {
        double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * Math.Sqrt(Math.Abs(x));
        ret += (20.0 * Math.Sin(6.0 * x * PI) + 20.0 * Math.Sin(2.0 * x * PI)) * 2.0 / 3.0;
        ret += (20.0 * Math.Sin(x * PI) + 40.0 * Math.Sin(x / 3.0 * PI)) * 2.0 / 3.0;
        ret += (150.0 * Math.Sin(x / 12.0 * PI) + 300.0 * Math.Sin(x / 30.0 * PI)) * 2.0 / 3.0;
        return ret;
    }

    /// <summary>
    /// 地球坐标转换为火星坐标
    /// World Geodetic System ==> Mars Geodetic System
    /// </summary>
    /// <param name="wgLat">地球坐标</param>
    /// <param name="wgLon">地球坐标</param>
    /// <param name="mgLat">火星坐标</param>
    /// <param name="mgLon">火星坐标</param>
    public static void Transform2Mars(double wgLat, double wgLon, out double mgLat, out double mgLon)
    {
        if (OutOfChina(wgLat, wgLon))
        {
            mgLat = wgLat;
            mgLon = wgLon;
            return;
        }
        double dLat = TransformLat(wgLon - 105.0, wgLat - 35.0);
        double dLon = TransformLon(wgLon - 105.0, wgLat - 35.0);
        double radLat = wgLat / 180.0 * PI;
        double magic = Math.Sin(radLat);
        magic = 1 - EE * magic * magic;
        double sqrtMagic = Math.Sqrt(magic);
        dLat = (dLat * 180.0) / ((A * (1 - EE)) / (magic * sqrtMagic) * PI);
        dLon = (dLon * 180.0) / (A / sqrtMagic * Math.Cos(radLat) * PI);
        mgLat = wgLat + dLat;
        mgLon = wgLon + dLon;
    }
}

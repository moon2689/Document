using System;
using UnityEngine;
using UnitySlippyMap.Helpers;
using UnitySlippyMap.Map;

namespace UnitySlippyMap.Layers
{
    public class GaoDeTileLayerBehaviour : WebTileLayerBehaviour
    {
        Style m_style = Style.Normal;

        public enum Style
        {
            Normal,
            Satellite,
        }

        public GaoDeTileLayerBehaviour()
        {
            isReadyToBeQueried = true;
        }

        private new void Awake()
        {
            base.Awake();
            minZoom = 1;
            maxZoom = 19;
        }

        protected override void GetTileCountPerAxis(out int tileCountOnX, out int tileCountOnY)
        {
            tileCountOnX = tileCountOnY = (int)Mathf.Pow(2, Map.RoundedZoom);
        }

        // Gets the center tile.
        protected override void GetCenterTile(int tileCountOnX, int tileCountOnY, out int tileX, out int tileY, out float offsetX, out float offsetZ)
        {
            //int[] tileCoordinates = GeoHelpers.WGS84ToTile(Map.CenterWGS84[0], Map.CenterWGS84[1], Map.RoundedZoom);
            //double[] centerTile = GeoHelpers.TileToWGS84(tileCoordinates[0], tileCoordinates[1], Map.RoundedZoom);
            double[] gcj = GPSUtil.gps84_To_Gcj02(Map.CenterWGS84[0], Map.CenterWGS84[1]);
            int[] tileCoordinates = GeoHelpers.WGS84ToTile(gcj[0], gcj[1], Map.RoundedZoom);
            double[] centerTile = GeoHelpers.TileToWGS84(tileCoordinates[0], tileCoordinates[1], Map.RoundedZoom);
            centerTile = GPSUtil.gcj02_To_Gps84(centerTile[0], centerTile[1]);

            double[] centerTileMeters = GeoHelpers.WGS84ToMeters(centerTile[0], centerTile[1]);

            tileX = tileCoordinates[0];
            tileY = tileCoordinates[1];
            offsetX = Map.RoundedHalfMapScale / 2.0f - (float)(Map.CenterEPSG900913[0] - centerTileMeters[0]) * Map.RoundedScaleMultiplier;
            offsetZ = -Map.RoundedHalfMapScale / 2.0f - (float)(Map.CenterEPSG900913[1] - centerTileMeters[1]) * Map.RoundedScaleMultiplier;
        }

        // Gets a neighbour tile.
        protected override bool GetNeighbourTile(int tileX, int tileY, float offsetX, float offsetZ, int tileCountOnX, int tileCountOnY, NeighbourTileDirection dir, out int nTileX, out int nTileY, out float nOffsetX, out float nOffsetZ)
        {
            bool ret = false;
            nTileX = 0;
            nTileY = 0;
            nOffsetX = 0.0f;
            nOffsetZ = 0.0f;

            switch (dir)
            {
                case NeighbourTileDirection.South:
                    if ((tileY + 1) < tileCountOnY)
                    {
                        nTileX = tileX;
                        nTileY = tileY + 1;
                        nOffsetX = offsetX;
                        nOffsetZ = offsetZ - Map.RoundedHalfMapScale;
                        ret = true;
                    }
                    break;

                case NeighbourTileDirection.North:
                    if (tileY > 0)
                    {
                        nTileX = tileX;
                        nTileY = tileY - 1;
                        nOffsetX = offsetX;
                        nOffsetZ = offsetZ + Map.RoundedHalfMapScale;
                        ret = true;
                    }
                    break;

                case NeighbourTileDirection.East:
                    nTileX = tileX + 1;
                    nTileY = tileY;
                    nOffsetX = offsetX + Map.RoundedHalfMapScale;
                    nOffsetZ = offsetZ;
                    ret = true;
                    break;

                case NeighbourTileDirection.West:
                    nTileX = tileX - 1;
                    nTileY = tileY;
                    nOffsetX = offsetX - Map.RoundedHalfMapScale;
                    nOffsetZ = offsetZ;
                    ret = true;
                    break;
            }


            return ret;
        }

        protected override string GetTileURL(int tileX, int tileY, int roundedZoom)
        {
            int style;
            switch (MapStyle)
            {
                case Style.Normal:
                    style = 7;
                    break;

                case Style.Satellite:
                    style = 6;
                    break;

                default:
                    throw new InvalidOperationException("Unknown style: " + MapStyle);
            }

            string lang = LanguageSetting.GetLBSString();
            return string.Format("http://wprd03.is.autonavi.com/appmaptile?lang={4}&style={0}&x={1}&y={2}&z={3}", style, tileX, tileY, roundedZoom, lang);
        }

        void Reload()
        {
            foreach (var pair in tiles)
            {
                TileBehaviour tile = pair.Value;

                Renderer renderer = tile.GetComponent<Renderer>();
                if (renderer)
                {
                    GameObject.DestroyImmediate(renderer.material.mainTexture);
                    renderer.material.mainTexture = null;
                    renderer.enabled = false;
                }

                tileCache.Add(tile);
            }

            tiles.Clear();

            base.UpdateContent();
        }


        public Style MapStyle
        {
            set
            {
                if (m_style != value)
                {
                    m_style = value;
                    Reload();
                }
            }
            get { return m_style; }
        }
    }

}
#!/bin/bash

echo "---------------------------------------------->Invoke BuildApkExportProj.sh<----------------------------------------------"
pwd

m_UnityPath=${1}
m_ProjFolder=${2}
m_Platform=${3}

m_ExportPath="${WORKSPACE}/Publish/export/UnityExportProject/buildplayer"

# 杀unity进程
if [ $m_KillUnity = "true" ];then
	echo "---------------------------------------------->Kill Unity.exe<----------------------------------------------"
	${JenkinsCode}/KillUnity.bat
fi

# 清理XLua code
if [ $m_ClearLua = "true" -o $m_GenerateLua = "true" ];then
	echo "---------------------------------------------->Clear lua code<----------------------------------------------"
	luaGenFolder="${m_ProjFolder}/UnityClient/Assets/ThirdParty/XLua/Gen"
	rm -rf $luaGenFolder
	echo "Delete folder:"${luaGenFolder}
fi

# 项目拉到最新
if [ $m_UpdateMain = "true" ];then
	echo "---------------------------------------------->Update main project<----------------------------------------------"
	cd $m_ProjFolder
	git checkout .;git clean -fd;git pull;git log -1
fi

# Unity打包
if [ $m_BuildPlayer = "true" ];then
	echo "---------------------------------------------->Unity, JenkinsTool.BuildPlayer<----------------------------------------------"

	rm -rf $m_ExportPath
	echo "Delete folder:"${m_ExportPath}

	"$m_UnityPath" -projectPath "$m_ProjFolder/UnityClient" \
	-buildTarget $m_Platform \
	-logFile "${WORKSPACE}/Publish/log/log_BuildApkExportProj.txt" \
	-executeMethod JenkinsTool.BuildPlayer \
	-quit -batchmode -nographics \
	-buildParams \
	"m_ExportPath=$m_ExportPath" \
	"m_GenerateLua=$m_GenerateLua" \
	|| exit 1
	
	echo "Unity build player finished:${m_ExportPath}"
fi

# 压缩
if [ $m_ZipFiles = "true" ];then
	echo "---------------------------------------------->Zip export files<----------------------------------------------"
	zipPath="${WORKSPACE}/Publish/export/BuildApkExportProj.zip"

	cd "$m_ExportPath"
	rm -rf "${zipPath}"
	zip -r "${zipPath}" ./*

	echo "Zip finished:${zipPath}"
fi

echo "---------------------------------------------->BuildApkExportProj.sh invoked finished!<----------------------------------------------"

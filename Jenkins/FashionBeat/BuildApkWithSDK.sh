#!/bin/bash

echo "---------------------------------------------->Invoke BuildApkWithSDK.sh<----------------------------------------------"
pwd

m_UnityPath=${1}
m_ProjFolder=${2}
m_Platform=${3}
m_ProductCode=${4}

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

# SDK项目拉到最新
if [ $m_UpdateSDKProj = "true" ];then
	echo "---------------------------------------------->Update sdk project<----------------------------------------------"
	cd $SDKCode
	git checkout .;git clean -fd;git pull;git log -1
fi

# Unity导出
if [ $m_ExportUnityProj = "true" ];then
	echo "---------------------------------------------->Unity, JenkinsTool.BuildPlayer<----------------------------------------------"

	exportPath="${SDKCode}/../u2as"
	rm -rf $exportPath
	echo "Delete folder:"${exportPath}

	"$m_UnityPath" -projectPath "$m_ProjFolder/UnityClient" \
	-buildTarget $m_Platform \
	-logFile "${WORKSPACE}/Publish/log/log_BuildApkWithSDK.txt" \
	-executeMethod JenkinsTool.BuildPlayer \
	-quit -batchmode -nographics \
	-buildParams \
	"m_ExportPath=$exportPath" \
	"m_GenerateLua=$m_GenerateLua" \
	|| exit 1
	
	echo "Unity build player finished:${exportPath}"
fi

# 集成sdk
if [ $m_BuildSDK = "true" ];then
	echo "---------------------------------------------->Build apk with sdk<----------------------------------------------"
	
	cd $SDKCode
	
	curTime=`date +%Y%m%d_%H%M%S`
	m_ApkName="${m_Region,,}_${curTime}.${m_TargetType,,}"
	echo "apk name: ${m_ApkName}"

	python -u "Python_script/jekinsgames.py" \
	"${m_ProductCode}" \
	"${m_Region}" \
	"${m_VersionAddress}" \
	"${m_TargetType}" \
	"${m_SplitPackage}" \
	"${m_VersionName}" \
	"${m_VersionCode}" \
	"${m_ApkName}"
fi

# 将apk移到Jenkins目录
cd "${SDKCode}/../apk"
tarFolder="${WORKSPACE}/Publish/export"
mkdir -p "${tarFolder}"
if [ $m_TargetType = "APK" ];then
	mv *.apk "${tarFolder}"
fi
if [ $m_TargetType = "AAB" ];then
	mv *.aab "${tarFolder}"
fi

echo "---------------------------------------------->BuildApkWithSDK.sh invoked finished!<----------------------------------------------"

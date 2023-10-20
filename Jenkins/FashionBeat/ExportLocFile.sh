#!/bin/bash

echo "---------------------------------------------->Invoke ExportLocFile.sh<----------------------------------------------"
pwd

m_UnityPath=${1}
m_ProjFolder=${2}
m_Platform=${3}
m_Language=${4}


# 项目拉到最新
if [ $m_GetChinese = "true" ];then
	echo "---------------------------------------------->Update excel config<----------------------------------------------"
	cd $m_ProjFolder/../server
	svn cleanup;svn revert --recursive .;svn update;svn log -l 1
fi
	
echo "---------------------------------------------->Update main project<----------------------------------------------"
cd $m_ProjFolder
git checkout .;git clean -fd;git pull;git log -1


# Unity打包
echo "---------------------------------------------->Unity, JenkinsTool.ExportLoc<----------------------------------------------"

"$m_UnityPath" -projectPath "$m_ProjFolder/UnityClient" \
-buildTarget $m_Platform \
-logFile "${WORKSPACE}/Publish/log/log_ExportLocFile.txt" \
-executeMethod JenkinsTool.ExportLoc \
-quit -batchmode -nographics \
-buildParams \
"m_GetChinese=$m_GetChinese" \
"m_ExportPath=${WORKSPACE}/Publish/loc" \
"m_Language=$m_Language" \
|| exit 1

echo "Unity build player finished."

#上传
cd $m_ProjFolder
git add "UnityClient/Assets/Localize/Text";git pull;git commit -m "Jenkins: 从配置和静态UI中提取本地化";git push;git show head

echo "---------------------------------------------->ExportLocFile.sh invoked finished!<----------------------------------------------"

#!/bin/bash

echo "---------------------------------------------->Invoke CollectShaderVariant.sh<----------------------------------------------"
pwd

m_UnityPath=${1}
m_ProjFolder=${2}
m_Platform=${3}


# 项目拉到最新
echo "---------------------------------------------->Update main project<----------------------------------------------"
cd $m_ProjFolder
pwd
git checkout .;git clean -fd;git pull;git log -1

echo "---------------------------------------------->Update art project<----------------------------------------------"
cd $m_ProjFolder/UnityClient/Assets/FashionBeat_ArtSVN
pwd
svn cleanup;svn revert --recursive .;svn update;svn log -l 1

# 搜集shader变种
echo "---------------------------------------------->Unity, JenkinsTool.BuildAB<----------------------------------------------"

echo "m_UnityPath:$m_UnityPath"

"$m_UnityPath" -projectPath "$m_ProjFolder/UnityClient" \
-buildTarget $m_Platform \
-logFile "${WORKSPACE}/Publish/log/log_CollectShaderVariant.txt" \
-executeMethod JenkinsTool.CollectShaderVariant \
-quit -batchmode -nographics \
|| exit 1

cd $m_ProjFolder
git add "UnityClient/Assets/Config/YooAsset/ShaderVariants";git pull;git commit -m "Jenkins: 上传shader变体搜集结果";git push;git show head --stat

echo "Unity collect shader variant finished"

echo "---------------------------------------------->CollectShaderVariant.sh invoked finished!<----------------------------------------------"

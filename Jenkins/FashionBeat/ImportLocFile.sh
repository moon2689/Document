#!/bin/bash

echo "---------------------------------------------->Invoke ImportLocFile.sh<----------------------------------------------"
pwd

m_UnityPath=${1}
m_ProjFolder=${2}
m_Platform=${3}
m_Language=${4}

# 项目拉到最新
echo "---------------------------------------------->Update main project<----------------------------------------------"
cd $m_ProjFolder
git checkout .;git clean -fd;git pull;git log -1

# Unity打包
echo "---------------------------------------------->Unity,JenkinsTool.ImportLoc<----------------------------------------------"

"$m_UnityPath" -projectPath "$m_ProjFolder/UnityClient" \
-buildTarget $m_Platform \
-logFile "${WORKSPACE}/Publish/log/log_ImportLocFile.txt" \
-executeMethod JenkinsTool.ImportLoc \
-quit -batchmode -nographics \
-buildParams \
"m_LocalizedExcel=${WORKSPACE}/m_LocalizedExcel" \
"m_Language=$m_Language" \
|| exit 1

echo "Unity import localize file finished."

#上传
cd $m_ProjFolder
git add "UnityClient/Assets/Localize/Text";git add "UnityClient/Assets/Resources/FashionBeat/Localize";git pull;git commit -m "Jenkins: 导入已翻译的本地化文件";git push;git show head

echo "---------------------------------------------->ImportLocFile.sh invoked finished!<----------------------------------------------"

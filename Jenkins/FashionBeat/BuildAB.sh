#!/bin/bash

echo "---------------------------------------------->Invoke BuildAB.sh<----------------------------------------------"
pwd

m_UnityPath=${1}
m_ProjFolder=${2}
m_Platform=${3}
m_ForceRebuild=${4}
m_FtpUrl=${5}
m_FtpDir=${6}
m_CdnUrl=${7}
m_FtpRSA=${8}
m_FtpPort=${9}
m_FtpUser=${10}


# 项目拉到最新
if [ $m_UpdateMain = "true" ];then
	echo "---------------------------------------------->Update main project<----------------------------------------------"
	cd $m_ProjFolder
	pwd
	git checkout .;git clean -fd;git pull;git log -1
fi

if [ $m_UpdateArt = "true" ];then
	echo "---------------------------------------------->Update art project<----------------------------------------------"
	cd $m_ProjFolder/UnityClient/Assets/FashionBeat_ArtSVN
	pwd
	svn cleanup;svn revert --recursive .;svn update;svn log -l 1
fi

if [ $m_UpdateMusic = "true" ];then
	echo "---------------------------------------------->Update music project<----------------------------------------------"
	cd $m_ProjFolder/UnityClient/Assets/FashionBeat_MusicGit
	pwd
	#git checkout .;git clean -fd;git pull;git log -1
	git pull;git log -1;git status
fi

if [ $m_ConvertConfig = "true" ];then
	echo "---------------------------------------------->Update excel config<----------------------------------------------"
	cd $m_ProjFolder/../server
	pwd
	svn cleanup;svn revert --recursive .;svn update;svn log -l 1
fi

# Unity打包
if [ $m_ConvertConfig = "true" -o $m_BuildAB = "true" -o $m_BuildDLL = "true" ];then
	echo "---------------------------------------------->Unity, JenkinsTool.BuildAB<----------------------------------------------"
	
	echo "m_UnityPath:$m_UnityPath"
	
	"$m_UnityPath" -projectPath "$m_ProjFolder/UnityClient" \
	-buildTarget $m_Platform \
	-logFile "${WORKSPACE}/Publish/log/log_BuildAB.txt" \
	-executeMethod JenkinsTool.BuildAB \
	-quit -batchmode -nographics \
	-buildParams \
	"m_ConvertConfig=$m_ConvertConfig" \
	"m_BuildAB=$m_BuildAB" \
	"m_CopyABToStream=$m_CopyABToStream" \
	"m_BuildTarget=$m_Platform" \
	"m_ForceRebuild=$m_ForceRebuild" \
	"m_BuildDLL=$m_BuildDLL" \
	|| exit 1
	
	cd $m_ProjFolder
	git add "UnityClient/Assets/Config/Tbl";git add "UnityClient/Assets/Scripts/XLua/LuaScripts/Config"
	
	if [ $m_Platform = "iOS" -a $m_CopyABToStream = "true" ];then
		git add "UnityClient/IOSBuildinBundle";
	fi
	
	git pull;git commit -m "Jenkins: 上传打包结果";git push;git show head --stat
	
	echo "Unity build succeed"
fi

# Ftp上传
if [ $m_UploadFtp = "true" ];then
	echo "---------------------------------------------->Rsync ab to ftp<----------------------------------------------"
	cd ${m_ProjFolder}

	ssh -i ${JenkinsCode}/rsa/${m_FtpRSA} -p ${m_FtpPort} ${m_FtpUser}@${m_FtpUrl} "mkdir -p ${m_CdnUrl}/${m_FtpDir}/"
	rsync -arze "ssh -i ${JenkinsCode}/rsa/${m_FtpRSA} -p ${m_FtpPort}" --progress "UnityClient/a/" ${m_FtpUser}@${m_FtpUrl}:${m_CdnUrl}/${m_FtpDir}/

	echo "Upload to ftp succeed"
fi

echo "---------------------------------------------->BuildAB.sh invoked finished!<----------------------------------------------"

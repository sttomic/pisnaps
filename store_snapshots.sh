#/bin/bash

CAM_NAME=$1
HOST=$2
PORT=$3
USERNAME=$4
PASSWORD=$5

CAM_URL="http://${HOST}:${PORT}/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=${USERNAME}&pwd=${PASSWORD}"

echo $CAM_URL



TMP_DIR_BASE=/home/pi/tmp_snapshots


startMinute=`date +%Y%m%d_%H%M`
currentMinute=$startMinute
tmp_dir=${TMP_DIR_BASE}/${CAM_NAME}/${startMinute}

while [ "$currentMinute" = "$startMinute" ]; do



	timestamp=`date +%Y%m%d_%H%M%S`
	filename="${CAM_NAME}_${timestamp}.jpg"
	mkdir -p $tmp_dir
	tmp_filepath="${tmp_dir}/${filename}"
	wget -q  "$CAM_URL" -O "$tmp_filepath"
	echo "RETRIEVED: ${filename}"

	
	currentMinute=`date +%Y%m%d_%H%M`	
	echo "current minute: $currentMinute"
	echo "start minute: $startMinute"
	sleep 0.5
done

echo "UPLOADING"
tarball=${TMP_DIR_BASE}/${CAM_NAME}/${startMinute}.tar.gz 
tar  -C ${TMP_DIR_BASE}/${CAM_NAME} -cf $tarball ${startMinute} --gzip
/usr/local/bin/dropbox_uploader.sh upload $tarball ${CAM_NAME}/${startMinute}.tar.gz  
rm -rf $tmp_dir
rm -f $tarball

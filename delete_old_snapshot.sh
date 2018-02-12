#!/bin/bash
#deletes files with filename pattern of X days old for dropbox webcam filesystem cleanup.

parent_dir=$1
stale_age_days=$2

filelist_str=`/usr/local/bin/dropbox_uploader.sh -q list $parent_dir`
filelist_str_no_ws="$(echo -e "${filelist_str}" | tr -d '[:space:]')"
echo $filelist_str_no_ws
D="\[D\]"
filelist=($(echo $filelist_str_no_ws | sed -e 's/'"$D"'/\n/g' | while read line; do echo $line | sed 's/[\t ]/'"$D"'/g'; done))

for (( i = 0; i < ${#filelist[@]}; i++ )); do
  filelist[i]=$(echo ${filelist[i]} | sed 's/'"$D"'/ /')
done


file_deletion_date=`date --date="$stale_age_days days ago" +%Y%m%d`
file_deletion_pattern="^$file_deletion_date.*$"

for (( i = 0; i < ${#filelist[@]}; i++ )); do
	if [[ "${filelist[i]}" =~ $file_deletion_pattern ]];
	then
		/usr/local/bin/dropbox_uploader.sh delete "$parent_dir/${filelist[i]}"
  		echo "deleted: ${filelist[i]}"
	fi
done



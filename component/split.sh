#!/bin/bash
shopt -s dotglob
shopt -s nullglob
COMPONENTS=(*/)
for dir in "${COMPONENTS[@]}"; do 
	echo "$dir";
	SOURCE_FILE=$(ls $dir*.tar)
	split --verbose -b99M $SOURCE_FILE $SOURCE_FILE.
done




#sudo docker load --input oai-gnb_latest_18.tar
#sudo docker tag <Image-ID> oai-gnb:latest


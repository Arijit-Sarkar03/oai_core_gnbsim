## Save one docker
```
sudo docker save -o mysql_5.7.tar mysql:5.7
```
## Save all dockers from a docker-compose files
```
sudo python3 ExportImages.py
```

## Spilt saved docker
```
split --verbose -b99M oai-gnb_latest.tar oai-gnb_latest.tar.
```
## Spilt all saved dockers
```
bash split.sh
```
## Recombine one docker
```
cat oai-gnb_latest.tar.a? > oai-gnb_latest_18.tar
```
## Create Docker image
```
sudo docker load --input oai-gnb_latest_18.tar
sudo docker tag <Image-ID> oai-gnb:latest # May not be needed
```
## Recombine and load all dockers
```
bash mergeAndCreate.sh
bash reduceSpace.sh # Removes tar files but keeps the splited images
```


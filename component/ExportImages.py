#!/usr/bin/env python3
import subprocess 
import sys
import os

YAML_FILE="../docker-compose/docker-compose-basic-nrf.yaml"


p1 = subprocess.Popen(["cat", YAML_FILE], stdout=subprocess.PIPE)
p2 = subprocess.Popen(["grep","image"], stdin=p1.stdout, stdout=subprocess.PIPE)
p1.stdout.close()  # Allow p1 to receive a SIGPIPE if p2 exits.
output,err = p2.communicate()
if(not err):
	image_lines=output.decode('UTF-8').split("\n")
	image_lines=[x for x in image_lines if x != '']
	images=[[l.split(":")[1].strip(),l.split(":")[2].strip()] for l in image_lines]
else:
	sys.exit("Problem with YAML file")

for img in images:
	IMGNAME=img[0]
	IMGVER=img[1]
	if not os.path.exists(IMGNAME):
		echo("DIRECTORY: %s does not exist. Created"%IMGNAME)
		os.makedirs(IMGNAME)
	CMD="sudo docker save -o %s/%s_%s.tar %s:%s" % (IMGNAME,IMGNAME, IMGVER,IMGNAME,IMGVER)
	os.system(CMD)
	print("File created : %s/%s_%s.tar" %(IMGNAME,IMGNAME, IMGVER))
os.system("sudo chmod 777 -Rvf ./")
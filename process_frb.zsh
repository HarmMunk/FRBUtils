#!/usr/bin/env zsh

#Get all .fil files to /dev/shm and process

SRC_DIR=$(pwd)
export PATH=${HOME}/PycharmProjects/frbscripts:${PATH}

mkdir -p tmp2

cd /dev/shm
echo -n "===== Start time: " | tee time.log
date | tee -a time.log
for f in ${SRC_DIR}/*.fil
do	
	fff=$(basename $f)
	ff=$(basename $f .fil)
	if [[ ! -a ${fff} ]]
	then
		ln -s ${f}
	fi
	echo ">>> starting " check_frb.py ${fff}
	time check_frb.py ${fff}
	cd process
	echo ">>> starting " candidate_maker.py ${ff}*.singlepulse
	time candidate_maker.py ${ff}*.singlepulse
	echo ">>> starting " predict.py --data_dir . --model a
	predict.py --data_dir . --model a
	cd ..
done
echo -n "===== End time: " | tee -a time.log
date | tee -a time.log


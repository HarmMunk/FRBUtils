#!/usr/bin/env zsh

#Get all .fil files to /dev/shm and process

SRC_DIR=$(pwd)
DATA_DIR=/dev/shm

export PATH=${HOME}/PycharmProjects/frbscripts:${PATH}

mkdir -p tmp2

cd /dev/shm
echo -n "===== Start time: " | tee time.log
date | tee -a time.log
for full_path in ${SRC_DIR}/*.fil
do	
	cd ${DATA_DIR}
	base_filename=$(basename ${full_path})
	relative_dir_name=$(basename ${base_filename} .fil)
	mkdir -p ${relative_dir_name}
	cd ${relative_dir_name}
	if [[ ! -a ${base_filename} ]]
	then
		ln -s ${full_path}
	fi
	echo ">>> starting " check_frb.py ${base_filename}
	time check_frb.py ${base_filename}
	if [ -d process ]]
	then
		cd process
		echo ">>> starting " candidate_maker.py ${base_filename}*.singlepulse
		time candidate_maker.py ${base_filename}*.singlepulse
		echo ">>> starting " predict.py --data_dir . --model a
		time predict.py --data_dir . --model a
		move_candidates
		if [[ -d good ]]
		then
			cd good
			plot_h5.py *.h5
			cd ..
		else 
			echo "Directory ${DATA_DIR}/${relative_dir_name}/process/good does not exits! Exiting."
			exit
		fi
	else
		echo "Directory ${DATA_DIR}/${relative_dir_name}/process does not exist! Exiting."
		exit
	fi
done

cd process
echo ">>> starting " predict.py --data_dir . --model a
predict.py --data_dir . --model a

echo -n "===== End time: " | tee -a time.log
date | tee -a time.log

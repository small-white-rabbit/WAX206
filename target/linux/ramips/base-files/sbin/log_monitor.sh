#!/bin/bash

max_log_num=$1

shift
log_type_list=""
for log_type in $@
do
	log_type_list="$log_type_list|$log_type"
done

while true
do
	log_num=0
	logread -e "^($log_type_list)" -f | while read line
	do
		log_num=$(($log_num+1))
		if [ $log_num > $max_log_num ]; then
			echo "Log is going to full, starting send email, then clear log"
#			Send email
#			logread -c 3
			break
		fi
	done
done

#!/bin/sh

if [ $# -ne 2 ]
  then
    echo "Expecting 2 args. Usage: `basename $0` win_dir_mount local_dir"
	exit 0
fi

mkdir -p ~/logs

CURTIME="$(date +%s)"

LOG_FILE=~/logs/$(date +%Y%m%d_%R).txt

rsync -avz -delete --bwlimit=30 --delete-before $1 $2 > $LOG_FILE

cd $2
md5sum --tag * | sort > ~/md5sum_local.txt
tr -d ' \t\r\f' < ~/md5sum_local.txt > ~/md5sum_local_2.txt
mv ~/md5sum_local_2.txt ~/md5sum_local.txt
tr -d ' \t\r\f' < $2/md5sums.txt | sort > ~/md5sums_2.txt
rm $2/md5sums.txt
mv ~/md5sums_2.txt ~/md5sums.txt


diff -Naur --ignore-matching-lines="md5sums.txt" ~/md5sums.txt ~/md5sum_local.txt >> $LOG_FILE

ENDTIME="$(date +%s)"
NUMSEC=`expr $ENDTIME - $CURTIME`
LOCAL_STATUS=$?
if [ $LOCAL_STATUS -ne 0 ]
then
	echo "ERROR: MD5 checksum differs" >> $LOG_FILE
else
	echo "MD5 checksum OK" >> $LOG_FILE
fi

echo "Sync finished in ${NUMSEC} seconds" >> $LOG_FILE

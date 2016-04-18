#!/bin/bash
PATH_PORTAL=`pwd`

mkdir -p $PATH_PORTAL/md5sum_check/md5sum_check_provided

if [ -d $PATH_PORTAL/automated/tomcat ]; then
	cp $PATH_PORTAL/automated/tomcat/* $PATH_PORTAL/md5sum_check
fi
if [ -d $PATH_PORTAL/automated/liferay ]; then
	cp $PATH_PORTAL/automated/liferay/* $PATH_PORTAL/md5sum_check
fi
if [ -d $PATH_PORTAL/automated/properties ]; then
	cp $PATH_PORTAL/automated/properties/resources.zip $PATH_PORTAL/md5sum_check
fi
if [ -d $PATH_PORTAL/automated/lars ]; then
	cp $PATH_PORTAL/automated/lars/* $PATH_PORTAL/md5sum_check
fi
if [ -d $PATH_PORTAL/manual ]; then
	cp $PATH_PORTAL/manual/* $PATH_PORTAL/md5sum_check
fi

ls -ltr $PATH_PORTAL/md5sum_check/ | awk '{print $9}'| grep -v '^$'| grep -v "md5sum_check_provided" | grep -v "md5sum_check_new" | grep -v "list" >> $PATH_PORTAL/md5sum_check/list_artifacts

for i in `cat $PATH_PORTAL/md5sum_check/list_artifacts`
do
	touch $PATH_PORTAL/md5sum_check/md5sum_check_provided/$i
	md5sum $PATH_PORTAL/md5sum_check/$i | awk '{print $1}' >> $PATH_PORTAL/md5sum_check/md5sum_check_provided/$i
	rm -rf $PATH_PORTAL/md5sum_check/$i
done
rm -rf $PATH_PORTAL/md5sum_check/list_artifacts


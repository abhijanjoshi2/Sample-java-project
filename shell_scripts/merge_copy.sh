#!/bin/bash

if [ "$#" != 3 ]
then
   echo "Usage: merge.sh <file_to_be_merged> <absolute/path/for/the/file> <SCT/PROD/DEV>"
   echo "Eg: merge.sh portalResourceKeys.properties $PATH_PORTAL/automated/properties/ DEV"
exit 0
fi

if [ $3 == PROD ] || [ $3 == SCT ]; then
	PATH_PROPS="/opt/ssp/"
	PATH_EXT_PROPS="/opt/ssp/apache-tomcat-7.0.34/webapps/ROOT/WEB-INF/classes/"
elif [ $3 == DEV ]; then
	PATH_PROPS="/opt/isat"
	PATH_EXT_PROPS="/opt/tomcat/apache-tomcat-7.0.34/webapps/ROOT/WEB-INF/classes/"
else
   echo "Usage: install_patch.sh -env <SCT/PROD/DEV>"
   echo "Eg: install_patch.sh -env DEV"
   exit 0
fi    

case "$1" in

portalResourceKeys.properties)

cp -rf $2/$1 $PATH_PROPS
chmod 775 $PATH_PROPS/$1

;;

portal-configuration.properties)

mv $2/$1 $2/$1"_new"
cp -rf $PATH_PROPS/$1 $2

cat $2/../properties_delta/changes_portal-configuration | awk -v RS="------" '{print $0 > "temp" NR}'

for i in `ls -ltr temp* | awk '{print $9}'`
do
   cat $i | grep -v "^$" >> Change
   rm -rf $i
   mv Change $i
done

for i in `ls -ltr temp* | awk '{print $9}'`
do
   n1=`grep -n "^new:" $i | cut -d":" -f1`
   t=`wc -l $i|awk '{print $1}'`
   n3=`expr $t + 1`
   grep "^old:" $i > /dev/null
   if [ $? == 0 ]
   then
       n2=`grep -n "^old:" $i | cut -d":" -f1`
       n1_1=`expr $n1 + 1`
       n1_2=`expr $n2 - 1`
       n2_1=`expr $n2 + 1`
       n2_2=`expr $n3 - 1`
       sed -n "${n1_1},${n1_2}p" $i >> new
       sed -n "${n2_1},${n2_2}p" $i >> old
       IFS=' '
       while read i
       do
          grep -n "$i" $2/$1 | cut -d":" -f1 >> line
       done < old
       sed -f <(sed 's/$/d/' line) $2/$1 >> $2/$1"_copy"
       first_line=`head -1 line`
       last_line=`wc -l $2/$1"_copy" | awk '{print $1}'`
       head -$first_line $2/$1"_copy" >> file1
       tail -`expr $last_line - $first_line` $2/$1"_copy" >> file2
       rm -rf $2/$1
       cat file1 new file2 >> $2/$1
       rm -rf new old $2/$1"_copy" file* line
   else
       n2=`grep -n "^last:" $i | cut -d":" -f1`
       n1_1=`expr $n1 + 1`
       n1_2=`expr $n2 - 1`
       n2_1=`expr $n2 + 1`
       n2_2=`expr $n3 - 1`
       sed -n "${n1_1},${n1_2}p" $i >> new
       echo " " >> $2/$1
       cat new >> $2/$1
       rm -rf new
   fi
done
cp -rf $2/$1 $PATH_PROPS
chmod 775 $PATH_PROPS/$1
mv $2/$1"_new" $2/$1
;;

portal-ext.properties)

mv $2/$1 $2/$1"_new"
cp -rf $PATH_EXT_PROPS/$1 $2

cat $2/../properties_delta/changes_portal-ext | awk -v RS="------" '{print $0 > "temp" NR}'

for i in `ls -ltr temp* | awk '{print $9}'`
do
   cat $i | grep -v "^$" >> Change
   rm -rf $i
   mv Change $i
done

for i in `ls -ltr temp* | awk '{print $9}'`
do
   n1=`grep -n "^new:" $i | cut -d":" -f1`
   t=`wc -l $i|awk '{print $1}'`
   n3=`expr $t + 1`
   grep "^old:" $i > /dev/null
   if [ $? == 0 ]
   then
       n2=`grep -n "^old:" $i | cut -d":" -f1`
       n1_1=`expr $n1 + 1`
       n1_2=`expr $n2 - 1`
       n2_1=`expr $n2 + 1`
       n2_2=`expr $n3 - 1`
       sed -n "${n1_1},${n1_2}p" $i >> new
       sed -n "${n2_1},${n2_2}p" $i >> old
       IFS=' '
       while read i
       do
          grep -n "$i" $2/$1 | cut -d":" -f1 >> line
       done < old
       sed -f <(sed 's/$/d/' line) $2/$1 >> $2/$1"_copy"
       first_line=`head -1 line`
       last_line=`wc -l $2/$1"_copy" | awk '{print $1}'`
       head -$first_line $2/$1"_copy" >> file1
       tail -`expr $last_line - $first_line` $2/$1"_copy" >> file2
       rm -rf $2/$1
       cat file1 new file2 >> $2/$1
       rm -rf new old $2/$1"_copy" file* line
   else
       n2=`grep -n "^last:" $i | cut -d":" -f1`
       n1_1=`expr $n1 + 1`
       n1_2=`expr $n2 - 1`
       n2_1=`expr $n2 + 1`
       n2_2=`expr $n3 - 1`
       sed -n "${n1_1},${n1_2}p" $i >> new
       echo " " >> $2/$1
       cat new >> $2/$1
       rm -rf new
   fi
done
cp -rf $2/$1 $PATH_EXT_PROPS
chmod 775 $PATH_EXT_PROPS/$1
mv $2/$1"_new" $2/$1

;;

resources.zip)
	
        rm -rf $PATH_PROPS/resources
	cp -rf $2/$1 $PATH_PROPS
        cd $PATH_PROPS
        unzip resources.zip
        rm -rf $PATH_PROPS/resources.zip
;;

*)

echo "Usage: merge.sh <file_to_be_merged> <absolute/path/for/the/file>"
echo "Eg: merge.sh portalResourceKeys.properties $PATH_PORTAL/automated/properties/"
exit 0
esac

rm -rf temp1 temp2 temp3


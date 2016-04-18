#!/bin/bash

###### Function to deploy #######
function deploy(){

if [ -d $PATH_PORTAL/manual ]; then
   arts_manual=`ls -ltr $PATH_PORTAL/manual/* | awk '{print $9}'| grep -v '^$' | wc -l`
fi
arts_automated=`ls -ltr $PATH_PORTAL/automated/* | awk '{print $9}'| grep -v '^$' | grep -v "changes" | wc -l`
total_arts=`expr $arts_manual + $arts_automated`

printf "\n${yellow}Total number of artfacts : $total_arts\n${nc}" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
sleep 4

ls -ltr $PATH_PORTAL/automated/* | awk '{print $9}'| grep -v '^$'| grep -v "changes" > list_artifacts_automated

if [ -d $PATH_PORTAL/manual ]; then
   ls -ltr $PATH_PORTAL/manual/* | awk '{print $9}'| cut -d"/" -f6 | grep -v '^$' > list_artifacts_manual
fi

printf "\n${yellow}Artifacts to be deployed manually :\n${nc}" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
sleep 2
if [ -f $PATH_PORTAL/list_artifacts_manual ]; then
   cat list_artifacts_manual | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
else
   printf "None"
fi
sleep 4

printf "\n${yellow}Artifacts that will be deployed now :${nc}" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
sleep 4
for i in `cat list_artifacts_automated`
do 
   printf "\n$i" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
   sleep 1
done

printf "\n\n${yellow}Proceed with deployment of $release_name? <YES/NO> :${nc}"
read input
if [ $input == YES ] || [ $input == yes ] || [ $input == y ] || [ $input == Y ]; then
	touch /tmp/portalDownForMaintenance.lock
	printf "\n${yellow}Created file /tmp/portalDownForMaintenance.lock${nc}" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
        printf "\n${yellow}Please wait for :\n${nc}"
        sleep 2
	seconds=180; date1=$((`date +%s` + $seconds));
	while [ "$date1" -ne `date +%s` ]; do
	     echo -ne "$(date -u --date @$(($date1 - `date +%s` )) +%H:%M:%S)\r";
	done

    deploy
else
    printf "\nexiting..."
    exit
fi

backup


printf "\n${yellow}Undeploying artifacts${nc}" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`

tail -0f $PATH_CATALINA/catalina.out >> $PATH_PORTAL/install_logs/catalina-`date +"%Y-%m-%d"` &

##Undeploying artifacts##
if [ -d $PATH_PORTAL/automated/tomcat ]; then
for i in `cat $PATH_PORTAL/automated/tomcat/list`;
do
    printf "\n${yellow}Undeploying $i\n${nc}" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
        sleep 5
    if [ -f $PATH_TOMCAT/$i ]; then
        touch $PATH_PORTAL/install_logs/$i"_undeploy_log"
        rm -rf $PATH_TOMCAT/$i
        tail -0f $PATH_CATALINA/catalina.out | tee -a $PATH_PORTAL/install_logs/$i"_undeploy_log" &
        tail -0f $PATH_PORTAL/install_logs/$i"_undeploy_log" | while read LOGLINE
        do
           [[ "${LOGLINE}" == *"Undeploying context"* ]] && sleep 10 && pkill -P $$ tail >> /dev/null
        done
        printf "\n${yellow}$i Undeployed${nc}" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
        art_dir=`echo $i | sed 's/.war//'`
		if [ -d $PATH_PORTAL/art_dir ]; then
			rm -rf $PATH_PORTAL/art_dir
			if [ $? != 0 ]; then
				printf "\n Not able to undeploy $i. Please run script with root permissions"
			fi
			printf "\n${yellow}$i Undeployed${nc}" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
		else
			printf "\n${yellow}artifact not in the webapps folder, looks like the arifact is \nnewly provided or it has been already undeployed prviously by the script before being terminated\n${nc}"
		fi
	sleep 3
    fi
		
done
fi

tail -0f $PATH_CATALINA/catalina.out >> $PATH_PORTAL/install_logs/catalina-`date +"%Y-%m-%d"` &

if [ -d $PATH_PORTAL/automated/liferay ]; then
for i in `cat $PATH_PORTAL/automated/liferay/list`;
do
    printf "\n${yellow}Undeploying $i".war"\n${nc}" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
        sleep 5
    if [ -d $PATH_TOMCAT/$i ]; then
        touch $PATH_PORTAL/install_logs/$i"_undeploy_log"
        rm -rf $PATH_TOMCAT/$i
        tail -0f $PATH_CATALINA/catalina.out | tee -a $PATH_PORTAL/install_logs/$i"_undeploy_log" &
        tail -0f $PATH_PORTAL/install_logs/$i"_undeploy_log" | while read LOGLINE
        do
           [[ "${LOGLINE}" == *"Undeploying context"* ]] && sleep 10 && pkill -P $$ tail >> /dev/null
        done
		if [ -d $PATH_PORTAL/$i ]; then
			rm -rf $PATH_PORTAL/$i
			if [ $? != 0 ]; then
				printf "\n Not able to undeploy $i. Please run script with root permissions"
				exit
			fi
			printf "\n${yellow}$i Undeployed${nc}" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
		else
			printf "\n${yellow}artifact is $i not in the webapps folder, looks like the arifact is \n newly provided or it has been already undeployed prviously by the script before being terminated\n${nc}"
		fi
		sleep 3
	done 
done
fi
tail -0f $PATH_CATALINA/catalina.out >> $PATH_PORTAL/install_logs/catalina-`date +"%Y-%m-%d"` &

##Deploying artifacts##
if [ -d $PATH_PORTAL/automated/tomcat ]; then
for i in `cat $PATH_PORTAL/automated/tomcat/list`;
do
    printf "\n${yellow}Deploying $i\n${nc}" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
	sleep 5
	touch $PATH_PORTAL/install_logs/$i"_deploy_log"
        if [ $i == "rsp.war" ] || [ $i == "ssp.war" ]; then
        Flag=1
        until [ $Flag == 0 ]; do
            cd $PATH_SETENV
            . ./setenv.sh
            env | grep "ISAT_PORTAL_ROOT"
            Flag=$?
        done
        fi
	cp -p $PATH_PORTAL/automated/tomcat/$i $PATH_TOMCAT
	tail -0f $PATH_CATALINA/catalina.out | tee -a $PATH_PORTAL/install_logs/$i"_deploy_log" &
	tail -0f $PATH_PORTAL/install_logs/$i"_deploy_log" | while read LOGLINE
    do
       [[ "${LOGLINE}" == *"Deploying web application archive"* ]] && sleep 10 && pkill -P $$ tail >> /dev/null
    done
	printf "\n${yellow}$i Deployed${nc}" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
        sleep 5
	printf "\n${yellow}Continue with next artifact? <YES/NO>:${nc}"
	read input
        if [ $input == YES ] || [ $input == yes ] || [ $input == y ] || [ $input == Y ]; then
	    continue
	else
	    exit
	fi
done
fi

tail -0f $PATH_CATALINA/catalina.out >> $PATH_PORTAL/install_logs/catalina-`date +"%Y-%m-%d"` &
	
if [ -d $PATH_PORTAL/automated/liferay ]; then
for i in `cat $PATH_PORTAL/automated/liferay/list`;
do
    printf "\n${yellow}Deploying $i".war"\n\n${nc}"
	sleep 5
	touch $PATH_PORTAL/install_logs/$i"_deploy_log" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
	cp -p $PATH_PORTAL/automated/liferay/$i".war" $PATH_LIFERAY
	tail -0f $PATH_CATALINA/catalina.out | tee -a $PATH_PORTAL/install_logs/$i"_deploy_log" &
	if [ $i == "lar-import-0.1" ]; then
		tail -0f $PATH_PORTAL/install_logs/$i"_deploy_log" | while read LOGLINE
		do
			[[ "${LOGLINE}" == *"Lar automation completed successfully"* ]] && sleep 5 && pkill -P $$ tail >> /dev/null
		done
		rm -rf $PATH_PORTAL/automated/liferay/$i
		if [ $? != 0 ]; then
			printf "\n${red}Please remove dir - $PATH_PORTAL/automated/liferay/$i on another console and press Y to continue\n Please do not Ctrl+C${nc}"
			read input
			if [ $input == YES ] || [ $input == yes ] || [ $input == y ] || [ $input == Y ]; then
				continue
			else
				exit
			fi
		fi
	else
		tail -0f $PATH_PORTAL/install_logs/$i"_deploy_log" | while read LOGLINE
		do
			[[ "${LOGLINE}" == *"Deploying web application directory"* ]] && sleep 10 && pkill -P $$ tail >> /dev/null
		done 
		printf "\n${yellow}$i Deployed${nc}" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
        sleep 5
	printf "\n${yellow}Continue with next artifact? <YES/NO>:${nc}"
	read input
        if [ $input == YES ] || [ $input == yes ] || [ $input == y ] || [ $input == Y ]; then
	    continue
	else
	    exit
	fi
done
fi

if [ -d $PATH_PORTAL/automated/properties ]
then
    
       printf "\n${yellow}Stopping server to deploy properties files\n${nc}"
       sleep 4
	stop
	
	for i in `cat $PATH_PORTAL/automated/properties/list`
	do
	   printf "\n${yellow}deploying $i${nc}" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
           $PATH_PORTAL/merge_copy.sh $i $PATH_PORTAL/automated/properties/ $ENV | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
           sleep 2
           if [ $i == "portal-ext.properties" ]
           then
	       vi $PATH_EXT_PROPS/$i
           elif [ $i != "resources.zip" ]
           then
              vi $PATH_PROPS/$i
           fi
           sleep 4
	done 
	printf "\n${yellow}Starting server after deploying properties files\n${nc}"
        sleep 4
	start

fi


printf "\n${yellow}Checking the logs to see if there are errors...${nc}"

grep -l "Exception" $PATH_PORTAL/install_logs/* >> grep_result1
grep -l "Error" $PATH_PORTAL/install_logs/* >> grep_result2
if [ -s grep_result1 ] || [ -s grep_result2 ]; then
   printf "\n${red}Please check the below listed log files, there may be errors in respective artifacts deployments/un-deployments\n${nc}"
   cat grep_result1 >> list
   cat grep_result2 >> list
   sort list | uniq | cut -d"/" -f6
else
   printf "\n${green}Deployment successful\n${nc}"
fi
rm -rf grep_result* list
rm -rf /tmp/portalDownForMaintenance.lock

}	

####### Function to stop tomcat server ########
function stop(){

printf "\n${yellow}Stopping Portal Server${nc}\n" >> $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`

$PATH_BIN/shutdown.sh | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`

sleep 40
process=`ps -aef | grep tomcat | wc -l`
if [ $process == 1 ] 
then
    printf "\n${yellow}Portal is STOPPED${nc}" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
elif [ $process > 1 ] 
then	
	kill -9 `ps -aef | grep tomcat | awk '{print $2}'` | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
    if [ $? != 0 ]
	then
	    printf "\n${red}Unable to stop tomcat. Please stop manually..${nc}"
		exit 0
	else
	    printf "\n${yellow}Portal is STOPPED${nc}" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
    fi
fi	
}

####### Function to start tomcat server #######

function start(){
Flag=1

printf "\n${yellow}Starting Server...${nc}\n" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`

until [ $Flag == 0 ]; do
     cd $PATH_SETENV
	 . ./setenv.sh
	 env | grep "ISAT_PORTAL_ROOT" > /dev/null
     Flag=$?
done
$PATH_BIN/startup.sh

tail -f $PATH_CATALINA/catalina.out | tee -a $PATH_PORTAL/install_logs/start_tomcat_log &

tail -f $PATH_PORTAL/install_logs/start_tomcat_log | while read LOGLINE
do
   [[ "${LOGLINE}" == *"Server startup"* ]] && pkill -P $$ tail
done
printf "\n${yellow}SERVER has STARTED${nc}" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`

sleep 10
 printf "\n${yellow}continue with deployments? <YES/NO>:${nc}"
 read input
 if [ $input == YES ] || [ $input == yes ] || [ $input == y ] || [ $input == Y ]; then
     continue
 else
     exit 0
 fi

}


####### Function to backup the artifacts #######
function backup(){

printf "\n${yellow}BackupingUp artifacts : Started${nc}\n" | tee -a $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`

if [ -d $PATH_PORTAL/automated/tomcat ]; then
	mkdir -p $PATH_PORTAL/prev_release_backup/tomcat 
	for i in `cat $PATH_PORTAL/automated/tomcat/list`
	do
		cp $PATH_TOMCAT/$i $PATH_PORTAL/prev_release_backup/tomcat
	done
fi

if [ -d $PATH_PORTAL/automated/liferay ]; then
	mkdir -p $PATH_PORTAL/prev_release_backup/liferay
	for i in `cat $PATH_PORTAL/automated/liferay/list`
	do
		cp -r $PATH_TOMCAT/$i $PATH_PORTAL/prev_release_backup/liferay
	done
fi

if [ -d $PATH_PORTAL/automated/properties ]; then
	mkdir -p $PATH_PORTAL/prev_release_backup/properties
	for i in `cat $PATH_PORTAL/automated/properties/list`
	do 
       		 if [ $i == "resources.zip" ]; then
           		cp -r $PATH_PROPS/resources $PATH_PORTAL/prev_release_backup/properties
        	elif [ $i == "portal-ext.properties" ]; then
           		cp -r $PATH_EXT_PROPS/$i $PATH_PORTAL/prev_release_backup/properties
       		else 
		        cp -r $PATH_PROPS/$i $PATH_PORTAL/prev_release_backup/properties
                 fi
	done
fi

total_backups=`ls -ltr $PATH_PORTAL/prev_release_backup/* | awk '{print $9}'| grep -v '^$' | wc -l`

printf "\nTotal Backups : $total_backups" >> $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
printf "\nTotal Backups : $arts_automated" >> $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
 
if [ $total_backups != $arts_automated ]
then
    printf "\n${red}Backup is not taken properly, Proceed with deployment? <YES/NO>${nc}\n"
	read input
    if [ $input == NO ] || [ $input == no ] || [ $input == n ] || [ $input == N ]; then
        printf "exiting..."
        exit 0
	fi
fi

printf "\n${yellow}BackupingUp artifacts : Completed{nc}\n"
}

########## Controlling Part ##########

if [ "$#" != 2 ] && [ "$#" != 4 ];then
   echo "Sorry wrong parameters!! Please take a look at user-manual for right usage of the script"
exit 0
fi

## set PATH_PORTAL variable ##
PATH_PORTAL=`pwd`

## create install_log dir ##
if [ ! -d $PATH_PORTAL/install_logs ]
then
	b=1
	mkdir -p $PATH_PORTAL/install_logs/install_$b
else
	a=`ls -ld $PATH_PORTAL/install_logs/install_* | awk '{print $9}' | cut -d"/" -f2 | tail -1 | cut -d"_" -f2`
	b=`expr $a + 1`
	mkdir -p $PATH_PORTAL/install_logs/install_$b
fi

## release name ##
release_name=`printf $PATH_PORTAL | rev | cut -d'/' -f1 | rev`

if [ $2 == PROD ] || [ $2 == SCT ]; then
	PATH_PROPS="/opt/ssp"
	PATH_EXT_PROPS="/opt/ssp/apache-tomcat-7.0.34/webapps/ROOT/WEB-INF/classes"
	PATH_TOMCAT="/opt/ssp/apache-tomcat-7.0.34/webapps"	
	PATH_LIFERAY="/opt/ssp/deploy"
	PATH_SETENV="/opt/ssp/apache-tomcat-7.0.34/bin"
	PATH_BIN="/opt/ssp/apache-tomcat-7.0.34/bin"
	PATH_CATALINA="/opt/ssp/apache-tomcat-7.0.34/logs"
        ENV=SCT
elif [ $2 == DEV ]; then
	PATH_PROPS="/opt/isat"
	PATH_EXT_PROPS="/opt/tomcat/apache-tomcat-7.0.34/webapps/ROOT/WEB-INF/classes"
	PATH_TOMCAT="/opt/tomcat/apache-tomcat-7.0.34/webapps"
	PATH_LIFERAY="/opt/tomcat/deploy"	
	PATH_SETENV="/opt/isat"
	PATH_BIN="/opt/tomcat/apache-tomcat-7.0.34/bin"
	PATH_CATALINA="/opt/tomcat/apache-tomcat-7.0.34/logs"
        ENV=DEV
elif [ $2 == ISREAL ]; then
	PATH_PROPS="/opt/isat"
	PATH_EXT_PROPS="/opt/tomcat/liferay-portal-6.2-ee-sp14/tomcat-7.0.62/webapps/ROOT/WEB-INF/classes"
	PATH_TOMCAT="/opt/tomcat/liferay-portal-6.2-ee-sp14/tomcat-7.0.62/webapps"
	PATH_LIFERAY="/opt/tomcat/liferay-portal-6.2-ee-sp14/deploy"	
	PATH_SETENV="/opt/isat"
	PATH_BIN="/opt/tomcat/liferay-portal-6.2-ee-sp14/tomcat-7.0.62/bin"
	PATH_CATALINA="/opt/tomcat/apache-tomcat-7.0.34/logs"
        ENV=ISREAL

else
   echo "Usage: install_patch.sh -env <SCT/PROD/DEV>"
   echo "Eg: install_patch.sh -env DEV"
   exit 0
fi

## this is usefull if script is running second time ##
    rm -rf $PATH_PORTAL/automated/liferay/list 
	rm -rf $PATH_PORTAL/automated/tomcat/list
	rm -rf $PATH_PORTAL/automated/properties/list
	rm -rf $PATH_PORTAL/*_list
	rm -rf $PATH_PORTAL/arts*
    
if [ -d $PATH_PORTAL/automated/tomcat ]; then
        ls -ltr $PATH_PORTAL/automated/tomcat | awk '{print $9}' | grep -v "^$">> list
	mv list automated/tomcat
	printf "\ndeploy function tomcat related artifacts list" >> $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
	cat automated/tomcat/list >> $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
fi

if [ -d $PATH_PORTAL/automated/liferay ]; then
	ls -ltr $PATH_PORTAL/automated/liferay | awk '{print $9}' | grep -v "^$" >> list
        sed 's/.war//g' list > list1
        mv list1 list
	mv list automated/liferay
	printf "\ndeploy function liferay related artifacts list" >> $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
	cat automated/liferay/list >> $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
fi

if [ -d $PATH_PORTAL/automated/properties ]; then
        ls -ltr $PATH_PORTAL/automated/properties/ | awk '{print $9}' | grep -v "^$" | cut -d"/" -f6 >> list
	mv list automated/properties
	printf "\ndeploy function properties related artifacts list" >> $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
	cat automated/properties/list >> $PATH_PORTAL/install_logs/install-`date +"%Y-%m-%d"`
fi


red='\033[0;31m'
nc='\033[0m'
green='\033[0;32m'
yellow='\033[0;33m'

case $4 in

   ROLLBACK )
	rollback
   ;;

esac



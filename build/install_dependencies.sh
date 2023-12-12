echo -e "\n\n\nSalesforce CLI version check\n"
sudo npm sfdx --version

echo "---------TEST----------"
#works if deploy is needed
#sf project deploy start --source-dir "force-app/main/default/classes/CreatingAccount1.cls" --source-dir "force-app/main/default/classes/CreatingAccount1.cls-meta.xml" --target-org $SALESFORCE_ORG_ALIAS --test-level NoTestRun


#sf project deploy report --use-most-recent
#sf project deploy report --job-id "0Af5j00000TcKLhCAN" -u ${SALESFORCE_ORG_ALIAS}
#deploy_id="0Af5j00000TcKLhCAN"
#sf project deploy report --job-id $deploy_id --dev-debug

#sfdx force:mdapi:deploy:report --jobid "0Af5j00000TcKLhCAN" -u ${SALESFORCE_ORG_ALIAS}

#0Af5j00000SwqOb - bad
#0Af5j00000TcKLhCAN - good



#1 POSITIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO ="Succeeded Deployed"
#2 POSITIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO ="Failed"

#1 DESTRUCTIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO ="Succeeded Deployed"
#2 DESTRUCTIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO ="Failed"
#3 DESTRUCTIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO ="Skipped"


#--------------
DESTRUCTIVE_CHANGES_PRESENTED=true
#

if [[ $DESTRUCTIVE_CHANGES_PRESENTED == true ]]
    then
        #DESTRUCTIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO="123123321Succeeded Deployed123133212"
        DESTRUCTIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO="123123321Succeeded Deployed123133212"
    else
        DESTRUCTIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO="Skiped"
fi



echo "---------- TEST -----------"
echo $DESTRUCTIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO

if [[ $DESTRUCTIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO == *"Succeeded Deployed"* || $DESTRUCTIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO == *"Skiped"* ]];
    then
        DESTRUCTIVE_DEPLOYMENT_PASSED=true
    else
        DESTRUCTIVE_DEPLOYMENT_PASSED=false
fi





POSITIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO="Succeeded Deployed"

if [[ $POSITIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO == *"Succeeded Deployed"* ]]
    then
        POSITIVE_DEPLOYMENT_PASSED=true
    else
        POSITIVE_DEPLOYMENT_PASSED=false
fi


echo "------ POSITIVE_DEPLOYMENT_PASSED ----"
echo $POSITIVE_DEPLOYMENT_PASSED
echo "------ DESTRUCTIVE_DEPLOYMENT_PASSED ----"
echo $DESTRUCTIVE_DEPLOYMENT_PASSED

if [[ $POSITIVE_DEPLOYMENT_PASSED == true && $DESTRUCTIVE_DEPLOYMENT_PASSED == true ]]
    then
        PR_MERGE=true
    else
        PR_MERGE=false
fi

echo "------ PR_MERGE ----"
echo $PR_MERGE








#--dry-run - test run without saving 
#SALESFORCE_DEPLOY_LOG=$(sf project deploy start --source-dir "force-app/main/default/classes/CreatingAccount1.cls" --source-dir "force-app/main/default/classes/CreatingAccount1.cls-meta.xml" --dry-run --test-level NoTestRun --target-org ${SALESFORCE_ORG_ALIAS})
#echo $SALESFORCE_DEPLOY_LOG

#mapfile -t SALESFORCE_DEPLOY_LOG_ARRAY < <( echo $SALESFORCE_DEPLOY_LOG | tr ' ' '\n' | sed 's/\(.*\),/\1 /' )


#COUNT=0
#ARRAY_LEN=${#SALESFORCE_DEPLOY_LOG_ARRAY[@]}
#SALESFORCE_DEPLOY_ID=""
#LOOP_LEN=$( expr $ARRAY_LEN - 1)

#while [ $COUNT -le $LOOP_LEN ]
#do
#    if [[ ${SALESFORCE_DEPLOY_LOG_ARRAY[$COUNT]} == *"ID:"* ]];
#    then
#        SALESFORCE_DEPLOY_ID_ARRAY_POSITION=$(( $COUNT +1))
#        SALESFORCE_DEPLOY_ID=${SALESFORCE_DEPLOY_LOG_ARRAY[$SALESFORCE_DEPLOY_ID_ARRAY_POSITION]}
#        COUNT=$(( $COUNT +1))
#    else   
#        COUNT=$(( $COUNT +1))
#    fi
#done

#echo "--------- SALESFORCE_DEPLOY_ID ------------"
#echo $SALESFORCE_DEPLOY_ID


#echo "--------- SALESFORCE_DEPLOYMENT_STATUS_INFO ------------"
#SALESFORCE_DEPLOYMENT_STATUS_INFO=$(sfdx force:mdapi:deploy:report --jobid ${SALESFORCE_DEPLOY_ID} -u ${SALESFORCE_ORG_ALIAS})
#echo $SALESFORCE_DEPLOYMENT_STATUS_INFO















#--source-dir "force-app/main/default/classes/CreatingAccount1.cls" --source-dir "force-app/main/default/classes/CreatingAccount1.cls-meta.xml"


#sfdx force:source:deploy -p "$FILES_TO_DEPLOY" -c -l RunSpecifiedTests -r "$LIST_OF_FILES_TO_TEST_TRUNC" -u ${SALESFORCE_ORG_ALIAS} --loglevel WARN

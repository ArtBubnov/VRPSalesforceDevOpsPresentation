echo -e "--- Deploy metadata to Salesforce org script executions start ---\n\n\n"




echo -e "--- Step 1. Define global variables for the current pipeline ---\n"

echo "Step 1 execution result:"
echo "Global variables display"
echo -e "\nEvent type is:"
echo "Push"
echo -e "\nSource branch name is:"
echo $SOURCE_BRANCH_NAME
echo -e "\nTarget branch name is:"
echo $TARGET_BRANCH_NAME
echo -e "\nSalesforce org alias is:"
echo $SALESFORCE_ORG_ALIAS

echo -e "\n---Step 1 execution is finished ---"




echo -e "\n\n\n--- Step 2. Deploy data to the target Salesforce org ----"

SALESFORCE_DEPLOY_LOG=$(sfdx force:source:deploy -p "$FILES_TO_DEPLOY" -u ${SALESFORCE_ORG_ALIAS} --loglevel WARN)

echo -e "\n--- Step 2 execution result ---"
echo "Step 2 execution result:"
echo "Salesforce deploy result is:"
echo $SALESFORCE_DEPLOY_LOG

echo -e "\n--- Step 2 execution is finished ---"




echo -e "\n\n\n--- Step 3. Deploy meta to the target Salesforce org deploy ID ----"
mapfile -t SALESFORCE_DEPLOY_LOG_ARRAY < <( echo $SALESFORCE_DEPLOY_LOG | tr ' ' '\n' | sed 's/\(.*\),/\1 /' )


COUNT=0
ARRAY_LEN=${#SALESFORCE_DEPLOY_LOG_ARRAY[@]}
SALESFORCE_DEPLOY_ID=""
LOOP_LEN=$( expr $ARRAY_LEN - 1)

while [ $COUNT -le $LOOP_LEN ]
do
    if [[ ${SALESFORCE_DEPLOY_LOG_ARRAY[$COUNT]} == *"ID:"* ]];
    then
        SALESFORCE_DEPLOY_ID_ARRAY_POSITION=$(( $COUNT +1))
        SALESFORCE_DEPLOY_ID=${SALESFORCE_DEPLOY_LOG_ARRAY[$SALESFORCE_DEPLOY_ID_ARRAY_POSITION]}
        COUNT=$(( $COUNT +1))
    else   
        COUNT=$(( $COUNT +1))
    fi
done


echo "POSITIVE_CHANGES_SALESFORCE_DEPLOY_ID=$SALESFORCE_DEPLOY_ID" >> "$GITHUB_ENV"

echo -e "\n--- Step 4 execution result ---"
echo "Step 4 execution result:"
echo "Salesforce org deploy ID is :"
echo $SALESFORCE_DEPLOY_ID
echo "--- Step 4 execution is finished ---"
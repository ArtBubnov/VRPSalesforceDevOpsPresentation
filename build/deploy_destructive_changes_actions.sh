echo -e "--- Deploy destructive changes script executions start ---\n\n\n"


echo -e "--- Step 1. Deploy destructive changes without saving ---\n"

if [[ $DESTRUCTIVE_CHANGES_PRESENTED == true ]]
    then
        SALESFORCE_DEPLOY_LOG=$(sf project delete source $ENV_DESTRUCTIVE_DIFF_SF -c --target-org ${SALESFORCE_ORG_ALIAS} --no-prompt)
        echo $SALESFORCE_DEPLOY_LOG

        
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

        echo $SALESFORCE_DEPLOY_ID
        echo "DESTRUCTIVE_CHANGES_SALESFORCE_DEPLOY_ID=$SALESFORCE_DEPLOY_ID" >> "$GITHUB_ENV"

        echo -e "\n\n--- Step 1 execution is finished ---"
    else
        echo "Due to there are no destructive changes detected"
        echo -e "Script exection will be finished with 0 code status\n"
        echo "The workflow execution will be proceeded"

        echo -e "\n--- Step 1 execution is finished ---"
        exit 0
fi
echo -e "--- Deploy destructive changes script executions start ---\n\n\n"


echo -e "--- Step 1. Deploy destructive changes without saving ---\n"

if [[ $DESTRUCTIVE_CHANGES_PRESENTED == true ]]
    then
        sf project delete source $ENV_DESTRUCTIVE_DIFF_SF -с --target-org ${SALESFORCE_ORG_ALIAS} --no-prompt

        echo -e "\n\n--- Step 1 execution is finished ---"
    else
        echo "Due to there are no destructive changes detected"
        echo -e "Script exection will be finished with 0 code status\n"
        echo "The workflow execution will be proceeded"

        echo -e "\n--- Step 1 execution is finished ---"
        exit 0
fi
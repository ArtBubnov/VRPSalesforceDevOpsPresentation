
echo -e "\n\n\nMerge PR\n"



echo -e "--- Step 1. Define Salesforce deployment status ---\n"

if [[ $DESTRUCTIVE_CHANGES_PRESENTED == true ]]
    then
        DESTRUCTIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO=$(sfdx force:mdapi:deploy:report --jobid ${$DESTRUCTIVE_CHANGES_SALESFORCE_DEPLOY_ID} -u ${SALESFORCE_ORG_ALIAS})
    else
        DESTRUCTIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO="Skiped"
fi



if [[ $DESTRUCTIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO == *"Succeeded Deployed"* || $DESTRUCTIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO == *"Skiped"* ]];
    then
        DESTRUCTIVE_DEPLOYMENT_PASSED=true
    else
        DESTRUCTIVE_DEPLOYMENT_PASSED=false
fi



POSITIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO=$(sfdx force:mdapi:deploy:report --jobid ${$POSITIVE_CHANGES_SALESFORCE_DEPLOY_ID} -u ${SALESFORCE_ORG_ALIAS})

if [[ $POSITIVE_SALESFORCE_DEPLOYMENT_STATUS_INFO == *"Succeeded Deployed"* ]]
    then
        POSITIVE_DEPLOYMENT_PASSED=true
    else
        POSITIVE_DEPLOYMENT_PASSED=false
fi



if [[ $POSITIVE_DEPLOYMENT_PASSED == true && $DESTRUCTIVE_DEPLOYMENT_PASSED == true ]]
    then
        PR_MERGE=true
    else
        PR_MERGE=false
fi

echo -e "\nStep 1 execution result:"
echo -e "\nSalesforce destructive deployment passed:"
echo $DESTRUCTIVE_DEPLOYMENT_PASSED
echo -e "\nSalesforce positive deployment passed:"
echo $POSITIVE_DEPLOYMENT_PASSED
echo -e "\nShould the PR be merged"
echo $PR_MERGE
echo -e "\n--- Step 1 execution is finished ---"




echo -e "--- Step 2. Define if PR should be merged ---\n"


if [[ $PR_MERGE == true ]];
then
    echo "Due to the Salesforce deploymen has been successful"
    echo "PR should be merget"
    curl -L \
      -X PUT \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer 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" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      https://api.github.com/repos/ArtBubnov/SalesforceDevOpsPresentation/pulls/${{ github.event.number }}/merge \
      -d '{"commit_title":"Expand enum","commit_message":"Add a new value to the merge_method enum"}' 
      echo -e "\n--- Step 2 execution is finished ---"
else
    echo -e "\n--- Step 2 execution is finished ---"
    echo "Due to the Salesforce deploymen has NOT been successful"
    echo "PR should NOT be merget"
    echo "Script execution will be finished with 1 status code"
    exit 1
fi


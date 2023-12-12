echo "--- Define positive and destructive changes script execution start ---\n"


echo -e "\n\n\n--- Step 1. Logic execution to define the list of POSITIVE files to be deployed to the Salesforce org ---"

echo -e "\nFind the difference between organizations"
DIFF_BRANCH="origin/"$TARGET_BRANCH_NAME

echo -e "\nDiff logic execution result:"
GET_DIFF=$(git diff --name-only --diff-filter=ACMR ${DIFF_BRANCH} ${SALESFORCE_META_DIRECTORY})

echo $GET_DIFF
FILES_TO_DEPLOY=$(git diff --name-only --diff-filter=ACMR ${DIFF_BRANCH} ${SALESFORCE_META_DIRECTORY} | tr '\n' ',' | sed 's/\(.*\),/\1 /')


echo -e "\nStep 1 execution is finished"
echo "Step 1 execution result:"
echo -e "\nFiles to deploy"
echo $FILES_TO_DEPLOY
echo "ENV_POSITIVE_DIFF_SF=$FILES_TO_DEPLOY" >> "$GITHUB_ENV"

echo -e "\n--- Step 1 execution is finished ---\n\n\n"




echo -e "--- Step 2. Define destructive changes ---\n"

mapfile -t files_array < <( git diff --name-only --diff-filter=D ${DIFF_BRANCH} ${SALESFORCE_META_DIRECTORY} )


COUNT=0
ARRAY_LEN=${#files_array[@]}
LOOP_LEN=$( expr $ARRAY_LEN - 1)
SF_COMMAND_META_STRING=""

if [[ $ARRAY_LEN != 0 ]]
    then
        while [ $COUNT -le $LOOP_LEN ]
        do
            CURRENT_ARRAY_NODE=${files_array[$COUNT]}
            SF_COMMAND_META_STRING=${SF_COMMAND_META_STRING}"--source-dir "'"'${CURRENT_ARRAY_NODE}'" '    
            COUNT=$(( $COUNT +1))

        done

        echo "ENV_DESTRUCTIVE_DIFF_SF=$SF_COMMAND_META_STRING" >> "$GITHUB_ENV"
        echo "DESTRUCTIVE_CHANGES_PRESENTED=true" >> "$GITHUB_ENV"

        echo -e "\nStep 2 execution result"
        echo "destructive changes list is: "
        echo $SF_COMMAND_META_STRING
        echo -e "\n--- Step 2 execution is finished ---"
    else
        echo "Due to there are no destructive changes detected"
        echo -e "Script exection will be finished with 0 code status\n"
        echo "The workflow execution will be proceeded"
        echo -e "\n--- Step 2 execution is finished ---"
        echo "DESTRUCTIVE_CHANGES_PRESENTED=false" >> "$GITHUB_ENV"
        exit 0
fi
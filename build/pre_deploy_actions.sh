echo -e "--- Predeploy actions script executions start ---\n\n\n"


echo -e "--- Step 1. Define global variables for the current pipeline ---\n"

echo -e "Global variables display:\n"
echo "Event type is:"
echo -e "Pull request\n"
echo "Source branch name is:"
echo $SOURCE_BRANCH_NAME
echo -e "\nTarget branch name is:"
echo $TARGET_BRANCH_NAME
echo -e "\nSalesforce org alias is:"
echo $SALESFORCE_ORG_ALIAS

HOME_DIR=$(pwd)

echo -e "\n--- Step 1 execution is finished ---"




echo -e "\n\n\n--- Step 2. Logic execution to define the list of apex tests to be executed during deployment to the Salesforce org ---"

#get to classes directory to define the list of tests to be executed
cd $APEX_TESTS_DIRECTORY

#add all the files in the folder into array
mapfile -t classes_files_array < <( ls )

#define which of the files are tests
COUNT=0
ARRAY_LEN=${#classes_files_array[@]}
LIST_OF_FILES_TO_TEST=""
LOOP_LEN=$( expr $ARRAY_LEN - 1)

while [ $COUNT -le $LOOP_LEN ]
do
    if [[ ${classes_files_array[$COUNT]} == *"Test.cls"* ]];
    then

        if [[ ${classes_files_array[$COUNT]} == *"cls-meta.xml"* ]];
        then
            LIST_OF_XML_FILES=$LIST_OF_XML_FILES{classes_files_array[$COUNT]}","
        else
            LEN_OF_FILE_NAME=${#classes_files_array[$COUNT]}
            NUMBER_OF_SYMBOLS_TO_TRUNCATE=$( expr $LEN_OF_FILE_NAME - 4 )
            FILE_NAME_TRUNC=$((echo ${classes_files_array[$COUNT]}) | cut -c 1-$NUMBER_OF_SYMBOLS_TO_TRUNCATE )
            LIST_OF_FILES_TO_TEST=$LIST_OF_FILES_TO_TEST$FILE_NAME_TRUNC","
        fi

    fi 
    COUNT=$(( $COUNT +1))
done

LEN_OF_LIST_OF_FILES_TO_TEST=${#LIST_OF_FILES_TO_TEST}
NUMBER_OF_SYMBOLS_TO_TRUNCATE=$( expr $LEN_OF_LIST_OF_FILES_TO_TEST - 1 )
LIST_OF_FILES_TO_TEST_TRUNC=$((echo ${LIST_OF_FILES_TO_TEST}) | cut -c 1-$NUMBER_OF_SYMBOLS_TO_TRUNCATE )


echo -e "\nStep 2 execution result:"
echo -e "\nList of apex tests to be executed:"
echo $LIST_OF_FILES_TO_TEST_TRUNC
cd $HOME_DIR

echo -e "\n--- Step 2 execution is finished ---"




echo -e "\n\n\n--- Step 3. Test deploy to the Salesforce org ---\n"

#sfdx force:source:deploy -p "$FILES_TO_DEPLOY" -c -l RunSpecifiedTests -r "$LIST_OF_FILES_TO_TEST_TRUNC" -u ${SALESFORCE_ORG_ALIAS} --loglevel WARN
#sfdx force:source:deploy -p "$FILES_TO_DEPLOY" -c -l NoTestRun -u ${SALESFORCE_ORG_ALIAS} --loglevel WARN
sfdx force:source:deploy -p "$ENV_POSITIVE_DIFF_SF" -c -l NoTestRun -u ${SALESFORCE_ORG_ALIAS} --loglevel WARN


echo -e "\n--- Step 3 execution is finished ---"
#!/bin/bash

logger () {
    echo -e "--- logger () function execution start. ---"
    echo -e "--- Output global info for the current pipeline ---\n\n"
    
    
    echo "Event is:"
    echo -e "Pull request\n"
    echo -e "Pull request number is:\n"
    echo $PR_NUMBER
    echo "Pull request source branch is:"
    echo $SOURCE_BRANCH_NAME
    echo -e "\nPull request target branch is:"
    echo $TARGET_BRANCH_NAME
    echo -e "Salesforce org alias that will be used is:"
    echo $SALESFORCE_ORG_ALIAS
    echo -e "\nInstalled SFDX version is:"
    sudo npm sfdx --version


    echo -e "\n--- logger () function execution end. ---"
}




login_to_SF_org () {
    echo -e "\n\n\n--- login_to_SF_org_full_version () function execution start. ---"
    echo -e "--- Login into Salesforce Org ---\n\n\n"


    echo -e "\n\n\n--- Step 1. Login to the target Salesforce org"

    echo "Creating .key file"
    touch access_pass.key

    echo -e "\nAdding access data to .key file"
    echo $ACCESS_KEY_SF > access_pass.key

    echo -e "\nTry to login to the Salesforce org"
    #sf org login sfdx-url --sfdx-url-file "access_pass.key" --alias ${SALESFORCE_ORG_ALIAS}
    sfdx force:auth:sfdxurl:store -f "access_pass.key" -a ${SALESFORCE_ORG_ALIAS} -d

    rm access_pass.key

    echo -e "\n--- Step 1.  execution is finished"
}




get_positive_changes () {
    echo -e "--- get_positive_changes () function execution start. ---"
    echo -e "--- Define positive changes ---\n"



    echo -e "\n\n--- Step 1. Logic execution to define the list of POSITIVE files to be deployed to the Salesforce org ---"


    echo -e "\nFind the difference between organizations"
    DIFF_SOURCE_BRANCH="origin/"$SOURCE_BRANCH_NAME
    DIFF_TARGET_BRANCH="origin/"$TARGET_BRANCH_NAME

    FILES_TO_DEPLOY=$(git diff ${DIFF_TARGET_BRANCH}..${DIFF_SOURCE_BRANCH} --name-only --diff-filter=ACMR ${SALESFORCE_META_DIRECTORY} | tr '\n' ',' | sed 's/\(.*\),/\1 /')


    echo -e "\nStep 1 execution is finished"
    echo "Step 1 execution result:"
    echo -e "Files to deploy"
    echo $FILES_TO_DEPLOY
    echo "ENV_POSITIVE_DIFF_SF=$FILES_TO_DEPLOY" >> "$GITHUB_ENV"


    echo -e "\n--- Step 1 execution is finished ---\n\n\n"
}




get_destructive_changes () {
    echo -e "--- get_destructive_changes () function execution start. ---"
    echo -e "--- Define destructive changes ---\n"


    echo -e "\n\n--- Step 1. Logic execution to define the list of DESTRUCTIVE files to be deleted from the Salesforce org ---"


    echo -e "\nFind the difference between organizations"
    DIFF_SOURCE_BRANCH="origin/"$SOURCE_BRANCH_NAME
    DIFF_TARGET_BRANCH="origin/"$TARGET_BRANCH_NAME


    FILES_TO_DEPLOY=$(git diff ${DIFF_TARGET_BRANCH}..${DIFF_SOURCE_BRANCH} --name-only --diff-filter=D ${SALESFORCE_META_DIRECTORY} | tr '\n' ',' | sed 's/\(.*\),/\1 /')

    if [[ ${#FILES_TO_DEPLOY} != 0 ]]
        then
            echo "ENV_DESTRUCTIVE_DIFF_SF=$FILES_TO_DEPLOY" >> "$GITHUB_ENV"
            echo "DESTRUCTIVE_CHANGES_PRESENTED=true" >> "$GITHUB_ENV"

            echo -e "\nStep 1 execution result"
            echo "destructive changes list is: "
            echo $FILES_TO_DEPLOY
            echo -e "\n\n\n--- Step 1 execution is finished ---"
        else
            echo "Due to there are no destructive changes detected"
            echo -e "Script exection will be finished with 0 code status\n"
            echo "The workflow execution will be proceeded"
            echo -e "\n\n\n--- Step 1 execution is finished ---"
            echo "DESTRUCTIVE_CHANGES_PRESENTED=false" >> "$GITHUB_ENV"
    fi
}




get_apex_tests_list () {
    echo -e "--- get_apex_tests_list () function execution start. ---"
    echo -e "--- Define list of Apex tests to be used ---\n\n"

    HOME_DIR=$(pwd)

    echo -e "--- Step 1. Logic execution to define the list of apex tests to be executed during deployment to the Salesforce org ---"

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


    echo -e "\nStep 1 execution result:"
    echo -e "\nList of apex tests to be executed:"
    echo $LIST_OF_FILES_TO_TEST_TRUNC
    echo "ENV_APEX_TESTS_SF=$LIST_OF_FILES_TO_TEST_TRUNC" >> "$GITHUB_ENV"

    cd $HOME_DIR

    echo -e "\n--- Step 1 execution is finished ---"

}




destructive_changes_pre_deploy_actions () {
    echo -e "--- destructive_changes_pre_deploy_actions () function execution start. ---"
    echo -e "--- Deploy destructive changes without saving ---\n\n"


    echo -e "--- Step 1. Deploy destructive changes without saving ---\n"
    
    if [[ $DESTRUCTIVE_CHANGES_PRESENTED == true ]]
        then
            sfdx force:source:delete -p "$ENV_DESTRUCTIVE_DIFF_SF" -c -u ${SALESFORCE_ORG_ALIAS}

            echo -e "\n\n--- Step 1 execution is finished ---"
        else
            echo -e "Script exection will be finished with 0 code status\n"
            echo "The workflow execution will be proceeded"

            echo -e "\n--- Step 1 execution is finished ---"
    fi
}




positive_changes_pre_deploy_actions () {
    echo -e "--- positive_changes_pre_deploy_actions () function execution start. ---"
    echo -e "--- Deploy positive changes without saving ---\n\n"


    echo -e "\n\n\n--- Step 3. Test deploy to the Salesforce org ---\n"
    echo -e $(git checkout origin/dev)
    echo -e "******* TEST ***********"
    echo $ENV_POSITIVE_DIFF_SF

    echo -e "******* TEST ***********"
    sfdx force:source:deploy -p "$ENV_POSITIVE_DIFF_SF" -c -l RunSpecifiedTests -r "$ENV_APEX_TESTS_SF" -u ${SALESFORCE_ORG_ALIAS}


    echo -e "\n--- Step 3 execution is finished ---"
}




destructive_changes_deploy_actions () {
    echo -e "--- destructive_changes_deploy_actions () function execution start. ---"
    echo -e "--- Deploy destructive changes ---\n\n"


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

}




positive_changes_deploy_actions () {
    echo -e "--- positive_changes_deploy_actions () function execution start. ---"
    echo -e "--- Deploy positive changes ---\n\n"


    echo -e "\n\n\n--- Step 1. Deploy data to the target Salesforce org ----"

    SALESFORCE_DEPLOY_LOG=$(sfdx force:source:deploy -p "$FILES_TO_DEPLOY" -u ${SALESFORCE_ORG_ALIAS} --loglevel WARN)

    echo -e "\n--- Step 1 execution result ---"
    echo "Step 1 execution result:"
    echo "Salesforce deploy result is:"
    echo $SALESFORCE_DEPLOY_LOG

    echo -e "\n--- Step 1 execution is finished ---"




    echo -e "\n\n\n--- Step 2. Deploy meta to the target Salesforce org deploy ID ----"
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

    echo -e "\n--- Step 2 execution result ---"
    echo "Step 2 execution result:"
    echo "Salesforce org deploy ID is :"
    echo "The step 3 has been complited"
    echo $SALESFORCE_DEPLOY_ID
    echo "--- Step 2 execution is finished ---"
}




test_actions () {
    echo -e "-------------TEST------------"
    echo -e $(git checkout origin/dev)
    HOME_DIR=$(pwd)

    cd force-app/main/default/lwc/barcodeScanner
    ls -a
    echo -e "-------------------------"
    cd __tests__
    ls -a
    cd $HOME_DIR
    echo -e "-------------TEST------------\n\n\n"





    #sfdx force:source:deploy -p "force-app/main/default/lwc/barcodeScanner/__tests__/barcodeScanner.test.js,force-app/main/default/lwc/barcodeScanner/barcodeScanner.html,force-app/main/default/lwc/barcodeScanner/barcodeScanner.js,force-app/main/default/lwc/barcodeScanner/barcodeScanner.js-meta.xml" -c -l NoTestRun -u ${SALESFORCE_ORG_ALIAS}
}
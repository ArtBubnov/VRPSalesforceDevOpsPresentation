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


    echo "Creating .key file"
    touch access_pass.key

    echo -e "\nAdding access data to .key file"
    echo $ACCESS_KEY_SF > access_pass.key

    echo -e "\nTry to login to the Salesforce org"
    #sf org login sfdx-url --sfdx-url-file "access_pass.key" --alias ${SALESFORCE_ORG_ALIAS}
    sfdx force:auth:sfdxurl:store -f "access_pass.key" -a ${SALESFORCE_ORG_ALIAS} -d

    rm access_pass.key

    echo -e "\n--- login_to_SF_org_full_version () function execution end. ---"
}




get_positive_changes () {
    echo -e "--- get_positive_changes () function execution start. ---"
    echo -e "--- Define positive changes ---\n"


    echo -e "\nFind the difference between organizations"
    DIFF_SOURCE_BRANCH="origin/"$SOURCE_BRANCH_NAME
    DIFF_TARGET_BRANCH="origin/"$TARGET_BRANCH_NAME

    FILES_TO_DEPLOY=$(git diff ${DIFF_TARGET_BRANCH}..${DIFF_SOURCE_BRANCH} --name-only --diff-filter=ACMR ${SALESFORCE_META_DIRECTORY} | tr '\n' ',' | sed 's/\(.*\),/\1 /')


    if [[ ${#FILES_TO_DEPLOY} != 0 ]]
        then
            echo "ENV_POSITIVE_DIFF_SF=$FILES_TO_DEPLOY" >> "$GITHUB_ENV"
            echo "POSITIVE_CHANGES_PRESENTED=true" >> "$GITHUB_ENV"

            echo "The following has been defined as files to be deployed"
            echo $FILES_TO_DEPLOY
        else
            echo "Due to there are no positive changes detected"
            echo -e "Script exection will be finished with 0 code status\n"
            echo "The workflow execution will be proceeded"
            echo "POSITIVE_CHANGES_PRESENTED=false" >> "$GITHUB_ENV"
    fi

    #echo -e "\nStep 1 execution is finished"
    #echo "Step 1 execution result:"
    #echo -e "Files to deploy"
    #echo $FILES_TO_DEPLOY
    #echo "ENV_POSITIVE_DIFF_SF=$FILES_TO_DEPLOY" >> "$GITHUB_ENV"


    echo -e "\n--- get_positive_changes () function execution end. ---"
}




get_destructive_changes () {
    echo -e "--- get_destructive_changes () function execution start. ---"
    echo -e "--- Define destructive changes ---\n"


    echo -e "\nFind the difference between organizations"
    DIFF_SOURCE_BRANCH="origin/"$SOURCE_BRANCH_NAME
    DIFF_TARGET_BRANCH="origin/"$TARGET_BRANCH_NAME


    FILES_TO_DEPLOY=$(git diff ${DIFF_TARGET_BRANCH}..${DIFF_SOURCE_BRANCH} --name-only --diff-filter=D ${SALESFORCE_META_DIRECTORY} | tr '\n' ',' | sed 's/\(.*\),/\1 /')

    if [[ ${#FILES_TO_DEPLOY} != 0 ]]
        then
            echo "ENV_DESTRUCTIVE_DIFF_SF=$FILES_TO_DEPLOY" >> "$GITHUB_ENV"
            echo "DESTRUCTIVE_CHANGES_PRESENTED=true" >> "$GITHUB_ENV"

            echo "The following has been defined as files to be deployed"
            echo $FILES_TO_DEPLOY
        else
            echo "Due to there are no destructive changes detected"
            echo -e "Script exection will be finished with 0 code status\n"
            echo "The workflow execution will be proceeded"

            echo "DESTRUCTIVE_CHANGES_PRESENTED=false" >> "$GITHUB_ENV"
    fi


    echo -e "\n--- get_destructive_changes () function execution end. ---"
}




get_apex_tests_list () {
    echo -e "--- get_apex_tests_list () function execution start. ---"
    echo -e "--- Define list of Apex tests to be used ---\n\n"


    HOME_DIR=$(pwd)
    cd $APEX_TESTS_DIRECTORY

    mapfile -t classes_files_array < <( ls )

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


    if [[ ${#LIST_OF_FILES_TO_TEST_TRUNC} != 0 ]]
        then
            echo "ENV_APEX_TESTS_SF=$LIST_OF_FILES_TO_TEST_TRUNC" >> "$GITHUB_ENV"
            echo "APEX_TESTS_PRESENTED=true" >> "$GITHUB_ENV"
            echo "The following has been defined as apex tests to be executed"
            echo $LIST_OF_FILES_TO_TEST_TRUNC
        else
            echo "Due to there are no apex tests detected"
            echo -e "Script exection will be finished with 0 code status\n"
            echo "The workflow execution will be proceeded"
            echo "APEX_TESTS_PRESENTED=false" >> "$GITHUB_ENV"
    fi

    cd $HOME_DIR


    echo -e "\n--- get_apex_tests_list () function execution end. ---"
}




destructive_changes_pre_deploy_actions () {
    echo -e "--- destructive_changes_pre_deploy_actions () function execution start. ---"
    echo -e "--- Deploy destructive changes without saving ---\n\n"

    BRANCH_TO_CHECKOUT="origin/"$TARGET_BRANCH_NAME
    echo -e $(git checkout ${BRANCH_TO_CHECKOUT})
    
    if [[ $DESTRUCTIVE_CHANGES_PRESENTED == true ]]
        then
        
            if [[ $APEX_TESTS_PRESENTED == true ]]
                then
                    if [[ $ENV_POSITIVE_DIFF_SF == true ]]
                        then
                            sfdx force:source:delete -p "$ENV_DESTRUCTIVE_DIFF_SF" -c -l NoTestRun -u ${SALESFORCE_ORG_ALIAS} --no-prompt
                        else
                            sfdx force:source:delete -p "$ENV_DESTRUCTIVE_DIFF_SF" -c -l NoTestRun -u ${SALESFORCE_ORG_ALIAS} --no-prompt
                    fi
                else
                    sfdx force:source:delete -p "$ENV_DESTRUCTIVE_DIFF_SF" -c -l NoTestRun -u ${SALESFORCE_ORG_ALIAS} --no-prompt
            fi

        else
            echo "Due to there are no destructive changes detected"
            echo -e "Script exection will be finished with 0 code status\n"
            echo "The workflow execution will be proceeded"
    fi


    echo -e "\n--- destructive_changes_pre_deploy_actions () function execution end. ---"
}




positive_changes_pre_deploy_actions () {
    echo -e "--- positive_changes_pre_deploy_actions () function execution start. ---"
    echo -e "--- Deploy positive changes without saving ---\n\n"


    BRANCH_TO_CHECKOUT="origin/"$SOURCE_BRANCH_NAME
    echo -e $(git checkout ${BRANCH_TO_CHECKOUT})    
    
    if [[ $POSITIVE_CHANGES_PRESENTED == true ]]
        then
            if [[ $APEX_TESTS_PRESENTED == true ]]
                then
                    sfdx force:source:deploy -p "$ENV_POSITIVE_DIFF_SF" -c -l RunSpecifiedTests -r "$ENV_APEX_TESTS_SF" -u ${SALESFORCE_ORG_ALIAS}
                else
                    sfdx force:source:deploy -p "$ENV_POSITIVE_DIFF_SF" -c -l NoTestRun -u ${SALESFORCE_ORG_ALIAS}
            fi
        else
            echo "Due to there are no positive changes detected"
            echo -e "Script exection will be finished with 0 code status\n"
            echo "The workflow execution will be proceeded"
    fi
    


    echo -e "\n--- positive_changes_pre_deploy_actions () function execution end. ---"
}




destructive_changes_deploy_actions () {
    echo -e "--- destructive_changes_deploy_actions () function execution start. ---"
    echo -e "--- Deploy destructive changes ---\n\n"


    BRANCH_TO_CHECKOUT="origin/"$TARGET_BRANCH_NAME
    echo -e $(git checkout ${BRANCH_TO_CHECKOUT})

    if [[ $DESTRUCTIVE_CHANGES_PRESENTED == true ]]
        then
           SALESFORCE_DEPLOY_LOG=$(sfdx force:source:delete -p "$ENV_DESTRUCTIVE_DIFF_SF" -l NoTestRun -u ${SALESFORCE_ORG_ALIAS} --no-prompt)

            #SALESFORCE_DEPLOY_LOG=$(sf project delete source $ENV_DESTRUCTIVE_DIFF_SF -c --target-org ${SALESFORCE_ORG_ALIAS} --no-prompt)
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
    fi


    echo -e "\n--- destructive_changes_deploy_actions () function execution end. ---"
}




positive_changes_deploy_actions () {
    echo -e "--- positive_changes_deploy_actions () function execution start. ---"
    echo -e "--- Deploy positive changes ---\n\n"


    BRANCH_TO_CHECKOUT="origin/"$SOURCE_BRANCH_NAME
    echo -e $(git checkout ${BRANCH_TO_CHECKOUT})  

    if [[ $POSITIVE_CHANGES_PRESENTED == true ]]
        then

            if [[ $APEX_TESTS_PRESENTED == true ]]
                then
                    SALESFORCE_DEPLOY_LOG=$(sfdx force:source:deploy -p "$ENV_POSITIVE_DIFF_SF" -l RunSpecifiedTests -r "$ENV_APEX_TESTS_SF" -u ${SALESFORCE_ORG_ALIAS})
                else
                    SALESFORCE_DEPLOY_LOG=$(sfdx force:source:deploy -p "$ENV_POSITIVE_DIFF_SF" -l NoTestRun -u ${SALESFORCE_ORG_ALIAS})
            fi

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
            echo $SALESFORCE_DEPLOY_ID

        else
            echo "Due to there are no positive changes detected"
            echo -e "Script exection will be finished with 0 code status\n"
            echo "The workflow execution will be proceeded"
    fi


    echo -e "\n--- destructive_changes_deploy_actions () function execution end. ---"
}
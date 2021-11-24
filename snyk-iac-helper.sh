#Snyk IaC Helper
#!/bin/bash
RED='\033[1;31m'
ORANGE='\033[1;33m'
CYAN='\033[1;36m'
GRAY='\033[1;30m'
GREEN='\033[1;32m'
PURPLE='\033[1;35m'
BLUE='\033[1;34m'
NC='\033[0m' 

printf "\n"
echo "${PURPLE}Snyk IAC Helper${NC}"

if [ -e snyk_iac_results.json ]
then
    rm snyk_iac_results.json
fi


if [ -p /dev/stdin ]; then
        echo "Processing Snyk IaC Data!"
        printf "\n"
        while IFS= read line; do
                echo ${line} >> snyk_iac_results.json

        done
else
        echo "This script requires input from Snyk IaC"
        echo "Example command: ${BLUE}snyk iac test --json | ./snyk-iac-helper.sh${NC}"
        printf "\n"
        exit
fi

RESULT=$(cat snyk_iac_results.json | jq length); 


RESULT=$((RESULT - 1)); 
SEVCOUNT=$((SEVCOUNT-1));

#Loop through files
for i in $(seq 0 $RESULT); do 
    FILENAME=`cat snyk_iac_results.json |  jq '.['$i'] | .targetFilePath';`
    FILE=`cat snyk_iac_results.json |  jq '.['$i'] | .targetFile';`
    printf "File: " 
    echo "$FILENAME" | sed -e 's/^"//' -e 's/"$//' 
    printf "\n"  

    SEVCOUNT=`cat snyk_iac_results.json | jq '.['$i'] | .infrastructureAsCodeIssues | select(length > 0)' | jq length`; \
    SEVCOUNT=$((SEVCOUNT-1)); \
    


    #Loop through sub array
    for j in $(seq 0 $SEVCOUNT); do \
        ISSUE=`cat snyk_iac_results.json| jq '.['$i'] | .infrastructureAsCodeIssues | select(length > 0)' | jq '.['$j'].issue';`

        if [ -z "${ISSUE}" ];
            then 
            :
        else
            #Title
            TITLE=`cat snyk_iac_results.json| jq '.['$i'] | .infrastructureAsCodeIssues | select(length > 0)' | jq '.['$j'].title';`
            echo "${PURPLE}>>>>>>>> $TITLE <<<<<<<<${NC}"
            #Issue
            printf "Issue: "
            echo ${BLUE}$ISSUE${NC}; \
            
            #Snyk ID
            printf "SNYK ID: "
            SNYKID=`cat snyk_iac_results.json | jq '.['$i'] | .infrastructureAsCodeIssues | select(length > 0)' | jq '.['$j'].publicId';`
            echo $SNYKID          

            #Line Number
            printf "Line Number: "
            LINENUMBER=`cat snyk_iac_results.json | jq '.['$i'] | .infrastructureAsCodeIssues | select(length > 0)' | jq '.['$j'].lineNumber';`
            echo $LINENUMBER

            #Severity
            printf "Severity: "
            SEVERITY=`cat snyk_iac_results.json | jq '.['$i'] | .infrastructureAsCodeIssues | select(length > 0)' | jq '.['$j'].severity';` 
            
            if [[ "$SEVERITY" == '"critical"' ]]; then            
                echo ${RED}$SEVERITY${NC}
            elif [[ "$SEVERITY" == '"high"' ]]; then 
                echo ${ORANGE}$SEVERITY${NC}
            elif [[ "$SEVERITY" == '"medium"' ]]; then 
                echo ${CYAN}$SEVERITY${NC}
            elif [[ "$SEVERITY" == '"low"' ]]; then 
                echo ${GRAY}$SEVERITY${NC}
            fi

            #Impact
            printf  "Impact: " 
            IMPACT=`cat snyk_iac_results.json| jq '.['$i'] | .infrastructureAsCodeIssues | select(length > 0)' | jq '.['$j'].impact';` 
            echo $IMPACT

            #Affected Line
            echo "Affected line or block in ${BLUE}$FILE${NC}:\n"
            eval sed -n "$LINENUMBER"p $FILENAME  
            printf "\n"

            #Resolve
            
            RESOLVE=`cat snyk_iac_results.json| jq '.['$i'] | .infrastructureAsCodeIssues | select(length > 0)' | jq '.['$j'].resolve';` 
            if [[ "$RESOLVE" != "null" ]]; then
                printf  "Resolve: "
                echo ${GREEN}$RESOLVE${NC}
            fi

            #Documentation
            CUSTOM=`cat snyk_iac_results.json | jq '.['$i'] | .infrastructureAsCodeIssues | select(length > 0)' | jq '.['$j'].isGeneratedByCustomRule';`
            if [[ "$CUSTOM" == "false" ]]; then
                printf "Documentation: "
                DOCUMENTATION=`cat snyk_iac_results.json | jq '.['$i'] | .infrastructureAsCodeIssues | select(length > 0)' | jq '.['$j'].documentation';`
                printf $DOCUMENTATION
                printf "\n\n"
                else
                echo "${GREEN}This is a Custom Rule${NC}"
                printf "\n"
            fi
            
        fi    
    done; \
    echo " ------------------------------------------------------------------------ \n" ; \
done; \
rm snyk_iac_results.json
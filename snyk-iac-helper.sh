#Snyk IaC Helper
#!/bin/bash
RED='\033[1;31m'
ORANGE='\033[1;33m'
CYAN='\033[1;36m'
GRAY='\033[1;30m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
BLUE='\033[1;34m'
NC='\033[0m' 

if [ -e snyk_iac_results.json ]
then
    rm snyk_iac_results.json
fi


if [ -p /dev/stdin ]; then
        echo "Processing Snyk IaC Data!"
        while IFS= read line; do
                echo ${line} >> snyk_iac_results.json

        done
else
        echo "This script requires input from Snyk IaC"
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
            printf  "Resolve: "
            RESOLVE=`cat snyk_iac_results.json| jq '.['$i'] | .infrastructureAsCodeIssues | select(length > 0)' | jq '.['$j'].resolve';` 
            echo $RESOLVE

            #References
            printf "Documentation: "
            DOCUMENTATION=`cat snyk_iac_results.json | jq '.['$i'] | .infrastructureAsCodeIssues | select(length > 0)' | jq '.['$j'].documentation';`
            printf $DOCUMENTATION
            printf "\n\n"
        fi    
    done; \
    echo " ------------------------------------------------------------------------ \n" ; \
done; \
rm snyk_iac_results.json
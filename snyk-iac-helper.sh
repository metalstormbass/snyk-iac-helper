#Snyk IaC Helper
#!/bin/bash
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
            echo ">>>>>>>> Issue <<<<<<<<"
            echo $ISSUE; \

            echo "Severity:"
            cat snyk_iac_results.json | jq '.['$i'] | .infrastructureAsCodeIssues | select(length > 0)' | jq '.['$j'].severity'; \

            echo "Impact:" 
            cat snyk_iac_results.json| jq '.['$i'] | .infrastructureAsCodeIssues | select(length > 0)' | jq '.['$j'].impact'; \

            echo "Line Number:"
            cat snyk_iac_results.json | jq '.['$i'] | .infrastructureAsCodeIssues | select(length > 0)' | jq '.['$j'].lineNumber'; \
            LINENUMBER=`cat snyk_iac_results.json | jq '.['$i'] | .infrastructureAsCodeIssues | select(length > 0)' | jq '.['$j'].lineNumber';`
    
            echo "Resolve:"
            cat snyk_iac_results.json| jq '.['$i'] | .infrastructureAsCodeIssues | select(length > 0)' | jq '.['$j'].resolve'; \
            
            #Generate Line Numbers
            #BEFORE=$((LINENUMBER - 5))
            #AFTER=$((LINENUMBER + 5))

            echo "Line of Code:"
            eval sed -n "$LINENUMBER"p $FILENAME  | sed 's/^/       /'
            echo "\n"
        fi    
    done; \
    echo " ------------------------------------------------------------------------ " ; \
done; \
rm snyk_iac_results.json
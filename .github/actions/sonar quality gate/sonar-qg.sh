#!/bin/bash/

# Write your commands here

echo "checking sonarqube project status of project $SONAR_PROJECTNAME"
projectUrl="dashboard?branch=$SONAR_BRANCH&id=$SONAR_PROJECTNAME"
echo "sonarurl - $SONAR_URL$projectUrl"

touch projstatus.json

echo "PWD" $2
curl $SONAR_URL/api/project_branches/list?project=$SONAR_PROJECTNAME -u Devops:$2  > projstatus.json
printf "Quality gate response of project - "
cat projstatus.json

cat projstatus.json | jq --arg s "$SONAR_BRANCH"  '.branches[] | select(.name == $s) | .status.qualityGateStatus' > branchstatus

printf "Quality gate response of branch - "
cat branchstatus

response=$(cat branchstatus | grep "OK")
success="OK"
if [[ $response == *"OK"* ]]; 
then

status="OK"
echo "Quality gate status for project branch - $SONAR_BRANCH: $status"
echo "Quality gate is passsed and Sonarqube analysis is successful, pushing the image to registry"

else

status="ERROR"
echo "Quality gate is failed, aborting the build"
exit 1

fi

####################
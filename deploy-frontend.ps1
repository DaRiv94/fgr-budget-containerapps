$RESOURCE_GROUP = '';
$CONTAINER_APP_ENV = ''
$BACKEND_CONTAINER_APP_URL = ''
$FRONTEND_CONTAINER_APP_NAME = 'frontend-service'
$DOCKER_USERNAME = ''

git clone --branch azure-container-apps-branch git@github.com:DaRiv94/fgr-budget-frontend-v2.git

Set-Location ./fgr-budget-frontend-v2
    
Add-Content -Path .env -Value "REACT_APP_PROJECT_ENV=sandbox"
Add-Content -Path .env -Value "REACT_APP_FGR_BUDGET_BACKEND_URL=$($BACKEND_CONTAINER_APP_URL)"

docker build -t $DOCKER_USERNAME/frontend-aca:latest .

docker push $DOCKER_USERNAME/frontend-aca:latest

az containerapp create `
--image $DOCKER_USERNAME/frontend-aca:latest `
--name $FRONTEND_CONTAINER_APP_NAME `
--resource-group $RESOURCE_GROUP `
--environment $CONTAINER_APP_ENV `
--ingress external `
--target-port 3000 `
--min-replicas 1

az containerapp show -g $RESOURCE_GROUP -n $FRONTEND_CONTAINER_APP_NAME --query "properties.configuration.ingress.fqdn" -o tsv

Set-Location ../


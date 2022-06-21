$RESOURCE_GROUP="fgr-aca-rg"
$LOCATION="eastus"
$SUB_ID="<subscription-id>"

# az login
az account set --subscription $SUB_ID

# Create resource group
az group create -n $RESOURCE_GROUP -l $LOCATION

# Deploy infrastructure and all backend budget apps
az deployment group create -n budgetapp -g $RESOURCE_GROUP -f ./deploy/main.bicep

# Display outputs from bicep deployment
az deployment group show -n budgetapp -g $RESOURCE_GROUP -o json --query properties.outputs.frontendparams.value
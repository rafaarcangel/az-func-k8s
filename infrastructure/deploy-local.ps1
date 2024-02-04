# example execution:
# .\deploy-local.ps1 -subscriptionId "{ID}" -repoDirectory "{ABSOLUTE_PATH}" -resourcePrefix = "{SOME_PREFIX}"

param (
    [Parameter(Mandatory = $true)][string]$resourceGroupName,
    [Parameter(Mandatory = $true)][string]$subscriptionId,
    [Parameter(Mandatory = $true)][string]$repoDirectory,
    [string]$resourceGroupLocation = 'westeurope',
    [switch]$createResourceGroup = $false,
    [string]$terraformStateContainerName = 'tfstate',
    [switch]$installTerraformCLI = $false,
    [switch]$installJq = $false,
    [switch]$azLogin = $false,
    [switch]$setSubscription = $false
)

if ($installTerraformCLI) {
    choco install terraform --force -y
}

if ($installJq) {
    choco install jq --force -y
}

if ($azLogin) {
    az login
}

if ($setSubscription) {
    az account set --subscription $subscriptionId
}

$terraformStatestorageAccountName = $($resourceGroupName.Replace('-', ''))+"sto"
if ($createResourceGroup) {
    az group create --name $resourceGroupName --location $resourceGroupLocation
    az storage account create --name $terraformStatestorageAccountName `
        --allow-blob-public-access `
        --location $resourceGroupLocation `
        --resource-group $resourceGroupName `
        --default-action Allow
    
    $accountKey = $(az storage account keys list --resource-group $resourceGroupName --account-name $terraformStatestorageAccountName --query '[0].value' -o tsv)
    $connString = $(az storage account show-connection-string --name $terraformStatestorageAccountName --resource-group $resourceGroupName --query 'connectionString')
    echo $accountKey $connString
    az storage container create --auth-mode key --name $terraformStateContainerName --account-name $terraformStatestorageAccountName --public-access container --connection-string $connString --account-key $accountKey
}

$terraformStateKey = "$($repoDirectory.split("\")[-1])-$($env:UserName.Replace('.', '-'))"
$startingLocation = Get-Location

$workingDirectory = "$repoDirectory\infrastructure"
Set-Location -Path $workingDirectory

terraform init `
    -backend-config="subscription_id=$subscriptionId" `
    -backend-config="resource_group_name=$resourceGroupName" `
    -backend-config="storage_account_name=$terraformStatestorageAccountName" `
    -backend-config="container_name=$terraformStateContainerName" `
    -backend-config="key=$terraformStateKey.tfstate"

terraform apply -auto-approve -var RESOURCE_GROUP_NAME=$resourceGroupName

Write-Output "`n`n-----------------------------`nOutput variables"
$stringsOutput = terraform output -json | jq 'to_entries | map(select(.value.type == \"string\") |{(.key): .value.value }) | add' | ConvertFrom-Json
if ($null -ne $stringsOutput) {
    Get-Member -InputObject $stringsOutput -MemberType NoteProperty | ForEach-Object { Write-Host "$($_.name): $($stringsOutput.$($_.name))" }
}
$objectsOutput = terraform output -json | jq 'to_entries | map(. as $data | select($data.value.type != \"string\") | $data.value.value | with_entries(.key |= . + \"-\" + $data.key)) | add' | ConvertFrom-Json
if ($null -ne $objectsOutput) {
    Get-Member -InputObject $objectsOutput -MemberType NoteProperty | ForEach-Object { Write-Host "$($_.name): $($objectsOutput.$($_.name))" }
}

Set-Location -Path $startingLocation
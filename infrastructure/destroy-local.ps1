# example execution:
# .\destroy-local.ps1 -subscriptionId "{ID}" -repoDirectory "{ABSOLUTE_PATH}" -resourcePrefix = "{SOME_PREFIX}"

param (
    [Parameter(Mandatory = $true)][string]$resourceGroupName,
    [Parameter(Mandatory=$true)][string]$subscriptionId,
    [Parameter(Mandatory=$true)][string]$repoDirectory,
    [switch]$installTerraformCLI = $false,
    [switch]$azLogin = $false,
    [switch]$setSubscription = $false
)

if ($installTerraformCLI) {
    choco install terraform --force -y
}
if ($azLogin) {
    az login
}
if ($setSubscription) {
    az account set --subscription $subscriptionId
}
$startingLocation = Get-Location

$workingDirectory = "$repoDirectory\infrastructure"
Set-Location -Path $workingDirectory

$localResourcePrefix = "$($resourcePrefix)local"
terraform apply -destroy -auto-approve -var "RESOURCE_GROUP_NAME=$resourceGroupName"


Remove-Item "$workingDirectory\.terraform.lock.hcl"
Remove-Item "$workingDirectory\.terraform" -Recurse

Set-Location -Path $startingLocation
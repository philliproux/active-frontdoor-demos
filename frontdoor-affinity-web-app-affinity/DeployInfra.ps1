# TODO
# - FD: HTTP and HTTPS - done, Caching - done, Session Affinity
# - Web Apps: Env Variables
# - Search usage of each param
# - SP
# - Incorporate into YAML Pipeline
param (
    [Parameter(Mandatory)]
    [string]$frontDoorResourceGroup,
    [Parameter(Mandatory)]
    [string]$frontDoorName,
    [Parameter(Mandatory)]
    [string]$frontDoorBackendPoolName, # redundant
    [Parameter(Mandatory)]
    [string]$webAppBlue,
    [Parameter(Mandatory)]
    [string]$webAppBlueUrl,
    [Parameter(Mandatory)]
    [string]$appServicePlanBlue,
    [Parameter(Mandatory)]
    [string]$webAppGreenUrl,
    [Parameter(Mandatory)]
    [string]$appServicePlanGreen,
    [Parameter(Mandatory)]
    [string]$webAppGreen,
    [Parameter(Mandatory)]
    [string]$appServicePlanSize
    # [Parameter(Mandatory=$false)]
    # [bool]$loginWithServicePrincipal = $false,
    # [Parameter(Mandatory=$false)]
    # [string]$spUsername = '',
    # [Parameter(Mandatory=$false)]
    # [string]$spPassword = '',
    # [Parameter(Mandatory=$false)]
    # [string]$tenant = ''
)

<#
    -- MOVE INTO UNIFIED PS FILE -- 
    - Az Login
    - Clone Fika App
    - Provision Infra
    - Build Solution / Publish to Azure to both blue/green.. http://tattoocoder.com/dotnet-azure-a-net-core-global-tool-to-deploy-an-application-to-azure-in-one-command/
    - Toggle
    .\DeployInfra.ps1 -frontDoorResourceGroup "PR-frontdoor-bluegreen-rg1" -frontDoorName "frontdoor-blue-green-pr1" -frontDoorBackendPoolName "DefaultBackendPool" -webAppBlue "frontdoor-web-blue3" -webAppGreen "frontdoor-web-green3" -webAppBlueUrl "frontdoor-web-blue3.azurewebsites.net" -webAppGreenUrl "frontdoor-web-green2.azurewebsites.net" -appServicePlanBlue "appservice-blue3" -appServicePlanGreen "appservice-green3" -appServicePlanSize "B1"
    .\DeployInfra.ps1 -frontDoorResourceGroup "pr-frontdoor-bluegreen-rg1" -frontDoorName "frontdoor-blue-green-pr1" -frontDoorBackendPoolName "DefaultBackendPool" -webAppBlue "frontdoor-web-blue-pr1" -webAppGreen "frontdoor-web-green-pr1" -webAppBlueUrl "frontdoor-web-blue-pr1.azurewebsites.net" -webAppGreenUrl "frontdoor-web-green-pr1.azurewebsites.net" -appServicePlanBlue "appservice-blue-pr1" -appServicePlanGreen "appservice-green3" -appServicePlanSize "D1"
    .\ToggleFrontdoorBackends.ps1 -frontDoorResourceGroup "frontdoor-bluegreen-rg2" -frontDoorName "frontdoor-blue-green2" -frontDoorBackendPoolName "DefaultBackendPool" -frontDoorUrl "http://frontdoor-blue-green2.azurefd.net" -webAppBlueUrl "frontdoor-web-blue2.azurewebsites.net" -webAppGreenUrl "frontdoor-web-green2.azurewebsites.net"
#>

Write-Host "Delete Resource Group: " $frontDoorResourceGroup
az group delete --name $frontDoorResourceGroup

# Instantiate variables
$frontDoorFQDN = $frontDoorName + ".azurefd.net"
$frontDoorBackEndPoolName = "DefaultBackendPool" # Default value created by FD

$frontDoorLoadBalancerSampleSize = 4
$frontDoorLoadBalanceSuccessfulSamplesRequired = 2
$frontDoorLoadBalancingName = "DefaultLoadBalancingSettings" # Default value created by FD

$frontDoorHealthProbeIntervalInSeconds = 30
$frontDoorHealthProbeName = "DefaultProbeSettings"
$frontDoorHealthProbePath = "/"
$frontDoorHealthProbeProtocol = "Https"

$frontDoorRouteType = "Forward"
$frontDoorRouteName = "DefaultRoutingRule" # Default value created by FD
$frontDoorRouteAcceptedProtocols = "Https"
$frontDoorRouteCaching = "Disabled"
$frontDoorEndPointName = "DefaultFrontendEndpoint" # Default value created by FD

Write-Host "Front Door Hostname:" $frontDoorFQDN

# Create FD / Web Resources
Write-Host "Create Resource Group"
az group create -l westeurope -n $frontDoorResourceGroup

Write-Host "Create Blue Web App"
az appservice plan create -g $frontDoorResourceGroup -n $appServicePlanBlue --sku $appServicePlanSize
az webapp create -g $frontDoorResourceGroup -p $appServicePlanBlue -n $webAppBlue

Write-Host "Create Green Web App"
az appservice plan create -g $frontDoorResourceGroup -n $appServicePlanGreen
az webapp create -g $frontDoorResourceGroup -p $appServicePlanGreen -n $webAppGreen

Write-Host "Create Front Door"
az network front-door create --backend-address $frontDoorFQDN --name $frontDoorName --resource-group $frontDoorResourceGroup
# Set Session Affinity to on - no built in argument for this
$frontDoorId = az network front-door show --name $frontDoorName --resource-group  $frontDoorResourceGroup --query 'id' -o tsv
Write-Host $frontDoorId
#az resource update --ids

Write-Host "Create Front Door Load Balancer"
az network front-door load-balancing create --front-door-name $frontDoorName --name $frontDoorLoadBalancingName --resource-group $frontDoorResourceGroup --sample-size $frontDoorLoadBalancerSampleSize --successful-samples-required $frontDoorLoadBalanceSuccessfulSamplesRequired

Write-Host "Create Health Probe"
az network front-door probe create --front-door-name $frontDoorName --interval $frontDoorHealthProbeIntervalInSeconds --name $frontDoorHealthProbeName --path $frontDoorHealthProbePath --resource-group $frontDoorResourceGroup --protocol $frontDoorHealthProbeProtocol  #{Http, Https}

Write-Host "Create Backend Pool"
az network front-door backend-pool create --address $webAppGreenUrl --front-door-name $frontDoorName --load-balancing $frontDoorLoadBalancingName --name $frontDoorBackEndPoolName --probe $frontDoorHealthProbeName --resource-group $frontDoorResourceGroup

Write-Host "Create Front Door Route Rule"
az network front-door routing-rule create --front-door-name $frontDoorName --frontend-endpoint $frontDoorEndPointName  --name $frontDoorRouteName --resource-group $frontDoorResourceGroup --route-type $frontDoorRouteType --backend-pool $frontDoorBackEndPoolName --accepted-protocols $frontDoorRouteAcceptedProtocols --caching $frontDoorRouteCaching #--patterns "/api/*"

# List Front Door Resources
Write-Host "`nList Backend Pools"
az network front-door backend-pool list --front-door-name $frontDoorName --resource-group $frontDoorResourceGroup -o table

Write-Host "`nList Backend Pool Backends"
az network front-door backend-pool backend list --front-door-name $frontDoorName --pool-name $frontDoorBackendPoolName --resource-group $frontDoorResourceGroup -o table

Write-Host "`nHealth Probe Settings"
az network front-door probe list --front-door-name $frontDoorName --resource-group $frontDoorResourceGroup -o table

Write-Host "`nList load balancers"
az network front-door load-balancing list --front-door-name $frontDoorName --resource-group $frontDoorResourceGroup -o table

Write-Host "`nList Routing Rules"
az network front-door routing-rule list --front-door-name $frontDoorName --resource-group $frontDoorResourceGroup -o table

Write-Host "`nList FrontEnd Endpoints"
az network front-door frontend-endpoint list --front-door-name $frontDoorName --resource-group $frontDoorResourceGroup -o table

Write-Host "`nFront Door Hostname:" $frontDoorFQDN
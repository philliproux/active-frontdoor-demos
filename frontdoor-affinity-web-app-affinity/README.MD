* Manually set Front Door Session Affinity enabled.  Azure CLI has a bug.

**Deployment**
<pre>
.\DeployInfra.ps1 -frontDoorResourceGroup "pr-active-frontdoor-demo-2" -frontDoorName "pr-active-frontdoor-demo-2" -frontDoorBackendPoolName "DefaultBackendPool" -webAppBlue "pr-active-frontdoor-demo-2-web-app-blue" -webAppGreen "pr-active-frontdoor-demo-2-web-app-green" -webAppBlueUrl "pr-active-frontdoor-demo-2-web-app-blue.azurewebsites.net" -webAppGreenUrl "pr-active-frontdoor-demo-2-web-app-green.azurewebsites.net" -appServicePlanBlue "pr-active-frontdoor-demo-2-web-appserviceplan-blue" -appServicePlanGreen "pr-active-frontdoor-demo-2-web-appserviceplan-green" -appServicePlanSize "D1"
</pre>
# Login to Azure

#az login 

# Show subscription list
# az account list --output table

# # Set Subscription
# az account set --subscription "Phillip VS - ITAS"

# # List resource groups
# az group list --output table

az resource create -g "pr-active-frontdoor-demo-2" -n "DefaultFrontendEndpoint" --resource-type "Microsoft.Network/frontdoors/frontendendpoints" --is-full-object --properties '{
    "identity": null,
    "kind": null,
    "location": null,
    "managedBy": null,
    "name": "DefaultFrontendEndpoint",
    "plan": null,
    "properties": {
      "customHttpsConfiguration": null,
      "customHttpsProvisioningState": "Disabled",
      "customHttpsProvisioningSubstate": "None",
      "hostName": "pr-active-frontdoor-demo-2.azurefd.net",
      "resourceState": "Enabled",
      "sessionAffinityEnabledState": "Disabled",
      "sessionAffinityTtlSeconds": 0,
      "webApplicationFirewallPolicyLink": null
    },
    "resourceGroup": "pr-active-frontdoor-demo-2",
    "sku": null,
    "tags": null
}'
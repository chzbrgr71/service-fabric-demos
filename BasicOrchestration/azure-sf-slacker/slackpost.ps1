Import-Module "$ENV:ProgramFiles\Microsoft SDKs\Service Fabric\Tools\PSModule\ServiceFabricSDK\ServiceFabricSDK.psm1"

Connect-serviceFabricCluster -ConnectionEndpoint briarsf1.northcentralus.cloudapp.azure.com:19000

# Deployment: Copy SF application package to image store
Copy-ServiceFabricApplicationPackage C:\SF\azure-sf-slacker\azure-sf-slacker\pkg\Debug\ -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore azure_sf_slacker
                                     
# Deployment: Register application type
Register-ServiceFabricApplicationType azure_sf_slacker

# Cleanup image store
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore azure_sf_slacker

Get-ServiceFabricApplicationType

# Deployment: Create application instance
New-ServiceFabricApplication -ApplicationName fabric:/azure_sf_slacker -ApplicationTypeName "azure_sf_slackerType" -ApplicationTypeVersion "2.1.10"

Get-ServiceFabricApplication
Get-ServiceFabricApplication | Get-ServiceFabricService
Get-ServiceFabricPartition "fabric:/azure_sf_slacker/slackpost"

# Deployment: Deploy service (auto-created above)
New-ServiceFabricService -ApplicationName fabric:/azure_sf_slacker -ServiceName fabric:/azure_sf_slacker/slackpost -ServiceTypeName slackpostType -Stateless -PartitionSchemeSingleton -InstanceCount 3

# Change service placement constraint
Update-ServiceFabricService -Stateless -ServiceName "fabric:/azure_sf_slacker/slackpost" -Force -PlacementConstraints "NodeType == primary"
Update-ServiceFabricService -Stateless -ServiceName "fabric:/azure_sf_slacker/slackpost" -Force -PlacementConstraints "NodeType == secondary"

# Update service instance count
Update-ServiceFabricService -Stateless -ServiceName "fabric:/azure_sf_slacker/slackpost" -Force -InstanceCount 12
Update-ServiceFabricService -Stateless -ServiceName "fabric:/azure_sf_slacker/slackpost" -Force -InstanceCount -1

# Health
Get-ServiceFabricClusterHealth
Get-ServiceFabricNodeHealth _primary_1
Get-ServiceFabricNode | Get-ServiceFabricNodeHealth | select NodeName, AggregatedHealthState | ft -AutoSize
Get-ServiceFabricApplicationHealth fabric:/azure_sf_slacker
Get-ServiceFabricServiceHealth -ServiceName fabric:/azure_sf_slacker/slackpost

# Kill node
Stop-ServiceFabricNode -NodeName "_primary_1" -CommandCompletionMode DoNotVerify
Start-ServiceFabricNode -NodeName "_primary_1" -CommandCompletionMode DoNotVerify

# Upgrade
Copy-ServiceFabricApplicationPackage C:\SF\azure-sf-slacker\azure-sf-slacker\pkg\Debug\ -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore azure_sf_slackerV2

Register-ServiceFabricApplicationType azure_sf_slackerV2

# Cleanup image store
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore azure_sf_slackerV2

Start-ServiceFabricApplicationUpgrade -ApplicationName "fabric:/azure_sf_slacker" -ApplicationTypeVersion 2.0.1 -Monitored -FailureAction Rollback
Start-ServiceFabricApplicationUpgrade -ApplicationName "fabric:/azure_sf_slacker" -ApplicationTypeVersion 2.1.15 -UnmonitoredAuto -UpgradeReplicaSetCheckTimeoutSec 60

Get-ServiceFabricApplicationUpgrade fabric:/azure_sf_slacker

# Cleanup
Remove-ServiceFabricApplication fabric:/azure_sf_slacker
Get-ServiceFabricApplicationType
Unregister-ServiceFabricApplicationType azure_sf_slackerType 2.1.15
Unregister-ServiceFabricApplicationType azure_sf_slackerType 2.1.9

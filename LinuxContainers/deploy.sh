azure servicefabric application package copy SimpleContainerApp fabric:ImageStore
azure servicefabric application type register SimpleContainerApp
azure servicefabric application create fabric:/SimpleContainerApp SimpleContainerApp 1.0
azure servicefabric service create --application-name fabric:/SimpleContainerApp --service-name fabric:/SimpleContainerApp/StatelessBackendService --service-type-name StatelessBackendService --instance-count 5 --service-kind Stateless --partition-scheme Singleton --placement-constraints "NodeType == Backend"
azure servicefabric service create --application-name fabric:/SimpleContainerApp --service-name fabric:/SimpleContainerApp/StatelessFrontendService --service-type-name StatelessFrontendService --instance-count 1 --service-kind Stateless --partition-scheme Singleton --placement-constraints "NodeType == Frontend"

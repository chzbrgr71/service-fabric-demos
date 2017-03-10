## SF for Linux Deployment Commands

git clone https://github.com/chzbrgr71/sf-container.git

```
azure servicefabric application package copy SimpleContainerApp fabric:ImageStore

azure servicefabric application type register SimpleContainerApp

azure servicefabric application create fabric:/SimpleContainerApp SimpleContainerApp 1.0

azure servicefabric service create --application-name fabric:/SimpleContainerApp --service-name fabric:/SimpleContainerApp/StatelessBackendService --service-type-name StatelessBackendService --instance-count 2 --service-kind Stateless --partition-scheme Singleton --placement-constraints "NodeType == backend"

azure servicefabric service create --application-name fabric:/SimpleContainerApp --service-name fabric:/SimpleContainerApp/StatelessFrontendService --service-type-name StatelessFrontendService --instance-count 4 --service-kind Stateless --partition-scheme Singleton --placement-constraints "NodeType == frontend"
```

## Clean-up

```
azure servicefabric service delete fabric:/SimpleContainerApp/StatelessFrontendService

azure servicefabric service delete fabric:/SimpleContainerApp/StatelessBackendService

azure servicefabric application delete fabric:/SimpleContainerApp

azure servicefabric application type unregister SimpleContainerApp 1.0
```
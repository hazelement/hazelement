Title: Kubernetes Basics
Date: 2019-02-21
Modified: 2019-02-21
Tags: Kubernetes
Authors: Harry Zheng
Summary: Basic commands and tools in kubernetes

This article covers some basic commands and instructions to deploy a kubernetes app. Some notes and images are taken from `https://kubernetes.io/docs/tutorials`. 

## Basic concept

### Nodes
A kubernetes **cluster** is consist of **Nodes**. A node can be a VM or a physical machine. 

![Pelican](../images/module_02_cluster.svg)

To check current nodes issue this command:

```
$ kubectl get nodes
NAME                 STATUS    ROLES     AGE       VERSION
docker-for-desktop   Ready     master    30m       v1.10.11
```

Each cluster should have one master node with a 0 or a few slave nodes.

### Pods
A node is consists of one or more **Pods**.  

![Pelican](../images/module_03_nodes.svg)

To get list of running pods, issue this command:

```
$ kubectl get pods
NAME                                   READY     STATUS    RESTARTS   AGE
kubernetes-bootcamp-5c69669756-rmxrn   1/1       Running   0          45m
```

A Pod is a Kubernetes abstraction that represents a group of one or more application containers (such as Docker or rkt), and some shared resources for those containers. Those resources include:

* Shared storage, as Volumes
* Networking, as a unique cluster IP address
* Information about how to run each container, such as the container image version or specific ports to use

![Pelican](../images/module_03_pods.svg)

### Services

A Service in Kubernetes is an abstraction which defines a logical set of Pods and a policy by which to access them. Services enable a loose coupling between dependent Pods. A Service is defined using YAML (preferred) or JSON, like all Kubernetes objects. 

![Pelican](../images/module_04_services.svg)

A Service routes traffic across a set of Pods. Services are the abstraction that allow pods to die and replicate in Kubernetes without impacting your application. Discovery and routing among dependent Pods (such as the frontend and backend components in an application) is handled by Kubernetes Services.

Services match a set of Pods using labels and selectors, a grouping primitive that allows logical operation on objects in Kubernetes. Labels are key/value pairs attached to objects and can be used in any number of ways:

* Designate objects for development, test, and production
* Embed version tags
* Classify an object using tags

![Pelican](../images/module_04_labels.svg)

### Networking

Pods running in side Kubernetes are running on a prviate, isolated network. By default, they are visible from other pods and services within the same cluster, but not outside. To quickly open on communication to outside world, `kubectl` can create a proxy to foward communications, 

`kubectl proxy` will create a proxy at `http://localhost:8001/version`. The API server will automatically create an endpoint for each pod, based on the pod name, that is also accessible through the proxy.

To access each individual pod, we need to get pod name. 
`export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')`. 
Then we can make a HTTP request to the application in that pod. `curl http://localhost:8001/api/v1/namespaces/default/pods/$POD_NAME/proxy/`

## Tutorial

### Make an deployment
Run this commmand to make a new deployment. 
`kubectl run kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1 --port=8080`

Get the name of running pod, `export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')`. 


### Check application configuration
Let’s verify that the application we deployed in the previous scenario is running. We’ll use the kubectl get command and look for existing Pods:

```
$ kubectl get pods
NAME                                   READY     STATUS    RESTARTS   AGE
kubernetes-bootcamp-5c69669756-rmxrn   1/1       Running   0          1h
```

Next, to view what containers are inside that Pod and what images are used to build those containers we run the describe pods command:
`kubectl describe pods`.

### View container logs
Anything that the application would normally send to STDOUT becomes logs for the container within the Pod. We can retrieve these logs using the kubectl logs command:
`kubectl logs $POD_NAME`

Note: We don’t need to specify the container name, because we only have one container inside the pod.

### Executing command on the container
We can execute commands directly on the container once the Pod is up and running. For this, we use the exec command and use the name of the Pod as a parameter. Let’s list the environment variables: 

```
$ kubectl exec $POD_NAME env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=kubernetes-bootcamp-5c69669756-rmxrn
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_PORT_HTTPS=443
NPM_CONFIG_LOGLEVEL=info
NODE_VERSION=6.3.1
HOME=/root
```
Again, worth mentioning that the name of the container itself can be omitted since we only have a single container in the Pod.

Next let’s start a bash session in the Pod’s container: `kubectl exec -ti $POD_NAME bash`.  We have now an open console on the container. To close the console, use `exit`. 

### Create a new service

To list current services in the cluster: 

```
$ kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   1h
```

Cluter services is created by default. 

To create a new service using running pods: `kubectl expose deployment/kubernetes-bootcamp --type="NodePort" --port 8080`

List services again:

```
$ kubectl get services
NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes            ClusterIP   10.96.0.1       <none>        443/TCP          1h
kubernetes-bootcamp   NodePort    10.104.156.85   <none>        8080:30527/TCP   2s
```
Notice that the new service `kubernetes-bootcamp` has a unique cluster-IP `10.104.156.85`, an internal port `30527` and an external port `8080`. 

Try access the end point with `curl 10.104.156.85:8080`. 

### Using labels

The Deployment created automatically a label for our Pod. With describe deployment command you can see the name of the label: `kubectl describe deployment`. 

This label can be used to query list of Pods:

```
$ kubectl get pods -l run=kubernetes-bootcamp
NAME                                   READY     STATUS    RESTARTS   AGE
kubernetes-bootcamp-5c69669756-rmxrn   1/1       Running   0          1h
```

The same can be used on services:
```
$ kubectl get services -l run=kubernetes-bootcamp
NAME                  TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes-bootcamp   NodePort   10.104.156.85   <none>        8080:30527/TCP   24m
```

Get name of the pod: `export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')`

Apply a new label to this pod: `kubectl label pod $POD_NAME app=v1`

And check the pod description: 

```
$ kubectl describe pods $POD_NAME`
Name:           kubernetes-bootcamp-5c69669756-rmxrn
Namespace:      default
Node:           docker-for-desktop/192.168.65.3
Start Time:     Thu, 21 Feb 2019 14:51:05 -0700
Labels:         app=v1
                pod-template-hash=1725225312
                run=kubernetes-bootcamp
...
```

This label can be used to query pods:

```
$ kubectl get pods -l app=v1
NAME                                   READY     STATUS    RESTARTS   AGE
kubernetes-bootcamp-5c69669756-rmxrn   1/1       Running   0          1h
```

### Delete a service

To delete a service, use this command `kubectl delete service -l run=kubernetes-bootcamp`

Confirm the service is gone:

```
$ kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   2h
```

But the pod should still be running:

```
$ kubectl exec -ti $POD_NAME curl localhost:8080
Hello Kubernetes bootcamp! | Running on: kubernetes-bootcamp-5c69669756-rmxrn | v=1
```

### Scaling a service

Scaling is achieved through number of replica in a deployment. Kubernetes also support auto scaling but it's not covered in this part of the tutorial. 

Running multiple instances of an application will require a way to distribute the traffic to all of them. Services have an integrated load-balancer that will distribute network traffic to all Pods of an exposed Deployment. Services will monitor continuously the running Pods using endpoints, to ensure the traffic is sent only to available Pods.

Once you have multiple instances of an Application running, you would be able to do Rolling updates without downtime. 

![Pelican](../images/module_05_scaling1.svg)

![Pelican](../images/module_05_scaling2.svg)

To scale an existing service, use the following commands. 

List running deployments: 
```
$ kubectl get deployments
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
kubernetes-bootcamp   1/1     1            1           37s
```

* The DESIRED state is showing the configured number of replicas.
* The CURRENT state show how many replicas are running now.
* The UP-TO-DATE is the number of replicas that were updated to match the desired (configured) state.

To scale the deployments to replica of 4:
```
$ kubectl scale deployments/kubernetes-bootcamp --replicas=4
deployment.apps/kubernetes-bootcamp scaled
$ kubectl get deployments
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
kubernetes-bootcamp   4/4     4            4           100s
```
We can see the available instances and ready instances are now four. 

Check if number of pods changed:
```
$ kubectl get pods -o wide
NAME                                   READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
kubernetes-bootcamp-6bf84cb898-4jx92   1/1     Running   0          8s    172.18.0.7   minikube   <none>           <none>
kubernetes-bootcamp-6bf84cb898-mm2g5   1/1     Running   0          8s    172.18.0.5   minikube   <none>           <none>
kubernetes-bootcamp-6bf84cb898-rsml8   1/1     Running   0          8s    172.18.0.3   minikube   <none>           <none>
kubernetes-bootcamp-6bf84cb898-wfvkt   1/1     Running   0          8s    172.18.0.6   minikube   <none>           <none>
```
There are 4 pods with different IP now. 

The changes should also register with deployments. 
```
$ kubectl describe deployments/kubernetes-bootcamp
Name:                   kubernetes-bootcamp
Namespace:              default
CreationTimestamp:      Sat, 23 Feb 2019 17:38:57 +0000
Labels:                 run=kubernetes-bootcamp
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               run=kubernetes-bootcamp
Replicas:               4 desired | 4 updated | 4 total | 4 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  run=kubernetes-bootcamp
  Containers:
   kubernetes-bootcamp:
    Image:        gcr.io/google-samples/kubernetes-bootcamp:v1
    Port:         8080/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   kubernetes-bootcamp-6bf84cb898 (4/4 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  73s   deployment-controller  Scaled up replicaset kubernetes-bootcamp-6bf84cb898 to 4
```

### Load balancing

With replica enabled, load balancing should also automatically enable for this service. 

```
$ kubectl describe services/kubernetes-bootcamp
Name:                     kubernetes-bootcamp
Namespace:                default
Labels:                   run=kubernetes-bootcamp
Annotations:              <none>
Selector:                 run=kubernetes-bootcamp
Type:                     NodePort
IP:                       10.97.18.242
Port:                     <unset>  8080/TCP
TargetPort:               8080/TCP
NodePort:                 <unset>  32111/TCP
Endpoints:                172.18.0.3:8080,172.18.0.5:8080,172.18.0.6:8080 +1 more...
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```
There are 4 endpoints on this services, each one is one our the replica. To verify the load balancing is working. Let's make request to this service and each time we should be hitting different pods. 

```
$ export NODE_PORT=$(kubectl get services/kubernetes-bootcamp -o go-template='{{(index .spec.ports 0).nodePort}}')
$ echo NODE_PORT=$NODE_PORT
NODE_PORT=32111
$ curl $(minikube ip):$NODE_PORT
Hello Kubernetes bootcamp! | Running on: kubernetes-bootcamp-6bf84cb898-rsml8 | v=1
$ curl $(minikube ip):$NODE_PORT
Hello Kubernetes bootcamp! | Running on: kubernetes-bootcamp-6bf84cb898-4jx92 | v=1
$ curl $(minikube ip):$NODE_PORT
Hello Kubernetes bootcamp! | Running on: kubernetes-bootcamp-6bf84cb898-wfvkt | v=1
```
As we can see in the `curl` printout. Each time we hit a different pod. 

### Scale down

To scale down the service, issue the same scale command but with a smaller replica number. 
```
$ kubectl scale deployments/kubernetes-bootcamp --replicas=2
deployment.extensions/kubernetes-bootcamp scaled
$ kubectl get deployments
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
kubernetes-bootcamp   2/2     2            2           6m26s
$ kubectl get pods -o wide
NAME                                   READY   STATUS        RESTARTS   AGE    IP           NODE       NOMINATED NODE   READINESS GATES
kubernetes-bootcamp-6bf84cb898-4jx92   1/1     Terminating   0          6m18s   172.18.0.7   minikube   <none>           <none>
kubernetes-bootcamp-6bf84cb898-mm2g5   1/1     Running       0          6m18s   172.18.0.5   minikube   <none>           <none>
kubernetes-bootcamp-6bf84cb898-rsml8   1/1     Running       0          6m18s   172.18.0.3   minikube   <none>           <none>
kubernetes-bootcamp-6bf84cb898-wfvkt   1/1     Terminating   0          6m18s   172.18.0.6   minikube   <none>           <none>
```

This confirms that 2 pods are terminating. 

### Rolling updates
**Rolling updates** allow Deployments' update to take place with zero downtime by incrementally updating Pods instances with new ones. The new Pods will be scheduled on Nodes with available resources.

By default, the maximum number of Pods that can be unavailable during the update and the maximum number of new Pods that can be created, is one. Both options can be configured to either numbers or percentages (of Pods). In Kubernetes, updates are versioned and any Deployments update can be rolled back to previous (stable) version. 

Similar to application Scaling, if a Deployment is exposed publicly, the Service will load-balance the traffic only to available Pods during the update. An available Pod is an instance that is available to the users of the application.

![Pelican](../images/module_06_rollingupdates1.svg)
![Pelican](../images/module_06_rollingupdates2.svg)
![Pelican](../images/module_06_rollingupdates3.svg)
![Pelican](../images/module_06_rollingupdates4.svg)


Rolling updates allow the following actions:

* Promote an application from one environment to another (via container image updates)
* Rollback to previous versions
* Continuous Integration and Continuous Delivery of applications with zero downtime

To roll out an update, follow these steps:

List running deployments:
```
$ kubectl get deployments
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
kubernetes-bootcamp   4/4     4            4           24s
```

List running pods:
```
$ kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
kubernetes-bootcamp-6bf84cb898-dg8zx   1/1     Running   0          25s
kubernetes-bootcamp-6bf84cb898-fzb22   1/1     Running   0          25s
kubernetes-bootcamp-6bf84cb898-mfq7l   1/1     Running   0          25s
kubernetes-bootcamp-6bf84cb898-r8snq   1/1     Running   0          25s
```

To update the image of the application to version 2, use the `set image` command, followed by the deployment name and the new image version:
```
$ kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=jocatalin/kubernetes-bootcamp:v2
deployment.apps/kubernetes-bootcamp image updated
```

The command notified the Deployment to use a different image for your app and initiated a rolling update. Check the status of the new Pods, and view the old one terminating with the `get pods` command:
```
$ kubectl get pods
NAME                                   READY   STATUS        RESTARTS   AGE
kubernetes-bootcamp-5bf4d5689b-4xkmn   1/1     Running       0          10s
kubernetes-bootcamp-5bf4d5689b-hv6qr   1/1     Running       0          10s
kubernetes-bootcamp-5bf4d5689b-jm57j   1/1     Running       0          13s
kubernetes-bootcamp-5bf4d5689b-qvgkz   1/1     Running       0          13s
kubernetes-bootcamp-6bf84cb898-dg8zx   1/1     Terminating   0          83s
kubernetes-bootcamp-6bf84cb898-fzb22   1/1     Terminating   0          83s
kubernetes-bootcamp-6bf84cb898-mfq7l   1/1     Terminating   0          83s
kubernetes-bootcamp-6bf84cb898-r8snq   1/1     Terminating   0          83s
$ kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
kubernetes-bootcamp-5bf4d5689b-4xkmn   1/1     Running   0          43s
kubernetes-bootcamp-5bf4d5689b-hv6qr   1/1     Running   0          43s
kubernetes-bootcamp-5bf4d5689b-jm57j   1/1     Running   0          46s
kubernetes-bootcamp-5bf4d5689b-qvgkz   1/1     Running   0          46s
```

Old instances are replaced with updated instances eventually. 

The update can be confirmed also by running a rollout status command:
```
$ kubectl rollout status deployments/kubernetes-bootcamp
deployment "kubernetes-bootcamp" successfully rolled out
```
To view the current image version of the app, run a describe command against the Pods:
```
kubectl describe pods
```

To roll back an update, let's deploy an update with problems:
```
kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=gcr.io/google-samples/kubernetes-bootcamp:v10
```

And check status:
```
$ kubectl get deployments
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
kubernetes-bootcamp   3/4     2            3           5m29s
$ kubectl get pods
NAME                                   READY   STATUS             RESTARTS AGE
kubernetes-bootcamp-597cfc5b76-cxccd   0/1     ImagePullBackOff   0 69s
kubernetes-bootcamp-597cfc5b76-h6r48   0/1     ErrImagePull       0 69s
kubernetes-bootcamp-5bf4d5689b-4xkmn   1/1     Running            0 4m9s
kubernetes-bootcamp-5bf4d5689b-jm57j   1/1     Running            0 4m12s
kubernetes-bootcamp-5bf4d5689b-qvgkz   1/1     Running            0 4m12s
```
Something is wrong with the updated images. 

To get more insights, use the `describe` command:
```
kubectl describe pods
```

To roll back the update, issue this command:
```
$ kubectl rollout undo deployments/kubernetes-bootcamp
deployment.apps/kubernetes-bootcamp rolled back
```

And we are back to old state:
```
$ kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
kubernetes-bootcamp-5bf4d5689b-4xkmn   1/1     Running   0          5m41s
kubernetes-bootcamp-5bf4d5689b-j6kp4   1/1     Running   0          21s
kubernetes-bootcamp-5bf4d5689b-jm57j   1/1     Running   0          5m44s
kubernetes-bootcamp-5bf4d5689b-qvgkz   1/1     Running   0          5m44s
```


## Kubernetes Commands

* check current version: `kubectl version`
* get cluster info: `kubectl cluster-info`
* list nodes: `kubectl get nodes`
* list pods: `kubectl get pods`
* describe pods: `kubectl describe pods`
* run a deployment: `kubectl run kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1 --port=8080`
* list deployments: `kubectl get deployments`




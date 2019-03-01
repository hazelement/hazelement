Title: Kubernetes Workflow
Date: 2019-03-01
Modified: 2019-03-03
Tags: Kubernetes, CI/CD
Authors: Harry Zheng
Summary: Typical workflow for a kubernetes cluster deployment

This article summarizes the basic workflow when working with a kubernetes cluster

## Basic deployment

### Run a node

To run the node using a an image, run this command 

```
kubectl run hello-world --replicas=5 --labels="run=load-balancer-example" --image=gcr.io/google-samples/node-hello:1.0  --port=8080
```

This will create a `hello-world` `Deployment` object with 5 replicas. 

Display information about the `Deployment`. 
```
kubectl get deployments hello-world
kubectl describe deployments hello-world
```

## Use a service to expose the deployment

Create a service to expose the `Deployment`:

```
kubectl expose deployment hello-world --type=LoadBalancer --name=my-service

```
This will create a `LoadBalance` service that manages the `hello-world` replicas and expose port `8080` to outside world. 

```
kubectl get services my-service
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP      PORT(S)    AGE
my-service   ClusterIP   10.3.245.137   104.198.205.71   8080/TCP   54s
```

Try access the service from outside using. 
```
curl http://<external-ip>:<port>
Hello Kubernetes!
```

# Change deployment replica

To change the number of replicas in the deployment object. use this command:
```
$ kubectl scale deployments/hello-world --replicas=8
deployment.extensions "hello-world" scaled
$ kubectl get deployments
NAME          DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
hello-world   8         8         8            8           15m
$ kubectl get pods
NAME                           READY     STATUS    RESTARTS   AGE
hello-world-5b446dd74b-72jp4   1/1       Running   0          16m
hello-world-5b446dd74b-7xh77   1/1       Running   0          9s
hello-world-5b446dd74b-87hlb   1/1       Running   0          16m
hello-world-5b446dd74b-c4q4t   1/1       Running   0          9s
hello-world-5b446dd74b-jzp9d   1/1       Running   0          16m
hello-world-5b446dd74b-plvrp   1/1       Running   0          9s
hello-world-5b446dd74b-pxg2w   1/1       Running   0          16m
hello-world-5b446dd74b-vrm4r   1/1       Running   0          16m
```

`hello-world` is the pod we are running and it's a `Deployment`, hence `deployments/hello-world`





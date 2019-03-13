Title: Kubernetes Stateless Application
Date: 2019-03-01
Modified: 2019-03-03
Tags: Kubernetes, CI/CD
Authors: Harry Zheng
Summary: Typical workflow for a kubernetes cluster deployment

This article is a summary of the tutorial at `https://kubernetes.io/docs/tutorials/stateless-application/guestbook/`. It utilizes manifest file to create deployments and services. 

A stateless application doesn't save its data to hard drive, thus every time the application is restarted. It returns back to its original state. 

## Objective

This tutorial covers basic steps to setup a guest book in stateless manner. It's a guest book application with redis backend.

1. Start up redis master. 
2. Start up redis slave.
3. Start up guest book front end.
4. Expose and view the Frontend service. 
5. Clean up.

## redis backend service

### Redis master

Create a redis master service has 2 steps.

1. Create redis master deployment
2. Create redis master service based on the deployment in step 1. 

#### Create redis master deployment
To create a redis master deployment, use the following manifest file, `redis-master-deployment.yaml`. 

```
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: redis-master
  labels:
    app: redis
spec:
  selector:
    matchLabels:
      app: redis
      role: master
      tier: backend
  replicas: 1
  template:
    metadata:
      labels:
        app: redis
        role: master
        tier: backend
    spec:
      containers:
      - name: master
        image: k8s.gcr.io/redis:e2e  # or just image: redis
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        ports:
        - containerPort: 6379
```

In terminal, issue this command `kubectl apply -f redis-master-deployment.yaml`. 

Ensure the deployment is running. 

```
$ kubectl get pods
NAME                            READY     STATUS              RESTARTS   AGE
redis-master-55db5f7567-wmrjk   0/1       ContainerCreating   0          8s
```

To view the logs of the master pod:

```
$ kubectl logs -f redis-master-55db5f7567-wmrjk
                _._
           _.-``__ ''-._
      _.-``    `.  `_.  ''-._           Redis 2.8.19 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._
 (    '      ,       .-`  | `,    )     Running in stand alone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 1
  `-._    `-._  `-./  _.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |           http://redis.io
  `-._    `-._`-.__.-'_.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |
  `-._    `-._`-.__.-'_.-'    _.-'
      `-._    `-.__.-'    _.-'
          `-._        _.-'
              `-.__.-'

[1] 13 Mar 20:29:20.725 # Server started, Redis version 2.8.19
[1] 13 Mar 20:29:20.726 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
[1] 13 Mar 20:29:20.726 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
[1] 13 Mar 20:29:20.726 * The server is now ready to accept connections on port 6379
```

#### Create redis master service

For other applications to communicate with redis master, we need to apply a `Service` to proxy the traffic to the redis master pod. Use the following manifest file, `redis-master-service.yaml`, to define a `Service`. 

```
apiVersion: v1
kind: Service
metadata:
  name: redis-master
  labels:
    app: redis
    role: master
    tier: backend
spec:
  ports:
  - port: 6379
    targetPort: 6379
  selector:
    app: redis
    role: master
    tier: backend
```

Start the service using the `apply` method. 
```
kubectl apply -f redis-master-service.yaml
```

Make sure the service is running:
```
$ kubectl get service
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
kubernetes     ClusterIP   10.96.0.1        <none>        443/TCP    19d
redis-master   ClusterIP   10.110.130.106   <none>        6379/TCP   5s

```

#### Create redis slave deployment

To create a redis slave deployment, use the following manifest file, `redis-slave-deployment.yaml`. 

```
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: redis-slave
  labels:
    app: redis
spec:
  selector:
    matchLabels:
      app: redis
      role: slave
      tier: backend
  replicas: 2
  template:
    metadata:
      labels:
        app: redis
        role: slave
        tier: backend
    spec:
      containers:
      - name: slave
        image: gcr.io/google_samples/gb-redisslave:v1
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        env:
        - name: GET_HOSTS_FROM
          value: dns
          # Using `GET_HOSTS_FROM=dns` requires your cluster to
          # provide a dns service. As of Kubernetes 1.3, DNS is a built-in
          # service launched automatically. However, if the cluster you are using
          # does not have a built-in DNS service, you can instead
          # access an environment variable to find the master
          # service's host. To do so, comment out the 'value: dns' line above, and
          # uncomment the line below:
          # value: env
        ports:
        - containerPort: 6379
```

Start up the deployment,

```
kubectl apply -f redis-slave-deployment.yaml
```

Check running pods, 
```
$ kubectl get pods
NAME                            READY     STATUS              RESTARTS   AGE
redis-master-55db5f7567-wmrjk   1/1       Running             0          23m
redis-slave-584c66c5b5-ghrsz    0/1       ContainerCreating   0          5s
redis-slave-584c66c5b5-tpd4l    0/1       ContainerCreating   0          5s

```

#### Create redis slave service

To open up slave deployment for other applications to communicate, we use a `Service` like the master deployment, `redis-slave-service.yaml`. 

```
apiVersion: v1
kind: Service
metadata:
  name: redis-slave
  labels:
    app: redis
    role: slave
    tier: backend
spec:
  ports:
  - port: 6379
  selector:
    app: redis
    role: slave
    tier: backend
```

Start the service, `kubectl apply -f redis-slave-service.yaml`. 

Check running services,

```
$ kubectl get services
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
kubernetes     ClusterIP   10.96.0.1        <none>        443/TCP    19d
redis-master   ClusterIP   10.110.130.106   <none>        6379/TCP   3m
redis-slave    ClusterIP   10.108.183.147   <none>        6379/TCP   7s
```

## PHP guestbook frontend

### Create frontend deployment

To create a deployment, use the manifest file, `frontend-deployment.yaml`. 

```
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: frontend
  labels:
    app: guestbook
spec:
  selector:
    matchLabels:
      app: guestbook
      tier: frontend
  replicas: 3
  template:
    metadata:
      labels:
        app: guestbook
        tier: frontend
    spec:
      containers:
      - name: php-redis
        image: gcr.io/google-samples/gb-frontend:v4
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        env:
        - name: GET_HOSTS_FROM
          value: dns
          # Using `GET_HOSTS_FROM=dns` requires your cluster to
          # provide a dns service. As of Kubernetes 1.3, DNS is a built-in
          # service launched automatically. However, if the cluster you are using
          # does not have a built-in DNS service, you can instead
          # access an environment variable to find the master
          # service's host. To do so, comment out the 'value: dns' line above, and
          # uncomment the line below:
          # value: env
        ports:
        - containerPort: 80
```

Start the deployment, 
```
kubectl apply -f frontend-deployment.yaml
```

Quest the list of pods to verify the frontend replicas are running:

```
$ kubectl get pods -l app=guestbook -l tier=frontend
NAME                        READY     STATUS              RESTARTS   AGE
frontend-5c548f4769-bsjjv   0/1       ContainerCreating   0          9s
frontend-5c548f4769-mjq4h   0/1       ContainerCreating   0          9s
frontend-5c548f4769-sljfb   0/1       ContainerCreating   0          9s
```

### Create frontend service

The `redis-slave` and `redis-master` services are only accessible within the container cluster because default type for a service is CluterIP. `ClusterIP` provides a single IP address for the set of Pods the Service is pointing to. This IP address is accessible only within the cluster.

To allow guests to be able to access the guestbook, we need to configure the frontend service to the external internet. This is achived through `type: NodePort` or `type: LoadBalancer`. We use `LoadBalancer` here as an example. `frontend-service.yaml`. 

```
apiVersion: v1
kind: Service
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  # comment or delete the following line if you want to use a LoadBalancer
  # type: NodePort 
  # if your cluster supports it, uncomment the following to automatically create
  # an external load-balanced IP for the frontend service.
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: guestbook
    tier: frontend
```

Start a the service, 

```
kubectl apply -f frontend-service.yaml
```

List running services to verify, 

```
$ kubectl get services
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
frontend       LoadBalancer    10.100.241.58    localhost        80:31546/TCP   32s
kubernetes     ClusterIP   10.96.0.1        <none>        443/TCP        19d
redis-master   ClusterIP   10.110.130.106   <none>        6379/TCP       6m
redis-slave    ClusterIP   10.108.183.147   <none>        6379/TCP       3m
```


## View the front end

To view the frontend, go to `localhost:80` on the browser and the frontend website should show up. 

## Scale the web frontend

Run the following command to scale up the number of frontend Pods,
```
kubectl scale deployment frontend --replicas=5
```

Query the list of Pods to verify the number of frontend Pods running, 
```
$ kubectl get pods
NAME                            READY     STATUS    RESTARTS   AGE
frontend-3823415956-70qj5       1/1       Running   0          5s
frontend-3823415956-dsvc5       1/1       Running   0          54m
frontend-3823415956-k22zn       1/1       Running   0          54m
frontend-3823415956-w9gbt       1/1       Running   0          54m
frontend-3823415956-x2pld       1/1       Running   0          5s
redis-master-1068406935-3lswp   1/1       Running   0          56m
redis-slave-2005841000-fpvqc    1/1       Running   0          55m
redis-slave-2005841000-phfv9    1/1       Running   0          55m
```

To scale down the number of frontend Pods:
```
kubectl scale deployment frontend --replicas=2
```

To verify,
```
$ kubectl get pods
NAME                            READY     STATUS    RESTARTS   AGE
frontend-3823415956-k22zn       1/1       Running   0          1h
frontend-3823415956-w9gbt       1/1       Running   0          1h
redis-master-1068406935-3lswp   1/1       Running   0          1h
redis-slave-2005841000-fpvqc    1/1       Running   0          1h
redis-slave-2005841000-phfv9    1/1       Running   0          1h
```

## Clean up

Run the following commands to delete all Pods, Deployments and Services, 
```
$ kubectl delete deployment -l app=redis
deployment.extensions "redis-master" deleted
deployment.extensions "redis-slave" deleted
$ kubectl delete service -l app=redis
service "redis-master" deleted
service "redis-slave" deleted
$ kubectl delete deployment -l app=guestbook
deployment.extensions "frontend" deleted
$ kubectl delete service -l app=guestbook
service "frontend" deleted
```

Query the list of Pods to verify all pods are terminated,
```
$ kubectl get pods
No resources found.
```

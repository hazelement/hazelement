Title: Kubernetes Stateful Application
Date: 2019-03-14
Modified: 2019-03-15
Tags: Kubernetes, CI/CD
Authors: Harry Zheng
Summary: Deploy a Kubernetes stateful application

This article is a summary of the [tutorial](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/). It utilizes manifest file to create deployments and services. 

Most of the time, we need to have persistent data saved at a location and when the service is restarted, the data was saved and can be loaded to restore its latest state. This is achived through stateful application in Kubernetes. 

## Objective

This tutorial covers basic steps deploy a simple web application using `StatefulSet`. The website is served in a html file by nginx. 

1. Create a StatefulSet
2. Manage Pods through StatefulSet
3. Delete a StatefulSet
4. Scale a StatefulSet
5. Update a StatefulSet's Pods

## Creating a StatefulSet

Using the `yaml` file below, we create a headless service, `nginx`, to publish the IP addresses of Pods in the StatefulSet, `web`. The manifest file `web.yaml`. 

```
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: k8s.gcr.io/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

In this tutorial, we will use two terminal windows. One uses `kubectl get pods -w -l app=nginx` command to get live update from Kubernetes service about the status of our pods. The other terminal window is used to execute command the deploy, update and delete Pods and StatefulSets. 

In the first terminal window execiute this command to watch the creation of the StatefulSet's Pods. 

```
kubectl get pods -w -l app=nginx
```

In the second terminal, use `kubectl create` to create the headless Service and StatefulSet defined in `web.yaml`.

```
$ kubectl create -f web.yaml
service/nginx created
statefulset.apps/web created
```

Check the running service, 
```
$ kubectl get service nginx
NAME      TYPE         CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
nginx     ClusterIP    None         <none>        80/TCP    12s
```

Check running statefulset
```
$ kubectl get statefulset web
NAME      DESIRED   CURRENT   AGE
web       2         1         20s
```

On the first terminal, we should see the Pods being deployed in action. 
```
$ kubectl get pods -w -l app=nginx
NAME      READY     STATUS    RESTARTS   AGE
web-0     0/1       Pending   0          0s
web-0     0/1       Pending   0         0s
web-0     0/1       ContainerCreating   0         0s
web-0     1/1       Running   0         19s
web-1     0/1       Pending   0         0s
web-1     0/1       Pending   0         0s
web-1     0/1       ContainerCreating   0         0s
web-1     1/1       Running   0         18s
```

## Pods in a StatefulSet

Pods in a StatefulSet have a unique ordinal index and a stable network identity.

### Examping the Pod's Ordinal Index

Get the StatefulSet’s Pods.

```
$ kubectl get pods -l app=nginx
NAME      READY     STATUS    RESTARTS   AGE
web-0     1/1       Running   0          1m
web-1     1/1       Running   0          1m
```

The Pods’ names take the form `<statefulset name>-<ordinal index>`. Since the web StatefulSet has two replicas, it creates two Pods, `web-0` and `web-1`.

Each Pod has a stable hostname based on its ordinal index. 

```
for i in 0 1; do kubectl exec web-$i -- sh -c 'hostname'; done
web-0
web-1

kubectl run -i --tty --image busybox:1.28 dns-test --restart=Never --rm  
nslookup web-0.nginx
Server:    10.0.0.10
Address 1: 10.0.0.10 kube-dns.kube-system.svc.cluster.local

Name:      web-0.nginx
Address 1: 10.244.1.6

nslookup web-1.nginx
Server:    10.0.0.10
Address 1: 10.0.0.10 kube-dns.kube-system.svc.cluster.local

Name:      web-1.nginx
Address 1: 10.244.2.6
```

### Manage Pods in StatefulSet

In second terminal, use `kubectl delete` to delete all Pods in the StatefulSet. 

```
$ kubectl delete pod -l app=nginx
pod "web-0" deleted
pod "web-1" deleted
```
This will delete both pods but StatefulSet will restart then. The process is shown in the first terminal. 

```
$ kubectl get pod -w -l app=nginx
NAME      READY     STATUS              RESTARTS   AGE
web-0     0/1       ContainerCreating   0          0s
NAME      READY     STATUS    RESTARTS   AGE
web-0     1/1       Running   0          2s
web-1     0/1       Pending   0         0s
web-1     0/1       Pending   0         0s
web-1     0/1       ContainerCreating   0         0s
web-1     1/1       Running   0         34s

```

Try print out the hostname again, 

```
for i in 0 1; do kubectl exec web-$i -- sh -c 'hostname'; done
web-0
web-1

kubectl run -i --tty --image busybox dns-test --restart=Never --rm /bin/sh 
nslookup web-0.nginx
Server:    10.0.0.10
Address 1: 10.0.0.10 kube-dns.kube-system.svc.cluster.local

Name:      web-0.nginx
Address 1: 10.244.1.7

nslookup web-1.nginx
Server:    10.0.0.10
Address 1: 10.0.0.10 kube-dns.kube-system.svc.cluster.local

Name:      web-1.nginx
Address 1: 10.244.2.8
```

The hostname persists, but IP addresses associated with the Pods maybe change. This is why it is important not to configure other applications to connect to Pods in a StatefulSet by IP address.

### Writing to stable storage

We will be writing a text to the index page in the persistent volume. 

Get the PersistentVolumeClaims for `web-0` and `web-1`.

```
$ kubectl get pvc -l app=nginx
NAME        STATUS    VOLUME                                     CAPACITY   ACCESSMODES   AGE
www-web-0   Bound     pvc-15c268c7-b507-11e6-932f-42010a800002   1Gi        RWO           48s
www-web-1   Bound     pvc-15c79307-b507-11e6-932f-42010a800002   1Gi   
```

The NGINX webservers, by default, will serve an index file at `/usr/share/nginx/html/index.html`. The `volumeMounts` field in the StatefulSets spec ensures that the `/usr/share/nginx/html `directory is backed by a PersistentVolume.
Write the Pods’ hostnames to their index.html files and verify that the NGINX webservers serve the hostnames.

```
for i in 0 1; do kubectl exec web-$i -- sh -c 'echo $(hostname) > /usr/share/nginx/html/index.html'; done

for i in 0 1; do kubectl exec -it web-$i -- curl localhost; done
web-0
web-1
```

Now let's delete the Pods:
```
$ kubectl delete pod -l app=nginx
pod "web-0" deleted
pod "web-1" deleted
```

StatefulSet will recreate these Pods and mount the same persistent volume onto them. Thus the changes we've written to `index.html` should still be there. 

Check the `index.html` again, 

```
for i in 0 1; do kubectl exec -it web-$i -- curl localhost; done
web-0
web-1
```

## Scaling a StatefulSet

### Scaling up

In terminal 2, user `kubectl scale` to scale the number of replicas to 5. 

```
$ kubectl scale sts web --replicas=5
statefulset.apps/web scaled
```

In terminal 1, this change should show up

```
kubectl get pods -w -l app=nginx
NAME      READY     STATUS    RESTARTS   AGE
web-0     1/1       Running   0          2h
web-1     1/1       Running   0          2h
NAME      READY     STATUS    RESTARTS   AGE
web-2     0/1       Pending   0          0s
web-2     0/1       Pending   0         0s
web-2     0/1       ContainerCreating   0         0s
web-2     1/1       Running   0         19s
web-3     0/1       Pending   0         0s
web-3     0/1       Pending   0         0s
web-3     0/1       ContainerCreating   0         0s
web-3     1/1       Running   0         18s
web-4     0/1       Pending   0         0s
web-4     0/1       Pending   0         0s
web-4     0/1       ContainerCreating   0         0s
web-4     1/1       Running   0         19s
```

### Scaling down

Use `kubectl patch` to scale the StatefulSet back down to three replicas. 

```
$ kubectl patch sts web -p '{"spec":{"replicas":3}}'
statefulset.apps/web patched
```

In temrinal 1, the process should show up. 

```
kubectl get pods -w -l app=nginx
NAME      READY     STATUS              RESTARTS   AGE
web-0     1/1       Running             0          3h
web-1     1/1       Running             0          3h
web-2     1/1       Running             0          55s
web-3     1/1       Running             0          36s
web-4     0/1       ContainerCreating   0          18s
NAME      READY     STATUS    RESTARTS   AGE
web-4     1/1       Running   0          19s
web-4     1/1       Terminating   0         24s
web-4     1/1       Terminating   0         24s
web-3     1/1       Terminating   0         42s
web-3     1/1       Terminating   0         42s
```

But the `PersistenVolumes` mounted to the Pods are not deleted when the StatefulSet's Pods are deleted. This is true when Pod deletion is caused by scaling the StatefulSet down. 

```
$ kubectl get pvc -l app=nginx
NAME        STATUS    VOLUME                                     CAPACITY   ACCESSMODES   AGE
www-web-0   Bound     pvc-15c268c7-b507-11e6-932f-42010a800002   1Gi        RWO           13h
www-web-1   Bound     pvc-15c79307-b507-11e6-932f-42010a800002   1Gi        RWO           13h
www-web-2   Bound     pvc-e1125b27-b508-11e6-932f-42010a800002   1Gi        RWO           13h
www-web-3   Bound     pvc-e1176df6-b508-11e6-932f-42010a800002   1Gi        RWO           13h
www-web-4   Bound     pvc-e11bb5f8-b508-11e6-932f-42010a800002   1Gi   
```


## Updating StatefulSets

The update strategy is determined by the `spec.updateStrategy` field of the StatefulSet API object. This feature can be used to upgrade the container images, resource requests and/or limits, labels, and annotations of the Pods in a StatefulSet. There are two valid update strategies, `RollingUpdate` and `OnDelete`. `RollingUpdate` strategy is the default for StatefulSets. 

### Rollin gupdate

`RollingUpdate` strategy update all Pods in a StatefulSet, in reverse ordinal order, while respecting the StatefulSet guarantees. 

Patch the `web` StatefulSet to apply the strategy, 

```
$ kubectl patch statefulset web -p '{"spec":{"updateStrategy":{"type":"RollingUpdate"}}}'
statefulset.apps/web patched
```

In terminal 2, patch the `web` to change the container image. 

```
$ kubectl patch statefulset web --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":"gcr.io/google_containers/nginx-slim:0.8"}]'
statefulset.apps/web patched
```
 
In terminal 1, the process should be shown,

```
kubectl get po -l app=nginx -w
NAME      READY     STATUS    RESTARTS   AGE
web-0     1/1       Running   0          7m
web-1     1/1       Running   0          7m
web-2     1/1       Running   0          8m
web-2     1/1       Terminating   0         8m
web-2     1/1       Terminating   0         8m
web-2     0/1       Terminating   0         8m
web-2     0/1       Terminating   0         8m
web-2     0/1       Terminating   0         8m
web-2     0/1       Terminating   0         8m
web-2     0/1       Pending   0         0s
web-2     0/1       Pending   0         0s
web-2     0/1       ContainerCreating   0         0s
web-2     1/1       Running   0         19s
web-1     1/1       Terminating   0         8m
web-1     0/1       Terminating   0         8m
web-1     0/1       Terminating   0         8m
web-1     0/1       Terminating   0         8m
web-1     0/1       Pending   0         0s
web-1     0/1       Pending   0         0s
web-1     0/1       ContainerCreating   0         0s
web-1     1/1       Running   0         6s
web-0     1/1       Terminating   0         7m
web-0     1/1       Terminating   0         7m
web-0     0/1       Terminating   0         7m
web-0     0/1       Terminating   0         7m
web-0     0/1       Terminating   0         7m
web-0     0/1       Terminating   0         7m
web-0     0/1       Pending   0         0s
web-0     0/1       Pending   0         0s
web-0     0/1       ContainerCreating   0         0s
web-0     1/1       Running   0         10s
```

From the log, we can confirm that the Pods are updated in reverse ordinal order. The StatefulSet controller terminates each Pod, and waits for it to transition to Running and Ready prior to updating the next Pod. Note that, even though the StatefulSet controller will not proceed to update the next Pod until its ordinal successor is Running and Ready, it will restore any Pod that fails during the update to its current version. Pods that have already received the update will be restored to the updated version, and Pods that have not yet received the update will be restored to the previous version. In this way, the controller attempts to continue to keep the application healthy and the update consistent in the presence of intermittent failures. 

Check the Pods' images:

```
for p in 0 1 2; do kubectl get po web-$p --template '{{range $i, $c := .spec.containers}}{{$c.image}}{{end}}'; echo; done
k8s.gcr.io/nginx-slim:0.8
k8s.gcr.io/nginx-slim:0.8
k8s.gcr.io/nginx-slim:0.8
```

`kubectl rollout status sts/<name>` can also view the status of a rolling update. 

### Staging an update

Staging an update can be achived by using the `partition` parameter of the `RollingUpdate` update strategy. It will keep all of the Pods in the StatefulSet at the current version while allowing mutation to the StatefulSet's `.spec.template`. 

Use the following command to issue the patch. 
```
kubectl patch statefulset web -p '{"spec":{"updateStrategy":{"type":"RollingUpdate","rollingUpdate":{"partition":3}}}}'
statefulset.apps/web patched
```

`"partition":3` covers the first 3 Pods in ordinal order. In this case web-2 is covered. 

Change the container's image, 

```
kubectl patch statefulset web --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":"k8s.gcr.io/nginx-slim:0.7"}]'
statefulset.apps/web patched
```

Delete the Pod in the StatefulSet, 

```
kubectl delete po web-2
pod "web-2" deleted
```

Wait for StatefulSet to restart the Pod. Check the Pod's image again.
 
```
kubectl get po web-2 --template '{{range $i, $c := .spec.containers}}{{$c.image}}{{end}}'
k8s.gcr.io/nginx-slim:0.8
```

Notice that it's still on version `0.8`. StatefulSet controller restored the Pod with its original container. This is because the ordinal of the Pod is less than the `partition` specified by the `updateStrategy`.

### Rolling out a Canary

To roll out a canary to test, we can dcrementing the `partition` number. 

```
$ kubectl patch statefulset web -p '{"spec":{"updateStrategy":{"type":"RollingUpdate","rollingUpdate":{"partition":2}}}}'
statefulset.apps/web patched
```

This will cover `web-0` and `web-1`, `web-2` is no longer covered and will be restarted. Wait for `web-2` to be Running and Ready. 

```
$ kubectl get po -l app=nginx -w
NAME      READY     STATUS              RESTARTS   AGE
web-0     1/1       Running             0          4m
web-1     1/1       Running             0          4m
web-2     0/1       ContainerCreating   0          11s
web-2     1/1       Running   0         18s
```

Check the Pod's container, 

```
kubectl get po web-2 --template '{{range $i, $c := .spec.containers}}{{$c.image}}{{end}}'
k8s.gcr.io/nginx-slim:0.7
```

When you changed the `partition`, the StatefulSet controller automatically updated the `web-2` Pod because the Pod’s ordinal was greater than or equal to the `partition`.

Verify `web-1` is still on version `0.8` by deleting it and wait for StatefulSet to restart it. 

```
kubectl delete po web-1
pod "web-1" deleted
```

Wait for `web-1` Pod to be Running and Ready, 

```
kubectl get po -l app=nginx -w
NAME      READY     STATUS        RESTARTS   AGE
web-0     1/1       Running       0          6m
web-1     0/1       Terminating   0          6m
web-2     1/1       Running       0          2m
web-1     0/1       Terminating   0         6m
web-1     0/1       Terminating   0         6m
web-1     0/1       Terminating   0         6m
web-1     0/1       Pending   0         0s
web-1     0/1       Pending   0         0s
web-1     0/1       ContainerCreating   0         0s
web-1     1/1       Running   0         18s
```

Check the image version, 

```
kubectl get po web-1 --template '{{range $i, $c := .spec.containers}}{{$c.image}}{{end}}'
k8s.gcr.io/nginx-slim:0.8
```

`web-1` was restored to original configuration because the Pod's ordinal was less than the parition. All Pods with an ordinal that is greater than or equial to the partiion will be updated when the Statefulset's `.spec.template` is updated. 

If a Pod that has an ordinal less than the partition is deleted or otherwise terminated, it will be restored to its original configuration.

### Phased roll outs

Now that we've tesd the canary update on web-2, it's time to roll it out to all other Pods. The perform the phased roll out, update the `partition` to `0`. This means none of the Pods are covered under `partition`. 

```
$ kubectl patch statefulset web -p '{"spec":{"updateStrategy":{"type":"RollingUpdate","rollingUpdate":{"partition":0}}}}'
statefulset.apps/web patched
```

Wait for all Pods to be come Running and Ready. 

```
kubectl get po -l app=nginx -w
NAME      READY     STATUS              RESTARTS   AGE
web-0     1/1       Running             0          3m
web-1     0/1       ContainerCreating   0          11s
web-2     1/1       Running             0          2m
web-1     1/1       Running   0         18s
web-0     1/1       Terminating   0         3m
web-0     1/1       Terminating   0         3m
web-0     0/1       Terminating   0         3m
web-0     0/1       Terminating   0         3m
web-0     0/1       Terminating   0         3m
web-0     0/1       Terminating   0         3m
web-0     0/1       Pending   0         0s
web-0     0/1       Pending   0         0s
web-0     0/1       ContainerCreating   0         0s
web-0     1/1       Running   0         3s
```

Check Pod's container image versions. 

```
for p in 0 1 2; do kubectl get po web-$p --template '{{range $i, $c := .spec.containers}}{{$c.image}}{{end}}'; echo; done
k8s.gcr.io/nginx-slim:0.7
k8s.gcr.io/nginx-slim:0.7
k8s.gcr.io/nginx-slim:0.7
```

Now all Pods are updated. 


## Deleting StatefulSets

StatefulSet supports both Non-Cascading and Cascading deletion. In a Non-Cascading Delete, the StatefulSet’s Pods are not deleted when the StatefulSet is deleted. In a Cascading Delete, both the StatefulSet and its Pods are deleted.

### Non-Cascading Delete

Use `kubectl delete` to delete the StatefulSet. Make sure to supply the `--cascade=false` paramter to the command. 

```
$ kubectl delete statefulset web --cascade=false
statefulset.apps "web" deleted
```

Get the Pods, 

```
$ kubectl get pods -l app=nginx
NAME      READY     STATUS    RESTARTS   AGE
web-0     1/1       Running   0          6m
web-1     1/1       Running   0          7m
web-2     1/1       Running   0          5m
```

All Pods are still running but they shouldn't be recreated if deleted as StatefulSet is deleted. 

Delete the first Pod, 

```
$ kubectl delete pod web-0
pod "web-0" deleted
```

List the Pods, 

```
kubectl get pods -l app=nginx
NAME      READY     STATUS    RESTARTS   AGE
web-1     1/1       Running   0          10m
web-2     1/1       Running   0          7m
```

`web-0` is removed for good. 

Now let's restart the StatefulSet, 

```
$ kubectl create -f web.yaml 
statefulset.apps/web created
Error from server (AlreadyExists): error when creating "web.yaml": services "nginx" already exists
```

Examp the output of the `kubectl get`, 

```
$ kubectl get pods -w -l app=nginx
NAME      READY     STATUS    RESTARTS   AGE
web-1     1/1       Running   0          16m
web-2     1/1       Running   0          2m
NAME      READY     STATUS    RESTARTS   AGE
web-0     0/1       Pending   0          0s
web-0     0/1       Pending   0         0s
web-0     0/1       ContainerCreating   0         0s
web-0     1/1       Running   0         18s
web-2     1/1       Terminating   0         3m
web-2     0/1       Terminating   0         3m
web-2     0/1       Terminating   0         3m
web-2     0/1       Terminating   0         3m
```

The manifest requested replica of 2. `web-0` was removed before, thus recreated. `web-1` exists and is adopted. `web-2` is beyond the replica 2 and is terminated. 

```
for i in 0 1; do kubectl exec -it web-$i -- curl localhost; done
web-0
web-1
```

Notice the hostname in `index.html` still persists. 

### Cascade delete

Use the same delete command but without `--cascade=false`. 

```
$ kubectl delete statefulset web
statefulset.apps "web" deleted
```

Examp the output of `kubectl get pods -w -l app=nginx`, 

```
kubectl get pods -w -l app=nginx
NAME      READY     STATUS    RESTARTS   AGE
web-0     1/1       Running   0          11m
web-1     1/1       Running   0          27m
NAME      READY     STATUS        RESTARTS   AGE
web-0     1/1       Terminating   0          12m
web-1     1/1       Terminating   0         29m
web-0     0/1       Terminating   0         12m
web-0     0/1       Terminating   0         12m
web-0     0/1       Terminating   0         12m
web-1     0/1       Terminating   0         29m
web-1     0/1       Terminating   0         29m
web-1     0/1       Terminating   0         29m
```

The Pods are deleted one at a time, with respect to the reverse order of their ordinal indices. 

Note that, cascading delete will delete the StatefulSet and its Pods, it will not delete the headless Service associated with the StatefulSet. We need to delete the `nginx` Service manually. 

```
$ kubectl delete service nginx
service "nginx" deleted
```

## Pod management policy

For some distributed systems, the StatefulSet ordering guarantees are unnecessary and/or undesierable. This can be changed using `.spec.podManagementPolicy` in the StatefulSet API object. 

### OrderedReady Pod Management

`OrderedReady` pod management is the default for StatefulSets. It tells the StatefulSet controller to respect the ordering guarantees demonstrated above.

### Parallel Pod Management

`Parallel` pod management tells the StatefulSet controller to launch or terminate all Pods in parallel, and not to wait for Pods to become Running and Ready or completely terminated prior to launching or terminating another Pod.

For example, 

```
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"
  podManagementPolicy: "Parallel"
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: k8s.gcr.io/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

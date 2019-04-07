Title: Kubernetes Persistent Volume
Date: 2019-03-25
Modified: 2019-03-25
Tags: Kubernetes
Authors: Harry Zheng
Summary: Deploying WordPress and MySQL with Persistent Volumes

This article is a summary of the [tutorial](https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/). It utilizes manifest file to create deployments and services. 

## Objectives

In this tutorial, we will deploy a WordPress and MySQL service using persistent volumes for data storage.  

A **PersistentVolume (PV)** is a piece of storage in the cluster that has been manually provisioned by an administrator, or dynamically provisioned by Kubernetes using a **StorageClass**. A **PersistentVolumeClaim** (PVC) is a request for storage by a user that can be fulfilled by a PV. PersistentVolumes and PersistentVolumeClaims are independent from Pod lifecycles and preserve data through restarting, rescheduling, and even deleting Pods.

## Create PersistentVolumeClaims and PersistentVolumes


MySQL and Wordpress each require a PersistentVolume to store data. Their PersistentVolumeClaims will be created at the deployment step.

Many cluster environments have a default StorageClass installed. When a StorageClass is not specified in the PersistentVolumeClaim, the cluster’s default StorageClass is used instead.

When a PersistentVolumeClaim is created, a PersistentVolume is dynamically provisioned based on the StorageClass configuration.

## Create a Secret for MySQL Password

A **Secret** is an object that stores a piece of senstive information like a password or a key. Once a **Secret** is created, it can be refer to in manifest files like an environment variable. 

Create a Secret object using the following command, replacing **YOUR_PASSWORD** with your own password. 
```
kubectl create secret generic mysql-pass --from-literal=password=YOUR_PASSWORD
```

This creates a `mysql-pass` object with key value pair `password` and `YOUR_PASSWORD`. 

Verify the Secret exists using the following command, 
```
$ kubectl get secrets
NAME                  TYPE                    DATA      AGE
mysql-pass            Opaque                  1         42s
```

Notice that the content is not shown. 

## Deploy MySQl

The following manifest, `mysql-deployment.yaml`, describes a single-instance MySQL Deployment. The MySQL container mounts the PersistentVolume at /var/lib/mysql. The **MYSQL_ROOT_PASSWORD** environment variable sets the database password from the Secret.

```
apiVersion: v1
kind: Service
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  ports:
    - port: 3306
  selector:
    app: wordpress
    tier: mysql
  clusterIP: None
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
  labels:
    app: wordpress
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
---
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: mysql
    spec:
      containers:
      - image: mysql:5.6
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass  # Secret object
              key: password  # key value pair value
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim
```

Deploy MySQL using the yaml file, 
```
$ kubectl create -f mysql-deployment.yaml
```

Verify that a PersistentVolume got dynamically provisioned,
```
$ kubectl get pvc
NAME             STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mysql-pv-claim   Bound     pvc-9ac5609d-4f32-11e9-9123-025000000001   20Gi       RWO            hostpath       8s
```

Verify pods is running,
```
$ kubectl get pods
NAME                              READY     STATUS    RESTARTS   AGE
wordpress-mysql-bcc89f687-b5vb2   1/1       Running   0          1m
```

## Deploy WordPress

The following manifest file, `wordpress-deployment.yaml`, describes a single-instance WordPress Deployment and Service. It uses PVC for persistent storage and a Secret for password. It also use `type: LoadBalancer`. This setting exposes WordPress to traffic from outside of the cluter. 

```
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  ports:
    - port: 80
  selector:
    app: wordpress
    tier: frontend
  type: LoadBalancer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wp-pv-claim
  labels:
    app: wordpress
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
---
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: frontend
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: frontend
    spec:
      containers:
      - image: wordpress:4.8-apache
        name: wordpress
        env:
        - name: WORDPRESS_DB_HOST
          value: wordpress-mysql
        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password
        ports:
        - containerPort: 80
          name: wordpress
        volumeMounts:
        - name: wordpress-persistent-storage
          mountPath: /var/www/html
      volumes:
      - name: wordpress-persistent-storage
        persistentVolumeClaim:
          claimName: wp-pv-claim
```

Create a WordPress Service and Deployment form the file `wordpress-deployment.yaml` file, 
```
kubectl create -f wordpress-deployment.yaml
```

Verify that a PersistentVolume got dynamically provisioned, 
```
$ kubectl get pvc
NAME             STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mysql-pv-claim   Bound     pvc-9ac5609d-4f32-11e9-9123-025000000001   20Gi       RWO            hostpath       8m
wp-pv-claim      Bound     pvc-cf4a8bdc-4f33-11e9-9123-025000000001   20Gi       RWO            hostpath       12s
```

Verify that Service is running, 

```
$ kubectl get services wordpress
NAME        TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
wordpress   LoadBalancer   10.110.116.160   localhost     80:31111/TCP   50s
```

Check `localhost` on the browser and a WordPress page should show up. 


## Cleaning up

1. Run the following command to delete Secret, `kubectl delete secret mysql-pass`
2. Run following command to delete all Deployments and Services, `kubectl delete deployment -l app=wordpress; kubectl delete service -l app=wordpress`
3. Run the following commands to delete the PersistentVolumeClaims. `kubectl delete pvc -l app=wordpress`






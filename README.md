# Hortonworks Hadoop cluster deployment with Kubernetes

_The point is to get the Hadoop cluster with needed components,_
                       _running as docker container at Kubernetes cluster._

Files: [`Dockerfile`](/Dockerfile)
       [`ambari.repo`](/ambari.repo)
       [`bp.json`](/bp.json)
       [`map.json`](/map.json)
       [`start.sh`](/start.sh)
must be placed at accessible from hub.docker.com git repository.

## 1. Create Docker Automated Build.
#### 1.1 Register at hub.docker.com and link your account to your git repository while creating Automated Build
Register at hub.docker.com and link account to github, ![Link Account to your github](/imgs/link_account.png) Create Automated Build, setting git repo [smaryn/hdpkub](https://github.com/smaryn/hdpkub.git) as a "Source Repository" ![Create Automated Build](/imgs/create_automated_build.png)

#### 1.2 Go to the "Build Settings" tab and click "Trigger" button to run docker image building.
![Trigger](/imgs/trigger.png)
The build may take a while and should be finished successfully,
you can always check the build status at Build Details tab ![Build Details](/imgs/build_details.png)

## 2. Prepare `kubectl` utility to be able to connect to Kubeletes master (198.18.8.161):
####  2.1 Download `kubectl` binary file from corresponding resource and place it somewhere in the $PATH:

##### For Linux workstation:
```bash
wget -c https://storage.googleapis.com/kubernetes-release/release/v1.1.8/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl
```

##### For Mac OS X workstation:
```bash
wget -c https://storage.googleapis.com/kubernetes-release/release/v1.1.8/bin/darwin/amd64/kubectl -O /usr/local/bin/kubectl
```

####  2.2 Configure `kubectl` utility:

##### Set Kubeletes cluster:
```bash
kubectl config set-cluster ubuntu --server=http://198.18.8.161:8080 --insecure-skip-tls-verify=true
```

##### Set context:
```bash
kubectl config set-context ubuntu --cluster=ubuntu --user=ubuntu
```

##### Add user for created cluster and password:
```bash
kubectl config set-credentials ubuntu --username=admin --password=HAKlQaGHHmU6W0W
```

##### Inform kubectl to use desired context:
```bash
kubectl config use-context ubuntu
```

##### Check kubectl configuration:
```bash
kubectl config view
```
##### Check connection to configured cluster:
```bash
kubectl get nodes
```


## 3. Kubernetes pod and service by prepared yaml files

#### 3.1 Create Kubernetes pod for Hadoop container(s) using [hdp.yaml](/kube/hdp.yaml):
```bash
kubectl create -f kube/hdp.yaml
```
#### 3.2 Create Kubernetes service for Hadoop using [hdp-service.yaml](/kube/hdp-service.yaml)
##### At this stage in the command output you should notice the TCP port which is assigned for Ambari server management:
```bash
kubectl create -f kube/hdp-service.yaml
```
##### 3.3 Check created service status:
```bash
kubectl logs hdpkub
```

#### 3.4 Check cluster deployment
##### Connect to Ambari Management Console
Open web browser and type Kubernetes node IP address and TCP port noticed at 2.3 stage.
Use default username and password (admin) to see how cluster is deployed. ![deployed](/imgs/cluster_deployed.png)


## 3. Cluster termination and Kubernetes pod and service removal

#### 3.1 Delete Kubernetes service:
```bash
kubectl delete -f kube/hdp-service.yaml
```
#### 3.2 Delete Kubernetes pod:
```bash
kubectl delete -f kube/hdp.yaml
```
##### 3.3 Obtain the root shell at the Kubernetes node and remove unused Docker containers and images
List all containers:
```bash
docker ps -a
```
Delete unused containers by ID:
```bash
docker rm -f <ID1> <ID2> <...>
```
List all images:
```bash
docker images
```
Delete uneeded images by ID:
```bash
docker rmi -f <ID1> <ID2> <...>
```

# Amazon Elastic Kubernetes Service (Amazon EKS)
This guide include support/references to run the WDIAS with using [Amazon EKS](https://aws.amazon.com/eks/).

IMPORTANT: (31-08-2019) At the time, EKS is charging for EKS Control Plane in hourly basis. Which is free for Google Kubernetes Engine (GKE) and DigitalOcean Kebenetes.

NOTE: If you are new to Kubernetes, [Introduction to Kubernetes](https://www.edx.org/course/introduction-to-kubernetes) course will give you better overview about Kubernetes and using it.

## Amazon EKS Clusters
In Kubernetes, it consist of two parts;
1. Kubernetes master setup which controls the Kubernetes cluster
2. Kubernetes worker nodes where actual work is happening (containers are running)

In the [Amazon EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/clusters.html), Kubernetes master nodes are running in a cluster which is handling by Amazon.
And the Kubernetes API is exposed via the Amazon EKS endpoint associated with your cluster.
The worker nodes run in your AWS account and connect to your cluster's control plane via the API server endpoint and a certificate file that is created for your cluster.

Otherthan using Amazon EKS, you can setup your own cluster using EC2 instances and setup Kubernetes on [top of that](https://aws.amazon.com/kubernetes/).

## Setup Amazno EKS
As it mentioned [here](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html), there're two options to setup a Amazon EKS cluster.
1. Using [eksctl](https://eksctl.io)
2. Using AWS Management Console

In this setup, we're using `eksctl` due to easy setup the cluster. Follow ["Getting Started with eksctl"](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)

#### Install the Latest AWS CLI
On MacOS using homebrew package manager, python2 is the default version. Thus here using a [Virtual Envirnment](https://docs.aws.amazon.com/cli/latest/userguide/install-virtualenv.html) to use python3.
If you're using a Virtual Envirnment, then don't need to add `--user` option while pip install.
`pip install --upgrade awscli`

#### Configure Your AWS CLI Credentials
- Create a user account for access the AWS cli (since using root it not a best practice), by following [Creating Your First IAM Admin User and Group](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html).
- Then configure AWS cli by generating Access Key and Secret Access Key by following [Quickly Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration).
  - While choosing the region may be better to attend [few other factor](https://www.concurrencylabs.com/blog/choose-your-aws-region-wisely/).
  - Then choose the region based on [Region name](https://docs.aws.amazon.com/general/latest/gr/rande.html#apigateway_region).
  - E.g. US East (N. Virginia)	-> `us-east-1`

#### Install eksctl
- `brew tap weaveworks/tap`
- `brew install weaveworks/tap/eksctl`
- Check `eksctl version && kubectl version --short --client` (You must use a `kubectl` version that is within [one minor version difference](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html) of your Amazon EKS cluster control plane.)

#### Create Your Amazon EKS Cluster and Worker Nodes
1. More info `eksctl create cluster --help` or [eksctl docs](https://eksctl.io/usage/creating-and-managing-clusters/)
```
eksctl create cluster \
--name prod \
--version 1.13 \
--nodegroup-name standard-workers \
--node-type t3.medium \
--nodes 3 \
--nodes-min 1 \
--nodes-max 4 \
--node-ami auto
```
Or using config yaml file. (Example config files [/examples](https://github.com/weaveworks/eksctl/tree/master/examples) )
`eksctl create cluster -f eks/simple-cluster.yaml`

2. Cluster provisioning usually takes between 10 and 15 minutes.
    - Check `kubectl get svc`

3. [Delete EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/delete-cluster.html)
    1. `kubectl get svc --all-namespaces`
    2. `kubectl delete svc <service-name>` Delete any services that have an associated EXTERNAL-IP value.
    3. `eksctl delete cluster --wait --name <cluster-name`
    Or if you used config file
    `eksctl delete cluster --wait -f eks/simple-cluster.yaml`

## Worker Nodes
See more details on [Managing nodegroups](https://eksctl.io/usage/managing-nodegroups/).

Details on [Amazon Instance Types](https://aws.amazon.com/ec2/instance-types/)

More nodegroups:
- `eksctl create cluster -f eks/simple-cluster.yaml`
- `eksctl create cluster -f eks/spot-cluster.yaml`

### Managing nodegroups helpers
- Listing nodegroups
```bash
eksctl get nodegroup --cluster=wdias-cluster -r us-east-2
eksctl get nodegroup --cluster=wdias-cluster -r us-east-2 --name=ng-core
```
- Scaling nodegroup
```bash
eksctl scale nodegroup --cluster=wdias-cluster -r us-east-2  --nodes=<desiredCount> --name=ng-core
```
- Add new nodegroup
```
eksctl create nodegroup -f eks/wdias-cluster.yaml -r us-east-2 --include=ng-grid,ng-test
```
- Delete nodegrups
```
eksctl delete nodegroup --cluster=wdias-cluster -r us-east-2 --name=ng-core
eksctl delete nodegroup -f eks/wdias-cluster.yaml --include=ng-grid,ng-test --approve
```
- Update nodegroup labels
```
kubectl label nodes -l alpha.eksctl.io/nodegroup-name=ng-1 new-label=foo
(-) eksctl set labels --cluster managed-cluster --nodegroup managed-ng-1 --labels kubernetes.io/managed-by=eks,kubernetes.io/role=worker # https://eksctl.io/usage/eks-managed-nodegroups/#managing-labels
```
- Node volume types: gp2, io1
  - Types: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html
  - Pricing: https://aws.amazon.com/ebs/pricing/

## Using Helm with Amazon EKS
Setup details [Helm with EKS](https://docs.aws.amazon.com/eks/latest/userguide/helm.html).

Before you can install Helm charts on your Amazon EKS cluster, you must configure kubectl to work for Amazon EKS.
- [To create your kubeconfig file with the AWS CLI](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html)
    - [Accessing Multiple Clusters](https://kubectl.docs.kubernetes.io/pages/app_composition_and_deployment/accessing_multiple_clusters.html)
    - [Kubernetes configures kubeconfig to access multiple clusters](https://programmer.help/blogs/kubernetes-configures-kubeconfig-to-access-multiple-clusters.html)
    ```
    kubectl config use-context docker-for-desktop
    kubectl config use-context kubernetes-admin@kubernetes
    ```

### To run helm and tiller locally
- Install Helm on MacOS - `brew install kubernetes-helm`
- Linux - Downlaod from https://helm.sh/docs/install/#from-canary-builds and extract binaries

Repeat when you want to use Helm with the cluster
1. `kubectl create namespace tiller`
For the following steps, you need a terminal window for the `tiller server` and another window for the `helm client`.
2. Open a new terminal window for the tiller server.
    - Check `users` info
3. Start tiller server with `TILLER_NAMESPACE` env
    - `export TILLER_NAMESPACE=tiller`
    - `tiller -listen=localhost:44134 -storage=secret -logtostderr`
4. In the helm client terminal window;
    - `export HELM_HOST=:44134`
5. `helm init --client-only`
6. Verify: `helm repo update`
7. Run Helm chart commands.
8. When you're finished, close your helm client and tiller server terminal windows. Repeat this procedure when you want to use helm with your cluster.

**Summary**:
- On server terminal
```sh
kubectl create namespace tiller && \
export TILLER_NAMESPACE=tiller && \
tiller -listen=localhost:44134 -storage=secret -logtostderr
```
- on client terminal
```sh
export HELM_HOST=:44134 && \
helm init --client-only && \
helm repo update
```


Direct install tiller on the cluster.
```
helm init
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=default:default
# kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
helm reset --force
```
Some reference:
- https://github.com/helm/helm/issues/3130#issuecomment-407866634. Not give above directly.
- https://github.com/helm/helm/blob/master/docs/rbac.md#example-deploy-tiller-in-a-namespace-restricted-to-deploying-resources-in-another-namespace

## Install metrics-server
- Install `curl` and `jq`
- Run following command;
```
DOWNLOAD_URL=$(curl --silent "https://api.github.com/repos/kubernetes-incubator/metrics-server/releases/latest" | jq -r .tarball_url)
DOWNLOAD_VERSION=$(grep -o '[^/v]*$' <<< $DOWNLOAD_URL)
curl -Ls $DOWNLOAD_URL -o metrics-server-$DOWNLOAD_VERSION.tar.gz
mkdir metrics-server-$DOWNLOAD_VERSION
tar -xzf metrics-server-$DOWNLOAD_VERSION.tar.gz --directory metrics-server-$DOWNLOAD_VERSION --strip-components 1
kubectl apply -f metrics-server-$DOWNLOAD_VERSION/deploy/1.8+/
```

## Ingress Setup
[EKS Workshop](https://eksworkshop.com)

## Troubleshooting
1. Unable to create new stack due to previous stack failed
  - `creating CloudFormation stack "eksctl-simple-cluster-cluster": AlreadyExistsException: Stack [eksctl-simple-cluster-cluster] already exists`
  - `unable to describe cluster control plane: unable to describe cluster control plane: ResourceNotFoundException: No cluster found for name:`
  - Solution: https://aws.amazon.com/premiumsupport/knowledge-center/ecs-cluster-delete-failure-stack/

2. InfluxDB installation issue
  - Error: run: write-buffer-size must be greater than 0. To generate a valid configuration file run `influxd config > influxdb.generated.conf`
  - As mentioned here, it's due to [Helm code base issue](https://github.com/helm/charts/issues/18418#issuecomment-547846211)
  - In order to fix the issue, install Helm version greater than 2.15.1. E.g. https://github.com/helm/helm/releases/tag/v2.16.1
  - `curl --location "https://get.helm.sh/helm-v2.16.1-linux-amd64.tar.gz" | tar xz -C bin`

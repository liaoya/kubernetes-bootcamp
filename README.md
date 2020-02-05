# README

Run `kubernetes-bootcamp` with `MicroK8s` on Ubuntu 18.04.
The origin page is <https://kubernetes.io/docs/tutorials/kubernetes-basics/>.
It use `node:6.14.2` as base image, it's too bigger, see <https://kubernetes.io/docs/tutorials/hello-minikube/>

## Setup Ubuntu 18.04

```bash
sudo snap install microk8s
sudo microk8s.enable registry
sudo apt install -q -y docker.io
```

`/etc/docker/daemon.json` is like the following

```json
{
  "registry-mirrors": [
    "https://dockerhub.azk8s.cn"
  ],
  "insecure-registries": [
    "localhost:32000"
  ]
}
```

## docker-compose

```bash
docker-compose up -d --build
curl -sL http://localhost:8080
docker-compose logs node
```

## MicroK8s

Build and push images to MicroK8s’ built-in registry

```bash
bash build.sh
docker push localhost:32000/samples/kubernetes-bootcamp:v1
docker push localhost:32000/samples/kubernetes-bootcamp:v2
```

### Module 2

```bash
kubectl create deployment kubernetes-bootcamp --image=localhost:32000/samples/kubernetes-bootcamp:v1
```

Setup proxy

```bash
echo -e "\n\n\n\e[92mStarting Proxy. After starting it will not output a response. Please click the first Terminal Tab\n"; kubectl proxy
```

Access the API server

```bash
curl http://localhost:8001/version
export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
echo Name of the Pod: $POD_NAME
```

### Module 3 - Explore your app

Setup proxy

```bash
echo -e "\n\n\n\e[92mStarting Proxy. After starting it will not output a response. Please click the first Terminal Tab\n"; kubectl proxy
```

```bash
export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
echo Name of the Pod: $POD_NAME
curl http://localhost:8001/api/v1/namespaces/default/pods/$POD_NAME/proxy/
```

### Module 4 - Expose your app publicly

```bash
kubectl get services
kubectl expose deployment/kubernetes-bootcamp --type="NodePort" --port 8080
kubectl get services

kubectl describe services/kubernetes-bootcamp
NODE_PORT=$(kubectl get services/kubernetes-bootcamp -o go-template='{{(index .spec.ports 0).nodePort}}')
echo NODE_PORT=$NODE_PORT
curl http://localhost:${NODE_PORT}

kubectl describe deployment
kubectl get pods -l run=kubernetes-bootcamp
kubectl get services -l run=kubernetes-bootcamp

# Add a new label to pod
POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
echo Name of the Pod: $POD_NAME
kubectl label pod $POD_NAME app=v1
kubectl describe pods $POD_NAME
kubectl get pods -l app=v1
```

### Module 5 - Scale up your app

```bash
# Step 1: Scaling a deployment
kubectl get deployments
kubectl get rs
kubectl scale deployments/kubernetes-bootcamp --replicas=4
kubectl get deployments
kubectl get pods -o wide
kubectl describe deployments/kubernetes-bootcamp

# Step 2: Load Balancing
NODE_PORT=$(kubectl get services/kubernetes-bootcamp -o go-template='{{(index .spec.ports 0).nodePort}}')
for itr in $(seq 1 20); do curl http://localhost:${NODE_PORT}; done

# Step 3: Scale Down
kubectl scale deployments/kubernetes-bootcamp --replicas=2
kubectl get deployments
kubectl get pods -o wide
```

### Module 6 - Update your app

```bash
# Step 1: Update the version of the app
kubectl get deployments
kubectl get pods
kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=localhost:32000/samples/kubernetes-bootcamp:v2

# Step 2: Verify an update
kubectl describe services/kubernetes-bootcamp
NODE_PORT=$(kubectl get services/kubernetes-bootcamp -o go-template='{{(index .spec.ports 0).nodePort}}')
curl http://localhost:${NODE_PORT}
kubectl rollout status deployments/kubernetes-bootcamp
kubectl describe pods

# Step 3: Rollback an update
kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=localhost:32000/samples/kubernetes-bootcamp:v10
kubectl get deployments
kubectl get pods
kubectl describe pods
kubectl rollout undo deployments/kubernetes-bootcamp
kubectl get pods
kubectl describe pods
```

# Commands

## Prepare working environment

```bash
# Change to your lastname, for composed names use "-" instead of space, ex EL KHAYALI -> el-khayali
export USER_NAME="<your-lastname-in-lowercase>"
export EKS_NAMESPACE=formation-$USER_NAME
cd ~/davidson-kubernetes-workshop
```

## TP 0 : Accessing your namespace

```bash
kubectl get namespace $EKS_NAMESPACE
# # Expected output
# NAME                STATUS   AGE
# formation-oussama   Active   5m20s

kubectl describe namespace $EKS_NAMESPACE
```

## TP 1.0: Deploy a simple pod

- Replace the environment variables with their corresponding values in this file : [demo-app-pod.yaml](tp/1.0/demo-app-pod.yaml)

- Apply the configuration

```bash

envsubst < <(cat tp/1.0/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -

# 1- Check if pod has been created
kubectl get pods -n $EKS_NAMESPACE
## Example expected output (Wait for the STATUS to become running ...)
# NAME      READY   STATUS    RESTARTS   AGE
# oussama   1/1     Running   0          43s

# 2- Check pod logs, you may need to wait for the application to start before logs become visible.
kubectl logs -n $EKS_NAMESPACE $USER_NAME
## Example expected output
# INFO:root:Starting the application on host oussama
#  * Serving Flask app 'app'
#  * Debug mode: off
# ...

# 3- Delete the pod
kubectl delete pod -n $EKS_NAMESPACE $USER_NAME
## Example expected output
# pod "oussama" deleted
```

## TP 2.0: Automate Pod Deployment

```bash
envsubst < <(cat tp/2.0/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -

# 1- Check deployment creation/status
kubectl get deployment -n $EKS_NAMESPACE
## Example expected output
# NAME      READY   UP-TO-DATE   AVAILABLE   AGE
# oussama   2/2     2            2           19s

# 2- Check pods created by deployment
# We filter pods created by our Deployment using the "app" label
kubectl get pods -n $EKS_NAMESPACE -l app=$USER_NAME
## Example expected output
# NAME                       READY   STATUS    RESTARTS   AGE
# oussama-8674cb9755-fwnw2   1/1     Running   0          56s
# oussama-8674cb9755-lbzf5   1/1     Running   0          56s
```
- Access My Application (Port forward)
```bash
kubectl port-forward -n $EKS_NAMESPACE deploy/$USER_NAME 8080:8080
```

- Now you application should be ready in http://localhost:8080


## TP 2.1: Adding probes

```bash
envsubst < <(cat tp/2.1/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -

# 1- Select one of our deployment's pod
export POD_NAME=$(kubectl get pods -n $EKS_NAMESPACE --selector=app=$USER_NAME -o jsonpath='{.items[0].metadata.name}') && echo $POD_NAME

# 2- Check Pod logs
kubectl logs -n $EKS_NAMESPACE $POD_NAME
# INFO:werkzeug:10.226.146.219 - - [30/Jan/2024 10:43:27] "GET /health HTTP/1.1" 200 -
# INFO:werkzeug:10.226.146.219 - - [30/Jan/2024 10:43:27] "GET /health-degraded HTTP/1.1" 200 -
# INFO:werkzeug:10.226.146.219 - - [30/Jan/2024 10:43:32] "GET /health-degraded HTTP/1.1" 200 -
# INFO:werkzeug:10.226.146.219 - - [30/Jan/2024 10:43:32] "GET /health HTTP/1.1" 200 -
```

## TP 2.2: A failing Liveness

```bash
envsubst < <(cat tp/2.2/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -

# 1- Check pods status
kubectl get pods -n $EKS_NAMESPACE -l app=$USER_NAME
## Expected output
# oussama-778d99c995-j5gw5   1/1     Running   0             68s
# oussama-778d99c995-v5skj   0/1     Running   1 (13s ago)   84s

# 2- Select one of our deployment's pod
export POD_NAME=$(kubectl get pods -n $EKS_NAMESPACE --selector=app=$USER_NAME -o jsonpath='{.items[0].metadata.name}') && echo $POD_NAME
## Expected output
# oussama-778d99c995-j5gw5

# 3- Check events
kubectl get events --field-selector involvedObject.name=$POD_NAME -n $EKS_NAMESPACE | grep Liveness
# 2m22s       Warning   Unhealthy   pod/oussama-778d99c995-j5gw5   Liveness probe failed: Get "http://10.0.1.148:8080/health-degraded": dial tcp 10.0.1.148:8080: connect: connection refused
# 112s        Warning   Unhealthy   pod/oussama-778d99c995-j5gw5   Liveness probe failed: HTTP probe failed with statuscode: 500

```

## TP 2.3: A failing Readiness

```bash
envsubst < <(cat tp/2.3/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -

# 1- Check pods status
kubectl get pods -n $EKS_NAMESPACE -l app=$USER_NAME
# NAME                      READY   STATUS    RESTARTS   AGE
# z18oelkh-bbfcb8cd-2gkz8   1/1     Running   0          6m8s
# z18oelkh-bbfcb8cd-c5mcd   1/1     Running   0          6m28s

# 2- Select one of our deployment's pod
export POD_NAME=$(kubectl get pods -n $EKS_NAMESPACE --selector=app=$USER_NAME -o jsonpath='{.items[0].metadata.name}') && echo $POD_NAME
## Expected output
# oussama-7588767d9f-djfgf

# 3- Check events
kubectl get events --field-selector involvedObject.name=$POD_NAME -n $EKS_NAMESPACE | grep Readiness
## Expected output
# 4m45s       Warning   Unhealthy   pod/oussama-7588767d9f-djfgf   Readiness probe failed: Get "http://10.0.1.247:8080/health-degraded": dial tcp 10.0.1.247:8080: connect: connection refused
# 4m          Warning   Unhealthy   pod/oussama-7588767d9f-djfgf   Readiness probe failed: HTTP probe failed with statuscode: 500
```
## TP 3.0: Expose your application

```bash
envsubst < <(cat tp/3.0/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -
```

### Service

```bash
# 1- Get the service
kubectl get service $USER_NAME -n $EKS_NAMESPACE
## Example expected output
# NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
# el-khayali   ClusterIP   172.20.42.124   <none>        8080/TCP   75s

## Expose service
kubectl port-forward -n $EKS_NAMESPACE service/$USER_NAME 8080:8080 1> /dev/null 2> /dev/null & 
```

- Go to http://127.0.0.1:8080

### Ingress

```bash
# 1- Get the Ingress
kubectl get ingress $USER_NAME -n $EKS_NAMESPACE
## Example expected output
# NAME         CLASS               HOSTS                       ADDRESS                                                PORTS   AGE
# el-khayali   aws-ingress-class   el-khayali.el-khayali.com   ingress-basics-721317054.us-east-1.elb.amazonaws.com   80      8m7s

# You can see your DNS Above in HOSTS (el-khayali.el-khayali.com )
```

- Open this URL in the browser: {CHANGE-TO-YOUR-LASTNME}.el-khayali.com


## TP 4.1: Updating a running application 

```bash
envsubst < <(cat tp/4.1/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -

# 1- Check pod update
kubectl get pods -n $EKS_NAMESPACE -l app=$USER_NAME
## Expected output (Pod will be recreated)
# NAME                        READY   STATUS    RESTARTS   AGE
# el-khayali-6c68c59896-7q5q8   1/1     Terminating   0          74m
# el-khayali-6c68c59896-vvcxs   1/1     Terminating   0          46m
# el-khayali-7cccc94478-s2249   1/1     Running       0          45s
# el-khayali-7cccc94478-tp8jg   1/1     Running       0          29s

# Wait for old Pod Termination

# 2- Select one of our deployment's pod
export POD_NAME=$(kubectl get pods -n $EKS_NAMESPACE --selector=app=$USER_NAME -o jsonpath='{.items[0].metadata.name}') && echo $POD_NAME

# 4- Check if env var has been added to this pod
kubectl exec -n $EKS_NAMESPACE $POD_NAME -- printenv NAMESPACE
## Expected output (Pod will be recreated)
# formation-el-khayali
```

## TP 4.2: Using a configmap

```bash
envsubst < <(cat tp/4.2/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -

# 1- Check configmap creation
kubectl get configmap -n $EKS_NAMESPACE $USER_NAME
## Expected output
# NAME       DATA   AGE
# z18oelkh   2      76s

# 2- Check if is_html and home.html keys exist
kubectl get configmap -n $EKS_NAMESPACE $USER_NAME -o jsonpath='{.data}'
## Expected output
# {"home.html":"\u003ch6\u003e It works ✅\u003c/h6\u003e\n","is_html":"true"}% 

# 3- Select one of our deployment's pod
export POD_NAME=$(kubectl get pods -n $EKS_NAMESPACE --selector=app=$USER_NAME -o jsonpath='{.items[0].metadata.name}') && echo $POD_NAME

# 4- Check if env var has been added to this pod
kubectl exec -n $EKS_NAMESPACE $POD_NAME -- printenv IS_HTML
## Expected output (Pod will be recreated)
# true

# 5- Check if file has been mounted to pod
kubectl exec -n $EKS_NAMESPACE $POD_NAME -- cat /config/home.html
## Expected output (Pod will be recreated)
# formation-z18oelkh
```

- Go to the `tp/4.2/demo-app-cm.yaml` file and change home.html content, what happens ?

## TP 4.3: Using a secret

```bash
envsubst < <(cat tp/4.3/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -

# 1- Check secret creation
kubectl get secret -n $EKS_NAMESPACE $USER_NAME
## Expected output
# NAME       TYPE     DATA   AGE
# z18oelkh   Opaque   1      3m51s

# 2- Check if is_html and home.html keys exist
kubectl get secret -n $EKS_NAMESPACE $USER_NAME -o jsonpath='{.data}'
## Expected output
# {"token":"enFranNkbnE="}%  

# 3- Select one of our deployment's pod
export POD_NAME=$(kubectl get pods -n $EKS_NAMESPACE --selector=app=$USER_NAME -o jsonpath='{.items[0].metadata.name}') && echo $POD_NAME
## Expected output
# z18oelkh-6786f7bff9-9nh7j

# 4- Check if env var has been added to this pod
kubectl exec -n $EKS_NAMESPACE $POD_NAME -- printenv TOKEN
## Expected output (Pod will be recreated)
# zqkjsdnq
```

## TP 5.0: Using RBAC

```bash
envsubst < <(cat tp/5.0/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -

# 1- Check serviceaccount creation
kubectl get serviceaccount -n $EKS_NAMESPACE $USER_NAME
# Expected output:
# NAME       SECRETS   AGE
# z18oelkh   0         4m22s

# 2- Check role creation
kubectl get role -n $EKS_NAMESPACE resourcequota-writer
## Expected output:
# NAME                   CREATED AT
# resourcequota-reader   2024-01-30T09:26:50Z

# 3- Check rolebinding creation
kubectl get rolebinding -n $EKS_NAMESPACE write-resourcequota
## Expected output:
# NAME                 ROLE                        AGE
# read-resourcequota   Role/resourcequota-reader   5m34s
```

## !! :warning: CLEAN RESOURCES :warning: !!

```bash

# 1- Delete all resources we created in privious steps
envsubst < <(cat tp/5.0/*.yaml) | kubectl delete -n $EKS_NAMESPACE -f -

# 2_ Check if resources has been deleted
kubectl get all -n $EKS_NAMESPACE
## Expected output:
# No resources found in formation-z18oelkh namespace.
```



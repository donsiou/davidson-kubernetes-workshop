# Commands

## Prepare working environment

```bash
# Change to your lastname, for composed names use "-" instead of space, ex EL KHAYALI -> el-khayali
export USER_NAME="<your-lastname-in-lowercase>"
export EKS_NAMESPACE=formation-$USER_NAME
```

---

## TP 0 : Accessing your namespace

- Get your namespace

```bash
kubectl get namespace $EKS_NAMESPACE
# # Expected output
# NAME                STATUS   AGE
# formation-oussama   Active   5m20s
```

- Describe your namespace

```bash
kubectl describe namespace $EKS_NAMESPACE
```
---

## TP 1.0: Deploy a simple pod

- Replace the environment variables with their corresponding values in this file : [demo-app-pod.yaml](tp/1.0/demo-app-pod.yaml)

- Apply the configuration

```bash
envsubst < <(cat tp/1.0/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -
```

- Check if pod has been created

```bash
kubectl get pods -n $EKS_NAMESPACE
## Example expected output (Wait for the STATUS to become running ...)
# NAME      READY   STATUS    RESTARTS   AGE
# oussama   1/1     Running   0          43s
```

- Check pod logs, you may need to wait for the application to start before logs become visible.

```bash
kubectl logs -n $EKS_NAMESPACE $USER_NAME
## Example expected output
# INFO:root:Starting the application on host oussama
#  * Serving Flask app 'app'
#  * Debug mode: off
# ...
```

- Delete the pod

```bash
kubectl delete pod -n $EKS_NAMESPACE $USER_NAME
## Example expected output
# pod "oussama" deleted
```

---

## TP 2.0: Automate Pod Deployment

- Apply the configuration

```bash
envsubst < <(cat tp/2.0/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -
```

- Check deployment creation/status

```bash
kubectl get deployment -n $EKS_NAMESPACE
## Example expected output
# NAME      READY   UP-TO-DATE   AVAILABLE   AGE
# oussama   2/2     2            2           19s
```

- Check pods created by deployment

```bash
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

- Now your application should be ready in http://localhost:8080

---

## TP 2.1: Adding probes

- Apply the configuration

```bash
envsubst < <(cat tp/2.1/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -
```

- Select one of our deployment's pod

```bash
export POD_NAME=$(kubectl get pods -n $EKS_NAMESPACE --selector=app=$USER_NAME -o jsonpath='{.items[0].metadata.name}') && echo $POD_NAME
```

- Check Pod logs

```bash
kubectl logs -n $EKS_NAMESPACE $POD_NAME
# INFO:werkzeug:10.226.146.219 - - [30/Jan/2024 10:43:27] "GET /health HTTP/1.1" 200 -
# INFO:werkzeug:10.226.146.219 - - [30/Jan/2024 10:43:27] "GET /health-degraded HTTP/1.1" 200 -
# INFO:werkzeug:10.226.146.219 - - [30/Jan/2024 10:43:32] "GET /health-degraded HTTP/1.1" 200 -
# INFO:werkzeug:10.226.146.219 - - [30/Jan/2024 10:43:32] "GET /health HTTP/1.1" 200 -
```

---

## TP 2.2: A failing Liveness

- Apply the configuration

```bash
envsubst < <(cat tp/2.2/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -
```

- Check pods status

```bash
kubectl get pods -n $EKS_NAMESPACE -l app=$USER_NAME
## Expected output
# oussama-778d99c995-j5gw5   1/1     Running   0             68s
# oussama-778d99c995-v5skj   0/1     Running   1 (13s ago)   84s
```

- Select one of our deployment's pod

```bash
export POD_NAME=$(kubectl get pods -n $EKS_NAMESPACE --selector=app=$USER_NAME -o jsonpath='{.items[0].metadata.name}') && echo $POD_NAME
## Expected output
# oussama-778d99c995-j5gw5
```

- Check events

```bash
kubectl get events --field-selector involvedObject.name=$POD_NAME -n $EKS_NAMESPACE | grep Liveness
# 2m22s       Warning   Unhealthy   pod/oussama-778d99c995-j5gw5   Liveness probe failed: Get "http://10.0.1.148:8080/health-degraded": dial tcp 10.0.1.148:8080: connect: connection refused
# 112s        Warning   Unhealthy   pod/oussama-778d99c995-j5gw5   Liveness probe failed: HTTP probe failed with statuscode: 500
```

---

## TP 2.3: A failing Readiness

- Apply the configuration

```bash
envsubst < <(cat tp/2.3/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -
```

- Check pods status

```bash
kubectl get pods -n $EKS_NAMESPACE -l app=$USER_NAME
# NAME                      READY   STATUS    RESTARTS   AGE
# z18oelkh-bbfcb8cd-2gkz8   1/1     Running   0          6m8s
# z18oelkh-bbfcb8cd-c5mcd   1/1     Running   0          6m28s
```

- Select one of our deployment's pod

```bash
export POD_NAME=$(kubectl get pods -n $EKS_NAMESPACE --selector=app=$USER_NAME -o jsonpath='{.items[0].metadata.name}') && echo $POD_NAME
## Expected output
# oussama-7588767d9f-djfgf
```

- Check events

```bash
kubectl get events --field-selector involvedObject.name=$POD_NAME -n $EKS_NAMESPACE | grep Readiness
## Expected output
# 4m45s       Warning   Unhealthy   pod/oussama-7588767d9f-djfgf   Readiness probe failed: Get "http://10.0.1.247:8080/health-degraded": dial tcp 10.0.1.247:8080: connect: connection refused
# 4m          Warning   Unhealthy   pod/oussama-7588767d9f-djfgf   Readiness probe failed: HTTP probe failed with statuscode: 500
```

---

## TP 3.0: Expose your application

- Apply the configuration

```bash
envsubst < <(cat tp/3.0/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -
```

### Service

- Get the service

```bash
kubectl get service $USER_NAME -n $EKS_NAMESPACE
## Example expected output
# NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
# el-khayali   ClusterIP   172.20.42.124   <none>        8080/TCP   75s
```

- Expose service

```bash
kubectl port-forward -n $EKS_NAMESPACE service/$USER_NAME 8080:8080 1> /dev/null 2> /dev/null &
```

- Go to http://127.0.0.1:8080

### Ingress

- Get the Ingress

```bash
kubectl get ingress $USER_NAME -n $EKS_NAMESPACE
## Example expected output
# NAME         CLASS               HOSTS                       ADDRESS                                                PORTS   AGE
# el-khayali   aws-ingress-class   el-khayali.el-khayali.com   ingress-basics-721317054.us-east-1.elb.amazonaws.com   80      8m7s
```

- Open this URL in the browser: {CHANGE-TO-YOUR-LASTNME}.el-khayali.com

---

## TP 4.1: Updating a running application

- Apply the configuration

```bash
envsubst < <(cat tp/4.1/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -
```

- Check pod update

```bash
kubectl get pods -n $EKS_NAMESPACE -l app=$USER_NAME
## Expected output (Pod will be recreated)
# NAME                        READY   STATUS    RESTARTS   AGE
# el-khayali-6c68c59896-7q5q8   1/1     Terminating   0          74m
# el-khayali-6c68c59896-vvcxs   1/1     Terminating   0          46m
# el-khayali-7cccc94478-s2249   1/1     Running       0          45s
# el-khayali-7cccc94478-tp8jg   1/1     Running       0          29s
```

- Wait for old Pod Termination

- Select one of our deployment's pod

```bash
export POD_NAME=$(kubectl get pods -n $EKS_NAMESPACE --selector=app=$USER_NAME -o jsonpath='{.items[0].metadata.name}') && echo $POD_NAME
```

- Check if env var has been added to this pod

```bash
kubectl exec -n $EKS_NAMESPACE $POD_NAME -- printenv NAMESPACE
## Expected output (Pod will be recreated)
# formation-el-khayali
```

---

## TP 4.2: Using a configmap

- Apply the configuration

```bash
envsubst < <(cat tp/4.2/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -
```

- Check configmap creation

```bash
kubectl get configmap -n $EKS_NAMESPACE $USER_NAME
## Expected output
# NAME       DATA   AGE
# z18oelkh   2      76s
```

- Check if is_html and home.html keys exist

```bash
kubectl get configmap -n $EKS_NAMESPACE $USER_NAME -o jsonpath='{.data}'
## Expected output
# {"home.html":"\u003ch6\u003e It works ✅\u003c/h6\u003e\n","is_html":"true"}%
```

- Select one of our deployment's pod

```bash
export POD_NAME=$(kubectl get pods -n $EKS_NAMESPACE --selector=app=$USER_NAME -o jsonpath='{.items[0].metadata.name}') && echo $POD_NAME
```

- Check if env var has been added to this pod

```bash
kubectl exec -n $EKS_NAMESPACE $POD_NAME -- printenv IS_HTML
## Expected output (Pod will be recreated)
# true
```

- Check if file has been mounted to pod

```bash
kubectl exec -n $EKS_NAMESPACE $POD_NAME -- cat /config/home.html
## Expected output (Pod will be recreated)
# formation-z18oelkh
```

- Go to the `tp/4.2/demo-app-cm.yaml` file and change home.html content, what happens?

---

## TP 4.3: Using a secret

- Apply the configuration

```bash
envsubst < <(cat tp/4.3/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -
```

- Check secret creation

```bash
kubectl get secret -n $EKS_NAMESPACE $USER_NAME
## Expected output
# NAME       TYPE     DATA   AGE
# z18oelkh   Opaque   1      3m51s
```

- Check if is_html and home.html keys exist

```bash
kubectl get secret -n $EKS_NAMESPACE $USER_NAME -o jsonpath='{.data}'
## Expected output
# {"token":"enFranNkbnE="}%
```

- Select one of our deployment's pod

```bash
export POD_NAME=$(kubectl get pods -n $EKS_NAMESPACE --selector=app=$USER_NAME -o jsonpath='{.items[0].metadata.name}') && echo $POD_NAME
## Expected output
# z18oelkh-6786f7bff9-9nh7j
```

- Check if env var has been added to this pod

```bash
kubectl exec -n $EKS_NAMESPACE $POD_NAME -- printenv TOKEN
## Expected output (Pod will be recreated)
# zqkjsdnq
```

---

## TP 5.0: Using RBAC

- Apply the configuration

```bash
envsubst < <(cat tp/5.0/*.yaml) | kubectl apply -n $EKS_NAMESPACE -f -
```

- Check serviceaccount creation

```bash
kubectl get serviceaccount -n $EKS_NAMESPACE $USER_NAME
# Expected output:
# NAME       SECRETS   AGE
# z18oelkh   0         4m22s
```

- Check role creation

```bash
kubectl get role -n $EKS_NAMESPACE resourcequota-writer
## Expected output:
# NAME                   CREATED AT
# resourcequota-reader   2024-01-30T09:26:50Z
```

- Check rolebinding creation

```bash
kubectl get rolebinding -n $EKS_NAMESPACE write-resourcequota
## Expected output:
# NAME                 ROLE                        AGE
# read-resourcequota   Role/resourcequota-reader   5m34s
```

---

## !! :warning: CLEAN RESOURCES :warning: !!

- Delete all resources we created in previous steps

```bash
envsubst < <(cat tp/5.0/*.yaml) | kubectl delete -n $EKS_NAMESPACE -f -
```

- Check if resources have been deleted

```bash
kubectl get all -n $EKS_NAMESPACE
## Expected output:
# No resources found in formation-z18oelkh namespace.
```



# GKE_kubeflow
在Google kubernetes Engine自動安裝kubeflow

## 使用教學
#### 移動到家目錄
``` Bash
cd ~/
``` 
#### 下載腳本
``` Bash
git clone https://github.com/loxacom123/GKE_kubeflow.git
```
#### 執行腳本
``` Bash
cd GKE_kubeflow

chmod +x install.sh

./install.sh -i <Your GCP Project ID>
```
#### 執行 Kubeflow UI 在8080 Port (安裝完成後，需要等待一段時間，約5~10分鐘)
``` Bash
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80
```

test
123
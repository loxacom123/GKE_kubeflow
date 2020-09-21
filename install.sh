# 預設參數
gcp_sa="gcp-sa"
k8s_sa="k8s-sa"
kf_name="my-kubeflow"


#參數讀取
while [ "$1" != "" ]; do
    case $1 in
        -i | --id ) shift;  # ProjectID
          project_id=$1 ;;
        -g | --gsa ) shift; # GSA Name
          gcp_sa=$1 ;;
        -k | --ksa ) shift; # KSA Name
          k8s_sa=$1 ;;
        -f | --kf ) shift; # Kubeflow 資料夾
          kf_name=$1 ;;
    esac
    shift;
done

#沒有填Projecit ID 結束
if [ "$project_id" = "" ]; then
  exit;
fi

echo "********** Preview Parameters **********"
echo "Project ID : ${project_id}"
echo "GSA Name : ${gcp_sa}"
echo "KSA Name : ${k8s_sa}"
echo "Kubeflow folder : ${kf_name}"
echo ""
echo ""

read -r -p "Are you sure? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        echo "OK"
        ;;
    *)
        echo "Bye"
        exit
        ;;
esac


echo "********** Setup Parameters **********"

## 環境參數 ##
# 專案ID
export PROJECT=$project_id
export PROJECT_ID=$project_id

# 名稱
export GSA_NAME=$gcp_sa
export KSA_NAME=$k8s_sa

# 以利後需使用kfctl指令
export PATH=$PATH:$(pwd)

# 部署將會使用這個設定檔
export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v0.7-branch/kfdef/kfctl_k8s_istio.0.7.1.yaml"

# Kubeflow部署過程生成的設定檔存放的資料夾名，可以設定成`my-kubeflow`或是`kf-test`
export KF_NAME=my-kubeflow

# 放置Kubeflow專案的資料夾路徑
export BASE_DIR=$(pwd)/kubeflow_project

# 此次部署Kubeflow的的完整路徑
export KF_DIR=${BASE_DIR}/${KF_NAME}

echo "********** Setup Kubeflow **********"

# 來到Kubeflow專案底下
mkdir -p ${KF_DIR}
cd ${KF_DIR}

# 部署
kfctl apply -V -f ${CONFIG_URI}

# 創建 Google Service Account
gcloud iam service-accounts create ${GSA_NAME}

# 創建 Kubernetes Service Account
kubectl create serviceaccount --namespace kubeflow k8s-sa

# 將上述兩個 Service Account 綁上關聯
gcloud iam service-accounts add-iam-policy-binding \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:${PROJECT_ID}.svc.id.goog[kubeflow/${KSA_NAME}]" \
  ${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com


kubectl annotate serviceaccount \
  --namespace kubeflow \
  ${KSA_NAME} \
  iam.gke.io/gcp-service-account=${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com
  
  
echo "********** Setup Complete **********"

# Instruction
For local execution:
```
git clone ...
cd 
docker-compose up -d 
curl 127.0.0.1:20101
curl 127.0.0.1:20101/phptest.php
curl 127.0.0.1:20101/redistest.php
curl 127.0.0.1:20101/postgrestest.php?id=1
ssh -p 20102 root@127.0.0.1
docker-compose down
```


For execution on GCP: 
```sh
git clone ...
cd 
terraform init
terrafrom apply

gcloud auth configure-docker
docker build -t gcr.io/helpful-lens-307104/php-test -f docker/Dockerfile ./
docker push gcr.io/helpful-lens-307104/php-test
gcloud container images list
gcloud container clusters get-credentials helpful-lens-307104-gke --region us-central1
ACCOUNT_EMAIL=$(gcloud iam service-accounts --format='value(email)' create k8s-gcr-auth-ro)
gcloud projects add-iam-policy-binding $PROJECT --member serviceAccount:$ACCOUNT_EMAIL --role roles/storage.objectViewer
gcloud iam service-accounts keys create --iam-account $ACCOUNT_EMAIL key.json

kubectl create secret docker-registry gcr-io --docker-server=gcr.io --docker-username=_json_key --docker-email=slodygin@gmail.com --docker-password="$(cat key.json)"
export POSTGRES_PASSWORD=$(terraform output db_password |sed 's/"//g')
sed -i "s/POSTGRES_PASSWORD/$POSTGRES_PASSWORD/g" php.yaml
export POSTGRES_USERNAME=$(terraform output db_username |sed 's/"//g')
sed -i "s/POSTGRES_USERNAME/$POSTGRES_USERNAME/g" php.yaml
export POSTGRES_HOST=$(terraform output db_host_ip |sed 's/"//g')
sed -i "s/POSTGRES_HOST/$POSTGRES_HOST/g" php.yaml
kubectl apply -f php.yaml 
kubectl rollout restart deployment phptest1

curl http://$(kubectl get ingress phptest1 |awk '{print $4}' |grep -v ADDRESS)
curl http://$(kubectl get ingress phptest1 |awk '{print $4}' |grep -v ADDRESS)/phptest.php
curl http://$(kubectl get ingress phptest1 |awk '{print $4}' |grep -v ADDRESS)/redistest.php
curl http://$(kubectl get ingress phptest1 |awk '{print $4}' |grep -v ADDRESS)/postgrestest.php?id=1
terraform destroy
```


Usefull links:
https://learnk8s.io/terraform-gke
https://dzone.com/articles/google-gke-and-sql-with-terraform-ion-medium

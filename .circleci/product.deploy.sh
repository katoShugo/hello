# ACCTからサービスアカウントキーファイルを作成
echo $ACCT_AUTH | base64 -d > ${HOME}/gcloud-service-key.json

# gloudの設定
sudo /opt/google-cloud-sdk/bin/gcloud --quiet components update
sudo /opt/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json
sudo /opt/google-cloud-sdk/bin/gcloud config set project deploy-test-212203

# コンテナのUPLOAD
docker build -t asia.gcr.io/deploy-test-212203/hello .
sudo /opt/google-cloud-sdk/bin/gcloud docker -- push asia.gcr.io/deploy-test-212203/hello

# GKEへのデプロイ
# sudo /opt/google-cloud-sdk/bin/gcloud --quiet compute copy-files asia.gcr.io/deploy-test-212203/hello
sudo /opt/google-cloud-sdk/bin/gcloud --quiet components update kubectl
sudo gcloud container clusters get-credentials hello-cluster --zone us-central1-a --project deploy-test-212203
sudo /opt/google-cloud-sdk/bin/gcloud container clusters get-credentials hello-cluster --zone us-central1-a --project deploy-test-212203
sudo kubectl patch deployment docker-hello-google -p '{"spec":{"template":{"spec":{"containers":[{"name":"docker-hello-google","image":"asia.gcr.io/deploy-test-212203/hello:1.0 --port 8080:'"$CIRCLE_SHA1"'"}]}}}}'

# kubectl run hello-server --image asia.gcr.io/deploy-test-212203/hello --port 8080
# kubectl expose deployment hello-server-test --type "LoadBalancer"
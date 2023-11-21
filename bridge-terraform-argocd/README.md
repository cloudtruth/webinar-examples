# setup aws creds
export AWS_PROFILE=your_profile
aws sso login

# Create aws backend support resources for terraform state
cd terraform/bootstrap
terraform init
terraform apply

# Run terraform to create resources
cd terraform/
terraform init
terraform workspace new development
terraform apply
terraform workspace new production
terraform apply

# Example of running terraform with variable values supplied from cloudtruth
terraform apply -var-file <(cloudtruth --env development --profile webinar --project bridge-terraform-argocd template get tfvars -s)


# Setup argo locally in minikube
minikube start
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
brew install argocd
kubectl port-forward svc/argocd-server -n argocd 8080:443
argocd login --insecure --username admin --password $(argocd admin initial-password -n argocd | head -n1) localhost:8080
open http://localhost:8080

# Test manifests with argocd plugin
export CLOUDTRUTH_API_KEY=xxx
cd application/
docker run --platform linux/amd64 -e CLOUDTRUTH_API_KEY -v $(pwd)/k8s:/data --workdir /data cloudtruth/argocd-cloudtruth-plugin /usr/bin/argocd-cloudtruth-plugin --environment development

# Build container in local minikube
eval $(minikube docker-env)
cd application/
docker build -t cloudtruth/bridge-terraform-argocd-application .

# Add application to argo
argocd app create mydemo-development --repo https://github.com/cloudtruth/webinar-examples --path bridge-terraform-argocd/application/k8s --dest-server https://kubernetes.default.svc --plugin-env CLOUDTRUTH_ENVIRONMENT=development

argocd app create mydemo-production --repo https://github.com/cloudtruth/webinar-examples --path bridge-terraform-argocd/application/k8s --dest-server https://kubernetes.default.svc --plugin-env CLOUDTRUTH_ENVIRONMENT=production

# Visit application
minikube service -n mydemo-development mydemo
minikube service -n mydemo-production mydemo

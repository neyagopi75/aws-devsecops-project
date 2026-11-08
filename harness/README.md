# Harness CD setup (EKS + Helm)

`deployment-pipeline.yaml` is a starter/draft, not a verified import-ready Harness pipeline. Create the deployment stage in Pipeline Studio, save it, then export Harness-generated YAML.

## Configure Harness
1. Add an AWS connector with least-privilege EKS discovery/authentication permissions.
2. Ensure a Harness Delegate can reach the EKS API endpoint and has supported EKS authentication/IAM configuration.
3. Create Kubernetes Service `devsecops_app`; connect Git and set manifest/chart path to `helm/` (chart name `hello-world`). Add an ECR artifact source for `aws-devsecops-app` and image tag from CI.
4. Create Environment `dev_environment`; Infrastructure `eks_infrastructure` selecting EKS cluster, namespace `devsecops`, and Helm release `devsecops-app`.
5. In Pipeline Studio create Deployment stage (Kubernetes/Helm), select Service and Environment/Infrastructure, choose Rolling strategy, configure artifact/tag, save.
6. Run pipeline and verify pods/service in EKS.

Do not store credentials/tokens in YAML or Helm values. Inject runtime secrets via an approved secret manager integration.

# AWS DevSecOps Platform

An end-to-end DevSecOps project that builds, scans, publishes, and deploys a containerized application to Amazon EKS using **GitHub, Jenkins, Snyk, Docker, Amazon ECR, Terraform, and Helm**.

> **Deployment approach:** Jenkins handles CI and CD. Harness is not part of this architecture. Helm is retained as the Kubernetes deployment tool. Vault is not included because a Vault runtime integration has not been implemented.


### Architecture flow

1. A developer pushes application or deployment changes to GitHub.
2. Jenkins checks out the repository and runs the pipeline.
3. Jenkins builds and tests the application.
4. Terraform configuration is validated.
5. Snyk scans the project for security issues.
6. Jenkins builds a Docker image and pushes it to Amazon ECR.
7. Jenkins updates the image tag in the Helm deployment and runs `helm upgrade --install`.
8. Helm creates or updates Kubernetes resources in Amazon EKS.
9. EKS worker nodes pull the image from ECR and run the application Pods.
10. Jenkins checks the Kubernetes rollout status.

---

## Technology stack

| Technology | Role |
|---|---|
| GitHub | Source code and version control |
| Jenkins | CI/CD automation |
| Snyk | Application/dependency security scanning |
| Docker | Container image build |
| Amazon ECR | Private container image registry |
| Terraform | AWS infrastructure as code |
| Amazon EKS | Managed Kubernetes control plane |
| EC2 worker nodes | Run application Pods |
| Helm | Package and deploy Kubernetes resources |
| IAM | Access control and AWS permissions |
| VPC | AWS network isolation |

---

## Repository layout

```text
aws-devsecops-project/
├── app/                    # Application source code
├── tests/                  # Application tests
├── Dockerfile              # Container image definition
├── Jenkins.yaml             # Jenkins pipeline
├── terraform/               # AWS infrastructure as code
│   ├── ...                 # VPC, EKS, IAM, ECR, Jenkins resources
├── helm/                    # Helm chart
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       └── service.yaml
├── README.md
└── ...
```

> The exact Terraform subfolders and application filenames can vary by repository revision. Keep this tree aligned with the files committed to GitHub.

---

## Application and image

The application listens on port **5000** and exposes a health endpoint at:

```text
/health
```

Current ECR image:

```text
441931764817.dkr.ecr.ap-south-1.amazonaws.com/aws-devsecops-app:7
```

- AWS Region: `ap-south-1`
- AWS Account: `441931764817`
- ECR repository: `aws-devsecops-app`
- Image tag: `7`

Use a new immutable tag for each release rather than relying on `latest`.

---

## Helm chart

The chart is located in `helm/`.

Current deployment values include:

- 2 replicas
- Container port 5000
- ClusterIP service
- Readiness and liveness checks on `/health`
- CPU and memory requests/limits
- Non-root container execution
- Read-only root filesystem
- Dropped Linux capabilities

### Validate the chart locally

From the repository root:

```powershell
helm lint .\helm
helm template aws-devsecops-app .\helm
```

### Deploy with Helm

Configure `kubectl` to use the EKS cluster first, then run:

```bash
helm upgrade --install aws-devsecops-app ./helm \
  --namespace devsecops \
  --create-namespace
```

Check the release and application:

```bash
helm list -n devsecops
kubectl get deployments,pods,svc -n devsecops
kubectl rollout status deployment/aws-devsecops-app -n devsecops
```

For a new image version, update the image tag in `helm/values.yaml` (or pass it with `--set`) and run the Helm upgrade again.

---

## Jenkins pipeline

The Jenkins pipeline is intended to perform the following stages:

1. **Checkout** — clone the GitHub repository.
2. **Build and Test** — install dependencies and run application tests.
3. **Terraform Validate** — initialize/validate Terraform configuration.
4. **Security Scan** — run Snyk using a Jenkins-managed credential.
5. **Docker Build** — build the application image.
6. **Push to ECR** — authenticate and publish the image.
7. **Deploy to EKS** — configure Kubernetes access and deploy/update the Helm release.
8. **Verify Deployment** — wait for rollout and report status.

### Jenkins credentials and access

Store secrets in **Jenkins Credentials** or an approved secret manager. Do not put AWS access keys, Snyk tokens, kubeconfig contents, or passwords in source files or Git.

For deployment, Jenkins needs:
- AWS permissions to authenticate and access the target EKS cluster.
- Kubernetes authorization to deploy into the `devsecops` namespace.
- Helm and kubectl installed on the Jenkins agent.

The EKS worker-node role needs permission to pull images from ECR. The Jenkins deployment identity and EKS node identity are separate responsibilities.

---

## Infrastructure

Terraform is used to provision and manage AWS resources. Typical resources in this project include:

- VPC and networking
- Amazon EKS cluster
- EKS worker nodes
- IAM roles and policies
- Amazon ECR repository
- Jenkins EC2 instance and related access

### Terraform workflow

Run Terraform from the relevant Terraform directory:

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Review the plan before applying infrastructure:

```bash
terraform apply
```

Never commit Terraform state files, private keys, access keys, or secret values.

---

## Security practices

- Run Snyk scans as part of CI.
- Use least-privilege IAM policies.
- Keep credentials in Jenkins Credentials; never commit them.
- Use unique image tags for releases.
- Run containers as non-root.
- Use a read-only root filesystem where the application supports it.
- Drop unnecessary Linux capabilities.
- Set resource requests and limits.
- Use readiness and liveness probes.
- Review Terraform plans before applying changes.
- Protect the GitHub main branch and require review for production changes.

---

## Troubleshooting

| Symptom | Checks |
|---|---|
| Jenkins cannot push to ECR | AWS credentials/role, ECR login, repository permissions, region |
| EKS Pods show `ImagePullBackOff` | Image URI/tag, ECR node permissions, region/account |
| Helm deployment fails | `helm lint`, `helm template`, namespace, Kubernetes access |
| Pods are not Ready | `kubectl describe pod`, application logs, `/health`, port 5000 |
| Rollout times out | `kubectl get pods`, `kubectl describe deployment`, `kubectl logs` |
| Terraform validation fails | Provider versions, syntax, variables, module paths |

Useful commands:

```bash
kubectl get pods -n devsecops
kubectl describe pod <pod-name> -n devsecops
kubectl logs <pod-name> -n devsecops
kubectl get events -n devsecops --sort-by=.lastTimestamp
helm status aws-devsecops-app -n devsecops
```

---

## Cleanup

Before deleting anything, confirm which resources are shared or still needed.

- Remove the Helm release only if the application should be stopped:

  ```bash
  helm uninstall aws-devsecops-app -n devsecops
  ```

- Destroy AWS infrastructure only after reviewing the Terraform plan and confirming that no important workloads or data depend on it:

  ```bash
  terraform plan -destroy
  terraform destroy
  ```

Deleting the Helm release does **not** delete the EKS cluster or ECR images.

---

## Project status

| Component | Status |
|---|---|
| GitHub source repository | Implemented |
| Jenkins CI pipeline | Implemented |
| Snyk integration | Implemented |
| Docker image build and ECR push | Implemented |
| Terraform infrastructure | Implemented / validated |
| EKS cluster and worker nodes | Provisioned and healthy |
| Helm chart | Validated locally |
| Jenkins-driven Helm CD | Next integration step |
| Harness CD | Not used |
| Vault runtime integration | Not implemented / excluded |

---

## Learning outcomes

This project demonstrates:

- CI/CD automation
- Infrastructure as Code
- Containerization
- Dependency and security scanning
- Container registry management
- Kubernetes deployment
- Helm-based release management
- AWS IAM and EKS integration
- Deployment verification and troubleshooting

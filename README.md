# Infrastructure as Code for CommitFlow

This repository contains the Infrastructure as Code (IaC) for the CommitFlow project. Infrastructure is provisioned with Terraform, while Kafka is configured using Ansible.

Since the ECS services depend on a running Kafka cluster, the infrastructure is provisioned in three sequential steps:

1. **Terraform** – Provision the networking infrastructure (VPC) and the Kafka EC2 instances.
2. **Ansible** – Configure the EC2 instances and install the Kafka cluster.
3. **Terraform** – Provision the remaining AWS infrastructure, including the ECS cluster and services, CloudWatch log groups, task definitions, and supporting resources.

In a production environment, the Kafka infrastructure would typically be managed in a separate repository with its own deployment lifecycle. For the purposes of this proof of concept, all infrastructure is kept in a single repository to simplify deployment and demonstration.

The entire provisioning process is automated through Bash scripts. In a real-world environment, these steps would normally be executed by a CI/CD pipeline, such as GitLab CI/CD, to provide repeatable, version-controlled, and fully automated infrastructure deployments.


<h1 align="center"> Lambda Function and API Gateway </h1> <br>
<p align="center">
  <a>
    <img alt="Terraform Lambda" title="Terraform Lambda" src="https://github.com/agusticonesagago/lambda_with_terraform/blob/main/doc/images/lambda.png?raw=true" width="900" height="500">
  </a>
</p>

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Key Considerations](#key-considerations)
- [Getting Started](#getting-started)
- [Feedback](#feedback)
- [License](#license)

## Introduction

This project is a personal endeavor to gain familiarity with Terraform and explore the implementation of an API Gateway with a Lambda function. It serves as a hands-on learning experience where I independently undertake the configuration and deployment tasks using Terraform. Through this project, I aim to enhance my understanding of Terraform's capabilities and deepen my knowledge of infrastructure provisioning and management.

## Prerequisites

Before using this project, make sure you have the following prerequisites installed:

- Docker Desktop: [Official Website](https://www.docker.com/products/docker-desktop)
- AWS Account: [Official Website](https://aws.amazon.com/)


## Key Considerations

Before proceeding with the Terraform deployment, it is important to consider the following key points:

**User Policies**

Ensure that the IAM user you are using to execute the Terraform commands has the necessary policies attached to create the required resources. If you encounter an error indicating a lack of permissions, review the error message to identify the required policies.

To address this:
- Log in to the AWS Management Console.
- Navigate to the IAM service.
- Locate the IAM user being used for Terraform deployment.
- Attach the necessary policies to the user, granting the required permissions for creating and managing the resources defined in your Terraform configuration.

By ensuring the IAM user has the appropriate policies attached, you can avoid authorization-related issues during the Terraform deployment process.

## Getting started

1. **Clone the Repository**: Clone the repository containing the Terraform configuration files to your local machine.

2. **Navigate to the Project Directory**: Open a terminal or command prompt and navigate to the directory where the project is cloned.

3. **Build the Docker Image**: Run the following command to build the Docker image:

   ```shell
   docker build -t lambda-image .
    ```
4. **Replace AWS Credentials in terraform.tfvars**: Open the `terraform.tfvars` file and replace `"your_aws_access_key_id"` and `"your_aws_secret_access_key"` with your actual AWS access key ID and secret access key, respectively.

5. **Choose Terraform State Storage Option**:  By default, the Terraform state file (`terraform.tfstate`) is saved in an S3 bucket. If you don't have an S3 bucket created beforehand and prefer to save the state file locally, follow these steps:
- Open the `main.tf` file.
- Locate lines 18 to 24 in the file and delete these lines to remove the S3 backend configuration.
- After deleting the lines, Terraform will save the state file locally instead of in an S3 bucket.

>  Note: Saving the state file locally means that you will need to handle state file backups and potential concurrent access issues manually.

By choosing the appropriate option and making the necessary changes in the `main.tf` file, you can control whether the Terraform state file is saved in an S3 bucket or locally.

6. **Run the Docker container**: Run the following command to start the Docker container:

   ```shell
   docker run -it --rm -v ${PWD}:/app lambda-image
    ```
This command runs the Docker container using the previously built image.

> Note: The Docker container is configured with the necessary tools and dependencies to execute the project.

After the Docker container starts, a shell session is opened in the terminal.

7. **Export AWS Credentials**:   Export your AWS credentials within the Docker container's shell. Run the following commands, replacing `your_aws_access_key_id` and `your_aws_secret_access_key` with your actual AWS credentials:

  ```shell
  export AWS_ACCESS_KEY_ID="your_aws_access_key_id"
  export AWS_SECRET_ACCESS_KEY="your_aws_secret_access_key"
  ```
These environment variables will provide the necessary credentials for Terraform to authenticate with AWS.

8. **Using the Docker container**: With the Docker container running and the AWS credentials set, you can execute the following commands within the container's shell:

- `make init`: This command initializes Terraform within the container. It sets up the working directory, downloads the necessary provider plugins, and prepares Terraform for use.

- `make plan`: This command generates an execution plan for Terraform. It analyzes the current state of your infrastructure and determines the actions needed to achieve the desired state defined in your Terraform configuration. It provides a preview of the changes that will be applied.

- `make apply`: This command applies the changes specified in the Terraform execution plan. It creates, modifies, or destroys resources as necessary to match the desired state. You will be prompted to confirm the changes before they are applied.

- `make destroy`: This command destroys all the resources managed by Terraform. It removes all infrastructure resources created by the Terraform configuration. Use this command with caution, as it permanently deletes resources.

- `make deploy`: This command combines the `init`, `plan`, and `apply` steps into a single command. It initializes Terraform, generates the execution plan, and applies the changes in one go.

## Feedback

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.

## License

This project is licensed under the Creative Commons Attribution 4.0 license, which allows others to use and modify the code as long as proper attribution is given. If you use this project in your work, please make sure to include a reference to this repository and its creators.
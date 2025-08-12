pipeline {
    agent any

    environment {
        // Adjust AWS credentials bindings or environment variables as per your setup
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'eu-west-1'
        TF_VAR_environment    = 'irl-dev'
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout your Terraform code from Git
                // assuming the repository is set up correctly so that it can pull the code
                git url: 'https://your.git.repo/terraform-aws-wordpress.git', branch: 'main'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('environments/ireland') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('environments/ireland') {
                    sh 'terraform plan -var-file="terraform.tfvars" -out=tfplan.binary'
                }
            }
        }

        stage('Terraform Plan Output') {
            steps {
                dir('environments/ireland') {
                    sh 'terraform show -json tfplan.binary > plan.json'
                }
            }
        }

        stage('Approval') {
            steps {
                // Manual approval before applying changes
                input message: 'Approve Terraform Apply?', ok: 'Apply'
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('environments/ireland') {
                    sh 'terraform apply -auto-approve tfplan.binary'
                }
            }
        }
    }

    post {
        success {
            echo "Terraform deployment completed successfully."
        }
        failure {
            echo "Terraform deployment failed."
        }
    }
}

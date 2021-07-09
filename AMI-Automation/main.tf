terraform {
required_providers {
aws = {
source = "hashicorp/aws"
version = "~> 3.44.0"
}
}
required_version = ">= 0.14.9"

backend "s3" {
# Replace this with your bucket name!
bucket = "ctiot-terraform-state"
key = "purmo-prod/ami-automation/terraform.tfstate"
region = "us-east-1"
# Replace this with your DynamoDB table name!
dynamodb_table = "terraform-up-and-running-locks"
encrypt = true
}
}

provider "aws" {
alias = "tfstate"
profile = "ctiotsolutiondev"
region = "us-east-1"
}

provider "aws" {
alias = "ctiotsolutiondev_main"
profile = "ctiotsolutiondev"
region = "us-east-1"
}

provider "aws" {
profile = "purmo-prod"
region = "eu-central-1"
}

resource "aws_instance" "ami_instance1" {
  ami           = "ami-0bad4a5e987bdebde"
  instance_type = "m3.medium"
  #iam_instance_profile = "prod-devops-role"
  key_name = var.key_name
  subnet_id = "subnet-0c838269bd0c1527f"
  vpc_security_group_ids               = [
        "sg-0c0c0045974cc9a65",
    ]
  root_block_device {
        delete_on_termination = true
        volume_size           = 60
        volume_type           = "gp2"
    }
  user_data = file("./script/userdata.sh")
  tags = {
    Name = "Base-ami"
  }
}
resource "aws_instance" "ami_instance" {
  ami           = "ami-0bad4a5e987bdebde"
  instance_type = "m3.medium"
  #iam_instance_profile = "prod-devops-role"
  key_name = var.key_name
  subnet_id = "subnet-0c838269bd0c1527f"
  vpc_security_group_ids               = [
        "sg-0c0c0045974cc9a65",
    ]
  root_block_device {
        delete_on_termination = true
        volume_size           = 60
        volume_type           = "gp2"
    }
  user_data = file("./script/userdata-docker.sh")
  tags = {
    Name = "Service-api-ami"
  }
}

resource "aws_instance" "ami_instance2" {
  ami           = "ami-0bad4a5e987bdebde"
  instance_type = "m3.medium"
  #iam_instance_profile = "prod-devops-role"
  key_name = var.key_name
  subnet_id = "subnet-0c838269bd0c1527f"
  vpc_security_group_ids               = [
        "sg-0c0c0045974cc9a65",
    ]
  root_block_device {
        delete_on_termination = true
        volume_size           = 60
        volume_type           = "gp2"
    }
  user_data = file("./script/userdata-base.sh")
  tags = {
    Name = "base-ami-n"
  }
}
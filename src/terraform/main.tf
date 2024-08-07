terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }

    backend "s3" {
        bucket = "visitorterraformstate"
        dynamodb_table = "state-lock"
        key = "global/mystatefile/terraform.tfstate"
        region = "eu-north-1"
        encrypt = true
    }

}

provider "aws" {
    region = "ap-southeast-2"
}

variable "flask_port" {
    type        = number
    default     = 5000
}

variable "http_port" {
    type        = number
    default     = 80
}

variable "ssh_port" {
    type        = number
    default     = 22
}

variable "outbound_anywhere" {
    type = number
    default = 0
}

# Security Group
resource "aws_security_group" "flask-terraform-sg" {
    name = "terraform-example-instance"

    ingress {
        description = "Flask"
        from_port   = var.flask_port
        to_port     = var.flask_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Webserver"
        from_port   = var.http_port
        to_port     = var.http_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH"
        from_port   = var.ssh_port
        to_port     = var.ssh_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Outbound"
        from_port   = var.outbound_anywhere
        to_port     = var.outbound_anywhere
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
    value       = aws_instance.flask.public_ip
    description = "Public IP of EC2 instance"
}

resource "aws_instance" "flask" {
    ami = "ami-076fe60835f136dc9"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.flask-terraform-sg.id]

    user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    cd /home/ubuntu/
    rm -rf SCA_Devops_Python_Project_Terraform
    git clone https://github.com/maryjonah/SCA_Devops_Python_Terraform.git
    cd SCA_Devops_Python_Terraform
    sudo apt install python3-venv -y
    sudo apt install python3-pip -y
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    cd src/
    flask run --host=0.0.0.0
    EOF

    user_data_replace_on_change = true

    tags = {
        Name = "sca-flask-terraform"
    }
}

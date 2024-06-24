terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
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
    region = "us-east-2"
}

variable "server_port" {
    type        = number
    default     = 5000
}

output "public_ip" {
    value       = aws_instance.flask.public_ip
    description = "The public IP address of the web server to view webpage"
}

resource "aws_instance" "flask" {
    ami = "ami-033fabdd332044f06"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.flask-terraform-sg.id]

    user_data = <<EOF
    cd /home/ubuntu/ &&
    rm -rf SCA_Devops_Python_Project_Terraform
    git clone https://github.com/maryjonah/SCA_Devops_Python_Terraform.git
    cd SCA_Devops_Python_Terraform
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    cd src/
    flask run --host=0.0.0.0
    EOF

    user_data_replace_on_change = true

    tags = {
        Name = "sca-flask-terraform-project"
    }
}

resource "aws_security_group" "flask-terraform-sg" {
    name = "terraform-example-instance"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
}

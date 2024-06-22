terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
    
    backend "s3" {
        key = "terraform.tfstate"
        region = "us-east-2"
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
    ami = "ami-0fb653ca2d3203ac1"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]

    user_data = <<-EOF
              cd /home/ubuntu/ &&
              rm -rf SCA_Devops_Python_Project_Terraform
              git clone https://github.com/maryjonah/SCA_Devops_Python_Terraform.git
              cd SCA_Devops_Python_Terraform
              git checkout main &&
              git reset --hard origin/main &&
              git pull origin main &&
              python3 -m venv venv
              source venv/bin/activate
              pip install -r requirements.txt
              cd src/
              flask run --host=0.0.0.0                
              EOF

    user_data_replace_on_change = true

    tags = {
        Name = "terraform-example"
    }
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port   = 80
        to_port     = 80
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

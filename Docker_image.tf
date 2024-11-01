variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "domain_name" {
  description = "The domain name for the Route 53 record"
  type        = string
}

variable "subdomain" {
  description = "The subdomain to point to the EC2 instance"
  type        = string
}

resource "aws_instance" "docker" {
  ami           = "ami-09c813fb71547fc4f"
  instance_type = var.instance_type

  # key_name      = "your-key-pair-name"    # Replace with your key pair name

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }

  # Reference the install_docker.sh file
  user_data = file("install_docker.sh")

  tags = {
    Name = "Docker"
  }
}

data "aws_route53_zone" "selected" {
  name = var.domain_name
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.subdomain
  type    = "A"
  ttl     = "300"
  records = [aws_instance.web_server.public_ip]
}

output "instance_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "instance_dns_name" {
  value = aws_route53_record.app.fqdn
}

resource "aws_security_group" "allow_ssh_ping" {
  name        = "allow_ssh_ping"
  description = "Security group that allows SSH and ping (ICMP) from any IP address"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from any IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ICMP ping from any IP"
    from_port   = -1 # -1 allows all ICMP types and codes
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 allows all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_ping"
  }
}

# Data source to fetch the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# EC2 Instance using the latest Amazon Linux 2 AMI
resource "aws_instance" "ping_test_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh_ping.id]
  subnet_id              = var.subnet_id
  private_ip             = var.private_ip

  tags = {
    Name = "peered-instance"
  }
}
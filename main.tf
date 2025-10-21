# main.tf

# Create Security Group
resource "aws_security_group" "ec2_sg" {
  name_prefix = "${var.instance_name}-sg"
  description = "Security group for ${var.instance_name} EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  # HTTP access (conditional)
  dynamic "ingress" {
    for_each = var.enable_http ? [1] : []
    content {
      description = "HTTP access"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # HTTPS access (conditional)
  dynamic "ingress" {
    for_each = var.enable_https ? [1] : []
    content {
      description = "HTTPS access"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.instance_name}-security-group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create EC2 Instance
resource "aws_instance" "main" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = data.aws_subnet.default.id
  
  # Enable/disable detailed monitoring
  monitoring = var.enable_monitoring
  
  # Associate public IP
  associate_public_ip_address = true

  # Root block device configuration
  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    encrypted   = true
    
    tags = {
      Name = "${var.instance_name}-root-volume"
    }
  }

  # User data script (if provided)
  user_data = var.user_data_script != "" ? var.user_data_script : templatefile("${path.module}/user-data.sh", {
    instance_name = var.instance_name
  })

  tags = {
    Name = var.instance_name
    Type = "EC2Instance"
  }

  # Prevent accidental termination
  lifecycle {
    create_before_destroy = true
  }
}

# Create Elastic IP (optional)
resource "aws_eip" "main" {
  count    = var.environment == "prod" ? 1 : 0
  instance = aws_instance.main.id
  domain   = "vpc"

  tags = {
    Name = "${var.instance_name}-eip"
  }

  depends_on = [aws_instance.main]
}

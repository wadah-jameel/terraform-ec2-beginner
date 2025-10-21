#!/bin/bash
# user-data.sh

# Update system packages
yum update -y

# Install useful packages
yum install -y htop git curl wget nano

# Install Docker (optional)
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install Apache web server
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Create a simple welcome page
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to ${instance_name}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .header { background-color: #f4f4f4; padding: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎉 Welcome to ${instance_name}</h1>
            <p>Your Terraform-deployed EC2 instance is running successfully!</p>
            <p><strong>Instance Details:</strong></p>
            <ul>
                <li>Hostname: $(hostname)</li>
                <li>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</li>
                <li>Instance Type: $(curl -s http://169.254.169.254/latest/meta-data/instance-type)</li>
                <li>Public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)</li>
                <li>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</li>
            </ul>
            <p>Deployed with ❤️ using Terraform</p>
        </div>
    </div>
</body>
</html>
EOF

# Set up log rotation for application logs
cat > /etc/logrotate.d/terraform-app << EOF
/var/log/terraform-app.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
}
EOF

# Log deployment completion
echo "$(date): User data script completed successfully" >> /var/log/terraform-app.log

# Send completion signal (optional)
echo "Instance ${instance_name} deployed successfully at $(date)" > /tmp/deployment-complete.txt

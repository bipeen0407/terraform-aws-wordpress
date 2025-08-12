#!/bin/bash

# Mount EFS
EFS_ID="${efs_id}"
MOUNT_POINT="/var/www/html/wp-content/uploads"
mkdir -p -m 777 $MOUNT_POINT
yum install -y amazon-efs-utils
mount -t efs -o tls ${efs_id}:/ $MOUNT_POINT
echo "${efs_id}:/ $MOUNT_POINT efs defaults,_netdev 0 0" >> /etc/fstab

# Retrieve Aurora DB password securely from AWS Secrets Manager
DB_SECRET_ARN="${db_secret_arn}"
DB_NAME="${db_name}"
DB_USER="${db_user}"
DB_HOST="${db_host}"

# Install AWS CLI for secret retrieval if not already present
yum install -y awscli

# Get password from Secrets Manager
DB_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id "$DB_SECRET_ARN" \
  --region $(curl -s http://169.254.169.254/latest/meta-data/placement/region) \
  --query SecretString --output text | jq -r .password)

# Save to environment file, set exports for app use
cat <<ENVVARS > /etc/wordpress-db.env
DB_NAME="${db_name}"
DB_USER="${db_user}"
DB_PASSWORD="$${DB_PASSWORD}"  # <--- ESCAPE THE BASH VARIABLE HERE!
DB_HOST="${db_host}"
ENVVARS

export DB_NAME="${db_name}"
export DB_USER="${db_user}"
export DB_PASSWORD="$${DB_PASSWORD}" # <--- AND HERE!
export DB_HOST="${db_host}"

# Optionally update wp-config.php with secrets for WordPress connectivity
sed -i "s/define('DB_NAME'.*/define('DB_NAME', '${db_name}');/" /var/www/html/wp-config.php
sed -i "s/define('DB_USER'.*/define('DB_USER', '${db_user}');/" /var/www/html/wp-config.php
sed -i "s/define('DB_PASSWORD'.*/define('DB_PASSWORD', '$${DB_PASSWORD}');/" /var/www/html/wp-config.php # <--- AND HERE!
sed -i "s/define('DB_HOST'.*/define('DB_HOST', '${db_host}');/" /var/www/html/wp-config.php

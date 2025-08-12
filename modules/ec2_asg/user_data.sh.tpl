#!/bin/bash

# Mount EFS
EFS_ID="${efs_id}"
MOUNT_POINT="/var/www/html/wp-content/uploads"
mkdir -p -m 777 $MOUNT_POINT
yum install -y amazon-efs-utils
mount -t efs -o tls ${EFS_ID}:/ $MOUNT_POINT
echo "${EFS_ID}:/ $MOUNT_POINT efs defaults,_netdev 0 0" >> /etc/fstab

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
DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"
DB_PASSWORD="${DB_PASSWORD}"
DB_HOST="${DB_HOST}"
ENVVARS

export DB_NAME="${DB_NAME}"
export DB_USER="${DB_USER}"
export DB_PASSWORD="${DB_PASSWORD}"
export DB_HOST="${DB_HOST}"

# Optionally update wp-config.php with secrets for WordPress connectivity
sed -i "s/define('DB_NAME'.*/define('DB_NAME', '${DB_NAME}');/" /var/www/html/wp-config.php
sed -i "s/define('DB_USER'.*/define('DB_USER', '${DB_USER}');/" /var/www/html/wp-config.php
sed -i "s/define('DB_PASSWORD'.*/define('DB_PASSWORD', '${DB_PASSWORD}');/" /var/www/html/wp-config.php
sed -i "s/define('DB_HOST'.*/define('DB_HOST', '${DB_HOST}');/" /var/www/html/wp-config.php


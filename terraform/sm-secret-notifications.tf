resource "random_password" "notifications_secret_password" {
  length  = 20
  special = false
}

resource "aws_secretsmanager_secret" "secrets_notifications" {
  name = "notifications_secrets"
}

resource "aws_secretsmanager_secret_version" "secrets_version_notifications" {
  secret_id     = aws_secretsmanager_secret.secrets_notifications.id
  secret_string = jsonencode({
    BCRYPT_SALT       = "10"
    JWT_EXPIRATION    = "2d"
    JWT_SECRET_KEY    = random_password.notifications_secret_password.result
    DB_URL            = "postgres://${module.rds_notifications.db_instance_username}:${random_password.notifications_database_password.result}@${module.rds_notifications.db_instance_address}:5432/${module.rds_notifications.db_instance_name}"
  })
}

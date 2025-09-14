output "database_instance_name" {
  description = "The name of the Cloud SQL instance"
  value       = google_sql_database_instance.culture_rails_postgres.name
}

output "database_instance_connection_name" {
  description = "The connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.culture_rails_postgres.connection_name
}

output "database_instance_private_ip" {
  description = "The private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.culture_rails_postgres.private_ip_address
}

output "database_name" {
  description = "The name of the database"
  value       = google_sql_database.culture_rails_database.name
}

output "database_user" {
  description = "The database user name"
  value       = google_sql_user.database_user.name
  sensitive   = true
}

output "database_password_secret_name" {
  description = "The name of the secret containing the database password"
  value       = google_secret_manager_secret.database_password.secret_id
}

output "database_url" {
  description = "The database URL for Rails (without password)"
  value       = "postgresql://${google_sql_user.database_user.name}@${google_sql_database_instance.culture_rails_postgres.private_ip_address}:5432/${google_sql_database.culture_rails_database.name}"
  sensitive   = true
}

output "database_host" {
  description = "The database host"
  value       = google_sql_database_instance.culture_rails_postgres.private_ip_address
}

output "database_port" {
  description = "The database port"
  value       = "5432"
}
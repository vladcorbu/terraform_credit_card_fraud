output "this_rds_cluster_master_password" {
  description = "The master password"
  value       = module.db.cluster_master_password
  sensitive   = true
}


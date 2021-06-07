// Project setting
region          = "europe-west2"
zone            = "europe-west2-a"
gcp_project     = "training-project-task-3"
credentials     = "credentials.json"

// Network setting
network_name    = "dev"
subnet_cidr     = "10.10.0.0/24"

//Instance setting
instance_name   = "web"
machine_type    = "f1-micro"
instance_image  = "ubuntu-os-cloud/ubuntu-2004-lts"
instance_count  = "2"
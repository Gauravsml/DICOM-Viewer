provider "google" {
  project = "myspringml2"
  region  = "us-central1"
}

# Create bucket to upload dicom
resource "google_storage_bucket" "upload" {
  name          = "terraform-upload-dicom"
  project 	= "myspringml2"
  location      = "US"
}

# Create bucket to put predicted dicom
resource "google_storage_bucket" "predicted" {
  name          = "terraform-predicted-dicom"
  project 	= "myspringml2"
  location      = "US"
}

resource "google_storage_bucket" "bucket" {
  name = "terraform-dicom-image-trigger-cloud-function-code"
}

# Bucket where cloud function code is kept
resource "google_storage_bucket_object" "archive" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./"
}

# Create cloud function
resource "google_cloudfunctions_function" "function" {
  name        = "terraform-dicom-image-trigger"
  description = "To trigger cloud composer once image gets uploaded in the bucket"
  runtime     = "python37"

  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  #entry_point = "function_gcs_event_trigger_dag" 
  #trigger_bucket = "terraform-upload-dicom"
  event_trigger {
  event_type		= "providers/cloud.storage/eventTypes/object.change"
  resource		= google_storage_bucket.upload.name
  failure_policy {
      retry = true
    }
  }
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_composer_environment" "hls-webinar" {
  name   = "hls-webinar-2"
  region = "us-central1"

  config {
    software_config {
      airflow_config_overrides = {
        core-load_example = "True"
      }

      pypi_packages = {
        pydicom = ""
        uuid = ""
        pillow = ""
        torchvision = ""
        img2vec-pytorch = ""
        torch = ""
        scikit-learn = ""
        pandas = ""
        xgboost = "==1.0.2"
        opencv-python-headless = ""
      }
    }
  }
}

resource "google_healthcare_dataset" "dataset" {
  name      = "dicom-datastore"
  location  = "us-central1"
  time_zone = "UTC"
}

resource "google_pubsub_topic" "topic" {
  name     = "projects/myspringml2/topics/dicom-annotated"
}

resource "google_healthcare_dicom_store" "default" {
  name    = "example-dicom-store"
  dataset = google_healthcare_dataset.dataset.id

  notification_config {
    pubsub_topic = google_pubsub_topic.topic.id
  }

  labels = {
    label1 = "labelvalue1"
  }
}

resource "google_container_node_pool" "pool-1" {
  name       = "pool-1"
  location   = "us-central1-c"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  timeouts {
    create = "30m"
    update = "20m"
  }
}

resource "google_container_node_pool" "pool-2" {
  name       = "pool-2"
  location   = "us-central1-c"
  cluster    = google_container_cluster.primary.name
  node_count = 3

  timeouts {
    create = "30m"
    update = "20m"
  }
}

resource "google_container_cluster" "primary" {
  name               = "hls-cluster"
  location           = "us-central1-c"
  initial_node_count = 2

  node_locations = [
    "us-central1-c",
  ]

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    machine_type = "n1-standard-1"

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
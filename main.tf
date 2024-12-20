# resource "google_storage_bucket" "auto-expire" {
#   name          = "gcp-demo-416310"
#   location      = "US"
#   force_destroy = true

#   lifecycle_rule {
#     condition {
#       age = 3
#     }
#     action {
#       type = "Delete"
#     }
#   }

#   lifecycle_rule {
#     condition {
#       age = 1
#     }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}
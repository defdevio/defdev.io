lambda_functions = {
  cloudflare_turnstile_validator = {
    spec = {
      description = "Handles validation of the CloudFlare turnstile"
      timeout     = 60
      ecr = {
        is_immutable = false
        image_tag    = "latest"
      }
    }
  }
  emailer = {
    spec = {
      description = "Handles the Contact Us form for defdev.io"
      timeout     = 60
      ecr = {
        is_immutable = false
        image_tag    = "latest"
      }
    }
  }
}

s3_buckets = {
  "defdev.io" = {
    spec = {
      is_bucket_website = true
      redirect_all_requests_to = {
        "www.defdev.io" = {
          protocol = "https"
        }
      }
    }
  }
  "www.defdev.io" = {
    spec = {
      source_file_path    = "../src"
      source_file_pattern = "**"
    }
  }
}
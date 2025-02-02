ecr_repos = {
  "defdevio/lambda-emailer" = {
    spec = {
      is_immutable = false
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
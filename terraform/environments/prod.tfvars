s3_buckets = {
  "defdev.io" = {
    is_bucket_website = true
    redirect_all_requests_to = {
      "www.defdev.io" = {
        protocol = "https"
      }
    }
  }
  "www.defdev.io" = {
    source_file_path    = "../src"
    source_file_pattern = "**"
  }
}
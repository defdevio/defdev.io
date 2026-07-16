resource "aws_cloudfront_response_headers_policy" "giscus_theme_cors" {
  name    = "${replace(var.origin_id, ".", "-")}-giscus-theme-cors"
  comment = "Allow giscus.app to fetch the custom theme stylesheet cross-origin"

  cors_config {
    access_control_allow_credentials = false

    access_control_allow_headers {
      items = ["*"]
    }

    access_control_allow_methods {
      items = ["GET", "HEAD"]
    }

    access_control_allow_origins {
      items = ["https://giscus.app"]
    }

    origin_override = true
  }
}

resource "aws_cloudfront_distribution" "this" {
  aliases             = var.aliases
  default_root_object = var.default_root_object
  enabled             = true
  is_ipv6_enabled     = false
  price_class         = "PriceClass_100"

  origin {
    domain_name              = var.domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
    origin_id                = var.origin_id
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.url_rewrite.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", ]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_cloudfront_function" "url_rewrite" {
  name    = "${replace(var.origin_id, ".", "-")}-url-rewrite"
  runtime = "cloudfront-js-1.0"
  publish = true
  comment = "Rewrite static routes to index.html for S3 origin"
  code    = <<-EOT
function handler(event) {
  var request = event.request;
  var uri = request.uri;

  // Keep direct file requests unchanged (assets, images, etc.)
  if (uri.includes('.')) {
    return request;
  }

  // Map clean URLs to static index files.
  if (uri.endsWith('/')) {
    request.uri = uri + 'index.html';
  } else {
    request.uri = uri + '/index.html';
  }

  return request;
}
EOT
}
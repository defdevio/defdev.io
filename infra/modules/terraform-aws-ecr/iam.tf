resource "aws_ecr_repository_policy" "this" {
  count      = var.repo_policy_document != null ? 1 : 0
  repository = aws_ecr_repository.this.name
  policy     = var.repo_policy_document
}
provider "aws" {
  region = "us-east-1"
}

# Creating a KMS Key to encrypt the ECR Repos

resource "aws_kms_key" "ecr_encryption_kms_key" {
  description = "KMS key for ECR encryption"
  deletion_window_in_days = 7

}

# Attaching the policy to the KMS 
resource "aws_kms_key_policy" "example" {
  key_id = aws_kms_key.ecr_encryption_kms_key.id
  policy = jsonencode({
    Id = "ecr_kms_key_may"
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
           AWS = "*"
        }
        Resource = "*"

        Sid      = "Enable IAM User Permissions"
      },
    ]
    Version = "2012-10-17"
  })
}


# Creating 3 Repos with Scan_on-push and Encryption

resource "aws_ecr_repository" "repo1" {
  name                 = "repo1"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key          = aws_kms_key.ecr_encryption_kms_key.arn
  }
}

resource "aws_ecr_repository" "repo2" {
  name                 = "repo2"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key          = aws_kms_key.ecr_encryption_kms_key.arn
  }
}

resource "aws_ecr_repository" "repo3" {
  name                 = "repo3"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key          = aws_kms_key.ecr_encryption_kms_key.arn
  }
}

# Attaching a Policy to delete the Repo after 8 images

resource "aws_ecr_lifecycle_policy" "lifecycle_policy1" {
  repository = aws_ecr_repository.repo1.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep 8 most recent images"
      selection    = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 8
      }
      action      = {
        type = "expire"
      }
    }]
  })
}

resource "aws_ecr_lifecycle_policy" "lifecycle_policy2" {
  repository = aws_ecr_repository.repo2.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep 8 most recent images"
      selection    = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 8
      }
      action      = {
        type = "expire"
      }
    }]
  })
}

resource "aws_ecr_lifecycle_policy" "lifecycle_policy3" {
  repository = aws_ecr_repository.repo3.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep 8 most recent images"
      selection    = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 8
      }
      action      = {
        type = "expire"
      }
    }]
  })
}


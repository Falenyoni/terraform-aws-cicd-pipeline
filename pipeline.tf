resource "aws_codebuild_project" "tf_plan" {
  name = "tf_cicd_plan"
  description = "Plan stage for Terraform"
  service_role = aws_iam_role.tf_codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "hashicorp/terraform:latest"
    type = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
      credential = var.dockerhub_credentials
      credential_provider = "SECRETS_MANAGER"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("buildspec/plan-buildspec.yml")
  }

}

resource "aws_codebuild_project" "tf_apply" {
  name = "tf_cicd_apply"
  description = "Apply stage for Terraform"
  service_role = aws_iam_role.tf_codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "hashicorp/terraform:latest"
    type = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
      credential = var.dockerhub_credentials
      credential_provider = "SECRETS_MANAGER"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("buildspec/apply-buildspec.yml")
  }

}


resource "aws_codepipeline" "tf_cicd_pipeline" {
  name = "tf-cicd"
  role_arn = aws_iam_role.tf_codepipeline_role.arn

  artifact_store {
    type = "S3"
    location = aws_s3_bucket.fn-terraform_codepipeline_artifacts_bucket.id
  }

  stage {
    name = "Source"
    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeStarSourceConnection"
      version = "1"
      output_artifacts = ["tf-code"]
      configuration = {
        FullRepositoryId = "Falenyoni/terraform-aws-cicd-pipeline"
        BranchName = "main"
        ConnectionArn = var.codestar_connector_credentials
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Plan"
    action {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["tf-code"]
      configuration = {
        ProjectName = "tf-cicd-plan"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name = "Deploy"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["tf-code"]
      configuration = {
        ProjectName = "tf-cicd-apply"
      }
    }
  }

}
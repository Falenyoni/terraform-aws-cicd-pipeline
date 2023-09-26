resource "aws_iam_role" "tf_codepipeline_role" {
  name               = "tf_codepipeline_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "codepipeline.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
  })
}

## policy document
data "aws_iam_policy_document" "tf_cicd_pipeline-policies" {
  statement {
    sid = ""
    actions = [ "codestar-connections:UseConnection" ]
    resources = [ "*" ]
    effect = "Allow"
  }
  statement {
    sid = ""
    actions = [ "cloudwatch:*","s3:*","codebuild:*" ]
    resources = [ "*" ]
    effect = "Allow"
  }
}
# IAM POlicy for logging from lambda

resource "aws_iam_policy" "tf_cicd_codepipeline_policy" {
  name        = "tf_cicd_codepipeline_policy"
  path        = "/"
  description = "Pipeline Policy"
  policy      = data.aws_iam_policy_document.tf_cicd_pipeline-policies.json
}

# Policy Attachment on the role.

resource "aws_iam_role_policy_attachment" "tf_cicd_pipeline_attachment" {
  role       = aws_iam_role.tf_codepipeline_role.id
  policy_arn = aws_iam_policy.tf_cicd_codepipeline_policy.arn
}


## Code Build Configuration

resource "aws_iam_role" "tf_codebuild_role" {
  name               = "tf_codebuild_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "codebuild.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
  })
}

## policy document
data "aws_iam_policy_document" "tf_codebuild-policies" {
   statement {
    sid = ""
    actions = [ "logs:*","s3:*","codebuild:*","secretsmanager:*", "iam:*" ]
    resources = [ "*" ]
    effect = "Allow"
  }
}
# IAM POlicy for logging from lambda

resource "aws_iam_policy" "tf_cicd_codebuild_policy" {
  name        = "tf-cicd-codebuild-policy"
  path        = "/"
  description = "CodeBuild policy"
  policy      = data.aws_iam_policy_document.tf_codebuild-policies.json
}

# Policy Attachment on the role.

resource "aws_iam_role_policy_attachment" "tf_cicd_codebuild_attachment1" {
  role       = aws_iam_role.tf_codebuild_role.id
  policy_arn = aws_iam_policy.tf_cicd_codebuild_policy.arn
}

resource "aws_iam_role_policy_attachment" "tf_cicd_codebuild_attachment2" {
  role       = aws_iam_role.tf_codebuild_role.id
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
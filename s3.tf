resource "random_pet" "terraform_codepipeline_artifacts_bucket" {
  prefix = "lambda"
  length = 2

}

resource "aws_s3_bucket" "fn-terraform_codepipeline_artifacts_bucket" {
  bucket        = random_pet.terraform_codepipeline_artifacts_bucket.id
  force_destroy = true
}
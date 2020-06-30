resource "aws_batch_job_queue" "terraform_example_batch_queue" {
  name = "terraform-example-batch-queue"
  state = "ENABLED"
  priority = 1
  compute_environments = [
    aws_batch_compute_environment.terraform_example_batch.arn
  ]
}
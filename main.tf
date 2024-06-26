provider "aws" {
  region = "OREGON"
}

resource "aws_s3_bucket" "bucket1" {
  bucket = "VvidArts_Upload_0112358"
  # acl    = "private"
}

resource "aws_s3_bucket" "bucket2" {
  bucket = "VvidArts_Download_0112358"
  # acl    = "private"
}

resource "aws_lambda_function" "s3_image_processor" {
  function_name = "YOUR_LAMBDA_FUNCTION_NAME"

  # The S3 bucket that contains the deployment package
  s3_bucket = aws_s3_bucket.bucket1.bucket
  s3_key    = "lambda_function_payload.zip"

  handler = "index.handler"
  role    = "YOUR_LAMBDA_ROLE_ARN"
  runtime = "nodejs12.x"

  environment {
    variables = {
      BUCKET = aws_s3_bucket.bucket2.bucket
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket1.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_image_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_image_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.bucket1.arn}/*"
}

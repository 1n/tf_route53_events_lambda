# better have separate CI process for lambda
data "external" "build_lambda" {
  program = ["/bin/bash", "${path.module}/build_lambda.sh"]
}

data "archive_file" "lambda_package" {
  type             = "zip"
  source_file      = "lambda/build/main"
  output_file_mode = "0666"
  output_path      = local.lambda_package_path

  depends_on = [
    data.external.build_lambda
  ]
}
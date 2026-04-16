resource "aws_ssm_parameter" "lca_settings" {
  name  = "lca-settings-${var.lob}"
  type  = "String"
  value = "{}"

  tags = {
    Project     = "LCA"
    LOB         = var.lob
    ManagedBy   = "Terraform"
    Environment = "production"
  }
}

resource "aws_lambda_function" "update_lca_settings" {
  function_name = "update-lca-settings-${var.lob}"
  role          = var.update_settings_role_arn
  handler       = "index.handler"
  runtime       = "python3.12"
  filename      = "${path.module}/../../lambda-files/update-lca-settings.zip"
  source_code_hash = filebase64sha256("${path.module}/../../lambda-files/update-lca-settings.zip")
  timeout       = 900
  architectures = ["x86_64"]

  tags = {
    Project     = "LCA"
    LOB         = var.lob
    ManagedBy   = "Terraform"
    Environment = "production"
  }
}

resource "aws_lambda_invocation" "update_lca_settings_initial" {
  function_name = aws_lambda_function.update_lca_settings.function_name

  input = jsonencode({
    RequestType        = "Create"
    ResponseURL        = "https://localhost/cfn-response-noop"
    StackId            = "arn:aws:cloudformation:us-east-1:000000000000:stack/terraform-managed/00000000"
    RequestId          = "terraform-update-lca-settings"
    ResourceType       = "Custom::UpdateLCASettings"
    LogicalResourceId  = "UpdateLCASettings"
    ResourceProperties = {
      LCASettingsName          = aws_ssm_parameter.lca_settings.name
      LCASettingsKeyValuePairs = {
        CategoryAlertRegex = var.category_alert_regex
      }
    }
    LCASettingsName          = aws_ssm_parameter.lca_settings.name
    LCASettingsKeyValuePairs = {
      CategoryAlertRegex = var.category_alert_regex
    }
  })

  depends_on = [
    aws_lambda_function.update_lca_settings,
    aws_ssm_parameter.lca_settings
  ]
}

resource "aws_lambda_function" "llm_prompt_upload" {
  function_name = "llm-prompt-upload-${var.lob}"
  role          = var.llm_prompt_upload_role_arn
  handler       = "llm_prompt_upload.lambda_handler"
  runtime       = "python3.12"
  filename      = "${path.module}/../../lambda-files/llm-prompt-upload.zip"
  source_code_hash = filebase64sha256("${path.module}/../../lambda-files/llm-prompt-upload.zip")
  timeout       = 60
  architectures = ["x86_64"]

  tags = {
    Project     = "LCA"
    LOB         = var.lob
    ManagedBy   = "Terraform"
    Environment = "production"
  }
}

resource "aws_lambda_invocation" "seed_llm_prompts" {
  function_name = aws_lambda_function.llm_prompt_upload.function_name

  input = jsonencode({
    RequestType                = "Create"
    ResponseURL                = "https://localhost/cfn-response-noop"
    StackId                    = "arn:aws:cloudformation:us-east-1:000000000000:stack/terraform-managed/00000000"
    RequestId                  = "terraform-seed-llm-prompts"
    ResourceType               = "Custom::SeedLLMPrompts"
    LogicalResourceId          = "SeedLLMPrompts"
    ResourceProperties         = {
      LLMPromptTemplateTableName = var.llm_prompt_table_name
    }
    LLMPromptTemplateTableName = var.llm_prompt_table_name
  })

  depends_on = [aws_lambda_function.llm_prompt_upload]
}

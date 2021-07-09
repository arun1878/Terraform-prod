resource "aws_dynamodb_table" "PurmoUserGatewayAttributes" {
  name           = "UserGatewayAttributes"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "GatewayID"
  range_key      = "UserGatewayAttributesId"

  attribute {
    name = "GatewayID"
    type = "S"
  }
  
  attribute {
    name= "UserGatewayAttributesId"
    type= "S"  
  }
}
resource "aws_dynamodb_table" "PurmoGatewayStatusList" {
  name           = "GatewayStatusList"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "GatewayID"
  range_key      = "StatusID"

  attribute {
    name = "GatewayID"
    type = "S"
  }
  
  attribute {
    name= "StatusID"
    type= "S"  
  }
}
resource "aws_dynamodb_table" "PurmoUserDeviceGroupList" {
  name           = "UserDeviceGroupList"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "GatewayID"
  range_key      = "GroupID"

  attribute {
    name = "GatewayID"
    type = "S"
  }
  
  attribute {
    name= "GroupID"
    type= "S"  
  }
}
resource "aws_dynamodb_table" "PurmoGatewayToDeviceList" {
  name           = "GatewayToDeviceList"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "GatewayID"
  range_key      = "DeviceID"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  attribute {
    name = "DeviceID"
    type = "S"
  }
  
  attribute {
    name= "GatewayID"
    type= "S"  
  }
}
resource "aws_dynamodb_table" "PurmoUserDeviceAttributes" {
  name           = "UserDeviceAttributes"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "GatewayID"
  range_key      = "UserDeviceAttributesId"

  attribute {
    name = "GatewayID"
    type = "S"
  }
  
  attribute {
    name= "UserDeviceAttributesId"
    type= "S"  
  }
}
resource "aws_dynamodb_table" "PurmoAutomationList" {
  name           = "AutomationList"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "GatewayID"
  range_key      = "AutomationId"

  attribute {
    name = "AutomationId"
    type = "S"
  }
  
  attribute {
    name= "GatewayID"
    type= "S"  
  }
}
resource "aws_dynamodb_table" "PurmoUserAutomationAttributes" {
  name           = "UserAutomationAttributes"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "GatewayID"
  range_key      = "AutomationId"

  attribute {
    name = "AutomationId"
    type = "S"
  }
  
  attribute {
    name= "GatewayID"
    type= "S"  
  }
}
resource "aws_dynamodb_table" "PurmoUsersAndPermissions" {
  name           = "UsersAndPermissions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "UserPermissionsId"
  range_key      = "GatewayID"

  attribute {
    name = "UserPermissionsId"
    type = "S"
  }
  
  attribute {
    name= "GatewayID"
    type= "S"  
  }
}
resource "aws_dynamodb_table" "PurmoUserNotificationTokens" {
  name           = "UserNotificationTokens"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "Token"
  range_key      = "userid"

  attribute {
    name = "Token"
    type = "S"
  }
  
  attribute {
    name= "userid"
    type= "S"  
  }
}
resource "aws_dynamodb_table" "PurmoGatewayAttributes" {
  name           = "GatewayAttributes"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "GatewayID"
  range_key      = null

  attribute {
    name = "GatewayID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "PurmoUserAttributes" {
  name           = "UserAttributes"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "user_id"
  range_key      = null

  attribute {
    name = "user_id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "PurmoOtp" {
  name           = "Otp"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "userid"
  range_key      = "PhoneNo"

  attribute {
    name = "userid"
    type = "S"
  }
  attribute {
    name = "PhoneNo"
    type = "S"
  }
  ttl {
    attribute_name = "Expiry"
    enabled        = true
  }
}

# resource "aws_lambda_event_source_mapping" "PurmoGatewayToDeviceList" {
#   event_source_arn  = aws_dynamodb_table.PurmoGatewayToDeviceList.stream_arn
#   function_name     = var.lambda_arn
#   starting_position = "TRIM_HORIZON"
#   maximum_retry_attempts = 10
# }

# resource "aws_lambda_event_source_mapping" "PurmoUserToDeviceList" {
#   event_source_arn  = aws_dynamodb_table.PurmoUserToDeviceList.stream_arn
#   function_name     = var.lambda_arn
#   starting_position = "LATEST" 
#   maximum_retry_attempts = 10
# }
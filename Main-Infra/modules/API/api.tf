########################################################################################
#    OTP  API GATEWAY                                                                  #
########################################################################################
resource "aws_api_gateway_rest_api" "OTP" {
  body = jsonencode({
    "swagger" : "2.0",
    "info" : {
      "description" : "to send OTP to a SNS service",
      "version" : "2021-06-30T08:39:32Z",
      "title" : "OTP"
    },
    "paths" : {
      "/send" : {
        "post" : {
          "consumes" : [
            "application/json"
          ],
          "produces" : [
            "application/json"
          ],
          "parameters" : [
            {
              "name" : "userid",
              "in" : "query",
              "required" : true,
              "type" : "string"
            },
            {
              "name" : "PhoneNo",
              "in" : "query",
              "required" : true,
              "type" : "string"
            },
            {
              "in" : "body",
              "name" : "Empty",
              "required" : true,
              "schema" : {
                "$ref" : "#/definitions/Empty"
              }
            }
          ],
          "responses" : {
            "200" : {
              "description" : "200 response",
              "schema" : {
                "$ref" : "#/definitions/Empty"
              }
            },
            "400" : {
              "description" : "400 response",
              "schema" : {
                "$ref" : "#/definitions/Empty"
              }
            },
            "401" : {
              "description" : "401 response",
              "schema" : {
                "$ref" : "#/definitions/Empty"
              }
            }
          },
          "x-amazon-apigateway-integration" : {
            "httpMethod" : "POST",
            "uri" : "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.otp_arn}/invocations",
            "responses" : {
              "default" : {
                "statusCode" : "200"
              },
              ".*\"message\":.*Authentication.*" : {
                "statusCode" : "401",
                "responseTemplates" : {
                  "application/json" : "$input.path('$.errorMessage')"
                }
              },
              ".*\"message\":.*Badrequest.*" : {
                "statusCode" : "400",
                "responseTemplates" : {
                  "application/json" : "$input.path('$.errorMessage')"
                }
              }
            },
            "requestTemplates" : {
              "application/json" : "##  See http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-mapping-template-reference.html\n##  This template will pass through all parameters including path, querystring, header, stage variables, and context through to the integration endpoint via the body/payload\n#set($allParams = $input.params())\n{\n\"body-json\" : $input.json('$'),\n\"params\" : {\n#foreach($type in $allParams.keySet())\n    #set($params = $allParams.get($type))\n\"$type\" : {\n    #foreach($paramName in $params.keySet())\n    \"$paramName\" : \"$util.escapeJavaScript($params.get($paramName))\"\n        #if($foreach.hasNext),#end\n    #end\n}\n    #if($foreach.hasNext),#end\n#end\n},\n\"stage-variables\" : {\n#foreach($key in $stageVariables.keySet())\n\"$key\" : \"$util.escapeJavaScript($stageVariables.get($key))\"\n    #if($foreach.hasNext),#end\n#end\n},\n\"context\" : {\n    \"account-id\" : \"$context.identity.accountId\",\n    \"api-id\" : \"$context.apiId\",\n    \"api-key\" : \"$context.identity.apiKey\",\n    \"authorizer-principal-id\" : \"$context.authorizer.principalId\",\n    \"caller\" : \"$context.identity.caller\",\n    \"cognito-authentication-provider\" : \"$context.identity.cognitoAuthenticationProvider\",\n    \"cognito-authentication-type\" : \"$context.identity.cognitoAuthenticationType\",\n    \"cognito-identity-id\" : \"$context.identity.cognitoIdentityId\",\n    \"cognito-identity-pool-id\" : \"$context.identity.cognitoIdentityPoolId\",\n    \"http-method\" : \"$context.httpMethod\",\n    \"stage\" : \"$context.stage\",\n    \"source-ip\" : \"$context.identity.sourceIp\",\n    \"user\" : \"$context.identity.user\",\n    \"user-agent\" : \"$context.identity.userAgent\",\n    \"user-arn\" : \"$context.identity.userArn\",\n    \"request-id\" : \"$context.requestId\",\n    \"resource-id\" : \"$context.resourceId\",\n    \"resource-path\" : \"$context.resourcePath\"\n    }\n}\n"
            },
            "passthroughBehavior" : "when_no_templates",
            "contentHandling" : "CONVERT_TO_TEXT",
            "type" : "aws"
          }
        }
      },
      "/verify" : {
        "post" : {
          "consumes" : [
            "application/json"
          ],
          "produces" : [
            "application/json"
          ],
          "parameters" : [
            {
              "name" : "userid",
              "in" : "query",
              "required" : true,
              "type" : "string"
            },
            {
              "name" : "OTP",
              "in" : "query",
              "required" : true,
              "type" : "string"
            },
            {
              "name" : "PhoneNo",
              "in" : "query",
              "required" : true,
              "type" : "string"
            },
            {
              "in" : "body",
              "name" : "Empty",
              "required" : true,
              "schema" : {
                "$ref" : "#/definitions/Empty"
              }
            }
          ],
          "responses" : {
            "200" : {
              "description" : "200 response",
              "schema" : {
                "$ref" : "#/definitions/Empty"
              }
            },
            "400" : {
              "description" : "400 response",
              "schema" : {
                "$ref" : "#/definitions/Empty"
              }
            },
            "401" : {
              "description" : "401 response",
              "schema" : {
                "$ref" : "#/definitions/Empty"
              }
            }
          },
          "x-amazon-apigateway-integration" : {
            "httpMethod" : "POST",
            "uri" : "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.otp_arn}/invocations",
            "responses" : {
              "default" : {
                "statusCode" : "200"
              },
              ".*\"message\":.*Authentication.*" : {
                "statusCode" : "401",
                "responseTemplates" : {
                  "application/json" : "$input.path('$.errorMessage')"
                }
              },
              ".*\"message\":.*Badrequest.*" : {
                "statusCode" : "400",
                "responseTemplates" : {
                  "application/json" : "$input.path('$.errorMessage')"
                }
              }
            },
            "requestTemplates" : {
              "application/json" : "##  See http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-mapping-template-reference.html\n##  This template will pass through all parameters including path, querystring, header, stage variables, and context through to the integration endpoint via the body/payload\n#set($allParams = $input.params())\n{\n\"body-json\" : $input.json('$'),\n\"params\" : {\n#foreach($type in $allParams.keySet())\n    #set($params = $allParams.get($type))\n\"$type\" : {\n    #foreach($paramName in $params.keySet())\n    \"$paramName\" : \"$util.escapeJavaScript($params.get($paramName))\"\n        #if($foreach.hasNext),#end\n    #end\n}\n    #if($foreach.hasNext),#end\n#end\n},\n\"stage-variables\" : {\n#foreach($key in $stageVariables.keySet())\n\"$key\" : \"$util.escapeJavaScript($stageVariables.get($key))\"\n    #if($foreach.hasNext),#end\n#end\n},\n\"context\" : {\n    \"account-id\" : \"$context.identity.accountId\",\n    \"api-id\" : \"$context.apiId\",\n    \"api-key\" : \"$context.identity.apiKey\",\n    \"authorizer-principal-id\" : \"$context.authorizer.principalId\",\n    \"caller\" : \"$context.identity.caller\",\n    \"cognito-authentication-provider\" : \"$context.identity.cognitoAuthenticationProvider\",\n    \"cognito-authentication-type\" : \"$context.identity.cognitoAuthenticationType\",\n    \"cognito-identity-id\" : \"$context.identity.cognitoIdentityId\",\n    \"cognito-identity-pool-id\" : \"$context.identity.cognitoIdentityPoolId\",\n    \"http-method\" : \"$context.httpMethod\",\n    \"stage\" : \"$context.stage\",\n    \"source-ip\" : \"$context.identity.sourceIp\",\n    \"user\" : \"$context.identity.user\",\n    \"user-agent\" : \"$context.identity.userAgent\",\n    \"user-arn\" : \"$context.identity.userArn\",\n    \"request-id\" : \"$context.requestId\",\n    \"resource-id\" : \"$context.resourceId\",\n    \"resource-path\" : \"$context.resourcePath\"\n    }\n}\n"
            },
            "passthroughBehavior" : "when_no_templates",
            "contentHandling" : "CONVERT_TO_TEXT",
            "type" : "aws"
          }
        }
      }
    },
    "definitions" : {
      "Empty" : {
        "type" : "object",
        "title" : "Empty Schema"
      }
    }
  })

  name = var.OTP_rest_api_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "OTP" {
  rest_api_id = aws_api_gateway_rest_api.OTP.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.OTP.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "OTP" {
  deployment_id = aws_api_gateway_deployment.OTP.id
  rest_api_id   = aws_api_gateway_rest_api.OTP.id
  stage_name    = "V1"
}

########################################################################################
#    DashboardData  API GATEWAY                                                                  #
########################################################################################

resource "aws_api_gateway_rest_api" "DashboardData" {
  body = jsonencode({
    "swagger" : "2.0",
    "info" : {
      "description" : "to get the gateway details for mobile",
      "version" : "2021-05-19T05:30:37Z",
      "title" : "GetDashBoardData"
    },
    "paths" : {
      "/PurmoGateway" : {
        "x-amazon-apigateway-any-method" : {
          "responses" : {
            "200" : {
              "description" : "200 response"
            }
          },
          "x-amazon-apigateway-integration" : {
            "httpMethod" : "POST",
            "uri" : "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.dashboard_arn}/invocations",
            "responses" : {
              ".*" : {
                "statusCode" : "200"
              }
            },
            "passthroughBehavior" : "when_no_match",
            "type" : "aws_proxy"
          }
        }
      },
      "/getdashboarddata" : {
        "get" : {
          "consumes" : [
            "application/json"
          ],
          "produces" : [
            "application/json"
          ],
          "parameters" : [
            {
              "name" : "userid",
              "in" : "query",
              "required" : true,
              "type" : "string"
            }
          ],
          "responses" : {
            "200" : {
              "description" : "200 response",
              "schema" : {
                "$ref" : "#/definitions/Empty"
              }
            },
            "400" : {
              "description" : "400 response",
              "schema" : {
                "$ref" : "#/definitions/Empty"
              }
            },
            "401" : {
              "description" : "401 response",
              "schema" : {
                "$ref" : "#/definitions/Empty"
              }
            }
          },
          "x-amazon-apigateway-integration" : {
            "httpMethod" : "POST",
            "uri" : "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.dashboard_arn}/invocations",
            "responses" : {
              "default" : {
                "statusCode" : "200"
              },
              ".*\"message\":.*Authentication.*" : {
                "statusCode" : "401",
                "responseTemplates" : {
                  "application/json" : "$input.path('$.errorMessage')"
                }
              },
              ".*\"message\":.*Badrequest.*" : {
                "statusCode" : "400",
                "responseTemplates" : {
                  "application/json" : "$input.path('$.errorMessage')"
                }
              }
            },
            "requestTemplates" : {
              "application/json" : "##  See http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-mapping-template-reference.html\n##  This template will pass through all parameters including path, querystring, header, stage variables, and context through to the integration endpoint via the body/payload\n#set($allParams = $input.params())\n{\n\"body-json\" : $input.json('$'),\n\"params\" : {\n#foreach($type in $allParams.keySet())\n    #set($params = $allParams.get($type))\n\"$type\" : {\n    #foreach($paramName in $params.keySet())\n    \"$paramName\" : \"$util.escapeJavaScript($params.get($paramName))\"\n        #if($foreach.hasNext),#end\n    #end\n}\n    #if($foreach.hasNext),#end\n#end\n},\n\"stage-variables\" : {\n#foreach($key in $stageVariables.keySet())\n\"$key\" : \"$util.escapeJavaScript($stageVariables.get($key))\"\n    #if($foreach.hasNext),#end\n#end\n},\n\"context\" : {\n    \"account-id\" : \"$context.identity.accountId\",\n    \"api-id\" : \"$context.apiId\",\n    \"api-key\" : \"$context.identity.apiKey\",\n    \"authorizer-principal-id\" : \"$context.authorizer.principalId\",\n    \"caller\" : \"$context.identity.caller\",\n    \"cognito-authentication-provider\" : \"$context.identity.cognitoAuthenticationProvider\",\n    \"cognito-authentication-type\" : \"$context.identity.cognitoAuthenticationType\",\n    \"cognito-identity-id\" : \"$context.identity.cognitoIdentityId\",\n    \"cognito-identity-pool-id\" : \"$context.identity.cognitoIdentityPoolId\",\n    \"http-method\" : \"$context.httpMethod\",\n    \"stage\" : \"$context.stage\",\n    \"source-ip\" : \"$context.identity.sourceIp\",\n    \"user\" : \"$context.identity.user\",\n    \"user-agent\" : \"$context.identity.userAgent\",\n    \"user-arn\" : \"$context.identity.userArn\",\n    \"request-id\" : \"$context.requestId\",\n    \"resource-id\" : \"$context.resourceId\",\n    \"resource-path\" : \"$context.resourcePath\"\n    }\n}\n"
            },
            "passthroughBehavior" : "when_no_templates",
            "contentHandling" : "CONVERT_TO_TEXT",
            "type" : "aws"
          }
        },
        "options" : {
          "consumes" : [
            "application/json"
          ],
          "produces" : [
            "application/json"
          ],
          "responses" : {
            "200" : {
              "description" : "200 response",
              "schema" : {
                "$ref" : "#/definitions/Empty"
              },
              "headers" : {
                "Access-Control-Allow-Origin" : {
                  "type" : "string"
                },
                "Access-Control-Allow-Methods" : {
                  "type" : "string"
                },
                "Access-Control-Allow-Headers" : {
                  "type" : "string"
                }
              }
            }
          },
          "x-amazon-apigateway-integration" : {
            "responses" : {
              "default" : {
                "statusCode" : "200",
                "responseParameters" : {
                  "method.response.header.Access-Control-Allow-Methods" : "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
                  "method.response.header.Access-Control-Allow-Headers" : "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'",
                  "method.response.header.Access-Control-Allow-Origin" : "'*'"
                }
              }
            },
            "requestTemplates" : {
              "application/json" : "{\"statusCode\": 200}"
            },
            "passthroughBehavior" : "when_no_match",
            "type" : "mock"
          }
        }
      }
    },
    "definitions" : {
      "Empty" : {
        "type" : "object",
        "title" : "Empty Schema"
      }
    }
  })

  name = var.Dash_rest_api_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "DashboardData" {
  rest_api_id = aws_api_gateway_rest_api.DashboardData.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.DashboardData.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "DashboardData" {
  deployment_id = aws_api_gateway_deployment.DashboardData.id
  rest_api_id   = aws_api_gateway_rest_api.DashboardData.id
  stage_name    = "V1"
}

########################################################################################
#    SetImageGateway  API GATEWAY                                                                  #
########################################################################################

resource "aws_api_gateway_rest_api" "GatewayImage" {
  body = jsonencode({
    "swagger" : "2.0",
    "info" : {
      "description" : "This will upload image for gateway",
      "version" : "2021-05-31T13:01:19Z",
      "title" : "SetGatewayImage"
    },
    "paths" : {
      "/SetGatewayImage" : {
        "x-amazon-apigateway-any-method" : {
          "responses" : {
            "200" : {
              "description" : "200 response"
            }
          },
          "x-amazon-apigateway-integration" : {
            "httpMethod" : "POST",
            "uri" : "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.GatewayImage_arn}/invocations",
            "responses" : {
              ".*" : {
                "statusCode" : "200"
              }
            },
            "passthroughBehavior" : "when_no_match",
            "type" : "aws_proxy"
          }
        }
      },
      "/setgatewayimage" : {
        "post" : {
          "produces" : [
            "application/json"
          ],
          "responses" : {
            "200" : {
              "description" : "200 response",
              "schema" : {
                "$ref" : "#/definitions/Empty"
              }
            }
          },
          "x-amazon-apigateway-integration" : {
            "httpMethod" : "POST",
            "uri" : "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.GatewayImage_arn}/invocations",
            "responses" : {
              "default" : {
                "statusCode" : "200"
              }
            },
            "passthroughBehavior" : "when_no_match",
            "contentHandling" : "CONVERT_TO_TEXT",
            "type" : "aws_proxy"
          }
        }
      }
    },
    "definitions" : {
      "Empty" : {
        "type" : "object",
        "title" : "Empty Schema"
      }
    },
    "x-amazon-apigateway-binary-media-types" : [
      "multipart/form-data",
      "image/jpeg",
      "*/*"
    ]
    }

  )

  name = var.Gateway_rest_api_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "GatewayImage" {
  rest_api_id = aws_api_gateway_rest_api.GatewayImage.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.GatewayImage.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "GatewayImage" {
  deployment_id = aws_api_gateway_deployment.GatewayImage.id
  rest_api_id   = aws_api_gateway_rest_api.GatewayImage.id
  stage_name    = "V1"
}

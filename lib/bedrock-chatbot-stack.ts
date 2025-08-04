import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as iam from 'aws-cdk-lib/aws-iam';
import { ApiGatewayToLambda } from '@aws-solutions-constructs/aws-apigateway-lambda';
import * as genai from '@cdklabs/generative-ai-cdk-constructs';
import { NagSuppressions } from 'cdk-nag';

export class BedrockChatbotStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create the Lambda function for the chatbot
    const chatbotLambda = new lambda.Function(this, 'ChatbotFunction', {
      runtime: lambda.Runtime.PYTHON_3_12, // Use latest runtime
      handler: 'index.handler',
      code: lambda.Code.fromInline(`
import json
import boto3
import logging
import os

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize Bedrock client
bedrock_runtime = boto3.client('bedrock-runtime', region_name=os.environ.get('AWS_DEFAULT_REGION', 'us-east-1'))

def handler(event, context):
    """
    Lambda function to handle chatbot requests using Amazon Bedrock
    """
    try:
        # Parse the request body
        if 'body' in event:
            body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
        else:
            body = event
        
        user_message = body.get('message', '')
        
        if not user_message:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
                },
                'body': json.dumps({
                    'error': 'Message is required'
                })
            }
        
        # Prepare the request for Bedrock
        model_id = 'anthropic.claude-3-haiku-20240307-v1:0'
        
        # Format the prompt for Claude
        prompt = {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 1000,
            "messages": [
                {
                    "role": "user",
                    "content": user_message
                }
            ]
        }
        
        # Call Bedrock
        response = bedrock_runtime.invoke_model(
            modelId=model_id,
            body=json.dumps(prompt),
            contentType='application/json'
        )
        
        # Parse the response
        response_body = json.loads(response['body'].read())
        ai_response = response_body['content'][0]['text']
        
        logger.info(f"Successfully processed message: {user_message[:50]}...")
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': json.dumps({
                'response': ai_response,
                'model': model_id
            })
        }
        
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'details': str(e)
            })
        }
      `),
      timeout: cdk.Duration.seconds(30)
    });

    // Add Bedrock permissions to the Lambda function
    chatbotLambda.addToRolePolicy(new iam.PolicyStatement({
      effect: iam.Effect.ALLOW,
      actions: [
        'bedrock:InvokeModel',
        'bedrock:InvokeModelWithResponseStream'
      ],
      resources: [
        `arn:aws:bedrock:${this.region}::foundation-model/anthropic.claude-3-haiku-20240307-v1:0`,
        `arn:aws:bedrock:${this.region}::foundation-model/anthropic.claude-3-sonnet-20240229-v1:0`,
        `arn:aws:bedrock:${this.region}::foundation-model/anthropic.claude-3-5-sonnet-20240620-v1:0`
      ]
    }));

    // Create API Gateway with Lambda using AWS Solutions Constructs
    const apiGatewayLambda = new ApiGatewayToLambda(this, 'ChatbotApi', {
      existingLambdaObj: chatbotLambda,
      apiGatewayProps: {
        restApiName: 'Bedrock Chatbot API',
        description: 'API Gateway for Bedrock Chatbot',
        defaultCorsPreflightOptions: {
          allowOrigins: ['*'],
          allowMethods: ['GET', 'POST', 'OPTIONS'],
          allowHeaders: ['Content-Type', 'Authorization']
        }
      }
    });

    // CDK Nag suppressions for demo project
    NagSuppressions.addResourceSuppressions(
      chatbotLambda,
      [
        {
          id: 'AwsSolutions-IAM4',
          reason: 'Demo project: AWS managed policy AWSLambdaBasicExecutionRole is acceptable for basic Lambda execution',
          appliesTo: ['Policy::arn:<AWS::Partition>:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole']
        },
        {
          id: 'AwsSolutions-L1',
          reason: 'Demo project: Python 3.12 is the latest stable runtime available in CDK at time of creation'
        }
      ],
      true // Apply to child resources
    );

    NagSuppressions.addResourceSuppressions(
      apiGatewayLambda.apiGateway,
      [
        {
          id: 'AwsSolutions-APIG2',
          reason: 'Demo project: Request validation not required for simple chatbot demo'
        },
        {
          id: 'AwsSolutions-COG4',
          reason: 'Demo project: Cognito authentication not required for public chatbot demo'
        }
      ],
      true // Apply to child resources
    );

    NagSuppressions.addResourceSuppressions(
      apiGatewayLambda.apiGateway.deploymentStage,
      [
        {
          id: 'AwsSolutions-APIG3',
          reason: 'Demo project: WAF not required for simple demo, but recommended for production'
        }
      ]
    );

    // Suppress CloudWatch role wildcard permissions (from Solutions Construct)
    NagSuppressions.addStackSuppressions(this, [
      {
        id: 'AwsSolutions-IAM5',
        reason: 'Demo project: CloudWatch logs wildcard permissions are from AWS Solutions Construct and are acceptable',
        appliesTo: ['Resource::arn:<AWS::Partition>:logs:<AWS::Region>:<AWS::AccountId>:*']
      }
    ]);

    // Output the API Gateway URL
    new cdk.CfnOutput(this, 'ApiUrl', {
      value: apiGatewayLambda.apiGateway.url,
      description: 'URL of the Bedrock Chatbot API'
    });

    // Output the Lambda function name
    new cdk.CfnOutput(this, 'LambdaFunctionName', {
      value: chatbotLambda.functionName,
      description: 'Name of the Lambda function'
    });

    // Output instructions
    new cdk.CfnOutput(this, 'Instructions', {
      value: 'Open frontend/index.html in your browser and enter the API URL above to start chatting!',
      description: 'Next steps'
    });
  }
}

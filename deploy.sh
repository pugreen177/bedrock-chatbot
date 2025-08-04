#!/bin/bash

# =============================================================================
# Bedrock Chatbot Deployment Script
# =============================================================================
# 
# This script automates the deployment of the Bedrock Chatbot application.
# It performs the following operations:
# 1. Validates AWS CLI configuration
# 2. Ensures CDK is properly bootstrapped
# 3. Installs project dependencies
# 4. Synthesizes and validates the CDK stack
# 5. Deploys the infrastructure to AWS
# 6. Provides post-deployment instructions
#
# Usage: ./deploy.sh
# Prerequisites: AWS CLI configured, Node.js and npm installed
# =============================================================================

echo "🚀 Deploying Bedrock Chatbot..."

# =============================================================================
# Function: check_aws_configuration
# Description: Verifies that AWS CLI is properly configured with valid credentials
# Returns: Exits with code 1 if AWS CLI is not configured
# =============================================================================
echo "🔐 Checking AWS CLI configuration..."
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS CLI is not configured. Please run 'aws configure' first."
    exit 1
fi
echo "✅ AWS CLI is properly configured."

# =============================================================================
# Function: ensure_cdk_bootstrap
# Description: Checks if CDK is bootstrapped in the current AWS account/region
#              and runs bootstrap if necessary
# Returns: Exits with code 1 if bootstrap fails
# =============================================================================
echo "🔍 Checking CDK bootstrap status..."
if ! aws cloudformation describe-stacks --stack-name CDKToolkit > /dev/null 2>&1; then
    echo "⚠️  CDK is not bootstrapped. Running bootstrap..."
    cdk bootstrap
    if [ $? -ne 0 ]; then
        echo "❌ CDK bootstrap failed. Please check your AWS credentials and permissions."
        exit 1
    fi
else
    echo "✅ CDK is already bootstrapped."
fi

# =============================================================================
# Function: install_dependencies
# Description: Installs all required npm dependencies for the project
# =============================================================================
echo "📦 Installing dependencies..."
npm install

# =============================================================================
# Function: synthesize_stack
# Description: Synthesizes the CDK stack to validate configuration and catch errors
#              before attempting deployment
# Returns: Exits with code 1 if synthesis fails
# =============================================================================
echo "🔍 Synthesizing CDK stack..."
cdk synth
if [ $? -ne 0 ]; then
    echo "❌ CDK synthesis failed. Please check the errors above."
    exit 1
fi

# =============================================================================
# Function: deploy_stack
# Description: Deploys the CDK stack to AWS without requiring manual approval
# Returns: Exits with code 1 if deployment fails
# =============================================================================
echo "🚀 Deploying the stack..."
cdk deploy --require-approval never

# =============================================================================
# Function: display_post_deployment_instructions
# Description: Shows success message and provides next steps for using the chatbot
# =============================================================================
if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Deployment successful!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Copy the API URL from the output above"
    echo "2. Open frontend/index.html in your browser"
    echo "3. Paste the API URL and start chatting!"
    echo ""
    echo "🔧 To view logs:"
    echo "   aws logs tail /aws/lambda/BedrockChatbotStack-ChatbotFunction* --follow"
    echo ""
    echo "🧹 To cleanup:"
    echo "   cdk destroy"
else
    echo "❌ Deployment failed. Please check the errors above."
    exit 1
fi

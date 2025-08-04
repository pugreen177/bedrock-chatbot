#!/bin/bash

# Bedrock Chatbot Deployment Script
echo "🚀 Deploying Bedrock Chatbot..."

# Check if AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS CLI is not configured. Please run 'aws configure' first."
    exit 1
fi

# Check if CDK is bootstrapped
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

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Synthesize the stack to check for errors
echo "🔍 Synthesizing CDK stack..."
cdk synth
if [ $? -ne 0 ]; then
    echo "❌ CDK synthesis failed. Please check the errors above."
    exit 1
fi

# Deploy the stack
echo "🚀 Deploying the stack..."
cdk deploy --require-approval never

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

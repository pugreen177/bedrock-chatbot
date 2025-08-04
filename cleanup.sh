#!/bin/bash

# Cleanup script for Bedrock Chatbot
echo "🧹 Cleaning up Bedrock Chatbot resources..."

echo "⚠️  This will delete all resources created by the Bedrock Chatbot stack."
echo "This includes:"
echo "  - Lambda function"
echo "  - API Gateway"
echo "  - IAM roles and policies"
echo "  - CloudWatch logs"
echo ""

read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled."
    exit 1
fi

echo "🗑️  Destroying CDK stack..."
cdk destroy --force

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Cleanup successful!"
    echo "All AWS resources have been deleted."
else
    echo ""
    echo "❌ Cleanup failed. You may need to manually delete some resources."
    echo "Check the AWS Console for any remaining resources."
fi

#!/bin/bash

# =============================================================================
# Bedrock Chatbot Cleanup Script
# =============================================================================
# 
# This script safely removes all AWS resources created by the Bedrock Chatbot
# deployment. It includes safety prompts to prevent accidental deletion.
#
# Resources that will be deleted:
# - Lambda function and associated logs
# - API Gateway and related resources
# - IAM roles and policies
# - CloudWatch log groups
#
# Usage: ./cleanup.sh
# Prerequisites: AWS CLI configured, CDK installed
# =============================================================================

echo "🧹 Cleaning up Bedrock Chatbot resources..."

# =============================================================================
# Function: display_warning_and_resource_list
# Description: Shows a detailed warning about what resources will be deleted
#              to ensure user understands the impact
# =============================================================================
echo "⚠️  This will delete all resources created by the Bedrock Chatbot stack."
echo "This includes:"
echo "  - Lambda function"
echo "  - API Gateway"
echo "  - IAM roles and policies"
echo "  - CloudWatch logs"
echo ""

# =============================================================================
# Function: prompt_for_confirmation
# Description: Prompts user for explicit confirmation before proceeding with deletion
# Returns: Exits with code 1 if user cancels the operation
# =============================================================================
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled."
    exit 1
fi

# =============================================================================
# Function: destroy_cdk_stack
# Description: Executes CDK destroy command to remove all stack resources
#              Uses --force flag to avoid additional confirmation prompts
# =============================================================================
echo "🗑️  Destroying CDK stack..."
cdk destroy --force

# =============================================================================
# Function: display_cleanup_results
# Description: Shows the result of the cleanup operation and provides guidance
#              for manual cleanup if automated cleanup fails
# =============================================================================
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Cleanup successful!"
    echo "All AWS resources have been deleted."
else
    echo ""
    echo "❌ Cleanup failed. You may need to manually delete some resources."
    echo "Check the AWS Console for any remaining resources."
fi

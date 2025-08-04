#!/usr/bin/env node
/**
 * AWS CDK Application Entry Point for Bedrock Chatbot
 * 
 * This file serves as the main entry point for the CDK application.
 * It creates and configures the CDK app, instantiates the Bedrock chatbot stack,
 * and applies security best practices using CDK Nag.
 */

import * as cdk from 'aws-cdk-lib';
import { BedrockChatbotStack } from '../lib/bedrock-chatbot-stack';
import { AwsSolutionsChecks } from 'cdk-nag';

/**
 * Initialize the CDK application
 */
const app = new cdk.App();

/**
 * Create the Bedrock chatbot stack with proper environment configuration.
 * 
 * The stack is configured to use:
 * - Account ID from CDK_DEFAULT_ACCOUNT environment variable
 * - Region from CDK_DEFAULT_REGION environment variable (defaults to us-east-1)
 */
const stack = new BedrockChatbotStack(app, 'BedrockChatbotStack', {
  env: { 
    account: process.env.CDK_DEFAULT_ACCOUNT, 
    region: process.env.CDK_DEFAULT_REGION || 'us-east-1'
  },
  description: 'Simple Bedrock Chatbot with API Gateway and Lambda'
});

/**
 * Apply CDK Nag security checks to ensure AWS best practices are followed.
 * This helps identify potential security issues and compliance violations.
 */
cdk.Aspects.of(app).add(new AwsSolutionsChecks({ verbose: true }));
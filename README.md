# Bedrock Chatbot - Simple Infrastructure as Code Project

A simple yet powerful chatbot built with AWS CDK, featuring Amazon Bedrock for AI responses, API Gateway for REST endpoints, and Lambda for serverless compute.

## 🏗️ Architecture

- **Amazon Bedrock**: Claude 3 Haiku model for AI responses
- **AWS Lambda**: Serverless function to handle chat requests
- **Amazon API Gateway**: REST API with CORS support
- **AWS Solutions Constructs**: Best practices for API Gateway + Lambda integration
- **CDK Nag**: Security best practices validation

## 📋 Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Node.js** (version 18.12.0 or higher)
3. **AWS CDK CLI** installed globally
4. **Bedrock model access** - Ensure Claude 3 Haiku is enabled in your AWS account

### Enable Bedrock Models

1. Go to the AWS Bedrock console
2. Navigate to "Model access" in the left sidebar
3. Request access to "Anthropic Claude 3 Haiku" model
4. Wait for approval (usually instant for Claude models)

## 🚀 Deployment

1. **Clone and navigate to the project**:
   ```bash
   cd /Users/htk/Downloads/bedrock-chatbot
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Bootstrap CDK** (if you haven't done this before in your account/region):
   ```bash
   cdk bootstrap
   ```

4. **Deploy the stack**:
   ```bash
   cdk deploy
   ```

5. **Note the outputs**: After deployment, you'll see outputs like:
   ```
   BedrockChatbotStack.ApiUrl = https://abc123.execute-api.us-east-1.amazonaws.com/prod/
   BedrockChatbotStack.LambdaFunctionName = BedrockChatbotStack-ChatbotFunction...
   ```

## 🧪 Testing

### Option 1: Using the Web Interface

1. Open `frontend/index.html` in your browser
2. Enter the API Gateway URL from the deployment outputs
3. Start chatting with the bot!

### Option 2: Using curl

```bash
curl -X POST https://YOUR-API-URL/prod/ \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, how are you?"}'
```

### Option 3: Using AWS CLI to test Lambda directly

```bash
aws lambda invoke \
  --function-name YOUR-LAMBDA-FUNCTION-NAME \
  --payload '{"message": "Hello from AWS CLI!"}' \
  response.json && cat response.json
```

## 🔧 Customization

### Change the AI Model

Edit `lib/bedrock-chatbot-stack.ts` and modify the `model_id` variable:

```typescript
// Available models (ensure you have access):
// - anthropic.claude-3-haiku-20240307-v1:0 (fastest, cheapest)
// - anthropic.claude-3-sonnet-20240229-v1:0 (balanced)
// - anthropic.claude-3-5-sonnet-20240620-v1:0 (most capable)
```

### Add Memory/Context

The current implementation is stateless. To add conversation memory:

1. Add DynamoDB table for session storage
2. Modify Lambda to store/retrieve conversation history
3. Include conversation context in Bedrock requests

### Add Authentication

Use the `aws-cognito-apigateway-lambda` Solutions Construct instead:

```bash
npm install @aws-solutions-constructs/aws-cognito-apigateway-lambda
```

## 📊 Monitoring

The stack includes basic CloudWatch logging. To view logs:

```bash
aws logs tail /aws/lambda/YOUR-LAMBDA-FUNCTION-NAME --follow
```

## 💰 Cost Optimization

- **Lambda**: Pay per request (very low cost for testing)
- **API Gateway**: Pay per API call
- **Bedrock**: Pay per token (Claude 3 Haiku is the most cost-effective)

Estimated cost for 1000 chat messages: ~$0.50-$2.00

## 🔒 Security Features

This project implements AWS security best practices:

- ✅ Least privilege IAM permissions
- ✅ CORS configuration for web access
- ✅ CDK Nag security validation
- ✅ AWS Solutions Constructs for vetted patterns
- ✅ No hardcoded credentials

## 🧹 Cleanup

To avoid ongoing charges:

```bash
cdk destroy
```

## 🛠️ Development Commands

- `npm run build`: Compile TypeScript to JavaScript
- `npm run watch`: Watch for changes and compile
- `npm run test`: Perform Jest unit tests
- `cdk diff`: Compare deployed stack with current state
- `cdk synth`: Emit the synthesized CloudFormation template

## 🐛 Troubleshooting

### Common Issues

1. **"Model not found" error**: Ensure you've enabled Claude 3 Haiku in Bedrock console
2. **CORS errors**: Check that your API Gateway has proper CORS configuration
3. **Permission denied**: Verify your AWS credentials have necessary permissions
4. **CDK Nag warnings**: Review security recommendations and add suppressions if needed

### Debug Lambda Function

```bash
# View recent logs
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/BedrockChatbotStack"

# Get specific log stream
aws logs describe-log-streams --log-group-name "/aws/lambda/YOUR-FUNCTION-NAME"
```

## 📚 Learning Resources

- [AWS CDK Documentation](https://docs.aws.amazon.com/cdk/)
- [Amazon Bedrock User Guide](https://docs.aws.amazon.com/bedrock/)
- [AWS Solutions Constructs](https://docs.aws.amazon.com/solutions/latest/constructs/)
- [CDK Nag Rules](https://github.com/cdklabs/cdk-nag)

## 🎯 Next Steps

1. **Add a knowledge base** using Bedrock Knowledge Bases
2. **Implement streaming responses** for real-time chat
3. **Add user authentication** with Cognito
4. **Create a React frontend** for better UX
5. **Add conversation memory** with DynamoDB
6. **Implement rate limiting** for production use

## 📄 License

This project is provided as-is for educational purposes. Feel free to modify and use as needed.

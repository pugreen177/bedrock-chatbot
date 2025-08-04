#!/bin/bash

# Test script for Bedrock Chatbot
echo "🧪 Testing Bedrock Chatbot..."

# Check if API URL is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <API_GATEWAY_URL>"
    echo "Example: $0 https://abc123.execute-api.us-east-1.amazonaws.com/prod/"
    exit 1
fi

API_URL="$1"

# Test message
TEST_MESSAGE="Hello, can you tell me a joke?"

echo "📤 Sending test message: '$TEST_MESSAGE'"
echo "🌐 API URL: $API_URL"
echo ""

# Send request to API Gateway
response=$(curl -s -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d "{\"message\":\"$TEST_MESSAGE\"}" \
  -w "\nHTTP_STATUS:%{http_code}")

# Extract HTTP status code
http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
response_body=$(echo "$response" | sed '/HTTP_STATUS:/d')

echo "📥 Response (HTTP $http_status):"
echo "$response_body" | jq . 2>/dev/null || echo "$response_body"

if [ "$http_status" = "200" ]; then
    echo ""
    echo "✅ Test successful! The chatbot is working."
else
    echo ""
    echo "❌ Test failed. HTTP status: $http_status"
    echo "Check the Lambda logs for more details:"
    echo "aws logs tail /aws/lambda/BedrockChatbotStack-ChatbotFunction* --follow"
fi

#!/bin/bash

# =============================================================================
# Bedrock Chatbot Testing Script
# =============================================================================
# 
# This script performs end-to-end testing of the deployed Bedrock Chatbot
# by sending HTTP requests to the API Gateway endpoint and validating responses.
#
# Test Process:
# 1. Validates that API Gateway URL is provided
# 2. Sends a test message to the chatbot API
# 3. Parses and displays the response
# 4. Validates HTTP status codes
# 5. Provides debugging information if tests fail
#
# Usage: ./test-chatbot.sh <API_GATEWAY_URL>
# Example: ./test-chatbot.sh https://abc123.execute-api.us-east-1.amazonaws.com/prod/
# Prerequisites: curl and jq installed, deployed chatbot stack
# =============================================================================

echo "🧪 Testing Bedrock Chatbot..."

# =============================================================================
# Function: validate_api_url_parameter
# Description: Checks if the required API Gateway URL parameter is provided
# Parameters: $1 - API Gateway URL (should be provided as script argument)
# Returns: Exits with code 1 if URL is not provided
# =============================================================================
if [ -z "$1" ]; then
    echo "Usage: $0 <API_GATEWAY_URL>"
    echo "Example: $0 https://abc123.execute-api.us-east-1.amazonaws.com/prod/"
    exit 1
fi

# =============================================================================
# Function: initialize_test_parameters
# Description: Sets up test configuration including API URL and test message
# =============================================================================
API_URL="$1"
TEST_MESSAGE="Hello, can you tell me a joke?"

echo "📤 Sending test message: '$TEST_MESSAGE'"
echo "🌐 API URL: $API_URL"
echo ""

# =============================================================================
# Function: send_test_request
# Description: Sends HTTP POST request to the chatbot API with test message
# Returns: HTTP response body and status code
# =============================================================================
response=$(curl -s -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d "{\"message\":\"$TEST_MESSAGE\"}" \
  -w "\nHTTP_STATUS:%{http_code}")

# =============================================================================
# Function: parse_response
# Description: Extracts HTTP status code and response body from curl output
# =============================================================================
http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
response_body=$(echo "$response" | sed '/HTTP_STATUS:/d')

# =============================================================================
# Function: display_response
# Description: Formats and displays the API response with proper JSON formatting
#              Falls back to plain text if JSON parsing fails
# =============================================================================
echo "📥 Response (HTTP $http_status):"
echo "$response_body" | jq . 2>/dev/null || echo "$response_body"

# =============================================================================
# Function: validate_test_results
# Description: Checks HTTP status code and provides appropriate success/failure messages
#              Includes debugging guidance for failed tests
# =============================================================================
if [ "$http_status" = "200" ]; then
    echo ""
    echo "✅ Test successful! The chatbot is working."
else
    echo ""
    echo "❌ Test failed. HTTP status: $http_status"
    echo "Check the Lambda logs for more details:"
    echo "aws logs tail /aws/lambda/BedrockChatbotStack-ChatbotFunction* --follow"
fi

#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Joomla AI CMS Setup...${NC}"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}Node.js is not installed. Please install Node.js first.${NC}"
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo -e "${RED}npm is not installed. Please install npm first.${NC}"
    exit 1
fi

# Function to display progress
progress() {
    echo -e "${GREEN}✓${NC} $1"
}

# Create .env.local if it doesn't exist
if [ ! -f .env.local ]; then
    echo -e "${BLUE}Creating .env.local file...${NC}"
    echo "HUGGINGFACE_API_KEY=" > .env.local
    progress "Created .env.local file"
fi

# Install dependencies
echo -e "${BLUE}Installing dependencies...${NC}"
npm install --legacy-peer-deps
progress "Installed dependencies"

# Build the project
echo -e "${BLUE}Building the project...${NC}"
npm run build
progress "Built the project"

# Check if port 8000 is in use
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null ; then
    echo -e "${BLUE}Port 8000 is in use. Stopping the process...${NC}"
    kill $(lsof -t -i:8000)
    progress "Stopped existing process on port 8000"
fi

# Start the server
echo -e "${BLUE}Starting the server...${NC}"
PORT=8000 npm run start &
progress "Server started on port 8000"

# Wait for server to start
echo -e "${BLUE}Waiting for server to start...${NC}"
sleep 5

# Create a zip of the project
echo -e "${BLUE}Creating project archive...${NC}"
zip -r joomla-ai-cms.zip . -x "node_modules/*" ".next/*" ".git/*"
progress "Created project archive: joomla-ai-cms.zip"

echo -e "${GREEN}Setup complete!${NC}"
echo -e "${BLUE}Important next steps:${NC}"
echo "1. Add your HuggingFace API key to .env.local"
echo "2. Access the CMS at http://localhost:8000"
echo -e "${BLUE}To stop the server, use: ${NC}kill \$(lsof -t -i:8000)"

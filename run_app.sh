#!/bin/bash

# Run Script for Moustra Mobile
# Usage: ./run_app.sh [staging|production] [debug|profile|release]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT=${1:-staging}
MODE=${2:-debug}

# Function to display usage
show_usage() {
  echo -e "${BLUE}=== Moustra Mobile Run Script ===${NC}"
  echo ""
  echo "Usage: $0 [environment] [mode]"
  echo ""
  echo "Environments:"
  echo "  staging     - Run with staging/dev environment (default)"
  echo "  production  - Run with production environment"
  echo ""
  echo "Modes:"
  echo "  debug       - Debug mode with hot reload (default)"
  echo "  profile     - Profile mode for performance testing"
  echo "  release     - Release mode (fully optimized)"
  echo ""
  echo "Examples:"
  echo "  $0                    # Staging + Debug (default)"
  echo "  $0 staging debug      # Staging + Debug"
  echo "  $0 production profile # Production + Profile"
  echo "  $0 production release # Production + Release"
  echo ""
}

# Check if help was requested
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  show_usage
  exit 0
fi

# Validate environment
if [[ "$ENVIRONMENT" != "staging" ]] && [[ "$ENVIRONMENT" != "production" ]]; then
  echo -e "${RED}ERROR: Invalid environment: $ENVIRONMENT${NC}"
  echo "Must be 'staging' or 'production'"
  show_usage
  exit 1
fi

# Validate mode
if [[ "$MODE" != "debug" ]] && [[ "$MODE" != "profile" ]] && [[ "$MODE" != "release" ]]; then
  echo -e "${RED}ERROR: Invalid mode: $MODE${NC}"
  echo "Must be 'debug', 'profile', or 'release'"
  show_usage
  exit 1
fi

# Backup current .env if it exists
if [ -f ".env" ]; then
  echo -e "${YELLOW}Backing up current .env to .env.backup${NC}"
  cp .env .env.backup
fi

# Trap to restore .env on exit
restore_env() {
  if [ -f ".env.backup" ]; then
    echo -e "${YELLOW}Restoring original .env${NC}"
    mv .env.backup .env
  fi
}
trap restore_env EXIT INT TERM

# Select and copy environment file
if [[ "$ENVIRONMENT" == "staging" ]]; then
  # For staging, use the default .env or restore from backup
  if [ -f ".env.backup" ]; then
    cp .env.backup .env
  elif [ ! -f ".env" ]; then
    echo -e "${RED}ERROR: .env file not found!${NC}"
    echo -e "${YELLOW}Please create .env with your development environment variables.${NC}"
    exit 1
  fi
  echo -e "${GREEN}Using .env for staging${NC}"
else
  # For production, use .env.production
  if [ ! -f ".env.production" ]; then
    echo -e "${RED}ERROR: .env.production file not found!${NC}"
    echo -e "${YELLOW}Please create .env.production with your production environment variables.${NC}"
    exit 1
  fi
  echo -e "${GREEN}Using .env.production for production${NC}"
  cp .env.production .env
fi

# Display configuration
echo -e "${GREEN}=== Moustra Mobile ===${NC}"
echo -e "${BLUE}Environment:${NC} $ENVIRONMENT"
echo -e "${BLUE}Mode:${NC} $MODE"
echo ""

# Run the app
echo -e "${GREEN}Starting app...${NC}"
flutter run --$MODE

# Check exit code
if [ $? -eq 0 ]; then
  echo -e "${GREEN}App stopped successfully${NC}"
else
  echo -e "${RED}App failed to run${NC}"
  exit 1
fi


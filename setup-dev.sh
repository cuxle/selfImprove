#!/bin/bash
# Development environment setup script for Emotion Legacy

set -e

echo "========================================="
echo "Emotion Legacy Development Setup"
echo "========================================="
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.11 or higher."
    exit 1
fi

echo "✅ Python $(python3 --version) found"

# Setup backend
echo ""
echo "Setting up backend..."
cd backend

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null

# Install dependencies
echo "Installing backend dependencies..."
pip install --upgrade pip
pip install -r requirements-dev.txt

# Copy .env.example to .env if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
    echo "⚠️  Please edit backend/.env with your database credentials"
fi

echo "✅ Backend setup complete"

# Setup pre-commit hooks
cd ..
if command -v pre-commit &> /dev/null; then
    echo ""
    echo "Setting up pre-commit hooks..."
    pre-commit install
    echo "✅ Pre-commit hooks installed"
else
    echo "⚠️  pre-commit not found. Install it with: pip install pre-commit"
fi

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Edit backend/.env with your database credentials"
echo "2. Start the backend server:"
echo "   cd backend"
echo "   source venv/bin/activate  # or venv\\Scripts\\activate on Windows"
echo "   make run"
echo ""
echo "3. In another terminal, set up Flutter:"
echo "   cd flutter_app"
echo "   flutter pub get"
echo "   flutter run -d chrome"
echo ""
echo "For more information, see CONTRIBUTING.md"

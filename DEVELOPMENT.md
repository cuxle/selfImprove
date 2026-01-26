# Development Environment

This document provides guidance for setting up and working with the Emotion Legacy development environment.

## Quick Start

Run the development setup script:

```bash
./setup-dev.sh
```

This will:
- Create a Python virtual environment
- Install all development dependencies
- Set up pre-commit hooks
- Create .env file if it doesn't exist

## Manual Setup

If you prefer manual setup, follow these steps:

### Backend

```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements-dev.txt
cp .env.example .env
# Edit .env with your credentials
make db-init
make run
```

### Frontend

```bash
cd flutter_app
flutter pub get
flutter run -d chrome
```

## Development Commands

### Backend (using Makefile)

```bash
cd backend
make help          # Show all available commands
make install       # Install production dependencies
make install-dev   # Install development dependencies
make test          # Run tests
make test-cov      # Run tests with coverage
make lint          # Check code quality
make format        # Format code
make run           # Start development server
make clean         # Remove cache files
```

### Testing

Run all tests:
```bash
cd backend
make test
```

Run specific test file:
```bash
cd backend
pytest tests/test_auth.py
```

Run with coverage:
```bash
cd backend
make test-cov
```

View coverage report:
```bash
cd backend
open htmlcov/index.html  # On macOS
# or
start htmlcov/index.html  # On Windows
# or
xdg-open htmlcov/index.html  # On Linux
```

### Code Quality

Check code quality:
```bash
cd backend
make lint
```

Format code:
```bash
cd backend
make format
```

## Tools and Configuration

### Code Formatters

- **Black**: Formats Python code (line length: 100)
- **isort**: Sorts and organizes imports

### Linters

- **flake8**: Checks code style and potential errors
- **mypy**: Static type checking

### Testing

- **pytest**: Testing framework
- **pytest-cov**: Coverage plugin
- **pytest-asyncio**: Async testing support

### Configuration Files

- `pytest.ini`: Pytest configuration
- `pyproject.toml`: Black, isort, and mypy configuration
- `.flake8`: Flake8 configuration
- `.pre-commit-config.yaml`: Pre-commit hooks
- `.editorconfig`: Editor configuration
- `Makefile`: Development commands

## Pre-commit Hooks

Pre-commit hooks automatically check code quality before commits.

Install hooks:
```bash
pre-commit install
```

Run manually:
```bash
pre-commit run --all-files
```

## Project Structure

```
selfImprove/
├── backend/
│   ├── app/              # Application code
│   ├── tests/            # Test files
│   ├── requirements.txt  # Production dependencies
│   ├── requirements-dev.txt  # Development dependencies
│   ├── pytest.ini        # Pytest configuration
│   ├── pyproject.toml    # Tool configuration
│   ├── .flake8           # Flake8 configuration
│   └── Makefile          # Development commands
├── flutter_app/          # Flutter application
├── .editorconfig         # Editor configuration
├── .pre-commit-config.yaml  # Pre-commit hooks
├── CONTRIBUTING.md       # Contribution guidelines
└── setup-dev.sh          # Development setup script
```

## Common Issues

### Database Connection Error

Make sure:
1. MySQL/PostgreSQL is running
2. Database exists: `CREATE DATABASE emotion_legacy_db;`
3. Credentials in `.env` are correct

### Import Errors

Activate virtual environment:
```bash
cd backend
source venv/bin/activate
```

### Test Failures

1. Check if database is properly configured
2. Ensure all dependencies are installed
3. Run `make clean` to remove cache files

## Next Steps

- Read [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
- Check [README.md](README.md) for project overview
- Review [PROJECT_STATUS.md](PROJECT_STATUS.md) for current status

## Getting Help

- Check existing documentation
- Review GitHub issues
- Contact maintainers

---

Happy coding! 🚀

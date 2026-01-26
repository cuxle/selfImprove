# Contributing to Emotion Legacy (情绪遗产)

Thank you for your interest in contributing to Emotion Legacy! This document provides guidelines and instructions for development.

## Development Setup

### Prerequisites

- Python 3.11+
- Flutter SDK 3.0+
- MySQL 8.0 or PostgreSQL
- Git

### Backend Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/cuxle/selfImprove.git
   cd selfImprove/backend
   ```

2. **Create a virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   make install-dev
   # or manually:
   pip install -r requirements-dev.txt
   ```

4. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials
   ```

5. **Initialize the database**
   ```bash
   make db-init
   # or manually:
   python -c "from app.config.database import engine, Base; Base.metadata.create_all(bind=engine)"
   ```

6. **Run the development server**
   ```bash
   make run
   # or manually:
   uvicorn app.main:app --reload
   ```

### Frontend Setup

1. **Navigate to the Flutter app directory**
   ```bash
   cd flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run -d chrome  # For web
   flutter run -d android # For Android
   flutter run -d ios     # For iOS
   ```

## Development Workflow

### Code Style

We use the following tools to maintain code quality:

- **Black**: Code formatter (line length: 100)
- **isort**: Import sorter
- **flake8**: Linter
- **mypy**: Static type checker

#### Format your code

```bash
cd backend
make format
```

#### Check code quality

```bash
cd backend
make lint
```

### Testing

#### Run tests

```bash
cd backend
make test
```

#### Run tests with coverage

```bash
cd backend
make test-cov
```

Coverage report will be generated in `htmlcov/index.html`.

### Pre-commit Hooks

We recommend using pre-commit hooks to automatically check code quality:

1. **Install pre-commit**
   ```bash
   pip install pre-commit
   ```

2. **Install the hooks**
   ```bash
   pre-commit install
   ```

3. **Run manually (optional)**
   ```bash
   pre-commit run --all-files
   ```

## Making Changes

### Branch Naming

- Feature: `feature/description`
- Bug fix: `fix/description`
- Documentation: `docs/description`
- Refactor: `refactor/description`

### Commit Messages

Follow conventional commit format:

- `feat: add new feature`
- `fix: fix bug description`
- `docs: update documentation`
- `test: add or update tests`
- `refactor: refactor code`
- `style: format code`
- `chore: update dependencies`

### Pull Request Process

1. Create a new branch from `main`
2. Make your changes
3. Run tests and linting
4. Commit your changes with clear messages
5. Push to your fork
6. Create a pull request with a clear description

### Writing Tests

- Place tests in `backend/tests/` directory
- Follow the naming convention: `test_*.py`
- Use pytest fixtures from `conftest.py`
- Aim for high test coverage (>80%)

Example:

```python
def test_feature(client, test_user_data):
    """Test description."""
    response = client.post("/api/v1/endpoint", json=test_user_data)
    assert response.status_code == 200
```

## Code Review

All submissions require review. We use GitHub pull requests for this purpose.

## Project Structure

### Backend

```
backend/
├── app/
│   ├── config/       # Configuration files
│   ├── models/       # Database models
│   ├── schemas/      # Pydantic schemas
│   ├── routes/       # API routes
│   ├── middleware/   # Middleware
│   ├── utils/        # Utility functions
│   └── main.py       # Application entry point
├── tests/            # Test files
├── requirements.txt  # Production dependencies
└── requirements-dev.txt  # Development dependencies
```

### Frontend

```
flutter_app/
├── lib/
│   ├── config/      # Configuration
│   ├── models/      # Data models
│   ├── services/    # API services
│   ├── providers/   # State management
│   ├── screens/     # UI screens
│   └── main.dart    # App entry point
└── test/            # Test files
```

## Available Make Commands

Run `make help` in the backend directory to see all available commands:

- `make install` - Install production dependencies
- `make install-dev` - Install development dependencies
- `make test` - Run tests
- `make test-cov` - Run tests with coverage
- `make lint` - Run code quality checks
- `make format` - Format code
- `make clean` - Remove cache and coverage files
- `make run` - Run development server
- `make db-init` - Initialize database

## Getting Help

- Check existing issues and pull requests
- Review project documentation
- Ask questions in GitHub Discussions
- Contact maintainers

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

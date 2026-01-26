.PHONY: help install install-dev test test-cov lint format clean run

help:  ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install:  ## Install production dependencies
	pip install -r requirements.txt

install-dev:  ## Install development dependencies
	pip install -r requirements-dev.txt

test:  ## Run tests
	pytest

test-cov:  ## Run tests with coverage report
	pytest --cov=app --cov-report=term-missing --cov-report=html

lint:  ## Run code quality checks
	@echo "Running flake8..."
	flake8 app tests
	@echo "Running mypy..."
	mypy app
	@echo "Running isort check..."
	isort --check-only app tests
	@echo "Running black check..."
	black --check app tests

format:  ## Format code with black and isort
	@echo "Running isort..."
	isort app tests
	@echo "Running black..."
	black app tests

clean:  ## Remove cache and coverage files
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name '*.pyc' -delete
	find . -type f -name '*.pyo' -delete
	find . -type d -name '*.egg-info' -exec rm -rf {} + 2>/dev/null || true
	rm -rf .pytest_cache .mypy_cache htmlcov .coverage

run:  ## Run development server
	uvicorn app.main:app --reload

migrate:  ## Run database migrations
	alembic upgrade head

migrate-create:  ## Create a new migration (use: make migrate-create message="description")
	alembic revision --autogenerate -m "$(message)"

db-init:  ## Initialize database
	python -c "from app.config.database import engine, Base; Base.metadata.create_all(bind=engine)"

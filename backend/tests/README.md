# Backend Tests

This directory contains all backend tests for the Emotion Legacy application.

## Test Structure

```
tests/
├── __init__.py           # Test package initialization
├── conftest.py           # Pytest fixtures and configuration
├── test_auth.py          # Authentication endpoint tests
├── test_diary.py         # Diary endpoint tests
├── test_health.py        # Health check tests
└── README.md            # This file
```

## Running Tests

### Run all tests
```bash
cd backend
pytest
```

### Run specific test file
```bash
pytest tests/test_auth.py
```

### Run specific test class
```bash
pytest tests/test_auth.py::TestUserRegistration
```

### Run specific test function
```bash
pytest tests/test_auth.py::TestUserRegistration::test_register_user_success
```

### Run with coverage
```bash
pytest --cov=app --cov-report=term-missing
```

### Run with detailed output
```bash
pytest -v
```

### Run and stop on first failure
```bash
pytest -x
```

## Test Fixtures

Common fixtures are defined in `conftest.py`:

- **`db_session`**: Provides a fresh database session for each test
- **`client`**: TestClient instance with test database
- **`test_user_data`**: Sample user data for testing
- **`test_diary_data`**: Sample diary data for testing
- **`test_challenge_data`**: Sample challenge data for testing

### Using Fixtures

```python
def test_example(client, test_user_data):
    response = client.post("/api/v1/auth/register", json=test_user_data)
    assert response.status_code == 201
```

## Writing Tests

### Test Organization

- Group related tests in classes
- Use descriptive test names
- One assertion per logical concept
- Test both success and failure cases

### Example Test Structure

```python
class TestFeature:
    """Test feature functionality."""

    def test_success_case(self, client):
        """Test successful operation."""
        response = client.get("/api/v1/endpoint")
        assert response.status_code == 200

    def test_failure_case(self, client):
        """Test error handling."""
        response = client.get("/api/v1/invalid")
        assert response.status_code == 404
```

### Testing Authenticated Endpoints

```python
@pytest.fixture
def auth_headers(client, test_user_data):
    """Get authentication headers."""
    client.post("/api/v1/auth/register", json=test_user_data)
    login_response = client.post(
        "/api/v1/auth/login",
        json={
            "email": test_user_data["email"],
            "password": test_user_data["password"],
        },
    )
    token = login_response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}

def test_protected_endpoint(client, auth_headers):
    response = client.get("/api/v1/protected", headers=auth_headers)
    assert response.status_code == 200
```

## Test Coverage

Aim for >80% code coverage. View coverage report:

```bash
pytest --cov=app --cov-report=html
open htmlcov/index.html
```

## Best Practices

1. **Test Independence**: Each test should be independent and not rely on others
2. **Clear Names**: Use descriptive test names that explain what is being tested
3. **Arrange-Act-Assert**: Structure tests with setup, execution, and verification
4. **Edge Cases**: Test boundary conditions and error cases
5. **Fast Tests**: Keep tests fast by using in-memory database
6. **Fixtures**: Use fixtures to avoid code duplication

## Common Assertions

```python
# Status codes
assert response.status_code == 200
assert response.status_code == status.HTTP_200_OK

# JSON response
data = response.json()
assert data["key"] == "value"
assert "key" in data

# Lists
assert len(data) > 0
assert isinstance(data, list)

# Exceptions
with pytest.raises(ValueError):
    function_that_raises()
```

## Debugging Tests

### Run with print output
```bash
pytest -s
```

### Run with Python debugger
```python
def test_example(client):
    import pdb; pdb.set_trace()
    response = client.get("/api/v1/endpoint")
```

### View SQL queries
Set `echo=True` in database engine configuration (in conftest.py).

## Continuous Integration

Tests run automatically on GitHub Actions for:
- Pull requests
- Pushes to main/develop branches
- Multiple Python versions (3.11, 3.12)

See `.github/workflows/backend-ci.yml` for configuration.

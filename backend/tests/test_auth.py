"""
Tests for authentication endpoints.
"""
import pytest
from fastapi import status


class TestUserRegistration:
    """Test user registration functionality."""

    def test_register_user_success(self, client, test_user_data):
        """Test successful user registration."""
        response = client.post("/api/v1/auth/register", json=test_user_data)
        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert "id" in data
        assert data["email"] == test_user_data["email"]
        assert data["username"] == test_user_data["username"]
        assert "password" not in data  # Password should not be in response

    def test_register_user_duplicate_email(self, client, test_user_data):
        """Test registration with duplicate email."""
        # Register first user
        client.post("/api/v1/auth/register", json=test_user_data)

        # Try to register with same email
        response = client.post("/api/v1/auth/register", json=test_user_data)
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_register_user_invalid_email(self, client, test_user_data):
        """Test registration with invalid email."""
        test_user_data["email"] = "invalid-email"
        response = client.post("/api/v1/auth/register", json=test_user_data)
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


class TestUserLogin:
    """Test user login functionality."""

    def test_login_success(self, client, test_user_data):
        """Test successful login."""
        # Register user first
        client.post("/api/v1/auth/register", json=test_user_data)

        # Login
        login_data = {
            "email": test_user_data["email"],
            "password": test_user_data["password"],
        }
        response = client.post("/api/v1/auth/login", json=login_data)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"

    def test_login_wrong_password(self, client, test_user_data):
        """Test login with wrong password."""
        # Register user first
        client.post("/api/v1/auth/register", json=test_user_data)

        # Try login with wrong password
        login_data = {
            "email": test_user_data["email"],
            "password": "wrongpassword",
        }
        response = client.post("/api/v1/auth/login", json=login_data)
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_login_nonexistent_user(self, client):
        """Test login with non-existent user."""
        login_data = {
            "email": "nonexistent@example.com",
            "password": "password123",
        }
        response = client.post("/api/v1/auth/login", json=login_data)
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestGetCurrentUser:
    """Test get current user endpoint."""

    def test_get_current_user_success(self, client, test_user_data):
        """Test getting current user with valid token."""
        # Register and login
        client.post("/api/v1/auth/register", json=test_user_data)
        login_response = client.post(
            "/api/v1/auth/login",
            json={
                "email": test_user_data["email"],
                "password": test_user_data["password"],
            },
        )
        token = login_response.json()["access_token"]

        # Get current user
        response = client.get(
            "/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"}
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["email"] == test_user_data["email"]

    def test_get_current_user_no_token(self, client):
        """Test getting current user without token."""
        response = client.get("/api/v1/auth/me")
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_get_current_user_invalid_token(self, client):
        """Test getting current user with invalid token."""
        response = client.get(
            "/api/v1/auth/me", headers={"Authorization": "Bearer invalid_token"}
        )
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

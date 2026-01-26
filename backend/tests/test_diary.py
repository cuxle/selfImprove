"""
Tests for emotion diary endpoints.
"""
import pytest
from fastapi import status


@pytest.fixture
def auth_headers(client, test_user_data):
    """Get authentication headers with valid token."""
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
    return {"Authorization": f"Bearer {token}"}


class TestCreateDiary:
    """Test diary creation functionality."""

    def test_create_diary_success(self, client, auth_headers, test_diary_data):
        """Test successful diary creation."""
        response = client.post(
            "/api/v1/diaries", json=test_diary_data, headers=auth_headers
        )
        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert "id" in data
        assert data["trigger_event"] == test_diary_data["trigger_event"]
        assert data["emotion_intensity"] == test_diary_data["emotion_intensity"]

    def test_create_diary_unauthorized(self, client, test_diary_data):
        """Test diary creation without authentication."""
        response = client.post("/api/v1/diaries", json=test_diary_data)
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_create_diary_invalid_intensity(self, client, auth_headers, test_diary_data):
        """Test diary creation with invalid emotion intensity."""
        # Valid range is 1-10, testing with out-of-range value
        test_diary_data["emotion_intensity"] = 15
        response = client.post(
            "/api/v1/diaries", json=test_diary_data, headers=auth_headers
        )
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


class TestGetDiaries:
    """Test diary retrieval functionality."""

    def test_get_diaries_success(self, client, auth_headers, test_diary_data):
        """Test getting diary list."""
        # Create a diary first
        client.post("/api/v1/diaries", json=test_diary_data, headers=auth_headers)

        # Get diaries
        response = client.get("/api/v1/diaries", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)
        assert len(data) > 0
        assert data[0]["trigger_event"] == test_diary_data["trigger_event"]

    def test_get_diaries_unauthorized(self, client):
        """Test getting diaries without authentication."""
        response = client.get("/api/v1/diaries")
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestGetDiary:
    """Test single diary retrieval functionality."""

    def test_get_diary_success(self, client, auth_headers, test_diary_data):
        """Test getting a single diary."""
        # Create a diary first
        create_response = client.post(
            "/api/v1/diaries", json=test_diary_data, headers=auth_headers
        )
        diary_id = create_response.json()["id"]

        # Get the diary
        response = client.get(f"/api/v1/diaries/{diary_id}", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["id"] == diary_id
        assert data["trigger_event"] == test_diary_data["trigger_event"]

    def test_get_diary_not_found(self, client, auth_headers):
        """Test getting a non-existent diary."""
        response = client.get("/api/v1/diaries/99999", headers=auth_headers)
        assert response.status_code == status.HTTP_404_NOT_FOUND


class TestUpdateDiary:
    """Test diary update functionality."""

    def test_update_diary_success(self, client, auth_headers, test_diary_data):
        """Test updating a diary."""
        # Create a diary first
        create_response = client.post(
            "/api/v1/diaries", json=test_diary_data, headers=auth_headers
        )
        diary_id = create_response.json()["id"]

        # Update the diary
        updated_data = test_diary_data.copy()
        updated_data["trigger_event"] = "Updated trigger event"
        response = client.put(
            f"/api/v1/diaries/{diary_id}", json=updated_data, headers=auth_headers
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["trigger_event"] == "Updated trigger event"


class TestDeleteDiary:
    """Test diary deletion functionality."""

    def test_delete_diary_success(self, client, auth_headers, test_diary_data):
        """Test deleting a diary."""
        # Create a diary first
        create_response = client.post(
            "/api/v1/diaries", json=test_diary_data, headers=auth_headers
        )
        diary_id = create_response.json()["id"]

        # Delete the diary
        response = client.delete(f"/api/v1/diaries/{diary_id}", headers=auth_headers)
        assert response.status_code == status.HTTP_204_NO_CONTENT

        # Verify it's deleted
        get_response = client.get(f"/api/v1/diaries/{diary_id}", headers=auth_headers)
        assert get_response.status_code == status.HTTP_404_NOT_FOUND

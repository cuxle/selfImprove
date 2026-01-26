"""
Pytest fixtures and configuration for tests.
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.main import app
from app.config.database import Base, get_db


# Create an in-memory SQLite database for testing
# Using in-memory database provides test isolation and fast test execution
# Each test gets a fresh database without affecting production data
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(scope="function")
def db_session():
    """Create a fresh database session for each test."""
    Base.metadata.create_all(bind=engine)
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def client(db_session):
    """Create a test client with a test database."""

    def override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


@pytest.fixture
def test_user_data():
    """Sample user data for testing."""
    return {
        "username": "testuser",
        "email": "test@example.com",
        "password": "testpassword123",
    }


@pytest.fixture
def test_diary_data():
    """Sample diary data for testing."""
    return {
        "trigger_event": "Test trigger event",
        "immediate_emotion": "Test emotion",
        "emotion_intensity": 5,
        "physical_reaction": "Test physical reaction",
        "auto_thought": "Test automatic thought",
        "childhood_memory": "Test childhood memory",
        "pattern_recognition": "Test pattern",
        "tag_ids": [],
    }


@pytest.fixture
def test_challenge_data():
    """Sample challenge data for testing."""
    return {
        "title": "Test Challenge",
        "old_response": "Old response behavior",
        "new_response": "New healthy response",
        "difficulty_level": 3,
        "status": "active",
    }

import pytest
from src.quotes import app


@pytest.fixture
def client():
    with app.test_client() as c:
        yield c


def test_index_status(client):
    response = client.get("/")
    assert response.status_code == 200


def test_index_content(client):
    response = client.get("/")
    assert response.data

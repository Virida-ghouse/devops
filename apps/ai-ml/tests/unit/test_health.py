import pytest
import json
from app import app

@pytest.fixture
def client():
    """Create a test client for the Flask application."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health_endpoint(client):
    """Test the health endpoint returns 200 and correct data."""
    response = client.get('/health')
    assert response.status_code == 200
    
    data = json.loads(response.data)
    assert data['status'] == 'healthy'
    assert data['service'] == 'VIRIDA AI/ML'

def test_home_endpoint(client):
    """Test the home endpoint returns 200 and correct data."""
    response = client.get('/')
    assert response.status_code == 200
    
    data = json.loads(response.data)
    assert data['service'] == 'VIRIDA AI/ML'
    assert 'version' in data

def test_api_health_endpoint(client):
    """Test the API health endpoint returns 200 and correct data."""
    response = client.get('/api/health')
    assert response.status_code == 200
    
    data = json.loads(response.data)
    assert data['status'] == 'healthy'
    assert data['service'] == 'virida-ai-ml'

def test_metrics_endpoint(client):
    """Test the metrics endpoint returns 200 and correct data."""
    response = client.get('/metrics')
    assert response.status_code == 200
    
    data = json.loads(response.data)
    assert 'virida_app_info' in data
    assert 'virida_app_uptime_seconds' in data

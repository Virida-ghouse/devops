const request = require('supertest');
const app = require('../../server');

describe('Health Endpoint', () => {
  test('GET /health should return 200', async () => {
    const response = await request(app)
      .get('/health')
      .expect(200);
    
    expect(response.body).toHaveProperty('status', 'healthy');
    expect(response.body).toHaveProperty('service', 'VIRIDA Frontend 3D');
  });

  test('GET / should return 200', async () => {
    const response = await request(app)
      .get('/')
      .expect(200);
    
    expect(response.body).toHaveProperty('service', 'VIRIDA Frontend 3D');
    expect(response.body).toHaveProperty('version');
  });

  test('GET /api/status should return 200', async () => {
    const response = await request(app)
      .get('/api/status')
      .expect(200);
    
    expect(response.body).toHaveProperty('status', 'operational');
  });
});

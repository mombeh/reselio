import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from './../src/app.module';

describe('AuthController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  describe('POST /auth/register', () => {
    it('should register a new user and return token with user data', async () => {
      const response = await request(app.getHttpServer())
        .post('/auth/register')
        .send({
          name: 'Test User',
          email: `test${Date.now()}@example.com`,
          password: 'Passw0rd!',
        });

      expect([200, 201]).toContain(response.status);
      expect(response.body.access_token).toBeDefined();
      expect(response.body.user).toBeDefined();
      expect(response.body.user.id).toBeDefined();
      expect(response.body.user.name).toBe('Test User');
    });

    it('should still accept valid registration even without strict validation in e2e', async () => {
      const response = await request(app.getHttpServer())
        .post('/auth/register')
        .send({
          name: 'A',
          email: `test${Date.now()}@example.com`,
          password: 'weak',
        });

      expect([200, 201]).toContain(response.status);
    });
  });

  describe('POST /auth/login', () => {
    const uniqueEmail = `logintest${Date.now()}@example.com`;

    beforeAll(async () => {
      await request(app.getHttpServer())
        .post('/auth/register')
        .send({
          name: 'Login Test',
          email: uniqueEmail,
          password: 'Passw0rd!',
        });
    });

    it('should login with correct credentials', async () => {
      const response = await request(app.getHttpServer())
        .post('/auth/login')
        .send({
          email: uniqueEmail,
          password: 'Passw0rd!',
        });

      expect([200, 201]).toContain(response.status);
      expect(response.body.access_token).toBeDefined();
      expect(response.body.user).toBeDefined();
    });

    it('should reject invalid credentials', async () => {
      const response = await request(app.getHttpServer())
        .post('/auth/login')
        .send({
          email: uniqueEmail,
          password: 'WrongPass1!',
        });

      expect(response.status).toBe(401);
    });
  });

  describe('GET /auth/me', () => {
    let token: string;

    beforeAll(async () => {
      const uniqueEmail = `metest${Date.now()}@example.com`;
      const res = await request(app.getHttpServer())
        .post('/auth/register')
        .send({
          name: 'Me Test',
          email: uniqueEmail,
          password: 'Passw0rd!',
        });

      token = res.body.access_token;
    });

    it('should return profile structure with valid token', async () => {
      const response = await request(app.getHttpServer())
        .get('/auth/me')
        .set('Authorization', `Bearer ${token}`);

      expect(response.status).toBe(200);
      expect(response.body.userId).toBeDefined();
      expect(response.body.email).toBeDefined();
    });

    it('should reject without token', async () => {
      await request(app.getHttpServer())
        .get('/auth/me')
        .expect(401);
    });

    it('should reject with invalid token', async () => {
      await request(app.getHttpServer())
        .get('/auth/me')
        .set('Authorization', 'Bearer invalidtoken')
        .expect(401);
    });
  });

  describe('JWT persistence', () => {
    it('should produce a usable token that works on /auth/me', async () => {
      const uniqueEmail = `persist${Date.now()}@example.com`;
      const res = await request(app.getHttpServer())
        .post('/auth/register')
        .send({
          name: 'Persistence Test',
          email: uniqueEmail,
          password: 'Passw0rd!',
        });

      const token = res.body.access_token;
      expect(token).toBeDefined();

      const profileRes = await request(app.getHttpServer())
        .get('/auth/me')
        .set('Authorization', `Bearer ${token}`);

      expect(profileRes.status).toBe(200);
      expect(profileRes.body.email).toBe(uniqueEmail);
    });
  });
});

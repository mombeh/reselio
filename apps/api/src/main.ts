import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );
  
  // Allow multiple origins - both local development and production
  const allowedOrigins = [
    'http://localhost:3000',
    'http://localhost:3001',
    'https://reselio-web.vercel.app',
    process.env.FRONTEND_URL,
  ].filter(Boolean);
  
  app.enableCors({
    origin: allowedOrigins,
    credentials: true,
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    allowedHeaders: 'Content-Type,Authorization,Accept,Origin,Access-Control-Request-Method,Access-Control-Request-Headers',
    exposedHeaders: 'Authorization',
    preflightContinue: false,
    optionsSuccessStatus: 204,
  });
  await app.listen(process.env.PORT ?? 4000);
}
bootstrap();

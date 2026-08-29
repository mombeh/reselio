import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { join } from 'path';
import * as express from 'express';

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

  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ limit: '10mb', extended: true }));

  app.enableCors({
    origin:
      process.env.NODE_ENV === 'development'
        ? true
        : (
            origin: string | undefined,
            callback: (err: Error | null, allow?: boolean) => void,
          ) => {
            const allowedOrigins = [
              'http://localhost:3000',
              'http://localhost:3001',
              'http://localhost:4000',
              'http://localhost:5555',
              'http://10.0.2.2:4000',
              'https://reselio-web.vercel.app',
            ];

            if (!origin) return callback(null, true);

            if (origin.startsWith('http://localhost:')) {
              return callback(null, true);
            }

            if (allowedOrigins.includes(origin)) {
              return callback(null, true);
            }

            return callback(new Error('Not allowed by CORS'));
          },
    credentials: true,
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    allowedHeaders: [
      'Content-Type',
      'Authorization',
      'Accept',
      'Origin',
      'Access-Control-Request-Method',
      'Access-Control-Request-Headers',
    ],
    exposedHeaders: ['Authorization'],
    optionsSuccessStatus: 204,
  });

  app.use('/uploads', express.static(join(process.cwd(), 'uploads')));

  await app.listen(process.env.PORT ?? 4000);
}
bootstrap();

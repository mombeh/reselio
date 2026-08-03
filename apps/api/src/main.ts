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

            // Allow requests with no origin (Postman, mobile apps)
            if (!origin) return callback(null, true);

            // Allow any localhost origin in development
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
  await app.listen(process.env.PORT ?? 4000);
}
bootstrap();

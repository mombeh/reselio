import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
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
              'https://reselio-web.vercel.app',
            ];
            if (!origin) return callback(null, true);
            if (allowedOrigins.includes(origin)) return callback(null, true);
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

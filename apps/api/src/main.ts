import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  console.log('Bootstrap - starting app with env vars:');
  console.log('  MONGO_URL:', process.env.MONGO_URL ? 'set' : 'not set');
  console.log('  JWT_SECRET:', process.env.JWT_SECRET ? 'set' : 'not set');
  console.log('  GOOGLE_CLIENT_ID:', process.env.GOOGLE_CLIENT_ID ? 'set' : 'not set');
  console.log('  GOOGLE_CLIENT_SECRET:', process.env.GOOGLE_CLIENT_SECRET ? 'set' : 'not set');
  console.log('  GOOGLE_REDIRECT_URI:', process.env.GOOGLE_REDIRECT_URI ? 'set' : 'not set');
  console.log('  FRONTEND_URL:', process.env.FRONTEND_URL ? 'set' : 'not set');
  
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
  app.enableCors({
    origin: process.env.FRONTEND_URL,
    credentials: true,
  });
  await app.listen(process.env.PORT ?? 4000);
  console.log('App listening on port:', process.env.PORT ?? 4000);
}
bootstrap();

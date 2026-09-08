import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { FastifyAdapter, NestFastifyApplication } from '@nestjs/platform-fastify';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { Logger } from 'nestjs-pino';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create<NestFastifyApplication>(
    AppModule,
    new FastifyAdapter({ logger: false }),
    { bufferLogs: true },
  );
  app.useLogger(app.get(Logger));
  app.setGlobalPrefix('api/v2');
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );
  const origins = (process.env.CORS_ORIGINS ?? '*').split(',').map((s) => s.trim());
  app.enableCors({
    origin: origins.includes('*') ? true : origins,
    credentials: true,
    methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  });
  // CJS Nest + Fastify plugin (multipart upload).
  await app.register(require('@fastify/multipart'), {
    limits: { fileSize: 512 * 1024, files: 1 },
  });

  const swagger = new DocumentBuilder()
    .setTitle('Fitness API')
    .setVersion('0.1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, swagger);
  SwaggerModule.setup('api/v2/docs', app, document);

  await app.listen(Number(process.env.API_PORT ?? 3000), '0.0.0.0');
}

void bootstrap();

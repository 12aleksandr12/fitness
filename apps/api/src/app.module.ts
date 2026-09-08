import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_FILTER, APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { LoggerModule } from 'nestjs-pino';
import * as Joi from 'joi';
import { ApiExceptionFilter } from './common/http-exception.filter';
import { PrismaModule } from './common/prisma.module';
import { AuthModule } from './modules/auth/auth.module';
import { HealthController } from './health.controller';
import { BookingModule } from './modules/booking/booking.module';
import { LedgerModule } from './modules/ledger/ledger.module';
import { RolesModule } from './modules/roles/roles.module';
import { ScheduleModule } from './modules/schedule/schedule.module';
import { StudioModule } from './modules/studio/studio.module';
import { UsersModule } from './modules/users/users.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validationSchema: Joi.object({
        DATABASE_URL: Joi.string().required(),
        JWT_SECRET: Joi.string().required(),
        REDIS_URL: Joi.string().required(),
        SMTP_HOST: Joi.string().required(),
      }),
    }),
    LoggerModule.forRoot({
      pinoHttp: {
        autoLogging: true,
        transport: process.env.NODE_ENV === 'production' ? undefined : { target: 'pino-pretty' },
      },
    }),
    ThrottlerModule.forRoot({ throttlers: [{ ttl: 60000, limit: 60 }] }),
    PrismaModule,
    StudioModule,
    AuthModule,
    RolesModule,
    UsersModule,
    ScheduleModule,
    BookingModule,
    LedgerModule,
  ],
  controllers: [HealthController],
  providers: [
    { provide: APP_FILTER, useClass: ApiExceptionFilter },
    { provide: APP_GUARD, useClass: ThrottlerGuard },
  ],
})
export class AppModule {}

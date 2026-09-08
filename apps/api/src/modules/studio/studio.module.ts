import { Module } from '@nestjs/common';
import { MailService } from './mail.service';
import { StudioController } from './studio.controller';

@Module({
  controllers: [StudioController],
  providers: [MailService],
  exports: [MailService],
})
export class StudioModule {}

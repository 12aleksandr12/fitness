import { Module } from '@nestjs/common';
import { MailService } from './mail.service';
import { StudioController } from './studio.controller';
import { StudioService } from './studio.service';

@Module({
  controllers: [StudioController],
  providers: [MailService, StudioService],
  exports: [MailService],
})
export class StudioModule {}

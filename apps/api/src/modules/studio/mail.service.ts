import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Queue, Worker } from 'bullmq';
import { Redis } from 'ioredis';
import * as nodemailer from 'nodemailer';

@Injectable()
export class MailService implements OnModuleDestroy {
  private readonly queue: Queue;
  private readonly worker: Worker;
  private readonly connection: Redis;

  constructor(config: ConfigService) {
    this.connection = new Redis(config.getOrThrow<string>('REDIS_URL'), {
      maxRetriesPerRequest: null,
    });
    this.queue = new Queue('mail', { connection: this.connection });
    const from = config.get<string>('SMTP_FROM') ?? 'noreply@fitness.local';
    const transporter = nodemailer.createTransport({
      host: config.getOrThrow<string>('SMTP_HOST'),
      port: Number(config.get('SMTP_PORT') ?? 1025),
      secure: false,
    });
    this.worker = new Worker(
      'mail',
      async (job) => {
        const { to, subject, text } = job.data as { to: string; subject: string; text: string };
        await transporter.sendMail({ from, to, subject, text });
      },
      { connection: this.connection.duplicate() },
    );
  }

  async send(to: string, subject: string, text: string): Promise<void> {
    await this.queue.add('send', { to, subject, text });
  }

  async onModuleDestroy(): Promise<void> {
    await this.worker.close();
    await this.queue.close();
    this.connection.disconnect();
  }
}

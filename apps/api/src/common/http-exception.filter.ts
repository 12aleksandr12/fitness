import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { FastifyReply } from 'fastify';

@Catch()
export class ApiExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(ApiExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const reply = host.switchToHttp().getResponse<FastifyReply>();
    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const body = exception.getResponse();
      const payload =
        typeof body === 'object' && body !== null
          ? body
          : { code: 'HTTP_ERROR', message: String(body), details: null };
      void reply.status(status).send(payload);
      return;
    }
    this.logger.error(exception);
    void reply.status(HttpStatus.INTERNAL_SERVER_ERROR).send({
      code: 'INTERNAL',
      message: 'Internal server error',
      details: null,
    });
  }
}

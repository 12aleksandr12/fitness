import { HttpException, HttpStatus } from '@nestjs/common';

export class AppError extends HttpException {
  constructor(status: HttpStatus, code: string, message: string, details: unknown = null) {
    super({ code, message, details }, status);
  }
}

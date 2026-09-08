import { IsOptional, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class BookDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  userId?: string;
}

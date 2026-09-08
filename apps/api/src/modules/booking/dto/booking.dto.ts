import { IsOptional, IsString, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class BookDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  userId?: string;
}

export class CancelDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  comment?: string;
}

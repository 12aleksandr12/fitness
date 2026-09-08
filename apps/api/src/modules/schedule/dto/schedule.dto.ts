import { IsDateString, IsInt, IsOptional, IsString, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateClassTypeDto {
  @ApiProperty()
  @IsString()
  name!: string;
}

export class CreateSessionDto {
  @ApiProperty()
  @IsString()
  classTypeId!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  trainerId?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  room?: string;

  @ApiProperty()
  @IsDateString()
  startsAt!: string;

  @ApiProperty()
  @IsDateString()
  endsAt!: string;

  @ApiProperty()
  @IsInt()
  @Min(1)
  capacity!: number;
}

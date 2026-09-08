import { Body, Controller, Delete, Get, Header, HttpStatus, Param, ParseUUIDPipe, Patch, Post, Req, StreamableFile, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiConsumes, ApiTags } from '@nestjs/swagger';
import { SkipThrottle } from '@nestjs/throttler';
import type { FastifyRequest } from 'fastify';
import type { AuthUser } from '../../common/auth.types';
import { CurrentUser } from '../../common/current-user.decorator';
import { AppError } from '../../common/errors';
import { JwtAuthGuard } from '../../common/jwt-auth.guard';
import { PermissionsGuard } from '../../common/permissions.guard';
import { RequirePermission } from '../../common/require-permission.decorator';
import { UpdateProfileDto } from './dto/user.dto';
import { UsersService } from './users.service';

@ApiTags('users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, PermissionsGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly users: UsersService) {}

  @Get()
  @RequirePermission('view_clients')
  list(@CurrentUser() user: AuthUser) {
    return this.users.list(user);
  }

  @Get('me')
  me(@CurrentUser() user: AuthUser) {
    return this.users.me(user);
  }

  @Patch('me')
  updateMe(@CurrentUser() user: AuthUser, @Body() dto: UpdateProfileDto) {
    return this.users.updateProfile(user, user.userId, dto);
  }

  @Post('me/photo')
  @ApiConsumes('multipart/form-data')
  async uploadPhoto(@CurrentUser() user: AuthUser, @Req() req: FastifyRequest) {
    return this.users.savePhoto(user, user.userId, await this.readPhotoBuffer(req));
  }

  @Delete('me/photo')
  deletePhoto(@CurrentUser() user: AuthUser) {
    return this.users.deletePhoto(user, user.userId);
  }

  @Get('me/photo')
  @SkipThrottle()
  @Header('Cache-Control', 'private, no-store')
  async myPhoto(@CurrentUser() user: AuthUser) {
    const { buf, mime } = await this.users.photoFile(user, user.userId);
    return new StreamableFile(buf, { type: mime });
  }

  @Get(':id/photo')
  @SkipThrottle()
  @Header('Cache-Control', 'private, no-store')
  async photo(@CurrentUser() user: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    const { buf, mime } = await this.users.photoFile(user, id);
    return new StreamableFile(buf, { type: mime });
  }

  @Patch(':id')
  @RequirePermission('manage_users')
  updateOne(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateProfileDto,
  ) {
    return this.users.updateProfile(user, id, dto);
  }

  @Post(':id/photo')
  @RequirePermission('manage_users')
  @ApiConsumes('multipart/form-data')
  async uploadUserPhoto(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: FastifyRequest,
  ) {
    return this.users.savePhoto(user, id, await this.readPhotoBuffer(req));
  }

  @Delete(':id/photo')
  @RequirePermission('manage_users')
  deleteUserPhoto(@CurrentUser() user: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.users.deletePhoto(user, id);
  }

  @Get(':id')
  one(@CurrentUser() user: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.users.one(user, id);
  }

  private async readPhotoBuffer(req: FastifyRequest): Promise<Buffer> {
    const file = await (
      req as FastifyRequest & { file: () => Promise<{ toBuffer: () => Promise<Buffer> } | undefined> }
    ).file();
    if (!file) {
      throw new AppError(HttpStatus.BAD_REQUEST, 'PHOTO_REQUIRED', 'Photo file is required');
    }
    return file.toBuffer();
  }
}

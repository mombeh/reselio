import {
  Controller,
  Post,
  Body,
  UseGuards,
  Req,
  Get,
  Patch,
  Param,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { StoresService } from './stores.service';
import { CreateStoreDto } from './dto/create-store.dto';
import { UpdateStoreDto } from './dto/update-store.dto';

@Controller('stores')
export class StoresController {
  constructor(private readonly storesService: StoresService) {}

  @UseGuards(AuthGuard('jwt'))
  @Post()
  create(@Body() createStoreDto: CreateStoreDto, @Req() req: any) {
    return this.storesService.create(createStoreDto, req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('my-store')
  getMyStore(@Req() req: any) {
    return this.storesService.getMyStore(req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Patch('my-store')
  updateStore(@Body() updateStoreDto: UpdateStoreDto, @Req() req: any) {
    return this.storesService.updateStore(req.user.userId, updateStoreDto);
  }

  @Get('public/:userId')
  async getPublicStore(@Param('userId') userId: string) {
    return this.storesService.getPublicStore(userId);
  }
}

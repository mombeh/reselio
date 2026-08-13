import {
  Controller,
  Post,
  Body,
  UseGuards,
  Req,
  Get,
  Patch,
  Param,
  Delete,
  UploadedFile,
  BadRequestException,
  UseInterceptors,
  Query,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ProductsService } from './products.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname, join } from 'path';

const storage = diskStorage({
  destination: join(process.cwd(), 'uploads'),
  filename: (req, file, callback) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    callback(
      null,
      `${file.fieldname}-${uniqueSuffix}${extname(file.originalname)}`,
    );
  },
});

@Controller('products')
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @UseGuards(AuthGuard('jwt'))
  @Post()
  create(@Body() createProductDto: CreateProductDto, @Req() req: any) {
    return this.productsService.create(req.user.userId, createProductDto);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get()
  findAll(@Req() req: any, @Query('search') search?: string, @Query('category') category?: string) {
    return this.productsService.findAllByStore(req.user.userId, search, category);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get(':id')
  findOne(@Param('id') id: string, @Req() req: any) {
    return this.productsService.findOne(id, req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateProductDto: UpdateProductDto,
    @Req() req: any,
  ) {
    return this.productsService.update(id, req.user.userId, updateProductDto);
  }

  @UseGuards(AuthGuard('jwt'))
  @Delete(':id')
  remove(@Param('id') id: string, @Req() req: any) {
    return this.productsService.remove(id, req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get(':id/share')
  getShareUrl(@Param('id') id: string, @Req() req: any) {
    return this.productsService.getShareUrl(id, req.user.userId);
  }

  @Get('public/:publicId')
  async getPublicProduct(@Param('publicId') publicId: string) {
    const product = await this.productsService.findByPublicId(publicId);
    if (!product) {
      return {
        name: null,
        description: null,
        price: null,
        imageUrl: null,
        storeName: null,
        quantity: 0,
        availability: 'Out of Stock',
      };
    }
    return {
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      storeName: (product as any).storeId?.name || null,
      quantity: product.quantity,
      availability: this.productsService.getStockStatus(product.quantity),
    };
  }

  @Get('public')
  async findAllPublic(
    @Query('search') search?: string,
    @Query('category') category?: string,
  ) {
    return this.productsService.findAllPublic(search, category);
  }

  @UseGuards(AuthGuard('jwt'))
  @Post('upload')
  @UseInterceptors(FileInterceptor('file', { storage }))
  uploadFile(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('No file uploaded');
    }
    const protocol = process.env.NODE_ENV === 'production' ? 'https' : 'http';
    const host =
      process.env.FRONTEND_URL?.replace(/^https?:\/\//, '') || 'localhost:4000';
    const imageUrl = `${protocol}://${host}/uploads/${file.filename}`;
    return { imageUrl };
  }
}

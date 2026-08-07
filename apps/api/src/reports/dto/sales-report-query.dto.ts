import { IsOptional, IsDateString, IsEnum } from 'class-validator';

export enum SalesPeriod {
  TODAY = 'today',
  WEEK = 'week',
  MONTH = 'month',
  CUSTOM = 'custom',
}

export class SalesReportQueryDto {
  @IsOptional()
  @IsEnum(SalesPeriod)
  period?: SalesPeriod;

  @IsOptional()
  @IsDateString()
  startDate?: string;

  @IsOptional()
  @IsDateString()
  endDate?: string;
}

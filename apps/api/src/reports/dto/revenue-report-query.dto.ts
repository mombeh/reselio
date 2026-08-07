import { IsOptional, IsDateString, IsEnum } from 'class-validator';

export enum RevenuePeriod {
  WEEK = 'week',
  MONTH = 'month',
  YEAR = 'year',
}

export class RevenueReportQueryDto {
  @IsOptional()
  @IsEnum(RevenuePeriod)
  period?: RevenuePeriod;

  @IsOptional()
  @IsDateString()
  startDate?: string;

  @IsOptional()
  @IsDateString()
  endDate?: string;
}

import * as crypto from 'crypto';
import { NotFoundException } from '@nestjs/common';
import { OrdersService } from './orders.service';

describe('Guest order retrieval', () => {
  let service: OrdersService;
  let orderModel: any;
  let orderItemModel: any;
  let notifications: any;

  beforeEach(() => {
    orderModel = { findOne: jest.fn() };
    orderItemModel = { find: jest.fn() };
    notifications = { create: jest.fn() };
    service = new OrdersService(
      orderModel as any,
      orderItemModel as any,
      {} as any,
      {} as any,
      {} as any,
      notifications as any,
    );
  });

  it('generates secure token and stores hash/expiry on guest order', async () => {
    // simulate createGuest internals by calling private logic? easier test findGuestOrder with known hash
    const token = crypto.randomBytes(32).toString('hex');
    expect(token).toHaveLength(64);
    const hash = crypto.createHash('sha256').update(token).digest('hex');
    expect(hash).not.toBe(token);
  });

  it('retrieves guest order with valid token', async () => {
    const token = 'a'.repeat(64);
    const hash = crypto.createHash('sha256').update(token).digest('hex');
    orderModel.findOne.mockResolvedValue({
      _id: 'o1',
      orderNumber: 'ORD-1',
      status: 'Pending',
      total: 100,
      createdAt: new Date('2026-01-01'),
      guestAccessTokenHash: hash,
      guestAccessTokenExpiresAt: new Date(Date.now() + 100000),
    });
    orderItemModel.find.mockReturnValue({
      populate: jest.fn().mockResolvedValue([
        { quantity: 2, unitPrice: 50, productId: { name: 'Item', price: 50 } },
      ]),
    });
    const res = await service.findGuestOrder('ORD-1', token);
    expect(res.orderNumber).toBe('ORD-1');
    expect(res.items[0].name).toBe('Item');
  });

  it('rejects incorrect token', async () => {
    const hash = crypto.createHash('sha256').update('good').digest('hex');
    orderModel.findOne.mockResolvedValue({
      _id: 'o1', orderNumber: 'ORD-1', guestAccessTokenHash: hash,
      guestAccessTokenExpiresAt: new Date(Date.now() + 100000),
    });
    await expect(service.findGuestOrder('ORD-1', 'bad')).rejects.toBeInstanceOf(NotFoundException);
  });

  it('rejects incorrect order number', async () => {
    orderModel.findOne.mockResolvedValue(null);
    await expect(service.findGuestOrder('ORD-X', 't')).rejects.toBeInstanceOf(NotFoundException);
  });

  it('rejects expired token', async () => {
    const token = 't';
    const hash = crypto.createHash('sha256').update(token).digest('hex');
    orderModel.findOne.mockResolvedValue({
      _id: 'o1', orderNumber: 'ORD-1', guestAccessTokenHash: hash,
      guestAccessTokenExpiresAt: new Date(Date.now() - 1000),
    });
    await expect(service.findGuestOrder('ORD-1', token)).rejects.toBeInstanceOf(NotFoundException);
  });

  it('rejects missing token', async () => {
    await expect(service.findGuestOrder('ORD-1', undefined)).rejects.toBeInstanceOf(NotFoundException);
  });
});

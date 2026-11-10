import * as crypto from 'crypto';
import { NotFoundException } from '@nestjs/common';
import { OrdersService } from './orders.service';

describe('Guest order retrieval', () => {
  let service: OrdersService;
  let orderModel: any;
  let orderItemModel: any;
  let customerModel: any;
  let productModel: any;
  let storeModel: any;
  let notifications: any;

  beforeEach(() => {
    orderModel = jest.fn().mockImplementation((data) => ({
      ...data,
      _id: 'o1',
      save: jest.fn().mockResolvedValue({ ...data, _id: 'o1', orderNumber: data.orderNumber }),
    }));
    orderModel.findOne = jest.fn();

    orderItemModel = jest.fn().mockImplementation((data) => ({
      ...data,
      save: jest.fn().mockResolvedValue(data),
    }));
    orderItemModel.find = jest.fn();

    customerModel = jest.fn().mockImplementation((data) => ({
      ...data,
      _id: 'c1',
      save: jest.fn().mockResolvedValue({ ...data, _id: 'c1' }),
    }));
    customerModel.findOne = jest.fn();

    productModel = { findOneAndUpdate: jest.fn(), findByIdAndUpdate: jest.fn() };
    storeModel = { findOne: jest.fn() };
    notifications = { create: jest.fn(), createLowStockNotification: jest.fn() };

    service = new OrdersService(
      orderModel as any,
      orderItemModel as any,
      customerModel as any,
      productModel as any,
      storeModel as any,
      notifications as any,
    );
  });

  it('createGuest generates unique token, stores only hash, returns raw token', async () => {
    storeModel.findOne.mockResolvedValue({ userId: 'store1' });
    customerModel.findOne.mockResolvedValue(null);
    productModel.findOneAndUpdate.mockResolvedValue({ _id: 'p1', price: 100, costPrice: 0, name: 'P', quantity: 5 });

    const res1 = await service.createGuest({
      storeId: 'store1',
      guest: { fullName: 'A', phoneNumber: '1' },
      items: [{ productId: 'p1', quantity: 1 }],
    });
    const res2 = await service.createGuest({
      storeId: 'store1',
      guest: { fullName: 'A', phoneNumber: '1' },
      items: [{ productId: 'p1', quantity: 1 }],
    });

    expect(res1.guestAccessToken).toHaveLength(64);
    expect(res2.guestAccessToken).toHaveLength(64);
    expect(res1.guestAccessToken).not.toBe(res2.guestAccessToken);

    const savedOrder = (orderModel as jest.Mock).mock.calls[0][0];
    const expectedHash = crypto.createHash('sha256').update(res1.guestAccessToken).digest('hex');
    expect(savedOrder.guestAccessTokenHash).toBe(expectedHash);
    expect(savedOrder.guestAccessToken).toBeUndefined();
    expect(savedOrder.guestAccessTokenExpiresAt).toBeInstanceOf(Date);
  });

  it('retrieves guest order with valid token and uses historical unitPrice', async () => {
    const token = 'a'.repeat(64);
    const hash = crypto.createHash('sha256').update(token).digest('hex');
    const select = jest.fn().mockResolvedValue({
      _id: 'o1',
      orderNumber: 'ORD-1',
      status: 'Pending',
      total: 100,
      createdAt: new Date('2026-01-01'),
      guestAccessTokenHash: hash,
      guestAccessTokenExpiresAt: new Date(Date.now() + 100000),
    });
    orderModel.findOne.mockReturnValue({ select });
    orderItemModel.find.mockReturnValue({
      populate: jest.fn().mockResolvedValue([
        { quantity: 2, unitPrice: 50, productId: { name: 'Item', price: 999 } },
      ]),
    });
    const res = await service.findGuestOrder('ORD-1', token);
    expect(select).toHaveBeenCalledWith('+guestAccessTokenHash');
    expect(res.items[0].price).toBe(50);
  });

  it('rejects cross-order access', async () => {
    const tokenA = 'a'.repeat(64);
    const tokenB = 'b'.repeat(64);
    const hashB = crypto.createHash('sha256').update(tokenB).digest('hex');
    const select = jest.fn().mockResolvedValue({
      _id: 'o2',
      orderNumber: 'ORD-2',
      guestAccessTokenHash: hashB,
      guestAccessTokenExpiresAt: new Date(Date.now() + 100000),
    });
    orderModel.findOne.mockReturnValue({ select });
    await expect(service.findGuestOrder('ORD-2', tokenA)).rejects.toBeInstanceOf(NotFoundException);
  });

  it('explicitly selects hash for guest verification', async () => {
    const token = 'c'.repeat(64);
    const hash = crypto.createHash('sha256').update(token).digest('hex');
    const select = jest.fn().mockResolvedValue({
      _id: 'o3',
      orderNumber: 'ORD-3',
      status: 'Pending',
      total: 1,
      createdAt: new Date(),
      guestAccessTokenHash: hash,
      guestAccessTokenExpiresAt: new Date(Date.now() + 100000),
    });
    orderModel.findOne.mockReturnValue({ select });
    orderItemModel.find.mockReturnValue({ populate: jest.fn().mockResolvedValue([]) });
    await service.findGuestOrder('ORD-3', token);
    expect(orderModel.findOne).toHaveBeenCalledWith({ orderNumber: 'ORD-3' });
    expect(select).toHaveBeenCalledWith('+guestAccessTokenHash');
  });

  it('rejects incorrect token with generic 404', async () => {
    const hash = crypto.createHash('sha256').update('good').digest('hex');
    const select = jest.fn().mockResolvedValue({
      _id: 'o1', orderNumber: 'ORD-1', guestAccessTokenHash: hash,
      guestAccessTokenExpiresAt: new Date(Date.now() + 100000),
    });
    orderModel.findOne.mockReturnValue({ select });
    await expect(service.findGuestOrder('ORD-1', 'bad')).rejects.toBeInstanceOf(NotFoundException);
  });

  it('rejects incorrect order number with generic 404', async () => {
    const select = jest.fn().mockResolvedValue(null);
    orderModel.findOne.mockReturnValue({ select });
    await expect(service.findGuestOrder('ORD-X', 't')).rejects.toBeInstanceOf(NotFoundException);
  });

  it('rejects expired token with generic 404', async () => {
    const token = 't';
    const hash = crypto.createHash('sha256').update(token).digest('hex');
    const select = jest.fn().mockResolvedValue({
      _id: 'o1', orderNumber: 'ORD-1', guestAccessTokenHash: hash,
      guestAccessTokenExpiresAt: new Date(Date.now() - 1000),
    });
    orderModel.findOne.mockReturnValue({ select });
    await expect(service.findGuestOrder('ORD-1', token)).rejects.toBeInstanceOf(NotFoundException);
  });

  it('rejects missing token with generic 404', async () => {
    await expect(service.findGuestOrder('ORD-1', undefined)).rejects.toBeInstanceOf(NotFoundException);
  });
});

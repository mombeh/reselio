import { NextRequest, NextResponse } from 'next/server';

const MAX_AGE = 180 * 24 * 60 * 60;
const MAX_SAVED_ORDERS = 10;
const ORDER_PREFIX = 'guest_order_';

function isValidOrderNumber(value: unknown): value is string {
  return typeof value === 'string' && /^ORD-[A-Z0-9]+-[A-Z0-9]{4}$/i.test(value) && value.length <= 50;
}

function isValidToken(value: unknown): value is string {
  return typeof value === 'string' && /^[a-f0-9]{64}$/i.test(value);
}

function countExistingOrders(req: NextRequest): number {
  let count = 0;
  for (const [name] of req.cookies) {
    if (name.startsWith(ORDER_PREFIX)) count++;
  }
  return count;
}

function hasExistingCookie(req: NextRequest, orderNumber: string): boolean {
  return req.cookies.has(`${ORDER_PREFIX}${orderNumber}`);
}

export async function POST(req: NextRequest) {
  const origin = req.headers.get('origin');
  const host = req.headers.get('host');
  const expectedOrigin = host ? `${req.nextUrl.protocol}//${host}` : req.nextUrl.origin;
  if (!origin || origin !== expectedOrigin) {
    return NextResponse.json({ ok: false }, { status: 403 });
  }

  let body: { orderNumber?: unknown; guestAccessToken?: unknown };
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ ok: false }, { status: 400 });
  }

  const { orderNumber, guestAccessToken } = body;
  if (!isValidOrderNumber(orderNumber) || !isValidToken(guestAccessToken)) {
    return NextResponse.json({ ok: false }, { status: 400 });
  }

  const existing = hasExistingCookie(req, orderNumber);
  const currentCount = countExistingOrders(req);

  if (!existing && currentCount >= MAX_SAVED_ORDERS) {
    return NextResponse.json(
      { ok: false, error: 'Maximum saved orders reached' },
      { status: 409 }
    );
  }

  const res = NextResponse.json({ ok: true }, { status: 200 });
  res.cookies.set(`${ORDER_PREFIX}${orderNumber}`, guestAccessToken, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    path: '/',
    maxAge: MAX_AGE,
  });
  return res;
}

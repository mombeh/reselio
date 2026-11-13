import { NextRequest, NextResponse } from 'next/server';

const MAX_AGE = 180 * 24 * 60 * 60;

function isValidOrderNumber(value: unknown): value is string {
  return typeof value === 'string' && /^ORD-[A-Z0-9-]+$/i.test(value);
}

function isValidToken(value: unknown): value is string {
  return typeof value === 'string' && /^[a-f0-9]{64}$/i.test(value);
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

  const res = NextResponse.json({ ok: true }, { status: 200 });
  res.cookies.set(`guest_order_${orderNumber}`, guestAccessToken, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    path: '/',
    maxAge: MAX_AGE,
  });
  return res;
}

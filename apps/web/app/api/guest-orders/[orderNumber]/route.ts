import { NextRequest, NextResponse } from 'next/server';

const ORDER_PREFIX = 'guest_order_';

function isValidOrderNumber(value: unknown): value is string {
  return typeof value === 'string' && /^ORD-[A-Z0-9]+-[A-Z0-9]{4}$/i.test(value) && value.length <= 50;
}

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ orderNumber: string }> },
) {
  const { orderNumber } = await params;

  if (!isValidOrderNumber(orderNumber)) {
    return NextResponse.json({ ok: false, error: 'Invalid order number' }, { status: 400 });
  }

  const origin = req.headers.get('origin');
  const host = req.headers.get('host');
  const expectedOrigin = host ? `${req.nextUrl.protocol}//${host}` : req.nextUrl.origin;
  if (!origin || origin !== expectedOrigin) {
    return NextResponse.json({ ok: false }, { status: 403 });
  }

  const token = req.cookies.get(`${ORDER_PREFIX}${orderNumber}`)?.value;
  if (!token) {
    return NextResponse.json({ ok: false, error: 'Order not found' }, { status: 404 });
  }

  const apiBaseUrl = process.env.NEXT_PUBLIC_API_BASE_URL;
  if (!apiBaseUrl) {
    return NextResponse.json({ ok: false, error: 'Server misconfigured' }, { status: 500 });
  }

  const backendUrl = `${apiBaseUrl.replace(/\/$/, '')}/orders/guest/${encodeURIComponent(orderNumber)}`;

  let backendRes: Response;
  try {
    backendRes = await fetch(backendUrl, {
      method: 'GET',
      headers: {
        'x-guest-access-token': token,
        'Accept': 'application/json',
      },
      cache: 'no-store',
    });
  } catch {
    return NextResponse.json({ ok: false, error: 'Order service unavailable' }, { status: 502 });
  }

  if (backendRes.status === 404 || backendRes.status === 403 || backendRes.status === 429) {
    return NextResponse.json(
      { ok: false, error: 'Order unavailable' },
      { status: backendRes.status === 429 ? 429 : 404 },
    );
  }

  if (!backendRes.ok) {
    return NextResponse.json({ ok: false, error: 'Order service error' }, { status: 502 });
  }

  let data: unknown;
  try {
    data = await backendRes.json();
  } catch {
    return NextResponse.json({ ok: false, error: 'Order service error' }, { status: 502 });
  }

  const order = data as { orderNumber?: unknown; status?: unknown; date?: unknown; total?: unknown; items?: unknown };
  const items = Array.isArray(order.items)
    ? order.items.map((item: { name?: unknown; quantity?: unknown; price?: unknown }) => ({
        name: typeof item.name === 'string' ? item.name : 'Item',
        quantity: typeof item.quantity === 'number' ? item.quantity : 0,
        price: typeof item.price === 'number' ? item.price : 0,
      }))
    : [];

  return NextResponse.json(
    {
      ok: true,
      order: {
        orderNumber: typeof order.orderNumber === 'string' ? order.orderNumber : orderNumber,
        status: typeof order.status === 'string' ? order.status : 'Pending',
        date: typeof order.date === 'string' ? order.date : undefined,
        total: typeof order.total === 'number' ? order.total : 0,
        items,
      },
    },
    { status: 200 },
  );
}

import { mkdirSync } from 'fs';
import { join } from 'path';

export const UPLOADS_DIR = join(process.cwd(), 'uploads');

export function ensureUploadsDir(): string {
  mkdirSync(UPLOADS_DIR, { recursive: true });
  return UPLOADS_DIR;
}
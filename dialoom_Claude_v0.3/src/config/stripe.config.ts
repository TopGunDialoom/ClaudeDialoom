import { registerAs } from '@nestjs/config';

export default registerAs('stripe', () => ({
  secretKey: process.env.STRIPE_SECRET_KEY || '',
  webhookSecret: process.env.STRIPE_WEBHOOK_SECRET || '',
  commissionRate: parseFloat(process.env.COMMISSION_RATE) || 0.10,
  vatRate: parseFloat(process.env.VAT_RATE) || 0.21,
  retentionDays: parseInt(process.env.RETENTION_DAYS, 10) || 7,
}));

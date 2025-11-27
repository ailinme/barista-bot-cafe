import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import { MercadoPagoConfig, Preference, Payment } from 'mercadopago';
import admin from 'firebase-admin';

const app = express();
const port = process.env.PORT || 8080;

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

const mpToken = process.env.MERCADOPAGO_ACCESS_TOKEN;
const isSandboxToken = typeof mpToken === 'string' && mpToken.startsWith('TEST-');
let mpPrefClient;
let mpPaymentClient;
if (!mpToken) {
  console.warn('MERCADOPAGO_ACCESS_TOKEN no definido. La creacion de preferencias fallara.');
} else {
  if (!isSandboxToken) {
    console.warn('Usando token APP_USR (produccion). Las tarjetas de prueba no funcionaran en modo productivo.');
  }
  const mpClient = new MercadoPagoConfig({ accessToken: mpToken });
  mpPrefClient = new Preference(mpClient);
  mpPaymentClient = new Payment(mpClient);
}

try {
  if (!admin.apps.length) {
    admin.initializeApp();
  }
} catch (err) {
  console.warn('Firebase Admin no inicializado:', err);
}

app.post('/payments/create_preference', async (req, res) => {
  try {
    if (!mpPrefClient) {
      return res.status(500).json({
        status: 'error',
        message: 'Token de Mercado Pago no configurado.',
      });
    }
    const { items, userId } = req.body || {};
    if (!Array.isArray(items) || items.length === 0) return res.status(400).json({ status: 'error', message: 'Items requeridos' });
    if (!userId) return res.status(400).json({ status: 'error', message: 'userId requerido' });

    const mpItems = items.map((item, idx) => ({
      id: item.id || `item-${idx}`,
      title: item.title || 'Producto',
      quantity: Number(item.quantity) || 1,
      currency_id: 'MXN',
      unit_price: Number(item.unit_price) || 0,
    }));

    const preference = {
      items: mpItems,
      payer: { id: userId },
      external_reference: `uid:${userId}`,
      back_urls: {
        success: 'https://example.com/checkout?status=approved',
        failure: 'https://example.com/checkout?status=failed',
        pending: 'https://example.com/checkout?status=pending',
      },
      auto_return: 'approved',
      notification_url: process.env.NOTIFICATION_URL || '',
    };

    const response = await mpPrefClient.create({ body: preference });
    const initPoint = response.init_point || '';
    const sandboxInitPoint = response.sandbox_init_point || '';
    const checkoutUrl = isSandboxToken ? sandboxInitPoint || initPoint : initPoint || sandboxInitPoint;

    return res.json({
      status: 'ok',
      preferenceId: response.id,
      initPoint,
      sandboxInitPoint,
      checkoutUrl,
      mode: isSandboxToken ? 'sandbox' : 'production',
    });
  } catch (err) {
    console.error('Error creando preferencia', err);
    return res.status(500).json({ status: 'error', message: 'No se pudo crear la preferencia' });
  }
});

app.post('/payments/webhook', async (req, res) => {
  try {
    const { type, data } = req.body || {};
    if (type !== 'payment') return res.sendStatus(200);
    const paymentId = data?.id;
    if (!paymentId || !mpPaymentClient) return res.sendStatus(200);
    const payment = await mpPaymentClient.get({ id: paymentId });
    const status = payment.status;
    const externalRef = payment.external_reference || '';
    if (status === 'approved' && externalRef.startsWith('uid:') && admin.apps.length) {
      const uid = externalRef.replace('uid:', '');
      const ref = admin.database().ref(`orders/${uid}`).orderByChild('paymentId').equalTo(String(paymentId));
      ref.once('value', snap => {
        snap.forEach(child => {
          child.ref.update({
            paymentStatus: 'approved',
            paymentMethod: 'mercadopago',
            paymentId: paymentId,
          });
        });
      });
    }
    res.sendStatus(200);
  } catch (err) {
    console.error('Webhook error', err);
    res.sendStatus(500);
  }
});

app.get('/health', (_req, res) => res.json({ status: 'ok' }));
app.get('/', (_req, res) => res.status(404).json({ status: 'error', message: 'Use /health o /payments/create_preference' }));

app.listen(port, '0.0.0.0', () => console.log(`Backend escuchando en ${port}`));

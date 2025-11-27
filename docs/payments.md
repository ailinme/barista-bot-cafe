# Pagos con Mercado Pago (MXN)

## Variables de entorno

Backend (`backend/.env`):
```
MERCADOPAGO_ACCESS_TOKEN=TEST-REPLACE-WITH-SANDBOX-TOKEN
NOTIFICATION_URL=https://tu-dominio.com/payments/webhook
PORT=8080
```

Flutter (ejemplo):
```
--dart-define=PAYMENTS_BASE_URL=http://10.0.2.2:8080
```

## Credenciales de prueba
- Usa las credenciales de **sandbox** de tu cuenta Mercado Pago (correo dioslevel1@gmail.com): en Mercado Pago > Desarrolladores > Tus integraciones > Credenciales > Sandbox: copia el Access Token que inicia con `TEST-`.
- No uses el token de producción hasta terminar pruebas.

## Flujo
1. Flutter llama a `POST {PAYMENTS_BASE_URL}/payments/create_preference` con items, total y userId.
2. El backend crea la preferencia (SDK oficial, token en env) y devuelve `initPoint`.
3. Flutter abre `PaymentWebView` con `initPoint`. Si el pago es aprobado, recién entonces llama a `OrderRepository.createOrder` guardando `paymentStatus`, `paymentMethod`, `paymentId`, `preferenceId`.
4. Si el pago falla/cancela, no se crea pedido.
5. Webhook opcional en `/payments/webhook` marca pagos aprobados en Firebase cuando Mercado Pago notifique.

## Pruebas
- Usa tarjetas de prueba de Mercado Pago (sandbox) y revisa el resultado en la WebView.
- Para emulador Android, apunta `PAYMENTS_BASE_URL` a `http://10.0.2.2:8080` si corres el backend local.

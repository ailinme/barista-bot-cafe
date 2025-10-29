import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Métrica personalizada para errores
const errorRate = new Rate('errors');

// Configuración de escenarios de carga
export const options = {
  stages: [
    { duration: '30s', target: 10 },  // Ramp-up a 10 usuarios en 30s
    { duration: '1m', target: 50 },   // Escala a 50 usuarios en 1min
    { duration: '2m', target: 50 },   // Mantén 50 usuarios por 2min
    { duration: '30s', target: 0 },   // Ramp-down a 0 usuarios
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% de requests deben ser < 500ms
    http_req_failed: ['rate<0.05'],   // Menos del 5% de fallos
    errors: ['rate<0.1'],             // Menos del 10% de errores
  },
};

// URL base de tu API (ajusta según tu backend)
const BASE_URL = 'https://tu-api.com/api/v1';

export default function () {
  // Escenario 1: Obtener menú de cafés
  const menuResponse = http.get(`${BASE_URL}/coffees`);
  
  check(menuResponse, {
    'menú status es 200': (r) => r.status === 200,
    'menú tiene productos': (r) => {
      try {
        const body = JSON.parse(r.body);
        return Array.isArray(body) && body.length > 0;
      } catch (e) {
        return false;
      }
    },
  }) || errorRate.add(1);

  sleep(1);

  // Escenario 2: Obtener detalle de un café específico
  const coffeeId = 1; // Ajusta según tus IDs reales
  const detailResponse = http.get(`${BASE_URL}/coffees/${coffeeId}`);
  
  check(detailResponse, {
    'detalle status es 200': (r) => r.status === 200,
    'detalle contiene precio': (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.price !== undefined;
      } catch (e) {
        return false;
      }
    },
  }) || errorRate.add(1);

  sleep(1);

  // Escenario 3: Crear una orden (POST)
  const orderPayload = JSON.stringify({
    items: [
      { coffeeId: 1, quantity: 2 },
      { coffeeId: 2, quantity: 1 },
    ],
    customerName: 'Test User',
    total: 140.0,
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  const orderResponse = http.post(
    `${BASE_URL}/orders`,
    orderPayload,
    params
  );
  
  check(orderResponse, {
    'orden creada (201)': (r) => r.status === 201,
    'orden tiene ID': (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.id !== undefined;
      } catch (e) {
        return false;
      }
    },
  }) || errorRate.add(1);

  sleep(2);

  // Escenario 4: Buscar cafés (simulando búsqueda)
  const searchResponse = http.get(`${BASE_URL}/coffees?search=latte`);
  
  check(searchResponse, {
    'búsqueda status es 200': (r) => r.status === 200,
  }) || errorRate.add(1);

  sleep(1);
}

// Función que se ejecuta al finalizar el test
export function handleSummary(data) {
  return {
    'summary.html': htmlReport(data),
    stdout: textSummary(data, { indent: ' ', enableColors: true }),
  };
}

function htmlReport(data) {
  return `
<!DOCTYPE html>
<html>
<head>
  <title>K6 Load Test Report - Barista Bot Café</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    h1 { color: #333; }
    .metric { margin: 10px 0; }
    .pass { color: green; }
    .fail { color: red; }
  </style>
</head>
<body>
  <h1>📊 Reporte de Pruebas de Carga</h1>
  <h2>Métricas Generales</h2>
  <div class="metric">
    <strong>Total de Requests:</strong> ${data.metrics.http_reqs.values.count}
  </div>
  <div class="metric">
    <strong>Request Duration (avg):</strong> ${data.metrics.http_req_duration.values.avg.toFixed(2)}ms
  </div>
  <div class="metric">
    <strong>Request Duration (p95):</strong> ${data.metrics.http_req_duration.values['p(95)'].toFixed(2)}ms
  </div>
  <div class="metric">
    <strong>Failed Requests:</strong> ${((data.metrics.http_req_failed.values.rate || 0) * 100).toFixed(2)}%
  </div>
  
  <h2>Thresholds</h2>
  ${Object.entries(data.thresholds || {}).map(([name, threshold]) => `
    <div class="metric ${threshold.ok ? 'pass' : 'fail'}">
      <strong>${name}:</strong> ${threshold.ok ? '✓ PASS' : '✗ FAIL'}
    </div>
  `).join('')}
</body>
</html>
  `;
}

function textSummary(data, options) {
  return `
========================================
  K6 Load Test Summary
========================================
Total Requests: ${data.metrics.http_reqs.values.count}
Average Duration: ${data.metrics.http_req_duration.values.avg.toFixed(2)}ms
========================================
  `;  // ← Asegúrate que cierre con backtick (`)
}
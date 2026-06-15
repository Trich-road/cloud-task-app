// Minimal smoke tests for CI
const http = require('http');
const assert = require('assert');

function ok(msg) { console.log('OK:', msg); }

// Basic check: require server file without starting network listeners
try {
  require('../server');
  ok('server module loads');
  console.log('All tests passed');
  process.exit(0);
} catch (err) {
  console.error('Test failure:', err && err.stack ? err.stack : err);
  process.exit(2);
}

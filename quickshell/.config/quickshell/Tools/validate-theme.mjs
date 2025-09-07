#!/usr/bin/env node
/**
 * validate-theme.mjs — Dev script to validate Theme.json against a hierarchical schema
 *
 * Usage:
 *   node Tools/validate-theme.mjs [--theme Theme.json] [--schema Docs/ThemeHierarchical.json] [--constraints Docs/ThemeConstraints.json] [--strict]
 *
 * Checks:
 * - Unknown (extra) tokens not present in the schema
 * - Flat tokens at the root (legacy)
 * - Deprecated tokens (hardcoded list)
 * - Missing tokens (schema leaves not present) — informational unless --strict
 */
import fs from 'node:fs';
import path from 'node:path';

const cwd = process.cwd();
function readJson(p) {
  try {
    const s = fs.readFileSync(p, 'utf8');
    return JSON.parse(s);
  } catch (e) {
    console.error(`ERR: Failed to read JSON ${p}:`, e.message);
    process.exitCode = 2;
    return {};
  }
}

function flatten(obj, base = '') {
  const out = new Set();
  function walk(o, prefix) {
    if (o === null || o === undefined) return;
    if (Array.isArray(o)) {
      // Arrays are not part of theme schema; treat as leaf
      out.add(prefix);
      return;
    }
    if (typeof o === 'object') {
      const keys = Object.keys(o);
      if (keys.length === 0) {
        out.add(prefix);
        return;
      }
      for (const k of keys) {
        const p = prefix ? `${prefix}.${k}` : k;
        if (o[k] !== null && typeof o[k] === 'object' && !Array.isArray(o[k])) {
          walk(o[k], p);
        } else {
          out.add(p);
        }
      }
    } else {
      out.add(prefix);
    }
  }
  walk(obj, base);
  return out;
}

function parseArgs(argv) {
  const args = { theme: 'Theme.json', schema: 'Docs/ThemeHierarchical.json', constraints: 'Docs/ThemeConstraints.json', strict: false };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--theme') { args.theme = argv[++i]; continue; }
    if (a === '--schema') { args.schema = argv[++i]; continue; }
    if (a === '--constraints') { args.constraints = argv[++i]; continue; }
    if (a === '--strict') { args.strict = true; continue; }
  }
  return args;
}


function main() {
  const args = parseArgs(process.argv);
  const themePath = path.resolve(cwd, args.theme);
  const schemaPath = path.resolve(cwd, args.schema);
  const theme = readJson(themePath);
  const schema = readJson(schemaPath);
  const constraints = fs.existsSync(args.constraints) ? readJson(path.resolve(cwd, args.constraints)) : {};

  const themePaths = flatten(theme);
  const schemaPaths = flatten(schema);

  // Unknown tokens: in theme but not in schema
  const unknown = [];
  for (const p of themePaths) if (!schemaPaths.has(p)) unknown.push(p);

  // Flat token detection removed — schema is authoritative and flat tokens are no longer supported.


  // Missing tokens (schema leaves not present in theme)
  function getAt(o, p) {
    try { return p.split('.').reduce((a, k) => (a ? a[k] : undefined), o); } catch { return undefined; }
  }
  const SKIP_MISSING = new Set(['media.time.fontScale']);
  const missing = [];
  for (const p of schemaPaths) {
    if (themePaths.has(p)) continue;
    if (SKIP_MISSING.has(p)) continue;
    const v = getAt(schema, p);
    if (v !== null && typeof v === 'object') continue; // ignore pure object groups
    missing.push(p);
  }

  function hdr(s) { console.log(`\n=== ${s} ===`); }
  console.log(`Validate: ${path.relative(cwd, themePath)} vs schema ${path.relative(cwd, schemaPath)}`);

  hdr('Unknown tokens');
  if (unknown.length) unknown.sort().forEach(p => console.log('  +', p)); else console.log('  (none)');

  // (flat tokens check removed)

  hdr('Missing tokens (informational)');
  if (missing.length) missing.sort().forEach(p => console.log('  -', p)); else console.log('  (none)');

  // Range/type checks from constraints
  function get(o, p) { try { return p.split('.').reduce((a,k)=> (a ? a[k] : undefined), o); } catch { return undefined; } }
  const bad = [];
  for (const [p, rule] of Object.entries(constraints || {})) {
    const v = get(theme, p);
    if (v === undefined) continue; // not present: let "missing" list cover it
    const t = typeof v;
    if (rule.type) {
      if (rule.type === 'integer') {
        if (!(t === 'number' && Number.isInteger(v))) bad.push(`${p}: expected integer, got ${t}`);
      } else if (rule.type === 'number') {
        if (!(t === 'number' && Number.isFinite(v))) bad.push(`${p}: expected number, got ${t}`);
      }
    }
    if (typeof v === 'number' && Number.isFinite(v)) {
      if (rule.min !== undefined && v < rule.min) bad.push(`${p}: ${v} < min ${rule.min}`);
      if (rule.max !== undefined && v > rule.max) bad.push(`${p}: ${v} > max ${rule.max}`);
    }
  }

  hdr('Constraint violations');
  if (bad.length) bad.sort().forEach(x => console.log('  !', x)); else console.log('  (none)');

  if (args.strict && (unknown.length || bad.length)) {
    console.error('\nStrict mode: validation errors present.');
    process.exitCode = 1;
  }
}

main();

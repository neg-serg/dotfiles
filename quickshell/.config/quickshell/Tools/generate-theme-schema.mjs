#!/usr/bin/env node
// Generate Docs/ThemeHierarchical.json from the repo's Theme.json (single source)
import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const themePath = path.resolve(root, 'Theme.json');
const outPath = path.resolve(root, 'Docs/ThemeHierarchical.json');

try {
  const s = fs.readFileSync(themePath, 'utf8');
  const obj = JSON.parse(s);
  const pretty = JSON.stringify(obj, null, 2) + '\n';
  fs.writeFileSync(outPath, pretty, 'utf8');
  console.log('Wrote', path.relative(root, outPath), 'from', path.relative(root, themePath));
} catch (e) {
  console.error('Failed to generate schema:', e.message);
  process.exitCode = 1;
}


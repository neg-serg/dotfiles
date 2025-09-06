#!/usr/bin/env node
// Compact formatting helper: removes decorative column alignment spaces
// - Collapses multiple spaces after ':' to a single space (outside strings)
// - Normalizes QML `property <type>  <name>:` to single space between type and name
// Skips vendor directory.
import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();

function walk(dir, out = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.name === 'vendor' || entry.name === '.git' || entry.name === 'node_modules') continue;
    const p = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(p, out);
    else out.push(p);
  }
  return out;
}

function processFile(p) {
  const ext = path.extname(p);
  if (!['.qml', '.js', '.mjs'].includes(ext)) return false;
  const src = fs.readFileSync(p, 'utf8');
  let changed = false;
  const lines = src.split(/\r?\n/);
  const out = lines.map(line => {
    let s = line;
    // Skip lines that are comments only
    if (/^\s*\/\//.test(s)) return s;
    // Collapse multiple spaces after ':' to single
    // Careful: do not touch inside string literals. Simple heuristic: operate on code before first '//' comment.
    const idxCom = s.indexOf('//');
    const code = idxCom >= 0 ? s.slice(0, idxCom) : s;
    const comment = idxCom >= 0 ? s.slice(idxCom) : '';
    let code2 = code.replace(/:\s{2,}/g, ': ');
    // Normalize QML property declarations: property <type>  <name>:
    code2 = code2.replace(/^(\s*property\s+\S+)\s{2,}(\S+\s*:)\s*/u, '$1 $2');
    if (code2 !== code) changed = true;
    return code2 + comment;
  });
  if (changed) {
    fs.writeFileSync(p, out.join('\n'), 'utf8');
  }
  return changed;
}

const files = walk(root);
let count = 0;
for (const f of files) if (processFile(f)) { console.log('Formatted', path.relative(root, f)); count++; }
console.log('Compact format done. Files changed:', count);


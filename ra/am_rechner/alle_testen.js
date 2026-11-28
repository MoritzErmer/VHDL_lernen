#!/usr/bin/env node
// Prueft alle Programme in ra/am_rechner mit dem IKR-RISC-II-Simulator aus dem Repo Rechnerarchtektur_Lernen.
// Aufruf aus dem Repo-Hauptordner: node ra/am_rechner/alle_testen.js [PFAD_ZUM_RA_REPO]
// Jede Datei enthaelt Testfaelle als Kommentar:
//   ; @test r1=$100, r2=3 => r1=5, m[$200]=7
// Links stehen Startregister, rechts erwartete Register (rN) und Speicherwoerter (m[adresse]).
const fs = require('fs');
const path = require('path');
const raRepo = process.argv[2] || process.env.RA_REPO || path.join(__dirname, '../../../moritzermer/rechnerarchtektur_lernen');
const IKR = require(path.join(path.resolve(raRepo), 'am_rechner/ikr_sim.js'));

function num(s) {
  s = s.trim();
  const neg = s.startsWith('-');
  if (neg) s = s.slice(1);
  const v = s.startsWith('$') ? parseInt(s.slice(1), 16) : s.startsWith('0x') ? parseInt(s.slice(2), 16) : parseInt(s, 10);
  return (neg ? -v : v) | 0;
}

let fehler = 0, tests = 0;
for (const f of fs.readdirSync(__dirname).filter(f => f.endsWith('.s')).sort()) {
  const src = fs.readFileSync(path.join(__dirname, f), 'utf8');
  const cases = [...src.matchAll(/;\s*@test\s+(.*?)\s*=>\s*(.*)$/gm)];
  if (!cases.length) { console.log(`${f}: kein @test`); fehler++; continue; }
  for (const [, given, want] of cases) {
    tests++;
    // Links: Register (r1=5) und Speicherwoerter (m[$300]=7) als Startwerte
    const parts = given.split(/,(?![^\[]*\])/).map(x => x.trim()).filter(Boolean);
    const regList = parts.filter(x => /^r\d+/.test(x));
    const memList = parts.filter(x => /^m\[/.test(x)).map(x => {
      const mm = /^m\[([^\]]+)\]\s*=\s*(.+)$/.exec(x);
      return `.mem ${mm[1]}: ${mm[2]}`;
    });
    const regs = '\n' + (regList.length ? '.reg ' + regList.join(', ') + '\n' : '') + memList.join('\n') + '\n';
    const p = IKR.parse(src + regs);
    if (p.errors.length) { console.log(`${f}: ` + p.errors.map(e => `Zeile ${e.line}: ${e.message}`).join('; ')); fehler++; break; }
    const r = IKR.run(p, { maxSteps: 200000 });
    const mem = {};
    r.mem.forEach(m => { mem[m.addr] = m.after; });
    const probleme = [];
    if (r.error) probleme.push(r.error);
    for (const w of want.split(/,(?![^\[]*\])/)) {
      const m = /^\s*(r\d+|m\[([^\]]+)\])\s*=\s*(.+?)\s*$/.exec(w);
      if (!m) { probleme.push('Erwartung nicht verstanden: ' + w); continue; }
      const soll = num(m[3]);
      const ist = m[1].startsWith('r') ? r.regs[+m[1].slice(1)] : (mem[num(m[2]) >>> 0] | 0);
      if (ist !== soll) probleme.push(`${m[1]} = ${ist} statt ${soll}`);
    }
    if (probleme.length) { fehler++; console.log(`${f} [${given}]: ${probleme.join('; ')}`); }
  }
}
console.log(`${tests} Testfaelle, ${fehler} Fehler`);
process.exit(fehler ? 1 : 0);

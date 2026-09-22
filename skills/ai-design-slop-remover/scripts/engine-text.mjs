#!/usr/bin/env bun
// @ts-check
/** Text-family scan: apply each rule matcher to the raw source text. */
import { lineAt, excerpt } from "./rule-shared.mjs";

/** @typedef {{ id: string, defaultSeverity: string, class: string, engines: string[], evidence: string, action: string, fix: string, clusterKey: string, dispositionPolicy: string, matcher: RegExp }} DetectorRule */
/** @typedef {{ rule: DetectorRule, engine: string, location: { file: string, line: number }, match: string }} RuleMatch */

/** @param {string} file @param {string} text @param {string} root @param {DetectorRule[]} rules @param {string} [engine] @returns {RuleMatch[]} */
export function scanText(file, text, root, rules, engine = 'text') {
  /** @type {RuleMatch[]} */
  const findings = [];
  for (const rule of rules.filter((entry) => entry.matcher)) {
    rule.matcher.lastIndex = 0;
    for (const match of text.matchAll(rule.matcher)) findings.push({ rule, engine, location: { file, line: lineAt(text, match.index ?? 0) }, match: excerpt(match[0]) });
  }
  return findings;
}

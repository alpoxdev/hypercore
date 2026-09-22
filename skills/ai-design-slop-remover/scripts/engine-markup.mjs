#!/usr/bin/env bun
// @ts-check
/** Markup-family scan: reuse the text scanner with the markup engine label. */
import { scanText } from './engine-text.mjs';

/** @typedef {{ id: string, defaultSeverity: string, class: string, engines: string[], evidence: string, action: string, fix: string, clusterKey: string, dispositionPolicy: string, matcher: RegExp }} DetectorRule */
/** @typedef {{ rule: DetectorRule, engine: string, location: { file: string, line: number }, match: string }} RuleMatch */

/** @param {string} file @param {string} text @param {string} root @param {DetectorRule[]} rules @returns {RuleMatch[]} */
export function scanMarkup(file, text, root, rules) { return scanText(file, text, root, rules, 'markup'); }

#!/usr/bin/env bun
// @ts-check
/** Shared discovery sets, fingerprinting, and ordering helpers for the slop detector. */
import { createHash } from "node:crypto";

/**
 * @typedef {{ id: string, severity: string, confidence: string, scope: string, location: { file: string, line: number }, evidence: string, action: string, fix: string, engine: string, evidenceKind: string, detectionConfidence: string, remediationConfidence: string, ruleClass: string, clusterKey: string, renderConfirmationRequired: boolean, exceptionStatus: string }} Finding
 */

export const SUPPORTED = new Set(['.html', '.jsx', '.tsx', '.vue', '.svelte', '.css', '.scss', '.less']);
export const IGNORED_DIRS = new Set(['.git', 'node_modules', 'dist', 'build', 'coverage', '.next', '.nuxt', '.svelte-kit']);

/** @param {string} text @param {number} offset @returns {number} */
export function lineAt(text, offset) { return text.slice(0, offset).split('\n').length; }
/** @param {string} value @returns {string} */
export function excerpt(value) { return value.replace(/\s+/g, ' ').trim().slice(0, 180); }
/** @param {Finding} finding @returns {string} */
export function fingerprint(finding) {
  return createHash('sha256').update([finding.id, finding.location.file, finding.location.line, finding.evidence].join('\0')).digest('hex');
}
/** @param {Finding[]} findings @returns {Finding[]} */
export function sortFindings(findings) {
  return findings.sort((left, right) => left.location.file.localeCompare(right.location.file)
    || left.location.line - right.location.line || left.id.localeCompare(right.id));
}
/** @param {Finding[]} findings @returns {Record<string, number>} */
export function summarize(findings) {
  /** @type {Record<string, number>} */
  const summary = { P0: 0, P1: 0, P2: 0, P3: 0 };
  for (const finding of findings) summary[finding.severity] += 1;
  return summary;
}

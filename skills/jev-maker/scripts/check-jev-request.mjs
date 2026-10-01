#!/usr/bin/env bun
// @ts-check
// Offline request checker for Jev (System One / Decisions) evaluation requests.
//
// Usage: bun check-jev-request.mjs [--route direct|bai|aisdk] <request.json>
// Exit codes: 0 = no errors, 1 = validation errors (an unparsable JSON file included), 2 = usage error.
// Codes carried by exit 1: INVALID_JSON for an unparsable file, INPUT_TOO_DEEP for a document nested deeper than the engine stack can read, and the shape codes below.
// The report carries no request string values: every finding is a code, a JSON path, and a fixed message.
import { readFileSync } from 'node:fs';

/**
 * @typedef {'direct' | 'bai' | 'aisdk'} Route
 * @typedef {{ code: string, path: string, message: string }} Finding
 * @typedef {{ questions: number, noul: number, choice: number, score: number, estimatedStateTokens: number }} Stats
 * @typedef {{ ok: boolean, route: string | null, errors: Finding[], warnings: Finding[], stats: Stats }} Report
 * @typedef {{ route: Route, file: string }} Cli
 * @typedef {{ errors: Finding[], warnings: Finding[], stats: Stats }} Validation
 */

/** @type {string[]} */
const ROUTES = ['direct', 'bai', 'aisdk'];

/** @type {Record<Route, string[]>} */
const ROUTE_QUESTION_TYPES = {
  direct: ['noul', 'choice', 'score'],
  bai: ['noul', 'choice', 'score'],
  aisdk: ['boolean', 'choice', 'score'],
};

const KNOWN_TOP_LEVEL_KEYS = ['state', 'model', 'questions', 'stream'];

const DIRECT_MODELS = ['jev-latest', 'jev-preview', 'jev-1.13.0'];

const BAI_MODELS = ['jev-1.13.0', 'jev-latest'];

const MAX_TOP_LEVEL_TOKENS = 32000;

const MAX_CHOICE_OPTIONS = 255;

const MAX_SCORE_LEVELS = 10;

const MIN_SCORE_LEVELS = 2;

// Key-shaped values are reported by path only; the matched text is never echoed.
/** @type {RegExp[]} */
const SECRET_PATTERNS = [/sk-[A-Za-z0-9]{16,}/u, /Bearer [A-Za-z0-9._-]{16,}/u];

/** A plain JSON key that can be written into a path as a dot segment. */
const PLAIN_KEY = /^[A-Za-z_][A-Za-z0-9_]*$/;

/**
 * Builds the path segment for a dynamic key. A key that looks like a credential becomes a
 * placeholder, so a key name is never echoed as if it were a value; a key that is not a plain
 * identifier is JSON-quoted, so a key holding a dot stays apart from a nested path.
 * @param {string} key
 * @returns {string}
 */
function pathKey(key) {
  if (SECRET_PATTERNS.some((pattern) => pattern.test(key))) return '["<redacted-key>"]';
  if (!PLAIN_KEY.test(key)) return `[${JSON.stringify(key)}]`;
  return `.${key}`;
}

/**
 * Builds an error that carries a usage-error code for the exit-2 report.
 * @param {string} code
 * @param {string} message
 * @returns {Error & { code: string }}
 */
function usageError(code, message) {
  return Object.assign(new Error(message), { code });
}

/**
 * Parses command line arguments.
 * @param {string[]} argv
 * @returns {Cli}
 * @throws {Error} When an option is unknown, repeated, or missing its value, or when the file argument is absent or repeated.
 */
function parseArgs(argv) {
  /** @type {Route} */
  let route = 'direct';
  let routeSeen = false;
  /** @type {string[]} */
  const files = [];

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--route') {
      if (routeSeen) {
        throw usageError('USAGE_UNKNOWN_ARGUMENT', 'Option --route may be given at most once.');
      }
      const value = argv[index + 1];
      if (typeof value !== 'string' || value.startsWith('--')) {
        throw usageError('USAGE_ARGUMENT_VALUE_MISSING', 'Option --route requires one of: direct, bai, aisdk.');
      }
      if (!ROUTES.includes(value)) {
        throw usageError('USAGE_UNKNOWN_ROUTE', 'Unknown route. Use direct, bai, or aisdk.');
      }
      route = /** @type {Route} */ (value);
      routeSeen = true;
      index += 1;
    } else if (arg.startsWith('--')) {
      throw usageError('USAGE_UNKNOWN_ARGUMENT', 'Unknown option. The only option is --route.');
    } else {
      files.push(arg);
    }
  }

  if (files.length === 0) {
    throw usageError('USAGE_MISSING_FILE', 'A request JSON file argument is required.');
  }
  if (files.length > 1) {
    throw usageError('USAGE_UNKNOWN_ARGUMENT', 'Only one request JSON file may be given.');
  }

  return { route, file: files[0] };
}

/**
 * Reports whether a value is a non-null, non-array object.
 * @param {unknown} value
 * @returns {value is Record<string, unknown>}
 */
function isRecord(value) {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

/**
 * Reports whether a value is one of the JSON shapes the API accepts for state, instructions, and descriptions.
 * @param {unknown} value
 * @returns {boolean}
 */
function isContentValue(value) {
  return typeof value === 'string' || Array.isArray(value) || isRecord(value);
}

/**
 * Reports whether a value is an accepted Choice option description (null, string, object, or array).
 * @param {unknown} value
 * @returns {boolean}
 */
function isChoiceOptionValue(value) {
  return value === null || isContentValue(value);
}

/**
 * Serializes a value to text for the size estimate, tolerating values JSON cannot represent.
 * @param {unknown} value
 * @returns {string}
 */
function serialize(value) {
  const text = JSON.stringify(value);
  return typeof text === 'string' ? text : '';
}

/**
 * Builds the JSON path of a question or one of its fields.
 * @param {string} id
 * @param {string | null} field
 * @returns {string}
 */
function questionPath(id, field) {
  const base = `$.questions${pathKey(id)}`;
  return field === null ? base : `${base}.${field}`;
}

/**
 * Builds the message for a rejected question type, naming the type name this route expects.
 * @param {Route} route
 * @param {unknown} type
 * @returns {string}
 */
function questionTypeMessage(route, type) {
  const expected = ROUTE_QUESTION_TYPES[route].join(', ');
  const hint = type === 'boolean'
    ? ' The yes/no type is named "boolean" on the AI SDK route and "noul" on the direct and b.ai routes.'
    : type === 'noul'
      ? ' The yes/no type is named "noul" on the direct and b.ai routes and "boolean" on the AI SDK route.'
      : '';
  return `Question type must be one of ${expected} for route ${route}.${hint}`;
}

/**
 * Scans string values for key-shaped secrets and records a finding per offending path.
 * @param {unknown} value
 * @param {string} path
 * @param {Finding[]} errors
 * @returns {void}
 */
function scanSecrets(value, path, errors) {
  if (typeof value === 'string') {
    if (SECRET_PATTERNS.some((pattern) => pattern.test(value))) {
      errors.push({
        code: 'SECRET_IN_REQUEST',
        path,
        message: 'This string looks like an API key or bearer token. Keep credentials out of the request body and send them in the request header at call time.',
      });
    }
    return;
  }
  if (Array.isArray(value)) {
    for (let index = 0; index < value.length; index += 1) {
      scanSecrets(value[index], `${path}[${index}]`, errors);
    }
    return;
  }
  if (isRecord(value)) {
    for (const key of Object.keys(value)) {
      scanSecrets(value[key], `${path}${pathKey(key)}`, errors);
    }
  }
}

/**
 * Estimates the token size of the serialized state plus the longest serialized question.
 * @param {Record<string, unknown>} document
 * @param {unknown} questions
 * @returns {number}
 */
function estimateStateTokens(document, questions) {
  let characters = serialize(document.state).length;
  let longestQuestion = 0;
  if (isRecord(questions)) {
    for (const id of Object.keys(questions)) {
      const size = serialize(questions[id]).length;
      if (size > longestQuestion) longestQuestion = size;
    }
  }
  characters += longestQuestion;
  return Math.ceil(characters / 4);
}

/**
 * Validates one entry of the questions map and updates the type counters.
 * @param {string} id
 * @param {unknown} value
 * @param {Route} route
 * @param {Finding[]} errors
 * @param {Finding[]} warnings
 * @param {Stats} stats
 * @returns {void}
 */
function validateQuestion(id, value, route, errors, warnings, stats) {
  const path = questionPath(id, null);

  if (id.trim().length === 0) {
    errors.push({
      code: 'QUESTION_ID_BLANK',
      path,
      message: 'Question ids must not be empty or whitespace only.',
    });
  }

  if (!isRecord(value)) {
    errors.push({
      code: 'QUESTION_NOT_OBJECT',
      path,
      message: 'Each question must be a JSON object with type, instructions, and criteria fields.',
    });
    return;
  }

  const type = value.type;
  if (typeof type !== 'string' || !ROUTE_QUESTION_TYPES[route].includes(type)) {
    errors.push({
      code: 'QUESTION_TYPE',
      path: questionPath(id, 'type'),
      message: questionTypeMessage(route, type),
    });
    return;
  }

  if (type === 'choice') {
    stats.choice += 1;
  } else if (type === 'score') {
    stats.score += 1;
  } else {
    // The AI SDK names the yes/no type "boolean"; it counts as the noul family.
    stats.noul += 1;
  }

  const instructions = value.instructions;
  if (instructions === undefined) {
    errors.push({
      code: 'INSTRUCTIONS_MISSING',
      path: questionPath(id, 'instructions'),
      message: 'Every question requires instructions describing what to decide.',
    });
  } else if (!isContentValue(instructions)) {
    errors.push({
      code: 'INSTRUCTIONS_TYPE',
      path: questionPath(id, 'instructions'),
      message: 'Instructions must be a string, an object, or an array.',
    });
  }

  const criteria = value.criteria;

  if (type === 'noul' || type === 'boolean') {
    if (criteria === undefined) return;
    if (!isRecord(criteria)) {
      errors.push({
        code: 'NOUL_CRITERIA_TYPE',
        path: questionPath(id, 'criteria'),
        message: 'Criteria for a yes/no question is optional but must be an object with true and false keys when present.',
      });
      return;
    }
    for (const key of Object.keys(criteria)) {
      if (key !== 'true' && key !== 'false') {
        errors.push({
          code: 'NOUL_CRITERIA_KEY',
          path: questionPath(id, 'criteria'),
          message: 'Criteria keys for a yes/no question must be exactly "true" or "false".',
        });
      } else if (!isContentValue(criteria[key])) {
        errors.push({
          code: 'NOUL_CRITERIA_VALUE',
          path: `${questionPath(id, 'criteria')}${pathKey(key)}`,
          message: 'A yes/no criteria description must be a string, an object, or an array.',
        });
      }
    }
    return;
  }

  if (type === 'choice') {
    if (!isRecord(criteria)) {
      errors.push({
        code: 'CHOICE_CRITERIA_MISSING',
        path: questionPath(id, 'criteria'),
        message: 'A choice question requires criteria: an object mapping each option to its description.',
      });
      return;
    }
    const options = Object.keys(criteria);
    const countIsValid = options.length >= 1 && options.length <= MAX_CHOICE_OPTIONS;
    if (!countIsValid) {
      errors.push({
        code: 'CHOICE_CRITERIA_COUNT',
        path: questionPath(id, 'criteria'),
        message: `A choice question takes 1 to ${MAX_CHOICE_OPTIONS} options; this one has ${options.length}.`,
      });
    }
    for (const option of options) {
      if (!isChoiceOptionValue(criteria[option])) {
        errors.push({
          code: 'CHOICE_CRITERIA_VALUE',
          path: `${questionPath(id, 'criteria')}${pathKey(option)}`,
          message: 'An option description must be null, a string, an object, or an array.',
        });
      }
    }
    if (countIsValid && !options.some((option) => ['none', 'other', 'unknown'].includes(option))) {
      warnings.push({
        code: 'NO_FALLBACK_OPTION',
        path: questionPath(id, 'criteria'),
        message: 'No none/other/unknown option is defined, so the model must pick one of the listed options. This is a heuristic check, not an API rule.',
      });
    }
    return;
  }

  if (!Array.isArray(criteria)) {
    errors.push({
      code: 'SCORE_CRITERIA_MISSING',
      path: questionPath(id, 'criteria'),
      message: 'A score question requires criteria: an ordered array of level descriptions.',
    });
    return;
  }
  if (criteria.length < MIN_SCORE_LEVELS) {
    errors.push({
      code: 'SCORE_CRITERIA_COUNT',
      path: questionPath(id, 'criteria'),
      message: `A score question needs at least ${MIN_SCORE_LEVELS} levels; this one has ${criteria.length}.`,
    });
  } else if (criteria.length > MAX_SCORE_LEVELS) {
    if (route === 'aisdk') {
      warnings.push({
        code: 'SCORE_CRITERIA_COUNT',
        path: questionPath(id, 'criteria'),
        message: `This score question has ${criteria.length} levels. The AI SDK documents no upper bound, but the direct and b.ai APIs accept at most ${MAX_SCORE_LEVELS}, so the request is not portable.`,
      });
    } else {
      errors.push({
        code: 'SCORE_CRITERIA_COUNT',
        path: questionPath(id, 'criteria'),
        message: `A score question takes ${MIN_SCORE_LEVELS} to ${MAX_SCORE_LEVELS} levels; this one has ${criteria.length}.`,
      });
    }
  }
  for (let index = 0; index < criteria.length; index += 1) {
    if (!isContentValue(criteria[index])) {
      errors.push({
        code: 'SCORE_LEVEL_TYPE',
        path: `${questionPath(id, 'criteria')}[${index}]`,
        message: 'A score level description must be a string, an object, or an array.',
      });
    }
  }
}

/**
 * Validates a parsed request document against the route contract.
 * @param {unknown} document
 * @param {Route} route
 * @returns {Validation}
 */
function validateRequest(document, route) {
  /** @type {Finding[]} */
  const errors = [];
  /** @type {Finding[]} */
  const warnings = [];
  const stats = emptyStats();

  if (!isRecord(document)) {
    errors.push({
      code: 'ROOT_NOT_OBJECT',
      path: '$',
      message: 'The request document must be a JSON object.',
    });
    return { errors, warnings, stats };
  }

  for (const key of Object.keys(document)) {
    if (!KNOWN_TOP_LEVEL_KEYS.includes(key)) {
      warnings.push({
        code: 'UNKNOWN_TOP_LEVEL_FIELD',
        path: `$${pathKey(key)}`,
        message: 'This top-level field is not part of the documented request shape and is ignored by the API.',
      });
    }
  }

  const state = document.state;
  if (state === undefined) {
    errors.push({
      code: 'STATE_MISSING',
      path: '$.state',
      message: 'The request requires state: the content every question is evaluated against.',
    });
  } else if (!isContentValue(state)) {
    errors.push({
      code: 'STATE_TYPE',
      path: '$.state',
      message: 'State must be a string, an object, or an array; null, numbers, and booleans are rejected.',
    });
  }

  const model = document.model;
  if (typeof model !== 'string' || model.trim().length === 0) {
    errors.push({
      code: 'MODEL_MISSING',
      path: '$.model',
      message: 'The request requires model as a non-empty string.',
    });
  } else if (route === 'bai') {
    if (!BAI_MODELS.includes(model)) {
      errors.push({
        code: 'MODEL_UNSUPPORTED',
        path: '$.model',
        message: `The b.ai Decisions API accepts only ${BAI_MODELS.join(' or ')}.`,
      });
    }
  } else if (route === 'direct') {
    if (!model.startsWith('jev-')) {
      errors.push({
        code: 'MODEL_UNSUPPORTED',
        path: '$.model',
        message: 'The direct TypeSafe API serves Jev models; use a model id that starts with "jev-".',
      });
    } else if (!DIRECT_MODELS.includes(model)) {
      warnings.push({
        code: 'MODEL_UNVERIFIED',
        path: '$.model',
        message: `Known aliases are ${DIRECT_MODELS.join(', ')}. This id starts with "jev-" but was not verified against the model list.`,
      });
    }
  }

  if (route === 'bai' && document.stream !== undefined && document.stream !== false) {
    errors.push({
      code: 'STREAM_NOT_SUPPORTED',
      path: '$.stream',
      message: 'The b.ai Decisions API returns one complete result; omit stream or set it to false.',
    });
  }

  const questions = document.questions;
  if (!isRecord(questions)) {
    errors.push({
      code: 'QUESTIONS_MISSING',
      path: '$.questions',
      message: 'The request requires questions: a non-empty map of question ids to question definitions.',
    });
  } else {
    const ids = Object.keys(questions);
    if (ids.length === 0) {
      errors.push({
        code: 'QUESTIONS_EMPTY',
        path: '$.questions',
        message: 'The questions map must contain at least one question.',
      });
    }
    stats.questions = ids.length;
    for (const id of ids) {
      validateQuestion(id, questions[id], route, errors, warnings, stats);
    }
  }

  scanSecrets(document, '$', errors);

  stats.estimatedStateTokens = estimateStateTokens(document, questions);
  if (stats.estimatedStateTokens > MAX_TOP_LEVEL_TOKENS) {
    warnings.push({
      code: 'STATE_LARGE',
      path: '$.state',
      message: `The serialized state plus the longest question is roughly ${stats.estimatedStateTokens} tokens by a length/4 estimate. The API limit for state plus the longest question is ${MAX_TOP_LEVEL_TOKENS}. This figure is an estimate, not a measured token count.`,
    });
  }

  return { errors, warnings, stats };
}

/**
 * Orders findings by JSON path, then by code, then by message.
 * @param {Finding} a
 * @param {Finding} b
 * @returns {number}
 */
function compareFindings(a, b) {
  if (a.path !== b.path) return a.path < b.path ? -1 : 1;
  if (a.code !== b.code) return a.code < b.code ? -1 : 1;
  if (a.message !== b.message) return a.message < b.message ? -1 : 1;
  return 0;
}

/**
 * Builds a zeroed stats block for reports that stop before validation.
 * @returns {Stats}
 */
function emptyStats() {
  return { questions: 0, noul: 0, choice: 0, score: 0, estimatedStateTokens: 0 };
}

/**
 * Writes the report to stdout as deterministic JSON.
 * @param {Report} report
 * @returns {void}
 */
function writeReport(report) {
  console.log(JSON.stringify(report, null, 2));
}

/**
 * Runs the checker and returns the process exit code.
 * @returns {number} 0 when the request is valid, 1 when it has errors, 2 on a usage error.
 */
function run() {
  /** @type {Route | null} */
  let route = null;

  try {
    const args = parseArgs(process.argv.slice(2));
    route = args.route;

    let text;
    try {
      text = readFileSync(args.file, 'utf8');
    } catch {
      throw usageError('USAGE_UNREADABLE_FILE', 'The request file could not be read.');
    }

    let document;
    try {
      document = JSON.parse(text);
    } catch {
      writeReport({
        ok: false,
        route,
        errors: [{
          code: 'INVALID_JSON',
          path: '$',
          message: 'The request file is not valid JSON.',
        }],
        warnings: [],
        stats: emptyStats(),
      });
      return 1;
    }

    const validation = validateRequest(document, args.route);
    validation.errors.sort(compareFindings);
    validation.warnings.sort(compareFindings);

    writeReport({
      ok: validation.errors.length === 0,
      route: args.route,
      errors: validation.errors,
      warnings: validation.warnings,
      stats: validation.stats,
    });
    return validation.errors.length === 0 ? 0 : 1;
  } catch (error) {
    // A document nested past the engine stack overflows during validation; that is a bad input, not a bad command.
    if (error instanceof RangeError) {
      writeReport({
        ok: false,
        route,
        errors: [{
          code: 'INPUT_TOO_DEEP',
          path: '$',
          message: 'The request nests deeper than this checker can read.',
        }],
        warnings: [],
        stats: emptyStats(),
      });
      return 1;
    }
    const code = error instanceof Error && 'code' in error && typeof error.code === 'string'
      ? error.code
      : 'USAGE_ERROR';
    writeReport({
      ok: false,
      route,
      errors: [{
        code,
        path: '$',
        message: error instanceof Error && code !== 'USAGE_ERROR' ? error.message : 'The checker could not run with these arguments.',
      }],
      warnings: [],
      stats: emptyStats(),
    });
    return 2;
  }
}

process.exit(run());

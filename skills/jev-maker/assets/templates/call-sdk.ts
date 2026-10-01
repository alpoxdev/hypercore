// Purpose: call Jev through the official TypeScript SDK, which reads the key from
// TYPESAFE_API_KEY, retries rate limits for you, and types each answer by question id.
// The SDK types the answer shape but does not range-check the values, so every signal is
// validated here before it can reach a decision: a value that is not a finite number inside
// 0..1 becomes a review, never an act.
// Fill in: the STATE record and the questions below, and the thresholds in
// constants.template.ts. A live call only after the user consents, and only then.
// The key is read from the environment by the SDK and is never printed here.

import { choice, TypeSafeClient } from "@typesafe-ai/sdk";
import { MODEL, THRESHOLDS } from "./constants.template";

// Consent gate. Leave this false until the person has agreed to a live call and knows its cost.
const LIVE_CALL_APPROVED = false;

const STATE = {
  ticket: {
    channel: "email",
    subject: "Payouts have been failing since Monday",
    message:
      "My payouts have been failing since Monday. I already re-entered my bank details twice. " +
      "I have supplier invoices due this week."
  },
  customer: { plan: "growth" }
};

interface Decision {
  readonly question: string;
  readonly outcome: "act" | "review";
  readonly signal: number | null;
  readonly threshold: number;
  readonly reason: string;
}

/**
 * Reads a decision signal, refusing any value the SDK type cannot guarantee at runtime: a value
 * that is not a finite number inside 0..1 returns null, which always becomes review, never act.
 */
function validatedSignal(value: unknown): number | null {
  if (typeof value !== "number" || !Number.isFinite(value) || value < 0 || value > 1) return null;
  return value;
}

/** Turns one answer value into a decision; a signal that fails validation goes to review. */
function decisionFor(question: string, value: unknown, threshold: number): Decision {
  const signal = validatedSignal(value);
  if (signal === null) {
    return {
      question,
      outcome: "review",
      signal: null,
      threshold,
      reason: "the value is missing or outside 0..1, so a person decides"
    };
  }
  if (signal >= threshold) {
    return { question, outcome: "act", signal, threshold, reason: "at or above the threshold" };
  }
  return { question, outcome: "review", signal, threshold, reason: "below the threshold" };
}

/** Sends one consented request and prints one act or review decision per question. */
async function main() {
  const client = new TypeSafeClient();

  const response = await client.systemOne({
    model: MODEL,
    state: STATE,
    questions: {
      // The SDK page documents the choice() helper, so the choice question uses it.
      queue: choice("Which queue should own this ticket?", {
        billing: "Charges, payouts, invoices, refunds.",
        technical: "Bugs, outages, integrations, API errors.",
        account: "Login, plan changes, team membership.",
        other: null
      }),
      // noul and score stay plain question objects, as the HTTP API reference writes them.
      needs_human: {
        type: "noul",
        instructions: "Does this ticket need a human agent, rather than an automated reply?",
        criteria: {
          true: "The customer asks for something only a person can decide, such as a manual payout retry or a refund.",
          false: "The linked help article or the account data in state answers the question."
        }
      },
      urgency: {
        type: "score",
        instructions: "How urgent is this ticket for the customer right now?",
        criteria: [
          "Can wait: no money or access is blocked this week.",
          "Time-boxed: money or access is blocked within the next few days.",
          "Blocking: the customer cannot operate and is losing money today."
        ]
      }
    }
  });

  // A noul answer is the yes probability; a choice or score answer carries the model's confidence.
  // Each value is validated before the comparison, so a bad value can never route to act.
  const decisions = [
    decisionFor("needs_human", response.answers.needs_human.noul, THRESHOLDS.noulActAtOrAbove),
    decisionFor("queue", response.answers.queue.confidence, THRESHOLDS.answerConfidenceAtOrAbove),
    decisionFor("urgency", response.answers.urgency.confidence, THRESHOLDS.answerConfidenceAtOrAbove)
  ];

  for (const decision of decisions) {
    console.log(
      `${decision.question}: ${decision.outcome} (signal ${decision.signal}, threshold ${decision.threshold}) - ${decision.reason}`
    );
  }
  console.log(`Chosen queue: ${response.answers.queue.choice}`);
}

if (LIVE_CALL_APPROVED) {
  main().catch((error: unknown) => {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = 1;
  });
} else {
  console.log("No call was made. Set LIVE_CALL_APPROVED to true only after the user consents.");
  console.log("The SDK reads the key from TYPESAFE_API_KEY at call time and never prints it.");
}

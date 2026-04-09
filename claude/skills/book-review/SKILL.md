---
name: book-review
description: Use when the user wants a full book review, multi-voice review, or polished long-form review of a book — orchestrates voice selection, parallel drafts, synthesis, fidelity checking, and polish
---

# Book Review

Supported book formats: `.txt`, `.pdf`, `.md`. For other formats (EPUB, MOBI), ask the user to convert to text first.

Produce a long-form, intellectually rigorous book review by generating drafts in multiple literary voices and synthesizing the best insights into one coherent piece. The approach treats voice not as a cosmetic layer but as a mode of thinking — different voices notice different things.

## Prerequisites

This skill requires `01_comprehension.md` and `02_critical_analysis.md` in the book's output directory. If either is missing:

1. Tell the user which prerequisite files are missing.
2. Ask for confirmation before running them: "I need to [summarize / critique] the book first. Proceed?"
3. Run the missing stages in order (comprehension before critique).
4. If files exist, check that the title and author match the current book. Warn if they don't.
5. If the book exceeds ~700,000 words, tell the user and suggest splitting the file.

## User Parameters

Ask the user conversationally (don't demand all upfront — use sensible defaults):

- **Length:** `short` (1,500–3,000 words), `medium` (3,000–6,000), `deep` (10,000–20,000). Default: `deep`.
- **Voices:** The user can optionally specify voices:
  - **3 voices** — skip voice selection, go straight to drafts.
  - **2 voices** — accept them, auto-select a third to maximize diversity, present all three for approval.
  - **1 voice** — single-voice mode: skip voice selection (Stage 3) and parallel drafts (Stage 4). Write one draft directly as `05_synthesis.md` (replacing the normal multi-voice synthesis of Stage 5), then proceed to fidelity check and polish. Do not write `03_voice_selection.md` or any `04_draft_*.md` files.
  - **4+ voices** — ask the user to pick 3 or fewer.
  - **0 voices (default)** — auto-select 3 voices.
- **Resume:** If the user says "resume from [stage]", read prior saved outputs and pick up from that stage.

## Stage 3: Voice Selection

Read `01_comprehension.md` and `02_critical_analysis.md`.

**Voice Roster (suggestions, not exhaustive):**

| Category | Voices |
|----------|--------|
| Analytical | Scott Alexander, Scott Aaronson, Tyler Cowen |
| Literary | David Foster Wallace, Joan Didion, Zadie Smith |
| Accessible | Bill Bryson, Mary Roach, Malcolm Gladwell |
| Critical | Michiko Kakutani, James Wood, Adam Gopnik |
| Ideas | Martha Nussbaum, Daniel Dennett, Eliezer Yudkowsky |

Any author works — the roster is a starting point, not a constraint.

**Selection criteria:**
- Maximize diversity — pick from different categories.
- Match to material — empirical claims benefit from analytical voices; human experience from literary ones.
- Productive tension — at least one voice somewhat adversarial to the book's style or assumptions.
- Leverage strengths — pick voices whose characteristic *way of noticing* surfaces things others miss.

**Reasoning must be specific:** Not "ACX because analytical" but "ACX because this book makes three falsifiable claims in chapters 4, 7, and 11 that deserve stress-testing."

Write `03_voice_selection.md`:

```
# Voice Selection: [Book Title]

## Voice 1: [Name]
**Category:** [category]
**Reasoning:** [specific reasoning for this book]

## Voice 2: [Name]
**Category:** [category]
**Reasoning:** [reasoning]

## Voice 3: [Name]
**Category:** [category]
**Reasoning:** [reasoning]
```

**CHECKPOINT:** Present the picks to the user and wait for approval. They can swap voices, accept, or request re-selection. Do not proceed until approved.

## Stage 4: Voice Drafts

Dispatch 3 subagents in parallel via the Agent tool, one per voice. Each subagent's prompt must include:
- The voice to write in
- The paths to `01_comprehension.md` and `02_critical_analysis.md`
- The path to the book file
- The length target
- The output file path

If parallel execution is unavailable, run drafts sequentially.

**Output:** `04_draft_<voice_name>.md` per voice. Normalize voice names for filenames: lowercase, replace non-alphanumeric characters with underscores, collapse consecutive underscores.

**Length per draft:** `deep` 5,000–8,000 words, `medium` 2,000–4,000, `short` 1,000–2,000.

**Instructions for each draft:**
- Comprehension and critical analysis are raw material — don't cover everything. Follow what's most interesting through this voice's lens.
- Structure is free-form. Follow the thinking, not the chapter order.
- The voice shapes what you *emphasize and notice*, not just how you write. Different voices ask different questions.
- Engage with ideas directly — argue, extend, complicate. Don't just describe.
- Use the critical analysis as a starting point but go beyond it. Do something with the weaknesses.
- Don't hedge. Have actual opinions. Take positions.
- Voice is a way of thinking, not a costume. Don't reduce it to surface tics.
- Different voices should notice different things. Don't force them to cover the same ground.

**CHECKPOINT:** After all drafts complete, notify the user. They can optionally read the drafts and give feedback before synthesis.

## Stage 5: Synthesis

Read all voice draft files plus `01_comprehension.md` and `02_critical_analysis.md`.

- Identify which voice's *way of engaging* produced the most insight — not just prettiest prose.
- Adopt that as the primary voice.
- Extract from all drafts: strongest arguments, sharpest observations, best examples, interesting tangents, unique insights.
- Write a new, coherent review that weaves the best material from all three. This is a genuine rewrite, not cut-and-paste.
- The final piece should feel like one unusually perceptive reviewer. No seams.
- Free-form structure. Let the piece find its shape.

**Length:** `deep` 10,000–20,000 words, `medium` 3,000–6,000, `short` 1,500–3,000. Short means picking 2–3 most important threads, not compressing everything.

Write `05_synthesis.md`.

## Stage 6: Fidelity Check

Read `05_synthesis.md` and the book file.

- Extract every factual claim the review makes about the book.
- Verify each against the source text. For long books, work claim by claim — search for relevant passages rather than holding the entire book in context.
- Categories of error: **misrepresentation**, **fabrication**, **misattribution**, **false absence**, **exaggeration**.
- Fix errors in place. If a correction changes the force of a critical argument, adjust the surrounding argument.
- Preserve voice and flow. Corrections should be invisible.

Write `06_fidelity_checked.md` (corrected review) and `06_fidelity_log.md`:

```
# Fidelity Check Log: [Book Title]

**Total claims checked:** [number]
**Issues found:** [number]

## Issue 1: [brief description]
**Category:** [category]
**Claim:** [what the review claimed]
**Explanation:** [what was wrong]
**Correction:** [what was changed]
```

This is the most important quality gate. A stylistically brilliant review that misrepresents the book is worse than useless.

## Stage 7: Polish

Read `06_fidelity_checked.md`.

- Light pass. The review is already substantively complete.
- Catch AI-isms: generic phrases ("it's important to note," "delve into," "at the end of the day"), excessive hedging, passive voice overuse.
- Sharpen bland vocabulary.
- Do NOT alter voice, structure, or humor — those are baked in.
- Do NOT add introductions, conclusions, or framing that weren't in the synthesis.

Write `07_final.md`.

**CHECKPOINT:** Print the final review to the conversation and notify the user it's saved to `07_final.md`.

## Error Handling

- If the book file cannot be read (unsupported format, too large, missing), tell the user and stop.
- If a stage produces incomplete output, retry once. If it fails again, show the user and ask how to proceed.
- If a subagent in Stage 4 fails, the other drafts are still usable. Offer to re-run the failed draft or proceed with what succeeded.
- File-based state provides implicit resumability. If any stage fails, completed outputs are saved. The user can say "resume from [stage]."

## Common Mistakes

- **Voices as costumes** — "Use footnotes like DFW" is wrong. The voice should change what you *notice and emphasize*, not just surface stylistic tics.
- **All voices covering the same ground** — The whole point is that different voices surface different things. If all three drafts discuss the same chapters in the same order, the voices aren't working.
- **Synthesis as cut-and-paste** — The synthesis must be a genuine rewrite, not paragraphs stitched together from three drafts.
- **Skipping fidelity check** — Never skip Stage 6. It's the most important quality gate.

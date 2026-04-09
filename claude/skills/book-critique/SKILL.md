---
name: book-critique
description: Use when the user wants to critically analyze a book's arguments, find weaknesses, evaluate evidence quality, or understand a book's intellectual context and gaps
---

# Book Critique

Supported book formats: `.txt`, `.pdf`, `.md`. For other formats (EPUB, MOBI), ask the user to convert to text first.

Produce a critical analysis of a book's arguments — what's strong, what's weak, what's missing, and where it sits in the broader intellectual landscape. This is evaluation, not summary.

## Prerequisites

This skill reads `01_comprehension.md` from the book's output directory to ground the critique in what the book actually says. If it doesn't exist:

1. Check if a `book_review/` directory exists next to the book file.
2. If `01_comprehension.md` is missing, tell the user: "I need to summarize the book first to ground the critique. Run the comprehension stage?" Wait for confirmation before proceeding.
3. If it exists, check that the title and author match the current book. Warn if they don't.

## Process

1. The user provides a path to a book file.
2. Determine the output directory: `book_review/` in the same directory as the book file.
3. Read `01_comprehension.md` (or produce it first — see Prerequisites).
4. Read the book.
5. Check if `02_critical_analysis.md` already exists. If it does, ask the user whether to overwrite or skip.
6. Write `02_critical_analysis.md` following the output format below.
7. Print a human-readable critical analysis to the conversation.

## Output Format

Write `02_critical_analysis.md` in this structure:

```
# Critical Analysis: [Book Title]

## Strongest Arguments
- **[argument]** — [why it's strong, what evidence supports it]

## Weakest Arguments
- **[argument]** — [why it's weak, what's missing or unconvincing]

## Rhetoric Over Evidence
- [where the author relies on rhetoric, analogy, or assertion rather than evidence]

## Gaps and Silences
- [what the book conspicuously ignores, counterarguments not addressed, evidence that would undermine the thesis]

## Intellectual Context
[How this book relates to other thinkers in the field. Who agrees, who disagrees, where it sits in the broader debate.]

## Temporal Lens
[What has happened since publication that validates, undermines, or recontextualizes the argument. Has the field moved on? Were predictions confirmed?]

## Audience and Purpose
[Who the book is written for. Does it succeed on its own terms?]

## Interesting Threads
- [underexplored ideas, surprising implications the author doesn't draw out, moments where the author is more interesting than they realize]
```

## Instructions

- **Steelman before criticizing.** Show you understand the strongest version of the argument before pointing out where it fails.
- Don't be contrarian for its own sake, but don't be deferential either.
- Think *with* the author, then *past* them.
- Be intellectually honest.
- **Ground the critique in what the book actually says** — reference the comprehension output. Do not critique based on what you "know" about the topic from training data. If the book makes a claim, evaluate it on the evidence the book provides.

## Common Mistakes

- **Critiquing the topic instead of the book** — "Behavioral economics has limitations" is not a critique of this specific book. Stay focused on what this author wrote.
- **False balance** — If the book's argument is genuinely strong, say so. Not every section needs a criticism.
- **Missing the author's own terms** — If the author explicitly addresses a counterargument, don't list it under "Gaps and Silences." That's a false absence.
- **Importing training data** — "Studies have since shown X" is valid for Temporal Lens, but not for evaluating the book's internal logic. The book's arguments should be evaluated on the evidence the book itself presents.

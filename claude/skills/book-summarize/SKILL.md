---
name: book-summarize
description: Use when the user wants a chapter-by-chapter summary of a book, asks "what does this book argue", or wants to comprehend a book's structure and claims before deeper analysis
---

# Book Summarize

Read a book and produce a structured chapter-by-chapter comprehension. Output is a markdown file that captures what the book says — its arguments, claims, evidence, key terms, and notable quotes — without evaluation.

## Process

1. The user provides a path to a book file (`.txt`, `.pdf`, or `.md`). If other formats (EPUB, MOBI), ask them to convert to text first.
2. Read the book using the Read tool. For large PDFs, read in page ranges.
3. Determine the output directory: `book_review/` in the same directory as the book file. Create it if needed.
4. If the output directory already exists, check for files from a prior run (02 through 07). If found, warn the user that stale outputs from a previous book may be present and offer to clear the directory before proceeding.
5. Check if `01_comprehension.md` already exists. If it does, ask the user whether to overwrite or skip.
6. Write `01_comprehension.md` following the output format below.
7. Print a human-readable summary to the conversation — not the raw file, but a concise overview of the book's thesis, arc, and chapter highlights.

## Output Format

Write `01_comprehension.md` in this structure:

```
# Comprehension: [Book Title]

**Author:** [name]
**Year:** [year or "Unknown"]
**Genre:** [genre]
**Subject Area:** [subject area]

## Overall Thesis

[The book's central argument in 1-3 paragraphs]

## Arc

[How the argument builds across chapters]

## Chapter 1: [Chapter Title]

### Summary
[The argument and narrative of this chapter]

### Key Claims
- [claim]

### Evidence Presented
- [evidence or example]

### Key Terms
- **[term]** — [how the author defines/uses it]

### Notable Quotes
> "[quote]"

## Chapter 2: [Chapter Title]
...
```

## Instructions

- **Stick to what the book says.** No evaluation, no outside knowledge, no opinions.
- If the author's argument is unclear, say it's unclear — do not fill in gaps.
- Quote directly when the author's specific phrasing matters.
- Every chapter gets a summary. Be thorough.
- If the book has no chapter structure (continuous essay, etc.), use logical sections instead. Number them sequentially, use descriptive section titles, and note in the Arc section that the book is unchaptered.
- If the book exceeds the model's context window (~700,000 words), tell the user and suggest splitting the file.

## Common Mistakes

- **Adding evaluation** — "This is a compelling argument" is evaluation. "The author argues X, citing Y" is comprehension. Stick to the latter.
- **Filling gaps** — If the author's logic has a hole, describe the hole. Don't patch it.
- **Importing outside knowledge** — If you know a study the author cites was later retracted, do not mention it here. This stage is about what the book says, not what is true.

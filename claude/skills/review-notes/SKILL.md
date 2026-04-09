---
name: review-notes
description: Use when user wants to review, clean, triage, or organize Obsidian notes, or pull Granola meeting notes - interactive pipeline that pulls meetings, finds loose notes, cleans them into structured format, files them, and surfaces TODOs and key info for overview docs
---

# Review Notes

## Overview

Interactive note-management pipeline: pull Granola meetings, find loose notes, collaboratively triage/rename/clean/file them, and surface key items into the right docs.

**Core principle:** Collaborative and curious, not presumptuous. Always show reasoning, always ask. "I see X, I think Y — does that sound right?"

## When to Use

- User says "clean up my notes", "review my notes", "process my notes", "pull Granola"
- User runs `/review-notes`
- Periodically as part of note hygiene

## Configuration

- **Vault path:** `~/Documents/Obsidian Vault/`
- **Filing rules:** Read `Where Things Go.md` from the vault root each run — do NOT hardcode folder routing
- **Granola:** Use `granola` CLI (installed globally via npm as `granola-cli`)
- **Sensitive content:** Flag notes containing credentials, backup codes, API keys and suggest moving to `Keep/`. No need to hide contents — this is a personal tool.

## Vault Conventions

Project and company folders follow a standard structure. Learn this so you don't invent structures that don't fit.

```
Career/<Company>/
  <Company> Overview.md    ← High-level overview only — keep it lean
  TODO.md                  ← Live TODO list (separate from overview)
  How We Work.md           ← Topic-specific doc
  Alignment Research/      ← Topic-specific subfolder
    Gradient Routing.md    ← One doc per topic (e.g. Emergent Misalignment.md, Acausal Trade.md)
  People/
    <Name>.md              ← Individual doc for frequent/important contacts
    Assorted.md            ← SINGLE FILE with one-liners for minor contacts
  Meetings/
    Raw/                   ← Raw transcripts
    YYYY-MM-DD-<title>.md  ← Cleaned meeting notes

Projects/<Project>/
  <Project> Overview.md
  TODO.md
  People/
    Assorted.md
  Meetings/
    Raw/
```

**Overview docs** (`* Overview.md`):
- Named `<Name> Overview.md` to make the purpose obvious
- High-level only: description, key info, people links, meeting links
- Do NOT put TODOs here — those belong in `TODO.md`
- Do NOT add every detail — keep it lean and scannable

**`People/` folder:**
- Individual `.md` files for people you interact with regularly
- `Assorted.md` — a **single flat file** with one-liner entries for minor contacts. This is a FILE, not a folder. Do not create `People/Assorted/` as a directory.

**`TODO.md`:**
- Live action item list per project/company, separate from the overview doc
- When surfacing TODOs from a meeting, they go here — not in the overview doc

**Topic folders** (e.g. `Alignment Research/`):
- Created when a topic is substantial enough to warrant multiple docs
- Each doc covers a specific topic (e.g. `Gradient Routing.md`, `Emergent Misalignment.md`, `Notes.md` for misc)

## Pipeline

### Phase 1: Pull from Granola

1. Run `granola meeting list` to list recent meetings
2. Check `Meetings/` for existing files — skip already-imported meetings (match by title + date)
3. For each new meeting:
   - Save raw transcript to `Meetings/Raw/YYYY-MM-DD-<title>.md`
   - Use `granola meeting enhanced` for AI-enhanced notes; fall back to `granola meeting notes` if unavailable
   - Create cleaned version at `Meetings/YYYY-MM-DD-<title>.md` using the cleaned note template
   - Skip meetings with empty transcripts (failed recordings)
4. Report: "Pulled N new meetings: [list]"

### Phase 2: Find Loose Notes

1. Scan vault root for `.md` files not inside any subfolder
2. Exclude `Where Things Go.md` (meta doc)
3. Look for related loose notes about the same topic — suggest merging them into one note
4. Look for loose files that share a name with an existing folder — suggest moving inside (with a rename like "Interview Notes")
5. For each loose note, present with a first-line preview and proposed action:

```
Found 6 loose notes:

1. Rafael.md — "use free time to use handbook..."
   -> Looks like an AE Studio onboarding convo with Rafael.
      Rename to "Onboarding Convo.md", file under Career/AE Studio/?

2. TODO.md — screenshot + "What do I do with linear?"
   -> Might be AE Studio related. Is this an AE Studio note?
```

**Key behaviors:**
- **Default to suggesting a descriptive rename.** Most loose notes have vague or misleading names. Suggest what the note is actually about.
- **Infer date from filesystem metadata.** For loose notes without a date in the content, use `stat -f %SB` (macOS) to get the file's creation date. Present this to the user: "This file was created on March 12 — use that as the note date?" The user confirms or corrects before the date is used in filenames or the cleaned note header.
- Ask about ambiguous associations: "Is this part of AE Studio? Project X?"
- Flag sensitive-looking notes and suggest moving to `Keep/`
- User confirms, redirects, renames, or skips each one

### Phase 3: Clean & File

For each confirmed note:

1. Move raw note to `<destination>/Raw/YYYY-MM-DD-<original-name>.md`
2. Write cleaned version to `<destination>/YYYY-MM-DD-<clean-name>.md`
3. Create destination folder and `Raw/` subfolder if they don't exist
4. **One-liners and short notes → merge, don't standalone.** If a note is too short for the full template, propose merging it into an existing doc rather than creating a separate cleaned note.
5. **Related notes → merge.** If multiple loose notes cover the same topic, combine them into one cleaned note.

**Cleaned note template:**

```markdown
## DD Month YYYY — Title

**Key Takeaways**
- ...

**Decisions**
- ...

**TODOs**
- [ ] ...

**Open Questions**
- ...
```

Omit empty sections rather than leaving them blank.

### Phase 4: Surface & Propose

This is the most important phase. After filing meetings and notes, read through each one and ask: does anything here need to be added to an existing doc?

Scan for these categories:

**TODOs** — any action items, follow-ups, tasks
→ Add to `TODO.md` for the relevant project/company
→ For TODOs from meetings more than a few days old, ask "Any of these already done?" before adding

**People** — any new person mentioned
→ Frequent/important contact: propose creating an individual doc in `People/`
→ Minor contact (met once, unlikely to need a full doc): propose adding a one-liner to `People/Assorted.md`

**Key info** — tools, processes, facts worth persisting (deadlines, org structure, workflows)
→ Add to the `* Overview.md` Key Info section — but keep it lean, one bullet per fact

**Topic-specific content** — anything substantive about a recurring topic
→ Alignment ideas/research: find the most relevant doc in `Alignment Research/` or propose creating a new one for the specific topic (e.g. `Emergent Misalignment.md`, `Gradient Routing.md`)
→ Process/methodology notes: `How We Work.md` or similar
→ Do NOT dump topic content into the overview doc

Present proposals explicitly before writing anything:

```
From "Core Values" (Apr 6):

  TODO: Look up Pygmalion effect study
  → Add to Career/AE Studio/TODO.md? [y/n]

  New person: Fernando (senior data scientist, 4-month-old son)
  → Minor contact — add one-liner to People/Assorted.md? [y/n]

  Key info: Co-publishing Gradient Routing paper with Anthropic next month
  → Add to AE Studio Overview.md Key Info? [y/n]

  Alignment content: working definition of alignment, Galileo example, hardware invariance idea
  → Add to Alignment Research/Notes.md? Or create a new doc? [y/n/specify]
```

**If an overview doc doesn't exist yet**, ask: "No overview doc for X yet. Create one?" Use this template:

```markdown
# Title

## Overview
Brief description.

## Key Info
- ...

## People
- ...

## Meetings
- ...
```

## What This Skill Does NOT Do

- Touch notes already filed in subfolders
- Reorganize existing folder structure
- Edit any doc without explicit approval
- Delete anything

## Common Mistakes

- **Being presumptuous** — Always ask before filing, renaming, or editing. Present reasoning.
- **Hardcoding folder rules** — Read `Where Things Go.md` each run. It may change.
- **Ignoring existing format** — When appending to a doc, match what's already there.
- **Keeping vague filenames** — Default to suggesting a descriptive rename.
- **Creating standalone notes for one-liners** — Short notes should be merged into an existing doc.
- **Missing merge opportunities** — Multiple loose notes about the same topic should be combined.
- **Missing folder conflicts** — A file named `Foo.md` next to a folder `Foo/` should be moved inside with a descriptive rename.
- **Adding stale TODOs without checking** — Old meeting TODOs may already be done. Ask first.
- **Creating `People/Assorted/` as a folder** — Assorted is a single flat file (`People/Assorted.md`), not a directory.
- **Putting TODOs in the overview doc** — TODOs go in `TODO.md`, not in `* Overview.md`.
- **Overloading the overview doc** — Overview docs are high-level. Topic-specific content belongs in its own doc or folder.

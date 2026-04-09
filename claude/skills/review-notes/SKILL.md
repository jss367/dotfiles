---
name: review-notes
description: Use when user wants to review, clean, triage, or organize Obsidian notes, or pull Granola meeting notes - interactive pipeline that pulls meetings, finds loose notes, cleans them into structured format, files them, and surfaces TODOs and key info for overview docs
---

# Review Notes

## Overview

Interactive note-management pipeline: pull Granola meetings, find loose notes, collaboratively triage/rename/clean/file them, and surface key items for overview docs.

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
5. Check the meeting-to-project filing table in `Where Things Go.md` — copy meetings to their project folders as specified

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
4. **One-liners and short notes → merge, don't standalone.** If a note is too short for the full template, propose merging it into an existing overview or TODO doc rather than creating a separate cleaned note.
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

Scan all newly processed notes for actionable items:

- **TODOs** — action items, follow-ups, tasks
- **Decisions** — things decided or agreed on
- **Key facts** — important info worth persisting (deadlines, tool names, processes, people)

For each item, propose where it goes:

```
From "Onboarding Convo" (Career/AE Studio/):
  TODO: Reach out to Bre about insurance
  -> Add to Career/AE Studio/TODO.md? [y/n/elsewhere]

  Key fact: Harvest used for time tracking
  -> Add to Career/AE Studio/AE Studio.md Key Info? [y/n/elsewhere]
```

**Behaviors:**
- **TODOs go to TODO docs.** Each project/company can have a live `TODO.md`. Prefer appending TODOs there rather than only embedding in overview docs.
- **Stale TODOs from older meetings:** When surfacing TODOs from meetings more than a few days old, ask "Any of these already done?" before adding them.
- If overview doc exists, read it first and match its existing format when appending
- If overview doc doesn't exist, ask: "No overview doc for X yet. Create one?"
- Use this default template for new overview docs:

```markdown
# Title

## Overview
Brief description.

## TODOs
- [ ] ...

## Decisions
- ...

## Key Info
- ...
```

## What This Skill Does NOT Do

- Touch notes already filed in subfolders
- Reorganize existing folder structure
- Edit overview docs without explicit approval
- Delete anything

## Common Mistakes

- **Being presumptuous** — Always ask before filing, renaming, or editing. Present reasoning.
- **Hardcoding folder rules** — Read `Where Things Go.md` each run. It may change.
- **Ignoring existing format** — When appending to an overview doc, match what's already there.
- **Keeping vague filenames** — Default to suggesting a descriptive rename. "Rafael.md" → "Onboarding Convo.md".
- **Creating standalone notes for one-liners** — Short notes should be merged into an existing doc (overview, TODO, etc.).
- **Missing merge opportunities** — Multiple loose notes about the same topic should be combined.
- **Missing folder conflicts** — A file named `Foo.md` next to a folder `Foo/` should be moved inside the folder with a descriptive rename.
- **Adding stale TODOs without checking** — Old meeting TODOs may already be done. Ask first.

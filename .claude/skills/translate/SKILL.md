---
name: translate
description: Translate an English 4DCu.be blog post into Dutch, place it in _posts/nl, and verify it through an independent back-translation into English. Use when the user runs /translate <post> or asks to translate/localize a blog post into Dutch.
---

# /translate — localize an English post into Dutch

## Arguments

`<post>` is a filename, slug, or path identifying an English source post below
`_posts/`, excluding `_posts/nl/`. Resolve both `.md` and `.markdown` files and
accept a date/slug fragment or a full path.

## Step 1 — Resolve and read the source

Find exactly one matching English post and read the entire file, including front
matter. If the argument matches multiple posts, ask the user to choose rather than
guessing.

The shared `post_id` is how the site links translations and generates reciprocal
`hreflang` annotations. If the English post has no `post_id`, add a stable,
language-neutral ID derived from its filename slug to the English front matter.
This is the only change this workflow may make to the English source.

## Step 2 — Find or choose the Dutch target

- Search `_posts/nl/` for the same `post_id`.
- If a Dutch translation exists, tell the user and ask whether it should be
  updated or skipped.
- Otherwise create `_posts/nl/<date>-<slug>.<extension>`, retaining the source
  filename and extension but not its optional year directory. Do not append `NL`
  to the slug.
- Do not add `locale` or `permalink`; `_config.yml` supplies `nl_NL` and the
  `/nl/` URL prefix for everything under `_posts/nl/`.

## Step 3 — Inspect site vocabulary and linked posts

- Read `_config.yml` and `_data/translations.yml` before translating.
- Keep every category slug unchanged. Dutch display labels are configured by
  locale in `_config.yml`.
- Inspect each `{% post_url ... %}` target and determine whether a Dutch post with
  the same `post_id` exists.
- Review nearby Dutch posts for established terminology and tone, but prioritize
  technical correctness and natural Flemish-Dutch phrasing.

## Step 4 — Translate with the translator agent

Delegate the translation synchronously to the `translator` subagent defined in
`.claude/agents/translator.md`. Give it the complete source file, the target path,
the unchanged category slugs, and the linked-post mapping from Step 3.

Translate:

- `title` and `description`
- `gallery_items[].description`
- human-readable `alt` and `title` text on images
- normal Markdown/HTML prose, headings, lists, and table text
- tags when a natural Dutch equivalent is appropriate

Copy unchanged:

- all category slugs
- `layout`, `date`, `author`, `cover`, `thumbnail`, `post_id`, and `coords`
- image and gallery paths
- fenced or indented code, inline code, commands, output, identifiers, API names,
  filenames, and paths
- all non-`post_url` URLs and Liquid expressions

Rewrite a `{% post_url ... %}` link to its `_posts/nl/` target only when that
Dutch translation exists. Otherwise leave the English target intact and record
it for the final report. Preserve all Markdown, Liquid, HTML, and front-matter
structure exactly.

## Step 5 — Verify through independent back-translation

Spawn a fresh `translator` subagent instance synchronously with only:

- the complete Dutch file just written
- the complete original English file
- instructions to independently back-translate the Dutch into English and report
  only meaning-level discrepancies

The verification should detect changed technical facts, numbers, names, code or
identifiers, dropped/added content, and tone changes. It should not flag harmless
stylistic differences.

## Step 6 — Fix and repeat

Correct only the passages or fields flagged by verification, then run a fresh
back-translation check again. Stop after a clean result or after three rounds. If
meaning-level issues remain after three rounds, leave them visible and report them
to the user rather than silently accepting them.

## Step 7 — Report

Summarize:

- the English file and Dutch file created or updated
- the `post_id` used and whether it was added to the English source
- confirmation that category slugs remained unchanged
- any `post_url` links that still point to English because no Dutch counterpart
  exists
- the verification outcome and number of rounds

## Notes

- Never change the English prose or body as part of translation.
- Keep front-matter key order and formatting consistent with the source and nearby
  Dutch posts.
- Assets are shared between languages; creating or translating image files is out
  of scope.
- The workflow creates or updates files only. It does not commit, push, or rebuild
  `docs/` unless the user asks for those actions separately.

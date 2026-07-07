# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

Production Bytes — a statically generated [SvelteKit](https://svelte.dev/docs/kit)
blog about enterprise software delivery, published to GitHub Pages. Posts are
Markdown; [mdsvex](https://mdsvex.pngwn.io/) compiles them to Svelte components
at build time. The build is fully prerendered to static HTML in `docs/`.

## Layout

- `src/content/YYYY/MM/DD-slug.md` — post source. Date folders are for humans;
  the public URL comes from each post's `slug` frontmatter (`/posts/<slug>/`).
- `src/lib/posts.js` — globs all `src/content/**/*.md`, exposes their frontmatter
  (`metadata`) and rendered components, sorted newest-first.
- `src/routes/` — the SvelteKit pages (home list + `posts/[slug]`).
- `make.sh` — the real build logic; the `Makefile` just delegates to it.
- `docs/` — build output and the GitHub Pages publish target (don't hand-edit).

## Commands

```bash
make dev        # local dev server (BASE_PATH="")
make build      # build static site into docs/
make preview    # preview the production build
```

Production builds set `BASE_PATH=/prodbytes` for GitHub Pages project hosting.

## Post frontmatter

Each post needs:

```yaml
---
title: ...
slug: ...        # drives the public URL: /posts/<slug>/
date: 'YYYY-MM-DD'
summary: ...     # one-line description, also used on the post list
---
```

Place new posts under the matching date folder and keep the slug unique.

## Writing posts

**Before writing anything, read the existing posts in `src/content/` first.**
They are the source of truth for voice and structure — match them rather than
inventing a new style.

- **Follow the established tone and wording.** Study how existing posts open,
  segment with `##` headings, and close (often with a question that invites
  discussion). Mirror that rhythm, vocabulary, and level of technical detail.
- **Be confident but humble.** Take clear positions and back them with real
  trade-offs and failure modes — but acknowledge uncertainty, avoid hype, and
  don't oversell. The audience ships software for a living and can tell the
  difference.
- Practical over theoretical. No buzzwords, no vendor talking points. Concrete
  examples, honest about what breaks.
- Link out to authoritative sources the way existing posts do.
- **Link every mentioned product, service, library, framework, or language** to
  its official site on first mention.
- **Link every mentioned GitHub project** to its repository (or the specific
  issue/queue being discussed).

## Social media posts

When writing promotional copy (LinkedIn, etc.) for posts or videos:

- **Tone it down and stay humble.** No hype, no self-promotion beyond what the
  content earns. Present it as "how I think about it", not the definitive answer.
- **No emojis** — use plain bullets instead.
- **No hashtags.**
- Strip tracking parameters from shared links unless asked to keep them.
- End with the same discussion-inviting question style the posts use.

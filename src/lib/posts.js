// Posts live as Markdown files under src/content/, organized into date folders
// (e.g. src/content/2026/06/25-hello-world.md). The folder layout is just for
// humans — the public URL is driven by each post's `slug` frontmatter, so
// /posts/<slug>/ stays clean regardless of how files are foldered.
//
// import.meta.glob eagerly imports every .md so we get both its compiled
// component (default export) and its frontmatter (the `metadata` export).
const files = import.meta.glob('/src/content/**/*.md', { eager: true });

// Files without `slug` frontmatter (e.g. draft notes) are not posts — skip them.
const published = Object.values(files).filter((mod) => mod.metadata?.slug);

/** @type {Array<{ slug: string, title: string, date: string, summary: string }>} */
export const posts = published
	.map((mod) => mod.metadata)
	.sort((a, b) => (a.date < b.date ? 1 : -1)); // newest first

/** Map of slug -> rendered Svelte component for the post body. */
export const components = Object.fromEntries(
	published.map((mod) => [mod.metadata.slug, mod.default])
);

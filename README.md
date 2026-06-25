# prodbytes

Production Bytes — a statically generated [SvelteKit](https://svelte.dev/docs/kit)
site published to GitHub Pages.

## Develop

```bash
make dev        # local dev server
make build      # build static site into docs/
make preview    # preview the production build
```

Local preview of the built site:

```bash
make build
process-compose up   # serves docs/ at http://localhost:8080/
```

## Posts

Posts are Markdown files under `src/content/`, organized into date folders
(e.g. `src/content/2026/06/25-welcome.md`). Each needs `title`, `slug`, `date`,
and `summary` frontmatter; the public URL is `/posts/<slug>/`.

## License

Content is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
See [LICENSE](LICENSE).

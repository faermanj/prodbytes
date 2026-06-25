// Prerender every route to static HTML so the site can be served from
// GitHub Pages (no Node server at runtime).
export const prerender = true;

// SvelteKit's client router can't trail-slash-normalize on a static host the
// same way a server does; 'always' keeps directory-style URLs consistent.
export const trailingSlash = 'always';

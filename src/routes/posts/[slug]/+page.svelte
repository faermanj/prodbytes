<script>
	import { base } from '$app/paths';
	import { components } from '$lib/posts.js';

	let { data } = $props();

	const post = $derived(data.post);
	// Look up the compiled Markdown component by slug. The map is module-level,
	// so the component is available during prerender (renders to static HTML).
	const Content = $derived(components[post.slug]);
</script>

<svelte:head>
	<title>{post.title} — ProdBytes</title>
	<meta name="description" content={post.summary} />
</svelte:head>

<article>
	<h1>{post.title}</h1>
	<time datetime={post.date}>{post.date}</time>

	<Content />

	<p><a href="{base}/">&larr; Back home</a></p>
</article>

import { error } from '@sveltejs/kit';
import { posts } from '$lib/posts.js';

// Tell the prerenderer which slugs exist so every post is emitted to static
// HTML even if nothing links to it yet.
export function entries() {
	return posts.map((post) => ({ slug: post.slug }));
}

export function load({ params }) {
	const post = posts.find((p) => p.slug === params.slug);
	if (!post) throw error(404, `No post with slug "${params.slug}"`);
	return { post };
}

<script>
	import { base } from '$app/paths';
	import { posts } from '$lib/posts.js';
</script>

<svelte:head>
	<title>ProdBytes</title>
	<meta name="description" content="Production Bytes — notes on building and shipping software." />
</svelte:head>

<h1>ProdBytes</h1>
<p>Notes on building and shipping software in production.</p>

<h2>Posts</h2>
<ul class="posts">
	{#each posts as post}
		<li>
			<a href="{base}/posts/{post.slug}/">{post.title}</a>
			<time datetime={post.date}>{post.date}</time>
			<p>{post.summary}</p>
		</li>
	{/each}
</ul>

<style>
	.posts {
		list-style: none;
		padding: 0;
	}

	.posts li {
		margin-bottom: 1.5rem;
	}

	.posts a {
		font-size: 1.1rem;
		font-weight: 600;
	}

	.posts time {
		margin-left: 0.5rem;
	}

	.posts p {
		margin: 0.25rem 0 0;
	}
</style>

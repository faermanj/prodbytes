<script>
	import { base } from '$app/paths';
	import '../app.css';

	let { children } = $props();
</script>

<div class="site">
	<header>
		<a class="brand" href="{base}/">ProdBytes</a>
		<nav>
			<a href="{base}/">Home</a>
		</nav>
	</header>

	<main>
		{@render children()}
	</main>

	<footer>
		<p>
			Content licensed under
			<a href="https://creativecommons.org/licenses/by/4.0/" rel="license">CC&nbsp;BY&nbsp;4.0</a>.
		</p>
	</footer>
</div>

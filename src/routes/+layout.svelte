<script>
  import './styles.css';
  import Header from './Header.svelte';
</script>

<div class="app">
  <Header />

  <main>
    <slot />
  </main>
</div>

<style>
</style>

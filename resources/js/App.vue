<template>
  <div id="app" class="bg-gray-50">
    <header class="bg-white shadow">
      <nav class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
        <h1 class="text-3xl font-bold text-gray-900">Comedy Trail</h1>
      </nav>
    </header>
    
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-2xl font-bold text-gray-900 mb-4">Welcome to Comedy Trail</h2>
        <p class="text-gray-600 mb-4">
          This is your Laravel application with Vue.js and Tailwind CSS.
        </p>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div class="bg-blue-50 p-4 rounded border border-blue-200">
            <h3 class="font-bold text-blue-900 mb-2">Vue.js</h3>
            <p class="text-sm text-blue-700">Progressive JavaScript framework for building UIs</p>
          </div>
          <div class="bg-green-50 p-4 rounded border border-green-200">
            <h3 class="font-bold text-green-900 mb-2">Laravel</h3>
            <p class="text-sm text-green-700">Modern PHP web application framework</p>
          </div>
          <div class="bg-purple-50 p-4 rounded border border-purple-200">
            <h3 class="font-bold text-purple-900 mb-2">Tailwind CSS</h3>
            <p class="text-sm text-purple-700">Utility-first CSS framework</p>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      message: 'Comedy Trail Application'
    }
  }
}
</script>

<style scoped>
</style>

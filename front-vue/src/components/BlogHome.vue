<template>
  <div>
    <h1>Bem-vindo ao Blog</h1>

    <h2>Posts Recentes</h2>
    <ul v-if="posts.length">
      <li v-for="post in posts" :key="post.id">
        <h3>{{ post.title }}</h3>
        <p>{{ post.content }}</p>
      </li>
    </ul>
    <p v-else>Não há posts publicados ainda.</p>

    <div v-if="posts.length">
      <button @click="fetchPosts(currentPage - 1)" :disabled="currentPage === 1">Anterior</button>
      <button @click="fetchPosts(currentPage + 1)" :disabled="currentPage === totalPages">Próximo</button>
    </div>

    <div v-if="loading" class="loading-indicator">Carregando...</div>
  </div>
</template>

<script>
import api from '../services/api';

export default {
  name: 'BlogHome',
  data() {
    return {
      posts: [],
      currentPage: 1,
      totalPages: 1,
      loading: false,
    };
  },
  async created() {
    await this.fetchPosts(1);
  },
  methods: {
    async fetchPosts(page) {
      this.loading = true;
      try {
        const response = await api.get('/posts', { params: { page } });
        this.posts = response.data.posts;
        this.currentPage = response.data.meta.current_page;
        this.totalPages = response.data.meta.total_pages;
      } catch (error) {
        console.error('Erro ao buscar posts:', error);
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>

<style scoped>
h1 {
  text-align: center;
  margin-bottom: 20px;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  margin-bottom: 15px;
}

h3 {
  margin: 0 0 5px;
}

.loading-indicator {
  text-align: center;
  color: #888;
  margin-top: 20px;
}
</style>

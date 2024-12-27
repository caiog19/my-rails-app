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
  </div>
</template>

<script>
import api from '../services/api'; // Certifique-se de que o arquivo API está no local correto

export default {
  name: 'BlogHome',
  data() {
    return {
      posts: [], // Lista de posts
    };
  },
  async created() {
    await this.fetchPosts(); // Carrega os posts ao montar o componente
  },
  methods: {
    async fetchPosts() {
      try {
        const response = await api.get('/posts'); // Substitua '/posts' pelo endpoint correto do backend
        this.posts = response.data; // Popula a lista de posts com a resposta da API
      } catch (error) {
        console.error('Erro ao buscar posts:', error);
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
</style>

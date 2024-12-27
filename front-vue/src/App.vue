<template>
  <div>
    <h1>Posts</h1>
    <ul>
      <li v-for="post in posts" :key="post.id">
        <h2>{{ post.title }}</h2>
        <p>{{ post.content }}</p>
      </li>
    </ul>
  </div>
</template>

<script>
import api from './services/api';

export default {
  data() {
    return {
      posts: [],
    };
  },
  async created() {
    try {
      const response = await api.get('/posts');
      this.posts = response.data;
    } catch (error) {
      console.error('Erro ao buscar posts:', error);
    }
  },
};
</script>

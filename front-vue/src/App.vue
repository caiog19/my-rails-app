<template>
  <div>
    <h1>Posts</h1>
    <ul>
      <li v-for="post in posts" :key="post.id">
        <h2>{{ post.title }}</h2>
        <p>{{ post.content }}</p>
      </li>
    </ul>

    <h2>Criar novo Post</h2>
    <form @submit.prevent="createPost">
      <div>
        <label for="title">Título:</label>
        <input v-model="newPost.title" id="title" />
      </div>
      <div>
        <label for="content">Conteúdo:</label>
        <textarea v-model="newPost.content" id="content"></textarea>
      </div>
      <button type="submit">Criar Post</button>
    </form>
  </div>
</template>

<script>
import api from './services/api';

export default {
  data() {
    return {
      posts: [],
      newPost: {
        title: '',
        content: '',
      },
    };
  },
  async created() {
    await this.fetchPosts();
  },
  methods: {
    async fetchPosts() {
      try {
        const response = await api.get('/posts');
        this.posts = response.data;
      } catch (error) {
        console.error('Erro ao buscar posts:', error);
      }
    },
    async createPost() {
      try {
        const response = await api.post('/posts', {
          post: this.newPost,
        });
        this.posts.push(response.data);
        this.newPost = { title: '', content: '' }; // Reseta o formulário
      } catch (error) {
        console.error('Erro ao criar post:', error);
      }
    },
  },
};
</script>

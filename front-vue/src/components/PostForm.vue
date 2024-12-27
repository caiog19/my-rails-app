<template>
    <div>
      <h2>{{ isEditing ? 'Editar Post' : 'Criar Novo Post' }}</h2>
      <form @submit.prevent="submitPost">
        <div>
          <label for="title">Título:</label>
          <input v-model="post.title" id="title" required />
        </div>
        <div>
          <label for="content">Conteúdo:</label>
          <textarea v-model="post.content" id="content" required></textarea>
        </div>
        <button type="submit">{{ isEditing ? 'Salvar Alterações' : 'Publicar Post' }}</button>
      </form>
    </div>
  </template>
  
  <script>
  import api from '../services/api';
  
  export default {
    props: {
      postToEdit: Object, 
    },
    data() {
      return {
        post: {
          title: '',
          content: '',
        },
        isEditing: false,
      };
    },
    created() {
      if (this.postToEdit) {
        this.post = { ...this.postToEdit };
        this.isEditing = true;
      }
    },
    methods: {
      async submitPost() {
        try {
          if (this.isEditing) {
            await api.put(`/posts/${this.post.id}`, this.post);
            alert('Post atualizado com sucesso!');
          } else {
            await api.post('/posts', this.post);
            alert('Post publicado com sucesso!');
          }
          this.$emit('postSaved');
        } catch (error) {
          console.error('Erro ao salvar o post:', error);
        }
      },
    },
  };
  </script>
  
<template>
  <div>
    <h2>Meus Posts</h2>
    
    <button @click="logout" class="logout-button">Logout</button>

    <div class="post-form">
      <h3>{{ isEditing ? 'Editar Post' : 'Criar Novo Post' }}</h3>
      <form @submit.prevent="submitPost">
        <div>
          <label for="title">Título:</label>
          <input v-model="post.title" id="title" type="text" required />
        </div>
        <div>
          <label for="content">Conteúdo:</label>
          <textarea v-model="post.content" id="content" required></textarea>
        </div>
        <button type="submit">{{ isEditing ? 'Salvar Alterações' : 'Publicar Post' }}</button>
        <button type="button" v-if="isEditing" @click="cancelEdit" class="cancel-button">Cancelar</button>
      </form>
    </div>

    <ul v-if="posts.length">
      <li v-for="post in posts" :key="post.id">
        <h3>{{ post.title }}</h3>
        <p>{{ post.content }}</p>
        <div class="post-actions">
          <button @click="editPost(post)" class="edit-button">Editar</button>
          <button @click="deletePost(post.id)" class="delete-button">Excluir</button>
        </div>
      </li>
    </ul>
    <p v-else>Você ainda não publicou nenhum post.</p>
  </div>
</template>

<script>
import api from '../services/api';
import { eventBus } from '../eventBus';

export default {
  name: 'UserPosts',
  data() {
    return {
      posts: [],
      post: {
        id: null,
        title: '',
        content: '',
      },
      isEditing: false,
    };
  },
  async created() {
    await this.fetchPosts();
  },
  methods: {
    async fetchPosts() {
      try {
        const response = await api.get('/meus-posts');
        this.posts = response.data;
      } catch (error) {
        console.error('Erro ao buscar posts:', error);
        alert('Não foi possível carregar os posts. Por favor, faça login novamente.');
        this.$router.push('/login'); 
      }
    },
    async deletePost(postId) {
      if (!confirm('Tem certeza de que deseja excluir este post?')) return;
      try {
        await api.delete(`/posts/${postId}`);
        this.posts = this.posts.filter((post) => post.id !== postId);
        alert('Post excluído com sucesso!');
      } catch (error) {
        console.error('Erro ao excluir post:', error);
        alert('Não foi possível excluir o post.');
      }
    },
    editPost(post) {
      this.post = { ...post };
      this.isEditing = true;
      window.scrollTo({ top: 0, behavior: 'smooth' }); 
    },
   
    cancelEdit() {
      this.resetForm();
    },
   
    async submitPost() {
      try {
        if (this.isEditing) {
          await api.put(`/posts/${this.post.id}`, {
            title: this.post.title,
            content: this.post.content,
          });
          alert('Post atualizado com sucesso!');
        } else {
          await api.post('/posts', {
            title: this.post.title,
            content: this.post.content,
          });
          alert('Post publicado com sucesso!');
        }
        this.resetForm();
        await this.fetchPosts(); 
      } catch (error) {
        console.error('Erro ao salvar o post:', error);
        alert('Não foi possível salvar o post. Verifique os dados e tente novamente.');
      }
    },
   
    resetForm() {
      this.post = {
        id: null,
        title: '',
        content: '',
      };
      this.isEditing = false;
    },
    
    logout() {
     
      localStorage.removeItem('token');
      eventBus.updateAuthentication(false);
      this.posts = [];
      this.resetForm();
      this.$router.push('/login');
      
      
      alert('Você foi deslogado com sucesso.');
    },
  },
};
</script>

<style scoped>

.logout-button {
  background-color: #f44336; 
  color: white;
  padding: 10px 20px;
  border: none;
  cursor: pointer;
  float: right;
  margin-bottom: 20px;
  border-radius: 4px;
}

.logout-button:hover {
  background-color: #d32f2f;
}

.post-form {
  border: 1px solid #ccc;
  padding: 20px;
  margin-bottom: 30px;
  border-radius: 4px;
  background-color: #f9f9f9;
}

.post-form h3 {
  margin-top: 0;
}

.post-form form div {
  margin-bottom: 15px;
}

.post-form label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
}

.post-form input[type="text"],
.post-form textarea {
  width: 100%;
  padding: 8px;
  box-sizing: border-box;
}

.post-form button {
  padding: 10px 15px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.post-form button[type="submit"] {
  background-color: #4caf50; 
  color: white;
}

.post-form button[type="submit"]:hover {
  background-color: #45a049;
}

.cancel-button {
  background-color: #9e9e9e; 
  color: white;
  margin-left: 10px;
}

.cancel-button:hover {
  background-color: #7e7e7e;
}

.post-actions {
  margin-top: 10px;
}

.edit-button {
  background-color: #2196f3; 
  color: white;
  padding: 5px 10px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  margin-right: 10px;
}

.edit-button:hover {
  background-color: #1976d2;
}

.delete-button {
  background-color: #f44336; 
  color: white;
  padding: 5px 10px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.delete-button:hover {
  background-color: #d32f2f;
}

.clearfix::after {
  content: "";
  clear: both;
  display: table;
}
</style>

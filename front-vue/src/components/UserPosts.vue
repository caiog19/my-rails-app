<template>
  <div>
    <h2>Meus Posts</h2>

    <!-- Botão para Logout -->
    <button @click="logout" class="logout-button">Logout</button>

    <!-- Lista de usuários para o administrador -->
    <div v-if="isAdmin" class="admin-section">
      <h3>Lista de Usuários</h3>
      <ul v-if="users && users.length">
        <li v-for="user in users" :key="user.id">
          <p>{{ user.full_name }} - {{ user.email }}</p>
          <button @click="deleteUser(user.id)" class="delete-button">Excluir Usuário</button>
        </li>
      </ul>
      <p v-else>Não há usuários cadastrados.</p>

      <!-- Controles de paginação -->
      <div v-if="users && users.length">
        <button @click="fetchUsers(currentPage - 1)" :disabled="currentPage === 1">Anterior</button>
        <button @click="fetchUsers(currentPage + 1)" :disabled="currentPage === totalPages">Próximo</button>
      </div>
    </div>

    <!-- Formulário e lista de posts -->
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

    <!-- Lista de posts -->
    <ul v-if="posts && posts.length">
      <li v-for="post in posts" :key="post.id">
        <h3>{{ post.title }}</h3>
        <p>{{ post.content }}</p>
        <div class="post-actions">
          <button
            v-if="isAdmin || post.user_id === currentUser.id"
            @click="deletePost(post.id)"
            class="delete-button"
          >
            Excluir
          </button>
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
      users: [], 
      post: {
        id: null,
        title: '',
        content: '',
      },
      currentUser: {}, 
      isEditing: false, 
      currentPage: 1, 
      totalPages: 1, 
      isAdmin: false, 
      loading: false, 
    };
  },
  async created() {
    await this.fetchCurrentUser(); 
    await this.fetchPosts(); 
    if (this.isAdmin) {
      await this.fetchUsers(); 
    }
  },
  methods: {
    async fetchCurrentUser() {
      const token = localStorage.getItem('token');
      try {
        const response = await api.get('/auth/me', {
          headers: { Authorization: `Bearer ${token}` },
        });
        this.currentUser = response.data.user;
        this.isAdmin = this.currentUser.admin;
      } catch (error) {
        console.error('Erro ao buscar informações do usuário:', error);
        this.currentUser = {};
        this.isAdmin = false;
      }
    },
    async fetchUsers(page = 1) {
      try {
        const response = await api.get('/users', { params: { page } });
        this.users = response.data.users || [];
        this.currentPage = response.data.meta.current_page || 1;
        this.totalPages = response.data.meta.total_pages || 1;
      } catch (error) {
        console.error('Erro ao buscar usuários:', error);
        this.users = [];
      }
    },
    async fetchPosts(page = 1) {
      this.loading = true;
      try {
        const response = await api.get('/meus-posts', { params: { page } });
        this.posts = response.data.posts || [];
        this.currentPage = response.data.meta.current_page || 1;
        this.totalPages = response.data.meta.total_pages || 1;
      } catch (error) {
        console.error('Erro ao buscar posts:', error);
        this.posts = [];
      } finally {
        this.loading = false;
      }
    },
    async deleteUser(userId) {
      if (!confirm('Tem certeza de que deseja excluir este usuário?')) return;
      try {
        await api.delete(`/users/${userId}`);
        this.users = this.users.filter((user) => user.id !== userId);
        alert('Usuário excluído com sucesso!');
      } catch (error) {
        console.error('Erro ao excluir usuário:', error);
        alert('Não foi possível excluir o usuário.');
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
      if (!this.post.title || !this.post.content) {
        alert('Título e conteúdo são obrigatórios.');
        return;
      }
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
        await this.fetchPosts(this.currentPage);
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

.loading-indicator {
  text-align: center;
  color: #888;
  margin-top: 20px;
}

.admin-section button {
  margin: 5px;
  padding: 8px 12px;
  border: 1px solid #ccc;
  background-color: #f9f9f9;
  cursor: pointer;
}

.admin-section button:hover {
  background-color: #e9e9e9;
}

.admin-section button:disabled {
  background-color: #f1f1f1;
  color: #aaa;
  cursor: not-allowed;
}

</style>

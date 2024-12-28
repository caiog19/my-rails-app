<template>
  <div>
    <h2>Meus Posts</h2>

    <!-- Botão para Logout -->
    <button @click="logout" class="logout-button">Logout</button>

    <!-- Formulário para criar ou editar posts -->
    <div class="post-form">
      <h3>{{ isEditing ? 'Editar Post' : 'Criar Novo Post' }}</h3>
      <form @submit.prevent="isEditing ? updatePost() : submitPost()">
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

    <!-- Lista de usuários para administradores -->
    <div v-if="isAdmin" class="admin-section">
      <h3>Lista de Usuários</h3>
      <ul v-if="users && users.length">
        <li v-for="user in users" :key="user.id">
          <p>{{ user.full_name }} - {{ user.email }}</p>
          <button @click="deleteUser(user.id)" class="delete-button">Excluir Usuário</button>
        </li>
      </ul>
      <p v-else>Não há usuários cadastrados.</p>

      <!-- Controles de paginação para usuários -->
      <div v-if="users && users.length" class="pagination">
        <button @click="fetchUsers(currentPageUsers - 1)" :disabled="currentPageUsers === 1">Anterior</button>
        <span>Página {{ currentPageUsers }} de {{ totalPagesUsers }}</span>
        <button @click="fetchUsers(currentPageUsers + 1)" :disabled="currentPageUsers === totalPagesUsers">Próximo</button>
      </div>
    </div>

    <!-- Lista de posts -->
    <ul v-if="posts && posts.length">
      <li v-for="post in posts" :key="post.id">
        <h3>{{ post.title }}</h3>
        <p>{{ post.content }}</p>
        <div class="post-actions">
          <button
            v-if="isAdmin || post.user_id === currentUser.id"
            @click="editPost(post)"
            class="edit-button"
          >
            Editar
          </button>
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

    <!-- Controles de paginação para posts -->
    <div v-if="posts && posts.length" class="pagination">
      <button @click="fetchPosts(currentPagePosts - 1)" :disabled="currentPagePosts === 1">Anterior</button>
      <span>Página {{ currentPagePosts }} de {{ totalPagesPosts }}</span>
      <button @click="fetchPosts(currentPagePosts + 1)" :disabled="currentPagePosts === totalPagesPosts">Próximo</button>
    </div>

    <div v-if="loading" class="loading-indicator">Carregando...</div>
  </div>

  <!-- Formulário para editar o cadastro -->
<div class="edit-profile-form">
  <h3>Editar Cadastro</h3>
  <form @submit.prevent="updateProfile">
    <div>
      <label for="fullName">Nome Completo:</label>
      <input v-model="profile.full_name" id="fullName" type="text" required />
    </div>
    <div>
      <label for="email">Email:</label>
      <input v-model="profile.email" id="email" type="email" required />
    </div>
    <div>
      <label for="password">Nova Senha:</label>
      <input v-model="profile.password" id="password" type="password" />
    </div>
    <div>
      <label for="passwordConfirmation">Confirme a Nova Senha:</label>
      <input v-model="profile.password_confirmation" id="passwordConfirmation" type="password" />
    </div>
    <button type="submit">Salvar Alterações</button>
  </form>
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
    profile: {
      full_name: '',
      email: '',
      password: '',
      password_confirmation: '',
    },
    currentUser: {},
    isEditing: false,
    currentPageUsers: 1,
    totalPagesUsers: 1,
    currentPagePosts: 1,
    totalPagesPosts: 1,
    isAdmin: false,
    loading: false,
  };
},
async created() {
  await this.fetchCurrentUser();
  this.loadProfile(); 
  await this.fetchPosts();
  if (this.isAdmin) {
    await this.fetchUsers();
  }
},
  methods: {
    loadProfile() {
    this.profile.full_name = this.currentUser.full_name || '';
    this.profile.email = this.currentUser.email || '';
  },
  async updateProfile() {
  try {
    await api.put('/auth/update-profile', {
      user: {
        full_name: this.profile.full_name,
        email: this.profile.email,
        password: this.profile.password,
        password_confirmation: this.profile.password_confirmation,
      },
    }, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('token')}`,
      },
    });
    alert('Perfil atualizado com sucesso!');
    // Optionally, reload the current user data
    await this.fetchCurrentUser();
  } catch (error) {
    console.error('Erro ao atualizar o perfil:', error);
    alert('Não foi possível atualizar o perfil.');
  }
},

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
      this.loading = true;
      try {
        const response = await api.get('/users', { params: { page } });
        this.users = response.data.users || [];
        this.currentPageUsers = response.data.meta.current_page || 1;
        this.totalPagesUsers = response.data.meta.total_pages || 1;
      } catch (error) {
        console.error('Erro ao buscar usuários:', error);
        this.users = [];
      } finally {
        this.loading = false;
      }
    },
    async fetchPosts(page = 1) {
      this.loading = true;
      try {
        const response = await api.get('/meus-posts', { params: { page } });
        this.posts = response.data.posts || [];
        this.currentPagePosts = response.data.meta.current_page || 1;
        this.totalPagesPosts = response.data.meta.total_pages || 1;
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
        const token = localStorage.getItem('token');
        await api.delete(`/users/${userId}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (this.users.length === 1 && this.currentPage > 1) {
          this.currentPage--;
        }
        await this.fetchUsers(this.currentPage);

        alert('Usuário excluído com sucesso!');
      } catch (error) {
        console.error('Erro ao excluir usuário:', error);
        alert('Não foi possível excluir o usuário.');
      }
    },
    async deletePost(postId) {
      if (!confirm('Tem certeza de que deseja excluir este post?')) return;
      try {
        const token = localStorage.getItem('token');
        await api.delete(`/posts/${postId}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (this.posts.length === 1 && this.currentPage > 1) {
          this.currentPage--;
        }
        await this.fetchPosts(this.currentPage);

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
    async updatePost() {
      if (!this.post.title || !this.post.content) {
        alert('Título e conteúdo são obrigatórios.');
        return;
      }
      try {
        const token = localStorage.getItem('token');
        await api.put(`/posts/${this.post.id}`, this.post, {
          headers: { Authorization: `Bearer ${token}` },
        });
        alert('Post atualizado com sucesso!');
        this.isEditing = false;
        this.resetForm();
        await this.fetchPosts(this.currentPagePosts);
      } catch (error) {
        console.error('Erro ao atualizar post:', error);
        alert('Não foi possível atualizar o post.');
      }
    },
    async submitPost() {
      if (!this.post.title || !this.post.content) {
        alert('Título e conteúdo são obrigatórios.');
        return;
      }
      try {
        await api.post('/posts', {
          title: this.post.title,
          content: this.post.content,
        });
        alert('Post publicado com sucesso!');
        this.resetForm();
        await this.fetchPosts(this.currentPagePosts);
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
      this.users = [];
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

.admin-section {
  margin-bottom: 40px;
}

.admin-section h3 {
  margin-bottom: 15px;
}

.admin-section ul {
  list-style-type: none;
  padding: 0;
}

.admin-section li {
  margin-bottom: 10px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.admin-section li p {
  margin: 0;
}

.admin-section .delete-button {
  padding: 5px 10px;
}

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 15px;
  margin-top: 20px;
}

.pagination button {
  background-color: #2196f3;
  color: white;
  padding: 5px 10px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.pagination button:disabled {
  background-color: #b0bec5;
  cursor: not-allowed;
}

.pagination span {
  font-size: 14px;
}
.edit-profile-form {
  border: 1px solid #ccc;
  padding: 20px;
  margin-bottom: 30px;
  border-radius: 4px;
  background-color: #f9f9f9;
}

.edit-profile-form h3 {
  margin-top: 0;
}

.edit-profile-form form div {
  margin-bottom: 15px;
}

.edit-profile-form label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
}

.edit-profile-form input {
  width: 100%;
  padding: 8px;
  box-sizing: border-box;
}

.edit-profile-form button {
  padding: 10px 15px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  background-color: #4caf50;
  color: white;
}

.edit-profile-form button:hover {
  background-color: #45a049;
}

</style>

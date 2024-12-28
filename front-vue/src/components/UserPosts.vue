<template>
  <div>
    <h2>Meus Posts</h2>

    <!-- Botão para Logout -->
    <button @click="logout" class="logout-button">Logout</button>

    <!-- Formulário para criar ou editar posts -->
    <div class="post-form">
      <h3>{{ isEditingPost ? 'Editar Post' : 'Criar Novo Post' }}</h3>
      <form @submit.prevent="isEditingPost ? updatePost() : submitPost()">
        <div>
          <label for="title">Título:</label>
          <input v-model="post.title" id="title" type="text" required />
        </div>
        <div>
          <label for="content">Conteúdo:</label>
          <textarea v-model="post.content" id="content" required></textarea>
        </div>
        <button type="submit">{{ isEditingPost ? 'Salvar Alterações' : 'Publicar Post' }}</button>
        <button type="button" v-if="isEditingPost" @click="cancelEditPost" class="cancel-button">Cancelar</button>
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

    <!-- Formulário para editar o cadastro -->
    <div class="edit-profile-form">
      <h3>Editar Cadastro</h3>
      
      <!-- Nome Completo -->
      <EditableField
        ref="editableFullName"
        label="Nome Completo"
        id="fullName"
        :value="profile.full_name"
        field="full_name"
        type="text"
        required
        @save="handleSave"
      />

      <!-- Email -->
      <EditableField
        ref="editableEmail"
        label="Email"
        id="email"
        :value="profile.email"
        field="email"
        type="email"
        required
        @save="handleSave"
      />

      <!-- Senha -->
      <EditableField
        ref="editablePassword"
        label="Nova Senha"
        id="password"
        :value="passwordPlaceholder"
        field="password"
        type="password"
        placeholder="Nova Senha"
        required
        @save="handleSave"
      />
    </div>
  </div>
</template>

<script>
import api from '../services/api';
import { eventBus } from '../eventBus';
import './BlogComponents.css';
import EditableField from './EditableField.vue'; // Importa o componente auxiliar

export default {
  name: 'UserPosts',
  components: {
    EditableField,
  },
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
      isEditingPost: false,
      currentPageUsers: 1,
      totalPagesUsers: 1,
      currentPagePosts: 1,
      totalPagesPosts: 1,
      isAdmin: false,
      loading: false,
      formErrors: {
        full_name: [],
        email: [],
        password: [],
      },
      passwordPlaceholder: '********', // Para esconder a senha no frontend
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
    // Método para lidar com a atualização de campos individuais
    async handleSave(payload) {
      try {
        await api.put('/auth/update-profile', payload, { // Enviar o payload completo com a chave 'user'
          headers: {
            Authorization: `Bearer ${localStorage.getItem('token')}`,
          },
        });
        alert('Perfil atualizado com sucesso!');
        await this.fetchCurrentUser();
        this.loadProfile();

        // Determinar qual campo foi atualizado para fechar o campo de edição correspondente
        const updatedField = Object.keys(payload.user)[0];
        // Mapeamento de campos para refs
        const fieldRefMap = {
          full_name: 'editableFullName',
          email: 'editableEmail',
          password: 'editablePassword',
        };
        const refName = fieldRefMap[updatedField];
        if (refName && this.$refs[refName]) {
          this.$refs[refName].closeEditing();
        }
      } catch (error) {
        console.error(`Erro ao atualizar campo:`, error);
        if (error.response && error.response.data && error.response.data.errors) {
          // Exibe erros específicos no frontend
          alert(`Erro(s) ao atualizar campo:\n${error.response.data.errors.join('\n')}`);
        } else {
          alert('Não foi possível atualizar campo.');
        }
      }
    },
    // Métodos de gerenciamento de posts
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
        if (this.users.length === 1 && this.currentPageUsers > 1) {
          this.currentPageUsers--;
        }
        await this.fetchUsers(this.currentPageUsers);
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
        if (this.posts.length === 1 && this.currentPagePosts > 1) {
          this.currentPagePosts--;
        }
        await this.fetchPosts(this.currentPagePosts);
        alert('Post excluído com sucesso!');
      } catch (error) {
        console.error('Erro ao excluir post:', error);
        alert('Não foi possível excluir o post.');
      }
    },

    editPost(post) {
      this.post = { ...post };
      this.isEditingPost = true;
      window.scrollTo({ top: 0, behavior: 'smooth' });
    },
    cancelEditPost() {
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
        this.isEditingPost = false;
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
      this.isEditingPost = false;
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


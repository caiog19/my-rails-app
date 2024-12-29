<template>
  <div>
    <h2>Meus Posts</h2>

    <button @click="logout" class="logout-button">Logout</button>

    <div class="tag-form">
      <h3>Criar Nova Tag</h3>
      <form @submit.prevent="createTag">
        <input
          v-model="newTagName"
          type="text"
          placeholder="Nome da Tag"
          required
        />
        <button type="submit">Criar Tag</button>
      </form>
    </div>

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

        <div>
          <label for="tags">Tags:</label>
          <select id="tags" v-model="post.tag_ids" multiple>
            <option v-for="tag in tags" :key="tag.id" :value="tag.id">
              {{ tag.name }}
            </option>
          </select>
          <p>Tags selecionadas: {{ post.tag_ids }}</p>
        </div>

        <button type="submit">
          {{ isEditingPost ? 'Salvar Alterações' : 'Publicar Post' }}
        </button>
        <button
          type="button"
          v-if="isEditingPost"
          @click="cancelEditPost"
          class="cancel-button"
        >
          Cancelar
        </button>
      </form>
    </div>

    <div v-if="isAdmin" class="admin-section">
      <h3>Lista de Usuários</h3>
      <ul v-if="users && users.length">
        <li v-for="user in users" :key="user.id">
          <p>{{ user.full_name }} - {{ user.email }}</p>
          <button @click="deleteUser(user.id)" class="delete-button">
            Excluir Usuário
          </button>
        </li>
      </ul>
      <p v-else>Não há usuários cadastrados.</p>

      <div v-if="users && users.length" class="pagination">
        <button
          @click="fetchUsers(currentPageUsers - 1)"
          :disabled="currentPageUsers === 1"
        >
          Anterior
        </button>
        <span>Página {{ currentPageUsers }} de {{ totalPagesUsers }}</span>
        <button
          @click="fetchUsers(currentPageUsers + 1)"
          :disabled="currentPageUsers === totalPagesUsers"
        >
          Próximo
        </button>
      </div>
    </div>

    <ul v-if="posts && posts.length">
      <li v-for="post in posts" :key="post.id">
        <h3>{{ post.title }}</h3>
        <p>{{ post.content }}</p>

        <div v-if="post.tags && post.tags.length">
          <strong>Tags:</strong>
          <ul>
            <li v-for="tag in post.tags" :key="tag.id">{{ tag.name }}</li>
          </ul>
        </div>

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

    <div v-if="posts && posts.length" class="pagination">
      <button
        @click="fetchPosts(currentPagePosts - 1)"
        :disabled="currentPagePosts === 1"
      >
        Anterior
      </button>
      <span>Página {{ currentPagePosts }} de {{ totalPagesPosts }}</span>
      <button
        @click="fetchPosts(currentPagePosts + 1)"
        :disabled="currentPagePosts === totalPagesPosts"
      >
        Próximo
      </button>
    </div>

    <div v-if="loading" class="loading-indicator">Carregando...</div>

    <div class="edit-profile-form">
      <h3>Editar Cadastro</h3>

      <div v-if="isAdmin || post.user_id === currentUser.id" class="info">Você é um admin, e não pode editar o seu cadastro</div>

      <EditableField
        ref="editableFullName"
        label="Nome Completo"
        id="fullName"
        :value="profile.full_name"
        field="full_name"
        type="text"
        required
        :is-admin="isAdmin"
        @save="handleSave"
      />

      <EditableField
        ref="editableEmail"
        label="Email"
        id="email"
        :value="profile.email"
        field="email"
        type="email"
        required
        :is-admin="isAdmin"
        @save="handleSave"
      />

      <EditableField
        ref="editablePassword"
        label="Nova Senha"
        id="password"
        :value="passwordPlaceholder"
        field="password"
        type="password"
        placeholder="Nova Senha"
        required
        :is-admin="isAdmin"
        @save="handleSave"
      />
    </div>
  </div>
</template>

<script>
import api from '../services/api';
import { eventBus } from '../eventBus';
import './BlogComponents.css';
import EditableField from './EditableField.vue';

export default {
  name: 'UserPosts',
  components: {
    EditableField,
  },
  data() {
    return {
      posts: [],
      users: [],
      tags: [],

      post: {
        id: null,
        title: '',
        content: '',
        tag_ids: [],
      },

      newTagName: '',

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

      passwordPlaceholder: '********',
    };
  },
  async created() {
    await this.fetchCurrentUser();
    await this.fetchTags();
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
        this.loadProfile();
      } catch (error) {
        console.error('Erro ao buscar informações do usuário:', error);
        this.currentUser = {};
        this.isAdmin = false;
      }
    },
    loadProfile() {
      this.profile.full_name = this.currentUser.full_name || '';
      this.profile.email = this.currentUser.email || '';
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

    async fetchTags() {
      try {
        const token = localStorage.getItem('token');
        const response = await api.get('/tags', {
          headers: { Authorization: `Bearer ${token}` },
        });
        this.tags = response.data;
      } catch (error) {
        console.error('Erro ao buscar tags:', error);
      }
    },

    async createTag() {
      if (!this.newTagName.trim()) {
        alert('O nome da tag não pode estar vazio.');
        return;
      }
      try {
        const token = localStorage.getItem('token');
        const response = await api.post(
          '/tags',
          { tag: { name: this.newTagName } },
          {
            headers: {
              Authorization: `Bearer ${token}`,
            },
          }
        );
        this.tags.push(response.data);
        this.newTagName = '';
        alert('Tag criada com sucesso!');
      } catch (error) {
        console.error('Erro ao criar tag:', error);
        alert(
          'Não foi possível criar a tag. Verifique se ela já existe ou tente novamente.'
        );
      }
    },

    async fetchPosts(page = 1) {
      this.loading = true;
      try {
        const token = localStorage.getItem('token');
        const response = await api.get('/meus-posts', {
          params: { page },
          headers: { Authorization: `Bearer ${token}` },
        });

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

    async handleSave(payload) {
      try {
        const token = localStorage.getItem('token');
        await api.put(
          '/auth/update-profile',
          { user: payload.user },
          {
            headers: { Authorization: `Bearer ${token}` },
          }
        );
        
        alert('Perfil atualizado com sucesso!');
        await this.fetchCurrentUser();
        this.loadProfile();
      } catch (error) {
        console.error('Erro ao salvar:', error);
        if (error.response?.data?.errors) {
          alert(`Erro: ${error.response.data.errors.join('\n')}`);
        } else {
          alert('Erro ao salvar os dados.');
        }
      }
    },

    editPost(post) {
      this.post = { ...post };
      if (!this.post.tag_ids) {
        this.post.tag_ids = [];
      }
      if (post.tags) {
        this.post.tag_ids = post.tags.map((t) => t.id);
      }

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
      console.log('DEBUG post antes de enviar:', this.post);
      if (!this.post.title || !this.post.content) {
        alert('Título e conteúdo são obrigatórios.');
        return;
      }
      try {
        const token = localStorage.getItem('token');
        await api.post('/posts', { post: this.post }, {
          headers: { Authorization: `Bearer ${token}` },
        });
        alert('Post publicado com sucesso!');
        this.resetForm();
        await this.fetchPosts(this.currentPagePosts);
      } catch (error) {
        console.error('Erro ao salvar o post:', error);
        alert('Não foi possível salvar o post. Verifique os dados e tente novamente.');
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

    resetForm() {
      this.post = {
        id: null,
        title: '',
        content: '',
        tag_ids: [],
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

<style>
.logout-button {
  margin-bottom: 20px;
}
.post-form {
  margin-bottom: 40px;
}
.tag-form {
  margin-bottom: 30px;
}
.cancel-button {
  margin-left: 10px;
  background-color: #f44336;
  color: white;
}
.cancel-button:hover {
  background-color: #d32f2f;
}
.delete-button {
  background-color: #f44336;
  color: white;
  margin-left: 10px;
}
.delete-button:hover {
  background-color: #d32f2f;
}
.edit-button {
  background-color: #2196f3;
  color: white;
}
.edit-button:hover {
  background-color: #1976d2;
}
.loading-indicator {
  margin-top: 20px;
  font-weight: bold;
}
.pagination {
  margin-top: 20px;
}
.edit-profile-form {
  margin-top: 40px;
  border-top: 1px solid #ccc;
  padding-top: 20px;
}
</style>

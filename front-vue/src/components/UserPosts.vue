<template>
  <div class="app-container">
    <div class="content">
      <h2 class="section-title">Meus Posts</h2>

      <div class="tag-form card">
        <h3>Criar Nova Tag</h3>
        <form @submit.prevent="createTag">
          <input v-model="newTagName" type="text" placeholder="Nome da Tag" required class="input-field" />
          <button type="submit" class="btn btn-primary">Criar Tag</button>
        </form>
      </div>

      <div class="post-form card">
        <h3>{{ isEditingPost ? 'Editar Post' : 'Criar Novo Post' }}</h3>
        <form @submit.prevent="isEditingPost ? updatePost() : submitPost()">
          <div class="form-group">
            <label for="title">Título:</label>
            <input v-model="post.title" id="title" type="text" required class="input-field" />
          </div>
          <div class="form-group">
            <label for="content">Conteúdo:</label>
            <textarea v-model="post.content" id="content" required class="input-field"></textarea>
          </div>

          <div class="form-group">
            <label for="tags">Tags:</label>
            <select id="tags" v-model="post.tag_ids" multiple class="input-field">
              <option v-for="tag in tags" :key="tag.id" :value="tag.id">
                {{ tag.name }}
              </option>
            </select>
            <p class="selected-tags">Tags selecionadas: {{ post.tag_ids }}</p>
          </div>

          <div class="form-actions">
            <button type="submit" class="btn btn-primary">
              {{ isEditingPost ? 'Salvar Alterações' : 'Publicar Post' }}
            </button>
            <button type="button" v-if="isEditingPost" @click="cancelEditPost" class="btn btn-secondary">
              Cancelar
            </button>
          </div>
        </form>
      </div>

      <div v-if="isAdmin" class="admin-section card">
        <h3>Lista de Usuários</h3>
        <ul v-if="users && users.length" class="user-list">
          <li v-for="user in users" :key="user.id" class="user-item">
            <div>
              <p class="user-name">{{ user.full_name }}</p>
              <p class="user-email">{{ user.email }}</p>
            </div>
            <button @click="deleteUser(user.id)" class="btn btn-danger">Excluir Usuário</button>
          </li>
        </ul>
        <p v-else class="no-users">Não há usuários cadastrados.</p>

        <div v-if="users && users.length" class="pagination">
          <button @click="fetchUsers(currentPageUsers - 1)" :disabled="currentPageUsers === 1"
            class="btn btn-pagination">
            Anterior
          </button>
          <span class="pagination-info">Página {{ currentPageUsers }} de {{ totalPagesUsers }}</span>
          <button @click="fetchUsers(currentPageUsers + 1)" :disabled="currentPageUsers === totalPagesUsers"
            class="btn btn-pagination">
            Próximo
          </button>
        </div>
      </div>

      <ul v-if="posts && posts.length" class="post-list">
        <li v-for="post in posts" :key="post.id" class="post-item card">
          <h3 class="post-title">{{ post.title }}</h3>
          <p class="post-content">{{ post.content }}</p>

          <div v-if="post.tags && post.tags.length" class="post-tags">
            <strong>Tags:</strong>
            <ul class="tag-list">
              <li v-for="tag in post.tags" :key="tag.id" class="tag-item">{{ tag.name }}</li>
            </ul>
          </div>

          <div class="post-actions">
            <button v-if="isAdmin || post.user_id === currentUser.id" @click="editPost(post)" class="btn btn-edit">
              Editar
            </button>
            <button v-if="isAdmin || post.user_id === currentUser.id" @click="deletePost(post.id)"
              class="btn btn-delete">
              Excluir
            </button>
          </div>
        </li>
      </ul>
      <p v-else class="no-posts">Você ainda não publicou nenhum post.</p>

      <div v-if="posts && posts.length" class="pagination">
        <button @click="fetchPosts(currentPagePosts - 1)" :disabled="currentPagePosts === 1" class="btn btn-pagination">
          Anterior
        </button>
        <span class="pagination-info">Página {{ currentPagePosts }} de {{ totalPagesPosts }}</span>
        <button @click="fetchPosts(currentPagePosts + 1)" :disabled="currentPagePosts === totalPagesPosts"
          class="btn btn-pagination">
          Próximo
        </button>
      </div>

      <div v-if="loading" class="loading-indicator">Carregando...</div>

      <div class="file-upload-form card">
        <h3>Upload de Arquivo para Criar Posts ou Tags</h3>
        <form @submit.prevent="uploadFile">
          <div class="form-group">
            <label for="file">Arquivo:</label>
            <input type="file" id="file" ref="fileInput" @change="selectFile" required class="input-field" />
          </div>
          <div class="form-group">
            <label for="resource_type">Tipo de Recurso:</label>
            <select id="resource_type" v-model="resourceType" required class="input-field">
              <option value="posts">Posts</option>
              <option value="tags">Tags</option>
            </select>
          </div>
          <button type="submit" class="btn btn-primary">Enviar Arquivo</button>
        </form>
      </div>

      <div class="edit-profile-form card">
        <h3>Editar Cadastro</h3>

        <div v-if="isAdmin || post.user_id === currentUser.id" class="info">
          Você é um admin, e não pode editar o seu cadastro
        </div>

        <EditableField ref="editableFullName" label="Nome Completo" id="fullName" :value="profile.full_name"
          field="full_name" type="text" required :is-admin="isAdmin" @save="handleSave" />

        <EditableField ref="editableEmail" label="Email" id="email" :value="profile.email" field="email" type="email"
          required :is-admin="isAdmin" @save="handleSave" />

        <EditableField ref="editablePassword" label="Nova Senha" id="password" :value="passwordPlaceholder"
          field="password" type="password" placeholder="Nova Senha" required :is-admin="isAdmin" @save="handleSave" />
      </div>
    </div>
  </div>
</template>

<script>
import api from '../services/api';
import { eventBus } from '../eventBus';
import '../styles/BlogUserPosts.css';
import EditableField from './EditableField.vue';

export default {
  name: 'UserPosts',
  components: {
    EditableField,
  },
  data() {
    return {
      selectedFile: null,
      resourceType: 'posts',
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
    selectFile(event) {
    this.selectedFile = event.target.files[0];
  },

  async uploadFile() {
    if (!this.selectedFile) {
      alert('Por favor, selecione um arquivo.');
      return;
    }

    const formData = new FormData();
    formData.append('file', this.selectedFile);
    formData.append('resource_type', this.resourceType);

    const token = localStorage.getItem('token');
    try {
      const response = await api.post('/file_uploads', formData, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'multipart/form-data',
        },
      });
      alert(response.data.message);
    } catch (error) {
      console.error('Erro ao enviar arquivo:', error);
      if (error.response && error.response.data.error) {
        alert(error.response.data.error);
      } else {
        alert('Não foi possível enviar o arquivo.');
      }
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

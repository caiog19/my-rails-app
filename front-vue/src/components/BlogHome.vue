<template>
  <div>
    <h1>Bem-vindo ao Blog</h1>
    <h2>Posts Recentes</h2>

    <ul v-if="posts.length">
      <li v-for="post in posts" :key="post.id">
        <h3>{{ post.title }}</h3>
        <p><small>Publicado por: {{ post.user_full_name }}</small></p>
        <p>{{ post.content }}</p>

        <div v-if="post.tags && post.tags.length">
          <p><strong>Tags:</strong></p>
          <ul>
            <li v-for="tag in post.tags" :key="tag.id">{{ tag.name }}</li>
          </ul>
        </div>

        <div v-if="currentUser && post.user_id === currentUser.id">
          <button @click="startEditPost(post)" class="edit-button">Editar</button>
        </div>
        <div v-if="isAdmin || (currentUser && post.user_id === currentUser.id)">
          <button @click="deletePost(post.id)" class="delete-button">Excluir</button>
        </div>

        <div v-if="isEditing && editingPostId === post.id" class="post-form">
          <h3>Editar Post</h3>
          <form @submit.prevent="updatePost">
            <div>
              <label for="title">Título:</label>
              <input v-model="editingPost.title" id="title" type="text" required />
            </div>
            <div>
              <label for="content">Conteúdo:</label>
              <textarea v-model="editingPost.content" id="content" required></textarea>
            </div>
            <button type="submit">Salvar Alterações</button>
            <button type="button" @click="cancelEdit" class="cancel-button">Cancelar</button>
          </form>
        </div>

        <div class="comments-section">
          <h4>Comentários</h4>
          <ul v-if="post.comments && post.comments.length">
            <li v-for="comment in post.comments" :key="comment.id">
              <p><strong>{{ comment.author_name }}</strong>: {{ comment.content }}</p>
            </li>
          </ul>
          <p v-else>Não há comentários ainda.</p>

          <form @submit.prevent="addComment(post.id)">
            <textarea v-model="newComments[post.id]" placeholder="Escreva um comentário..."></textarea>
            <button type="submit">Comentar</button>
          </form>
        </div>
      </li>
    </ul>

    <p v-else>Não há posts publicados ainda.</p>

    <div v-if="totalPages > 1" class="pagination">
      <button @click="fetchPosts(currentPage - 1)" :disabled="currentPage === 1">
        Anterior
      </button>
      <span>Página {{ currentPage }} de {{ totalPages }}</span>
      <button @click="fetchPosts(currentPage + 1)" :disabled="currentPage === totalPages">
        Próximo
      </button>
    </div>

    <div v-if="loading" class="loading-indicator">Carregando...</div>
  </div>
</template>

<script>
import api from '../services/api';

export default {
  name: 'BlogHome',
  data() {
    return {
      posts: [],
      currentPage: 1,
      totalPages: 1,
      loading: false,
      currentUser: null,
      isAdmin: false,
      isEditing: false,
      editingPostId: null,
      editingPost: {},
      newComments: {},
    };
  },
  async created() {
    await this.fetchCurrentUser();
    await this.fetchPosts(1);
  },
  methods: {
    async fetchCurrentUser() {
      const token = localStorage.getItem('token');
      if (!token) {
        this.currentUser = null;
        this.isAdmin = false;
        return;
      }
      try {
        const response = await api.get('/auth/me', {
          headers: { Authorization: `Bearer ${token}` },
        });
        this.currentUser = response.data.user;
        this.isAdmin = this.currentUser.admin;
      } catch (error) {
        console.error('Erro ao carregar informações do usuário:', error);
        this.currentUser = null;
        this.isAdmin = false;
      }
    },
    async fetchPosts(page) {
      this.loading = true;
      try {
        const response = await api.get('/posts', { params: { page } });
        const postsWithComments = await Promise.all(
          response.data.posts.map(async (post) => {
            const comments = await this.fetchComments(post.id);
            return { ...post, comments };
          })
        );
        this.posts = postsWithComments;
        this.currentPage = response.data.meta.current_page;
        this.totalPages = response.data.meta.total_pages;
      } catch (error) {
        console.error('Erro ao buscar posts:', error);
      } finally {
        this.loading = false;
      }
    },
    async fetchComments(postId) {
      try {
        const token = localStorage.getItem('token');
        const headers = token ? { Authorization: `Bearer ${token}` } : {};
        const response = await api.get(`/posts/${postId}/comments`, { headers });
        return response.data;
      } catch (error) {
        console.error(`Erro ao buscar comentários para o post ${postId}:`, error);
        return [];
      }
    },
    async addComment(postId) {
      const content = this.newComments[postId];
      if (!content || !content.trim()) {
        alert('O comentário não pode estar vazio.');
        return;
      }
      try {
        const token = localStorage.getItem('token');
        const headers = token ? { Authorization: `Bearer ${token}` } : {};
        const response = await api.post(
          `/posts/${postId}/comments`,
          { comment: { content } },
          { headers }
        );
        const postIndex = this.posts.findIndex((post) => post.id === postId);
        if (postIndex > -1) {
          this.posts[postIndex].comments.unshift(response.data);
        }
        this.newComments[postId] = '';
      } catch (error) {
        console.error(`Erro ao adicionar comentário para o post ${postId}:`, error);
        alert('Não foi possível adicionar o comentário.');
      }
    },
    startEditPost(post) {
      if (post.user_id !== this.currentUser.id) {
        alert('Você só pode editar seus próprios posts.');
        return;
      }
      this.isEditing = true;
      this.editingPostId = post.id;
      this.editingPost = { ...post }; 
    },
    async updatePost() {
      try {
        const token = localStorage.getItem('token');
        await api.put(`/posts/${this.editingPostId}`, this.editingPost, {
          headers: { Authorization: `Bearer ${token}` },
        });

        alert('Post atualizado com sucesso!');
        this.isEditing = false;
        this.editingPostId = null;
        this.editingPost = {};
        await this.fetchPosts(this.currentPage);
      } catch (error) {
        console.error('Erro ao atualizar post:', error);
        alert('Não foi possível atualizar o post.');
      }
    },
    cancelEdit() {
      this.isEditing = false;
      this.editingPostId = null;
      this.editingPost = {};
    },
    async deletePost(postId) {
      if (!confirm('Tem certeza de que deseja excluir este post?')) return;
      try {
        const token = localStorage.getItem('token');
        await api.delete(`/posts/${postId}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        alert('Post excluído com sucesso!');
        this.posts = this.posts.filter((post) => post.id !== postId);
        if (this.posts.length === 0) {
          if (this.currentPage > 1) {
            this.currentPage--;
          }
          await this.fetchPosts(this.currentPage);
        } else {
          await this.fetchPosts(this.currentPage);
        }
      } catch (error) {
        console.error('Erro ao excluir post:', error);
        alert('Não foi possível excluir o post.');
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

.loading-indicator {
  text-align: center;
  color: #888;
  margin-top: 20px;
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

.post-form {
  margin-top: 10px;
  border: 1px solid #ccc;
  padding: 10px;
  border-radius: 4px;
  background-color: #f9f9f9;
}

.comments-section {
  margin-top: 15px;
  border-top: 1px solid #ddd;
  padding-top: 10px;
}

.comments-section h4 {
  margin: 0 0 10px;
}

.comments-section ul {
  list-style-type: none;
  padding: 0;
}

.comments-section li {
  margin-bottom: 10px;
}

textarea {
  width: 100%;
  min-height: 50px;
  margin-bottom: 10px;
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
</style>

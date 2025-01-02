<template>
  <div class="home-container">
    <h1>Posts Recentes</h1>

    <div class="search-container">
      <input v-model="searchQuery" type="text" placeholder="Busque por título, conteúdo ou tag..."
        class="search-input" />
    </div>



    <ul class="post-list" v-if="posts.length">
      <li class="post-item" v-for="post in posts" :key="post.id">
        <h3>{{ post.title }}</h3>
        <p><small>Publicado por: {{ post.user_full_name }}</small></p>
        <p>{{ post.content }}</p>

        <div class="post-tags" v-if="post.tags && post.tags.length">
          <p><strong>Tags:</strong></p>
          <ul>
            <li v-for="tag in post.tags" :key="tag.id">{{ tag.name }}</li>
          </ul>
        </div>

        <div class="button-group" v-if="currentUser && post.user_id === currentUser.id">
          <button @click="startEditPost(post)" class="edit-button">Editar</button>
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
          <ul class="comments-list" v-if="post.comments && post.comments.length">
            <li v-for="comment in post.comments" :key="comment.id">
              <p>
                <strong>{{ comment.author_name }}</strong>:
                <span v-if="comment.hidden && isAdmin">[Comentário oculto]</span>
                <span v-else>{{ comment.content }}</span>
              </p>
              <div v-if="isAdmin">
                <button v-if="!comment.hidden" @click="hideComment(post.id, comment.id)"
                  class="hide-button">Ocultar</button>
                <button v-else @click="revealComment(post.id, comment.id)" class="reveal-button">Revelar</button>
              </div>
            </li>
          </ul>

          <p v-else>Não há comentários ainda.</p>

          <div class="container-admin">
            <form @submit.prevent="addComment(post.id)" class="comment-form">
              <textarea v-model="newComments[post.id]" placeholder="Escreva um comentário..."></textarea>
              <button type="submit" class="post-button">Comentar</button>
            </form>
            <button v-if="isAdmin || (currentUser && post.user_id === currentUser.id)" @click="deletePost(post.id)"
              class="delete-button">Excluir Post</button>
          </div>


        </div>
      </li>
    </ul>

    <p v-else>Não há posts publicados ainda.</p>

    <div class="pagination" v-if="totalPages > 1">
      <button @click="fetchPosts(currentPage - 1)" :disabled="currentPage === 1">
        Anterior
      </button>
      <span>Página {{ currentPage }} de {{ totalPages }}</span>
      <button @click="fetchPosts(currentPage + 1)" :disabled="currentPage === totalPages">
        Próximo
      </button>
    </div>

    <div class="loading-indicator" v-if="loading">Carregando...</div>
  </div>
</template>

<script>
import api from '../services/api';
import '../styles/BlogHome.css';
import _ from 'lodash';

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
      searchQuery: '',
    };
  },
  async created() {
    await this.fetchCurrentUser();
    await this.fetchPosts(1);
  },
  methods: {

    async hideComment(postId, commentId) {
      if (!confirm('Tem certeza de que deseja ocultar este comentário?')) return;
      try {
        const token = localStorage.getItem('token');
        await api.patch(`/posts/${postId}/comments/${commentId}/hide`, {}, {
          headers: { Authorization: `Bearer ${token}` },
        });
        // Atualizar o comentário localmente
        const postIndex = this.posts.findIndex(post => post.id === postId);
        if (postIndex !== -1) {
          const commentIndex = this.posts[postIndex].comments.findIndex(c => c.id === commentId);
          if (commentIndex !== -1) {
            this.posts[postIndex].comments[commentIndex].hidden = true;
            this.posts[postIndex].comments[commentIndex].content = 'Este comentário está oculto.';

          }
        }
      } catch (error) {
        console.error('Erro ao ocultar comentário:', error);
        alert('Não foi possível ocultar o comentário.');
      }
    },

    async revealComment(postId, commentId) {
      if (!confirm('Tem certeza de que deseja revelar este comentário?')) return;
      try {
        const token = localStorage.getItem('token');
        await api.patch(`/posts/${postId}/comments/${commentId}/reveal`, {}, {
          headers: { Authorization: `Bearer ${token}` },
        });
        // Atualizar o comentário localmente
        const postIndex = this.posts.findIndex(post => post.id === postId);
        if (postIndex !== -1) {
          const commentIndex = this.posts[postIndex].comments.findIndex(c => c.id === commentId);
          if (commentIndex !== -1) {
            this.posts[postIndex].comments[commentIndex].hidden = false;
            await this.fetchPosts(this.currentPage);
          }
        }
      } catch (error) {
        console.error('Erro ao revelar comentário:', error);
        alert('Não foi possível revelar o comentário.');
      }
    },


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
    async search() {
      await this.fetchPosts(1, this.searchQuery);
    },

    async fetchPosts(page, searchQuery = '') {
    this.loading = true;
    try {
      const token = localStorage.getItem('token');
      const headers = token ? { Authorization: `Bearer ${token}` } : {};

      const response = await api.get('/posts', { 
        params: { page, query: searchQuery || this.searchQuery },
        headers 
      });
      this.posts = response.data.posts;
      this.currentPage = response.data.meta.current_page;
      this.totalPages = response.data.meta.total_pages;
    } catch (error) {
      console.error('Erro ao buscar posts:', error);
    } finally {
      this.loading = false;
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
    debounceSearch: _.debounce(function (query) {
      this.fetchPosts(1, query);
    }, 300),
  },
  watch: {
    searchQuery: {
      handler(newQuery) {
        this.debounceSearch(newQuery);
      },
      immediate: true,
    },
  },
};
</script>

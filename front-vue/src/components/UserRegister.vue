<template>
  <div>
    <h2>Cadastrar</h2>
    <form @submit.prevent="register">
      <div>
        <label for="fullName">Nome Completo:</label>
        <input
          v-model="user.full_name"
          id="fullName"
          type="text"
          :class="{ 'is-invalid': getError('full_name') }"
        />
        <p v-if="getError('full_name')" class="error-message">
          {{ getError('full_name') }}
        </p>
      </div>
      <div>
        <label for="email">Email:</label>
        <input
          v-model="user.email"
          id="email"
          type="email"
          :class="{ 'is-invalid': getError('email') }"
        />
        <p v-if="getError('email')" class="error-message">
          {{ getError('email') }}
        </p>
      </div>
      <div>
        <label for="password">Senha:</label>
        <input
          v-model="user.password"
          id="password"
          type="password"
          :class="{ 'is-invalid': getError('password') }"
        />
        <p v-if="getError('password')" class="error-message">
          {{ getError('password') }}
        </p>
      </div>
      <div>
        <label for="passwordConfirmation">Confirme a Senha:</label>
        <input
          v-model="user.password_confirmation"
          id="passwordConfirmation"
          type="password"
          :class="{ 'is-invalid': getError('password_confirmation') }"
        />
        <p v-if="getError('password_confirmation')" class="error-message">
          {{ getError('password_confirmation') }}
        </p>
      </div>
      <button type="submit">Cadastrar</button>
    </form>
  </div>
</template>

<script>
import api from '../services/api';

export default {
  name: 'UserRegister',
  data() {
    return {
      user: {
        full_name: '',
        email: '',
        password: '',
        password_confirmation: '',
      },
      errors: [],
    };
  },
  methods: {
    
    async register() {
    this.errors = []; 

    // Validações locais
    if (!this.user.full_name) {
      this.errors.push({ field: 'full_name', message: 'Nome Completo não pode estar vazio' });
    }
    if (!this.user.email) {
      this.errors.push({ field: 'email', message: 'Email não pode estar vazio' });
    }
    if (this.user.password.length < 8) {
      this.errors.push({ field: 'password', message: 'Senha deve ter no mínimo 8 caracteres' });
    }
    if (this.user.password !== this.user.password_confirmation) {
      this.errors.push({ field: 'password_confirmation', message: 'Confirmação de Senha não coincide' });
    }

    // Se houver erros locais, exiba-os e não envie a requisição
    if (this.errors.length) {
      return;
    }

      try {
        const response = await api.post('/signup', { user: this.user });
        alert(response.data.message);
        this.$router.push('/login');
      } catch (error) {
        if (error.response && error.response.data && error.response.data.errors) {
          this.errors = error.response.data.errors; 
        } else {
          alert('Erro ao cadastrar: algo deu errado.');
          console.error(error);
        }
      }
    },
    getError(field) {
      const error = this.errors.find((e) => e.field === field);
      return error ? error.message : null;
    },
  },
};
</script>

<style>
.error-message {
  color: red;
  font-size: 0.9rem;
  margin-top: 5px;
}

.is-invalid {
  border-color: red;
}
</style>

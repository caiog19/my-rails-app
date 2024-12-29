<template>
  <div class="editable-field">
    <label :for="id">{{ label }}:</label>
    <div v-if="!isEditing" class="display-mode">
      <span>{{ displayValue }}</span>
      <button @click="enableEdit" class="alterar-button">Alterar</button>
    </div>
    <div v-else class="edit-mode">
      <template v-if="field === 'password'">
        <div class="password-fields">
          <div class="password-field">
            <input
              v-model="editableValue"
              :id="id + '_new'"
              type="password"
              placeholder="Nova Senha"
              required
            />
          </div>
          <div class="password-field">
            <input
              v-model="passwordConfirmation"
              type="password"
              placeholder="Confirme a Nova Senha"
              required
            />
          </div>
          <div class="password-field">
            <input
              v-model="currentPassword"
              type="password"
              placeholder="Senha Atual"
              required
            />
          </div>
        </div>
      </template>
      <template v-else>
        <div class="standard-fields">
          <input
            v-model="editableValue"
            :id="id"
            :type="type"
            :placeholder="placeholder"
            :required="required"
          />
          <input
            v-model="currentPassword"
            type="password"
            placeholder="Senha Atual"
            required
          />
        </div>
      </template>

      <div class="action-buttons">
        <button @click="save" class="salvar-button" :disabled="isLoading">
          {{ isLoading ? 'Salvando...' : 'Salvar' }}
        </button>
        <button @click="cancel" class="cancelar-button">Cancelar</button>
      </div>

      <div v-if="errors.length" class="error-messages">
        <ul>
          <li v-for="error in errors" :key="error">{{ error }}</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EditableField',
  props: {
    label: {
      type: String,
      required: true,
    },
    id: {
      type: String,
      required: true,
    },
    value: {
      type: [String, Number],
      required: true,
    },
    field: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      default: 'text',
    },
    placeholder: {
      type: String,
      default: '',
    },
    required: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      isEditing: false,
      editableValue: this.value,   
      currentPassword: '',
      passwordConfirmation: '',
      errors: [],
      isLoading: false,
    };
  },
  computed: {
    displayValue() {
      
      if (this.field === 'password') {
        return '********';
      }
      return this.value;
    },
  },
  watch: {
   
    value(newVal) {
      if (!this.isEditing) {
        this.editableValue = newVal;
      }
    },
  },
  methods: {
    enableEdit() {
      this.isEditing = true;
    },
    cancel() {
      this.isEditing = false;
      this.editableValue = this.value;
      this.currentPassword = '';
      this.passwordConfirmation = '';
      this.errors = [];
    },

    async save() {
      this.isLoading = true;
      this.errors = [];
      let payload = {
        user: {},
      };

      if (this.field === 'password') {
        payload.user.password = this.editableValue;
        payload.user.password_confirmation = this.passwordConfirmation;
        payload.user.current_password = this.currentPassword;
      } else {
        payload.user[this.field] = this.editableValue;
        payload.user.current_password = this.currentPassword;
      }

      try {
        await this.$emit('save', payload);
        this.closeEditing();
      } catch (error) {
        console.error('Erro ao salvar:', error);
        this.errors.push('Não foi possível salvar os dados.');
      } finally {
        this.isLoading = false;
      }
    },

    closeEditing() {
      this.isEditing = false;
      this.editableValue = this.value;
      this.currentPassword = '';
      this.passwordConfirmation = '';
      this.errors = [];
    },
    setErrors(errors) {
      this.errors = errors;
    },
  },
};
</script>

<style scoped>
.editable-field {
  margin-bottom: 20px;
}

.editable-field label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
}

.display-mode {
  display: flex;
  align-items: center;
}

.display-mode span {
  margin-right: 10px;
}

.edit-mode {
  display: flex;
  flex-direction: column;
}

.password-fields,
.standard-fields {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.password-fields {
  margin-bottom: 10px;
}

.password-field,
.standard-fields input {
  flex: 1;
  min-width: 200px;
}

.action-buttons {
  margin-top: 10px;
  display: flex;
  gap: 10px;
}

.alterar-button,
.salvar-button,
.cancelar-button {
  padding: 8px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  flex-shrink: 0;
}

.alterar-button {
  background-color: #2196f3;
  color: white;
}

.alterar-button:hover {
  background-color: #1976d2;
}

.salvar-button {
  background-color: #4caf50;
  color: white;
}

.salvar-button:hover {
  background-color: #45a049;
}

.cancelar-button {
  background-color: #f44336;
  color: white;
}

.cancelar-button:hover {
  background-color: #d32f2f;
}

.error-messages {
  color: red;
  margin-top: 10px;
}

.error-messages ul {
  padding-left: 20px;
}

.error-messages li {
  list-style-type: disc;
}
</style>

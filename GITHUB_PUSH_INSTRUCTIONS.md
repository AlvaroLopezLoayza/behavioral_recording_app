# Instrucciones: Subir Código a GitHub

## 🔍 Situación Actual

- ✅ Repositorio GitHub creado: https://github.com/AlvaroLopezLoayza/behavioral_recording_app
- ✅ Commit local listo (998dfac)
- ✅ Remote configurado correctamente
- ⚠️ **Push bloqueado por autenticación**

El repositorio es **privado**, por lo que requiere autenticación para hacer push.

---

## 📋 Métodos de Autenticación

### Opción 1: Personal Access Token (Recomendado)

1. **Crear Token**:
   - Ve a https://github.com/settings/tokens
   - Click "Generate new token" → "Generate new token (classic)"
   - Nombre: `behavioral_recording_app_token`
   - Scopes: Marca `repo` (full control of private repositories)
   - Click "Generate token"
   - **COPIA EL TOKEN** (solo se muestra una vez)

2. **Usar Token para Push**:
   ```bash
   cd d:\DEV\PERSONAL\behavioral_recording_app
   git push -u origin main
   ```
   
   Cuando solicite credenciales:
   - Username: `AlvaroLopezLoayza`
   - Password: **PEGA TU TOKEN** (no tu contraseña de GitHub)

3. Windows guardará las credenciales automáticamente para futuros push.

---

### Opción 2: GitHub CLI

Si tienes `gh` instalado:

```bash
cd d:\DEV\PERSONAL\behavioral_recording_app
gh auth login
gh auth setup-git
git push -u origin main
```

Para instalar GitHub CLI:
```bash
winget install GitHub.cli
```

---

### Opción 3: GitHub Desktop (GUI)

1. Descarga GitHub Desktop: https://desktop.github.com/
2. Abre GitHub Desktop
3. File → Add Local Repository
4. Selecciona: `d:\DEV\PERSONAL\behavioral_recording_app`
5. Click "Publish repository" o "Push origin"

---

## ✅ Verificar Push Exitoso

Después del push, verifica en:
https://github.com/AlvaroLopezLoayza/behavioral_recording_app

Deberías ver:
- ✅ README.md
- ✅ pubspec.yaml
- ✅ Estructura de carpetas lib/
- ✅ Commit inicial visible

---

## 🚀 Próximos Pasos Después del Push

Una vez subido el código:

1. **Configurar Supabase**:
   - Crear proyecto en https://supabase.com
   - Ejecutar migraciones SQL
   - Configurar Row Level Security

2. **Implementar Features**:
   - Core error handling
   - Behavior Definition feature
   - ABC Recording feature
   - Authentication

3. **Testing**:
   - Unit tests
   - Integration tests
   - Manual testing

---

## 📌 Comando Recomendado

**Opción más simple** (requiere crear token primero):

```bash
cd d:\DEV\PERSONAL\behavioral_recording_app
git push -u origin main
```

Cuando pida credenciales, usa tu username y el **token** como password.

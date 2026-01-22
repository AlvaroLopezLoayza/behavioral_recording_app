# 🚨 Error de Autenticación - Solución

## Problema Detectado

Git está usando credenciales cacheadas de la cuenta **ALOPEZ555**, pero el repositorio pertenece a **AlvaroLopezLoayza**.

Error: `Permission to AlvaroLopezLoayza/behavioral_recording_app.git denied to ALOPEZ555`

---

## ✅ Solución: Limpiar Credenciales (Windows)

### Método 1: Administrador de Credenciales (Más Fácil)

1. Presiona `Win + R`, escribe `control` y presiona Enter
2. Busca y abre **"Administrador de credenciales"** (Credential Manager)
3. Click en **"Credenciales de Windows"**
4. Busca entradas que digan:
   - `git:https://github.com`
   - O cualquier entrada relacionada con GitHub
5. Click en cada una → **"Quitar"** / **"Remove"**

### Método 2: Comando PowerShell

Ejecuta en PowerShell como Administrador:

```powershell
cmdkey /list | Select-String github | ForEach-Object { cmdkey /delete:($_ -replace ".*Target: ", "") }
```

---

## 🔑 Después de Limpiar Credenciales

### Opción A: Push con Token (Recomendado)

1. **Crear Personal Access Token**:
   - Ve a: https://github.com/settings/tokens
   - Click "Generate new token" → "Generate new token (classic)"
   - Nombre: `behavioral_app_token`
   - Selecciona scope: `repo` ✓
   - Click "Generate token"
   - **COPIA EL TOKEN** (solo se muestra una vez)

2. **Hacer Push**:
   ```bash
   cd d:\DEV\PERSONAL\behavioral_recording_app
   git push -u origin main
   ```

3. **Cuando pida credenciales**:
   - Username: `AlvaroLopezLoayza`
   - Password: **PEGA TU TOKEN** (Ctrl+V)

Windows guardará estas credenciales para futuros push.

### Opción B: GitHub Desktop (Sin Terminal)

1. Descarga e instala: https://desktop.github.com/
2. Inicia sesión con tu cuenta `AlvaroLopezLoayza`
3. File → Add Local Repository → Selecciona `d:\DEV\PERSONAL\behavioral_recording_app`
4. Click "Publish repository" o "Push origin"

---

## ⚡ Comandos Exactos a Ejecutar

```bash
# 1. Ve al directorio del proyecto
cd d:\DEV\PERSONAL\behavioral_recording_app

# 2. Verifica el remote (debe mostrar https://github.com/AlvaroLopezLoayza/behavioral_recording_app)
git remote -v

# 3. Haz push (pedirá credenciales la primera vez)
git push -u origin main
```

---

## ✅ Verificar Éxito

Después del push exitoso, verifica en:
**https://github.com/AlvaroLopezLoayza/behavioral_recording_app**

Deberías ver:
- ✓ 150+ archivos
- ✓ README.md visible
- ✓ Carpeta `lib/` con estructura Clean Architecture
- ✓ Commit inicial con mensaje completo

---

## 🆘 Si Continúa Fallando

Si después de limpiar credenciales sigue fallando, verifica:

1. **¿Eres el dueño del repositorio?**
   - Ve a https://github.com/AlvaroLopezLoayza/behavioral_recording_app/settings
   - Si no puedes acceder, solicita acceso al dueño

2. **¿El repositorio es público?**
   - Debe decir "Public" en la página del repo
   - Si dice "Private", cámbialo en Settings

3. **Usa SSH en lugar de HTTPS**:
   ```bash
   git remote set-url origin git@github.com:AlvaroLopezLoayza/behavioral_recording_app.git
   git push -u origin main
   ```
   (Requiere configurar SSH keys primero)

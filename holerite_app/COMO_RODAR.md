# Como Rodar o App

## Pré-requisitos
- Flutter SDK instalado (https://docs.flutter.dev/get-started/install)
- Android Studio ou VS Code com extensão Flutter
- Dispositivo Android ou emulador

## Passos

### 1. Criar o projeto Flutter base
```bash
# Na pasta pai do projeto
flutter create holerite_app_base --org com.pedroaugusto --project-name holerite_app
```

### 2. Copiar os arquivos do código
Substitua a pasta `lib/` e o `pubspec.yaml` pelo conteúdo deste repositório.

### 3. Instalar dependências
```bash
cd holerite_app
flutter pub get
```

### 4. Configurar a API (IMPORTANTE)
Abra `lib/core/api/api_client.dart` e ajuste os endpoints reais.

**Como descobrir os endpoints:**
1. Abra o Chrome e acesse fitcard.app.questorpublico.com.br
2. Pressione F12 → aba "Network"
3. Faça login e navegue pelos holerites
4. Capture as URLs, headers e formato das respostas
5. Atualize `ApiConfig` com as informações corretas

### 5. Rodar
```bash
flutter run
```

## Funcionalidades
- Login com usuário/senha ou token direto
- Dashboard com resumo financeiro
- Lista de todos os holerites com download de PDF
- Visualizador de PDF integrado
- Gráficos de evolução salarial (mensal e anual)
- Comparativo entre anos
- Sync automático em background (verifica novos holerites 2x/dia)
- Notificação push quando novo holerite disponível
- Cache offline dos PDFs baixados
- Compartilhamento de PDF

## Estrutura do Projeto
```
lib/
├── main.dart                    # Entrada + splash screen
├── core/
│   ├── api/api_client.dart      # ← CONFIGURE OS ENDPOINTS AQUI
│   ├── models/holerite.dart     # Modelos de dados
│   ├── services/
│   │   ├── auth_service.dart    # Autenticação
│   │   ├── holerite_service.dart # Busca e download
│   │   ├── holerite_provider.dart # State management
│   │   └── notification_service.dart # Notificações + WorkManager
│   └── theme/app_theme.dart     # Tema dark azul
├── features/
│   ├── auth/login_screen.dart   # Tela de login
│   ├── home/home_screen.dart    # Navegação principal
│   ├── dashboard/               # Dashboard com resumo
│   ├── holerites/               # Lista + visualizador PDF
│   ├── charts/                  # Gráficos fl_chart
│   └── profile/                 # Perfil + configurações
└── shared/widgets/              # Componentes reutilizáveis
```

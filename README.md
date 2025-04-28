# Desafio MiniTok

Este projeto é um desafio para o MiniTok, desenvolvido com Flutter. Uma aplicação de gerenciamento de arquivos com autenticação e capacidade de compartilhamento.

## Sumário

- [Início Rápido](#início-rápido)
- [Especificações Técnicas](#especificações-técnicas)
- [Funcionalidades Principais](#funcionalidades-principais)
- [Arquitetura](#arquitetura)
  - [Visão Geral](#visão-geral)
  - [Estrutura de Pastas](#estrutura-de-pastas)
  - [Detalhamento das Camadas](#detalhamento-das-camadas)
  - [Fluxo de Dados](#fluxo-de-dados)
  - [Injeção de Dependência](#injeção-de-dependência)
- [Executando o Projeto](#executando-o-projeto)
- [Testes](#testes)
- [Configuração do Firebase](#configuração-do-firebase)
- [Tempo de Desenvolvimento](#tempo-de-desenvolvimento)
- [Desafios e Soluções](#desafios-e-soluções)

## Início Rápido

Para começar a usar o MiniTok rapidamente:

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/minitok.git
cd minitok

# Instale as dependências
flutter pub get

# Execute o aplicativo (certifique-se de ter um emulador rodando ou dispositivo conectado)
flutter run
```

Requisitos prévios:
- Flutter 3.27.1
- Projeto configurado no Firebase (Authentication e Storage)
- Arquivo de configuração do Firebase nas pastas corretas

## Especificações Técnicas

- **Flutter**: 3.27.1
- **Arquitetura**: Clean Architecture
- **Metodologia**: SOLID, DRY, KISS
- **Desenvolvimento**: TDD (Test-driven development)
- **Gerenciamento de Estado**: BLoC Pattern
- **Injeção de Dependências**: get_it

## Funcionalidades Principais

### Autenticação
- Autenticação via e-mail utilizando Firebase Authentication
- Login e registro de usuários
- Persistência de sessão

### Gerenciamento de Arquivos
- Tela de listagem de arquivos com pré-visualização
- Upload de novos arquivos via câmera ou galeria
- Download de arquivos para armazenamento local
- Compartilhamento de arquivos com outros aplicativos

### Padrões de Projeto
O projeto implementa o padrão Adapter para desacoplar dependências externas:
- firebase_auth
- firebase_storage
- image_picker
- file_picker
- share_plus

## Arquitetura

### Visão Geral

O MiniTok é construído seguindo princípios de Clean Architecture, que separa o código em camadas com diferentes níveis de abstração:

![Clean Architecture](https://blog.cleancoder.com/uncle-bob/images/2012-08-13-the-clean-architecture/CleanArchitecture.jpg)

Os principais benefícios desta arquitetura são:

1. **Independência de frameworks**: A lógica de negócio não depende de bibliotecas externas
2. **Testabilidade**: Facilidade para escrever testes unitários
3. **Independência da UI**: A interface pode mudar sem afetar o restante do sistema
4. **Independência de banco de dados**: A camada de dados é isolada
5. **Escalabilidade**: Facilita o crescimento do projeto mantendo a qualidade

### Estrutura de Pastas

```
lib/
├── core/                     # Utilitários e componentes compartilhados
│   ├── error/                # Tratamento de erros
│   ├── usecases/             # Interfaces base para casos de uso
│   ├── network/              # Configuração de rede e conectividade
│   └── utils/                # Funções utilitárias
│
├── domain/                   # Camada de Domínio
│   ├── entities/             # Modelos puros de domínio
│   │   ├── user.dart         # Entidade de usuário
│   │   └── file_item.dart    # Entidade de arquivo
│   ├── repositories/         # Interfaces de repositórios
│   │   ├── auth_repository.dart
│   │   └── file_repository.dart
│   └── usecases/             # Casos de uso da aplicação
│       ├── auth/
│       │   ├── sign_in.dart
│       │   └── sign_out.dart
│       └── files/
│           ├── get_files.dart
│           ├── upload_file.dart
│           └── share_file.dart
│
├── data/                     # Camada de Dados
│   ├── models/               # Implementações concretas das entidades
│   │   ├── user_model.dart
│   │   └── file_model.dart
│   ├── repositories/         # Implementações dos repositórios
│   │   ├── auth_repository_impl.dart
│   │   └── file_repository_impl.dart
│   └── datasources/          
│       ├── firebase_auth_service.dart
│       ├── firebase_storage_service.dart
│
├── infra/                    # Camada de Infraestrutura
│   └── adapters/             # Adaptadores para libs externas
│       ├── firebase_auth_adapter.dart
│       ├── firebase_storage_adapter.dart
│       ├── image_picker_adapter.dart
│       ├── file_picker_adapter.dart
│       └── share_adapter.dart
│
└── presentation/            # Camada de Apresentação
    ├── pages/               # Telas da aplicação
    │   ├── auth/
    │   │   ├── login_page.dart
    │   │   └── signup_page.dart
    │   └── files/
    │       ├── file_list_page.dart
    │       └── file_detail_page.dart
    ├── widgets/             # Widgets reutilizáveis
    │   ├── file_card.dart
    │   └── loading_indicator.dart
    ├── bloc/                # Gerenciamento de estado (usando BLoC)
    │   ├── auth/
    │   │   ├── auth_bloc.dart
    │   │   ├── auth_event.dart
    │   │   └── auth_state.dart
    │   └── files/
    │       ├── files_bloc.dart
    │       ├── files_event.dart
    │       └── files_state.dart
    └── routes/              # Rotas da aplicação
        └── app_router.dart
```

### Detalhamento das Camadas

#### 1. Camada de Domínio (Domain Layer)
Camada mais interna, contém a lógica de negócio central e é completamente independente de frameworks externos:
- **Entities**: Modelos de dados puros sem dependências externas que representam os conceitos fundamentais da aplicação
- **Repositories**: Interfaces que definem contratos para acesso a dados, sem implementação concreta
- **Usecases**: Casos de uso que encapsulam operações específicas do negócio e orquestram o fluxo de dados entre entidades e repositórios

#### 2. Camada de Dados (Data Layer)
Implementa os contratos definidos na camada de domínio e gerencia as fontes de dados:
- **Models**: Extensões das entidades que adicionam funcionalidades como serialização/deserialização
- **Repositories**: Implementações concretas das interfaces definidas no domínio
- **Datasources**: Interfaces e implementações para acesso a dados remotos (API, Firebase) e locais (cache, banco de dados)

#### 3. Camada de Infraestrutura (Infra Layer)
Fornece implementações técnicas para frameworks e serviços externos:
- **Adapters**: Implementa o padrão Adapter para encapsular bibliotecas de terceiros, permitindo sua substituição sem afetar as camadas superiores
- **Services**: Implementações de serviços específicos de infraestrutura

#### 4. Camada de Apresentação (Presentation Layer)
Gerencia a UI e interação com o usuário:
- **Pages**: Telas completas da aplicação
- **Widgets**: Componentes reutilizáveis da UI
- **Bloc**: Implementação do padrão BLoC para gerenciamento de estado, separando:
  - **Events**: Eventos disparados pela UI
  - **States**: Estados possíveis da UI
  - **Bloc**: Classe que processa eventos e emite estados
- **Routes**: Configuração de navegação

### Fluxo de Dados

O fluxo de dados na aplicação segue um padrão unidirecional:

1. **Interação do Usuário**: O usuário interage com a UI (Presentation Layer)
2. **Disparo de Eventos**: A UI dispara eventos que são captados pelo BLoC
3. **Processamento dos Eventos**: O BLoC processa os eventos e chama os casos de uso apropriados
4. **Execução da Lógica de Negócio**: Os casos de uso executam a lógica de negócio utilizando os repositórios
5. **Acesso a Dados**: Os repositórios acessam os dados através de datasources e adaptadores
6. **Retorno de Resultados**: Os dados seguem o caminho inverso até chegarem à UI
7. **Atualização da UI**: O BLoC emite um novo estado e a UI é atualizada

Este fluxo unidirecional facilita o rastreamento de problemas, melhora a testabilidade e mantém a separação de responsabilidades.

### Injeção de Dependência

O MiniTok utiliza a biblioteca **get_it** para injeção de dependências, o que proporciona:

- **Desacoplamento**: As classes não precisam conhecer a implementação de suas dependências
- **Facilidade de testes**: As dependências podem ser facilmente substituídas por mocks durante os testes
- **Configuração centralizada**: Todas as dependências são configuradas em um único lugar

Exemplo de configuração:

```dart
final getIt = GetIt.instance;

void setupDependencies() {
  // Adapters
  getIt.registerLazySingleton<FirebaseAuthAdapter>(() => FirebaseAuthAdapterImpl());
  getIt.registerLazySingleton<FirebaseStorageAdapter>(() => FirebaseStorageAdapterImpl());
  
  // Datasources
  getIt.registerLazySingleton<AuthDatasource>(() => AuthDatasourceImpl(getIt()));
  getIt.registerLazySingleton<FileDatasource>(() => FileDatasourceImpl(getIt()));
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()));
  getIt.registerLazySingleton<FileRepository>(() => FileRepositoryImpl(getIt()));
  
  // Usecases
  getIt.registerLazySingleton(() => SignInUsecase(getIt()));
  getIt.registerLazySingleton(() => GetFilesUsecase(getIt()));
  
  // BLoCs
  getIt.registerFactory(() => AuthBloc(getIt(), getIt()));
  getIt.registerFactory(() => FilesBloc(getIt(), getIt(), getIt()));
}
```

## Executando o Projeto

1. Certifique-se de ter o Flutter 3.27.1 instalado
2. Clone este repositório
3. Execute `flutter pub get` para instalar as dependências
4. Configure o Firebase no projeto
5. Execute `flutter run` para iniciar a aplicação

## Testes

Este projeto segue os princípios de TDD (Test-Driven Development) com testes unitários.

Execute `flutter test` para rodar todos os testes.

### Estrutura de Testes

```
test/
├── domain/
│   ├── usecases/           # Testes de casos de uso
│   └── repositories/       # Testes de repositórios
├── data/
│   ├── models/             # Testes de modelos
│   └── repositories/       # Testes de implementações de repositórios  
├── infra/
│   └── adapters/           # Testes de adaptadores
```

### Configuração Manual (se necessário)

Se precisar configurar manualmente, siga estes passos:

1. Acesse o [Console do Firebase](https://console.firebase.google.com)
2. Crie um novo projeto ou selecione um existente
3. Adicione os apps iOS e Android:
   - Para iOS: Bundle ID = `com.minitok.example`
   - Para Android: Package name = `com.minitok.example`
4. Baixe e adicione os arquivos de configuração manualmente:
   - `google-services.json` em `android/app/`
   - `GoogleService-Info.plist` em `ios/Runner/`

### Verificando a Instalação

Execute o seguinte comando para verificar se tudo está configurado corretamente:

```bash
flutter run
```

Se encontrar problemas, verifique:
- Se todos os arquivos de configuração estão nos locais corretos
- Se as dependências do Firebase estão atualizadas no `pubspec.yaml`
- Se o projeto está corretamente registrado no Console do Firebase

## Tempo de Desenvolvimento

Tempo total estimado: 3 dias

### Distribuição do Tempo
- **Dia 1**: Setup inicial, configuração do Firebase e implementação da arquitetura base
- **Dia 2**: Desenvolvimento das features principais (auth e upload/download de arquivos)
- **Dia 3**: Implementação dos testes, refinamentos e documentação

## Desafios e Soluções

### 1. Arquitetura e Organização
- **Desafio**: Implementação do Clean Architecture mantendo a separação clara entre camadas
- **Solução**: Definição rigorosa de responsabilidades para cada camada e uso de interfaces para garantir o desacoplamento

### 2. Gerenciamento de Estado
- **Desafio**: Implementação do BLoC pattern de forma eficiente
- **Solução**: Estruturação clara de eventos e estados, com testes extensivos para garantir o comportamento correto em diferentes cenários

### 3. Firebase Integration
- **Desafio**: Configuração segura do Firebase mantendo as chaves protegidas
- **Solução**: Implementação de adaptadores para isolar o código do Firebase e uso de variáveis de ambiente para chaves sensíveis

### 4. Testes
- **Desafio**: Implementação de testes seguindo TDD
- **Solução**: Uso de mocks para simular dependências externas e foco em testar o comportamento em vez de implementações

### 5. Performance
- **Desafio**: Otimização do upload/download de arquivos
- **Solução**: Implementação de caching e processamento assíncrono para evitar bloqueios na UI durante operações com arquivos

# Desafio MiniTok

Este projeto é um desafio para o MiniTok, desenvolvido com Flutter.

## Especificações Técnicas

- **Flutter**: 3.27.1
- **Arquitetura**: Clean Architecture
- **Metodologia**: SOLID, DRY, KISS
- **Desenvolvimento**: TDD (Test-driven development)

## Funcionalidades Principais

### Autenticação
- Autenticação via e-mail utilizando Firebase

### Gerenciamento de Arquivos
- Tela de listagem de arquivos (pré-visualização/download/compartilhamento).
- Botão para upload de arquivos.
- Funcionalidade de compartilhamento é um extra e diferencial.

### Padrões de Projeto
Uso de Adapters para:
- firebase_auth
- firebase_storage
- image_picker
- file_picker
- share_plus

## Estrutura do Projeto

O projeto segue uma arquitetura limpa (Clean Architecture) com separação clara de responsabilidades:

### Visão Geral da Estrutura de Pastas

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
Contém regras de negócio da aplicação, independente de qualquer framework externo:
- **Entities**: Modelos de dados puros sem dependências externas
- **Repositories**: Interfaces que definem operações de dados necessárias
- **Usecases**: Casos de uso que encapsulam a lógica de negócio específica

#### 2. Camada de Dados (Data Layer)
Implementação concreta dos repositórios definidos na camada de domínio:
- **Models**: Implementações das entidades que podem incluir serialização
- **Repositories**: Implementações concretas dos repositórios
- **Datasources**: Fontes de dados locais e remotas

#### 3. Camada de Infraestrutura (Infra Layer)
Implementações técnicas e adaptadores para bibliotecas externas:
- **Adapters**: Padrão adaptador para encapsular bibliotecas de terceiros como Firebase, evitando dependência direta

#### 4. Camada de Apresentação (Presentation Layer)
Interface com o usuário e gerenciamento de estado:
- **Pages**: Telas da aplicação
- **Widgets**: Componentes reutilizáveis da UI
- **Bloc**: Gerenciamento de estado usando o padrão BLoC
- **Routes**: Gerenciamento de navegação

### Fluxo de Dados

1. UI dispara eventos (Presentation)
2. Eventos são processados pelo gerenciador de estado (BLoC)
3. BLoC executa casos de uso apropriados (Domain)
4. Casos de uso interagem com repositórios (Domain -> Data)
5. Repositórios acessam fontes de dados através de adaptadores (Data -> Infra)
6. Resultados seguem o caminho inverso até a UI

### Princípios de Injeção de Dependência

O projeto utiliza injeção de dependência para garantir baixo acoplamento:
- **get_it**: Para registro e resolução de dependências

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

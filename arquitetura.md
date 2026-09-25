# Arquitetura do Poti App

Este documento explica como o código em `lib/` está organizado e traz um passo a passo para criar novas páginas no mesmo padrão.

- **Parte 1 — Documentação conceitual:** camadas, responsabilidades e fluxo de dados.
- **Parte 2 — Manual prático:** como criar uma página nova, com código completo.
- **Parte 3 — Histórico de ajustes:** divergências que foram corrigidas e pontos que ainda estão em aberto.

---

## Parte 1 — Documentação conceitual

### 1.1 Stack

| Item | Uso no projeto |
|---|---|
| Flutter (Material 3) | UI. Tema definido em `main.dart` com `ColorScheme.fromSeed` e fonte `Nunito`. |
| `flutter_riverpod` ^3 | Gerência de estado e injeção de dependências (providers). |
| `go_router` ^18 | Navegação declarativa por rotas nomeadas. |

### 1.2 Visão geral das pastas

```
lib/
├── main.dart                      # Ponto de entrada: ProviderScope + MaterialApp.router
└── src/
    ├── routing/
    │   └── app_router.dart        # Todas as rotas do app (GoRouter)
    ├── core/                      # Código compartilhado, sem regra de negócio
    │   └── ui/
    │       ├── theme/
    │       │   ├── app_colors.dart        # Paleta central (tokens de cor)
    │       │   ├── app_text_styles.dart   # Estilos de texto reutilizáveis
    │       │   └── app_decorations.dart   # Decorações reutilizáveis (card padrão)
    │       ├── pages/
    │       │   └── em_construcao_screen.dart  # Tela provisória para rotas do menu sem feature
    │       └── widgets/
    │           ├── app_scaffold.dart      # Esqueleto padrão das telas logadas
    │           ├── app_drawer.dart        # Menu lateral (lê o usuário logado)
    │           └── drawer_menu_item.dart  # Item "pílula" do menu
    └── features/                  # Uma pasta por funcionalidade
        ├── auth/                  # Sessão global (usuário logado)
        ├── splash/                # Tela de abertura
        ├── login/                 # Login (feature de referência, com todas as camadas)
        └── home/                  # Tela inicial (dashboard), com todas as camadas
```

Fontes ficam em `assets/fonts/` e são declaradas no `pubspec.yaml` (família `Nunito`, pesos 400 a 800). O tema global aplica essa família, então **não repita `fontFamily` nos widgets**.

### 1.3 Organização por feature (feature-first)

Cada funcionalidade fica em `lib/src/features/<nome_da_feature>/` e é dividida em camadas. As features **login** (fluxo de ação) e **home** (tela de consulta) têm todas as camadas. A login é a **referência oficial** mostrada abaixo; a home segue a mesma estrutura, com `application/home_controller.dart`, `data/` e `domain/repositories/`:

```
features/login/
├── domain/                        # O QUE o negócio é (Dart puro, sem Flutter)
│   └── repositories/
│       └── login_repository.dart          # Contrato abstrato
├── data/                          # DE ONDE os dados vêm
│   ├── data_sources/
│   │   └── login_remote_data_source.dart  # Chamada externa (API/mock)
│   ├── dtos/
│   │   └── user_dto.dart                  # Formato da API + fromJson + toDomain()
│   └── repository/
│       └── login_repository_impl.dart     # Implementa o contrato: DTO → model
├── application/                   # COMO o caso de uso acontece
│   └── login_controller.dart              # Notifier + todos os providers da feature
└── ui/                            # COMO aparece na tela
    ├── pages/
    │   └── login_screen.dart              # Tela ligada a uma rota
    ├── states/
    │   └── login_state.dart               # Estados possíveis da tela
    └── widgets/
        └── login_form.dart                # Partes visuais da tela
```

### 1.4 Responsabilidade de cada camada

| Camada | Pasta | Responsabilidade | Pode importar | Não pode importar |
|---|---|---|---|---|
| **Domain: models** | `domain/models/` | Entidades de negócio imutáveis (`final`, construtor `const`). Enums de status ficam no mesmo arquivo. | Nada (Dart puro) | Flutter, Riverpod, DTOs |
| **Domain: repositories** | `domain/repositories/` | `abstract class` com o contrato de acesso a dados. Trabalha só com models. | `domain/models` | `data/` |
| **Data: data sources** | `data/data_sources/` | O **único** lugar que sabe que existe uma API. Faz a chamada e devolve DTO. Hoje simula com `Future.delayed`. | `data/dtos` | `domain`, UI |
| **Data: DTOs** | `data/dtos/` | Espelha o JSON da API (`fromJson`, nomes em `snake_case` no mapa) e converte com `toDomain()`. | `domain/models` | UI |
| **Data: repository impl** | `data/repository/` | `implements` o contrato. Chama o data source e converte DTO em model. | `domain`, `data_sources` | UI, controllers |
| **Application** | `application/` | `Notifier` com a lógica do caso de uso: muda o estado (loading → sucesso/erro) e fala com outros controllers (ex.: `AuthController`). **Também declara os providers da feature.** | `domain`, `data`, `ui/states`, outras features `application` | Widgets, `BuildContext` |
| **UI: states** | `ui/states/` | Classes que descrevem o que a tela pode mostrar. | `domain/models` | Flutter |
| **UI: pages** | `ui/pages/` | Widget ligado a uma rota. Observa o controller, reage a eventos (`ref.listen`) e monta o layout. | `application`, `ui/states`, `ui/widgets`, `core` | `data/` direto |
| **UI: widgets** | `ui/widgets/` | Blocos visuais da tela. De preferência `StatelessWidget` que recebem dados por parâmetro. | `domain/models`, `core`, `application` (só formulários) | `data/` |

### 1.5 Fluxo de dependências

As setas mostram "quem conhece quem". O domínio fica no centro e não conhece ninguém:

```
          ┌──────────────── UI ─────────────────┐
          │  pages ──► widgets                  │
          │    │                                │
          │    ▼ ref.watch / ref.listen / read  │
          └────┼────────────────────────────────┘
               ▼
        application (Notifier + providers)
               │ ref.read(repositoryProvider)
               ▼
   domain/repositories (abstract)  ◄── implements ──  data/repository (impl)
               │                                          │
               ▼                                          ▼
         domain/models  ◄────── toDomain() ─────── data/dtos ◄── data_sources (API)
```

### 1.6 Fluxo de execução real (login → home)

1. `main.dart` envolve o app em `ProviderScope` e usa `MaterialApp.router(routerConfig: appRouter)`.
2. `appRouter` começa em `/splash`. `SplashScreen` roda a animação e, depois de 3,5 s, chama `context.go('/login')`.
3. O `LoginForm` chama `ref.read(loginControllerProvider.notifier).entrar(...)`.
4. `LoginController.entrar`:
   - `state = LoginLoading()` → o formulário desabilita os campos e mostra o spinner;
   - `_repository.login()` → `LoginDataSource.login()` devolve um `UserDto` → o repositório converte para `User`;
   - `ref.read(authControllerProvider.notifier).definirUsuario(user)` → a sessão passa a ser responsabilidade do `AuthController`;
   - `state = LoginSuccess(user)`, ou `LoginError(msg)` se der erro.
5. `LoginScreen` usa `ref.listen` para reagir a eventos: com `LoginSuccess` chama `context.goNamed('home')`; com `LoginError` mostra um SnackBar.
6. `HomeScreen` usa `AppScaffold`, que coloca o `AppDrawer`. O drawer lê o `authControllerProvider` para mostrar nome e foto.
7. No botão "Sair" do drawer: `AuthController.logout()`, depois `context.goNamed('login')`.

### 1.7 Gerência de estado (Riverpod 3)

**Padrão atual: `Notifier` + `NotifierProvider`** (a API moderna, sem o import `legacy.dart`).

```dart
class XController extends Notifier<XState> {
  @override
  XState build() => const XInitial();   // estado inicial
  // métodos públicos mudam `state`; `ref` já vem herdado
}

final xControllerProvider =
    NotifierProvider<XController, XState>(XController.new);
```

**Providers ficam no fim do arquivo do controller**, separados por um banner `// ====`, nesta ordem: data source → repository → controller. O repository recebe o data source por `ref.watch`, e é isso que permite trocar o mock pela API real (ou por um fake em testes) sem mexer no controller.

**Dois formatos de estado são usados:**

| Formato | Quando usar | Exemplo |
|---|---|---|
| `sealed class` com subclasses (`Initial`, `Loading`, `Success`, `Error`) | Telas de **ação/fluxo**: submeter algo, depois navegar ou mostrar erro. | `login_state.dart` |
| Classe única com `isLoading`, `errorMessage`, listas e `copyWith` | Telas de **consulta/dashboard** com vários blocos de dados ao mesmo tempo. | `home_state.dart` |

**Como a UI consome o estado:**

- `ref.watch(provider)` dentro do `build` para redesenhar;
- `ref.listen(provider, (prev, next) {...})` para efeitos colaterais (navegar, SnackBar). Nunca navegue dentro do `build`;
- `ref.read(provider.notifier).metodo()` em callbacks (`onPressed`).

**Estado global de sessão:** `authControllerProvider` (`features/auth/application/auth_controller.dart`) é a **única fonte de verdade** sobre quem está logado. As features só chamam `definirUsuario` e `logout`, e leem o `User?`.

### 1.8 Navegação (go_router)

- Todas as rotas ficam em `lib/src/routing/app_router.dart`.
- Toda rota tem `path` e `name`. As telas navegam por nome (`context.goNamed('home')`). O drawer navega por path (`context.go(entrada.rota)`).
- `go` substitui a pilha (usado entre fluxos: splash → login → home e no logout).
- Uma transição customizada usa `pageBuilder` + `CustomTransitionPage` (exemplo: `/login` sobe de baixo para cima).

### 1.9 UI compartilhada (`core/ui`)

| Arquivo | O que oferece |
|---|---|
| `AppScaffold` | Esqueleto das telas logadas: botão de menu, `actions` à direita, título grande (26px, Nunito) e `body` expandido até a borda inferior. Parâmetros: `titulo`, `body`, `rotaAtual`, `mostrarMenu`, `actions`, `floatingActionButton`, `backgroundColor`. |
| `AppDrawer` | Menu lateral com foto, saudação, itens e botão Sair. Os itens ficam na lista `_entradas`. `rotaAtual` marca o item ativo e evita navegar para a própria tela. |
| `DrawerMenuItem` | Item em formato de pílula (ativo/inativo). |
| `AppColors` | Paleta: `primary` `0xFF0F4C5C`, `accent` `0xFF4BA3B8`, `background` `rgb(210,221,225)`, `surface`, `surfaceMuted` `0xFFF2F2F7`, `borderAccent`, `buttonPrimary`, `cardBorder`, `cardShadow`, `tableRowEven/Odd`, `statusConfirmed/Pending/Canceled`, `error`, `textPrimary`, `textSecondary`, `textHint` etc. **Nenhuma cor em hexadecimal fora deste arquivo.** |
| `AppTextStyles` | `pageTitle`, `sectionTitle`, `sectionSubtitle`, `formLabel`, `formHint`, `buttonLabel` e os estilos do drawer. Novos estilos reutilizáveis entram aqui. |
| `AppDecorations` | `card`: o card branco padrão (raio 12, borda e sombra). |
| `EmConstrucaoScreen` | Tela provisória (`titulo`, `rotaAtual`) usada no router para os itens do menu que ainda não têm feature. |

**Padrão visual das telas logadas** (tirado da Home):

- fundo do `AppScaffold`: `AppColors.background` (azul-acinzentado);
- corpo: container `AppColors.surfaceMuted` com cantos superiores de 30 (`ClipRRect`) e `SingleChildScrollView`;
- títulos de seção: centralizados, `AppTextStyles.sectionTitle`, com subtítulo `AppTextStyles.sectionSubtitle` em CAIXA ALTA (na Home, o widget interno `_TituloSecao`);
- cards: `decoration: AppDecorations.card`, margem horizontal 16 e 12 entre cards;
- listas dentro do scroll: `ListView.builder` com `shrinkWrap: true` + `NeverScrollableScrollPhysics`.

### 1.10 Convenções de nomes

| Elemento | Convenção | Exemplos |
|---|---|---|
| Arquivos | `snake_case` com sufixo do papel | `*_screen.dart`, `*_controller.dart`, `*_state.dart`, `*_model.dart`, `*_dto.dart`, `*_repository.dart`, `*_repository_impl.dart`, `*_remote_data_source.dart`, `*_widget.dart` |
| Classes | `PascalCase` com o mesmo sufixo | `LoginScreen`, `HomeController`, `UserDto`, `EvolutionModel` |
| Providers | `camelCase` + `Provider` | `loginControllerProvider`, `loginRepositoryProvider` |
| Métodos de controller e parâmetros de widgets do core | **Português** | `entrar`, `resetar`, `definirUsuario`, `titulo`, `rotaAtual`, `mostrarMenu` |
| Campos de models e DTOs | Inglês | `patient`, `appointmentType`, `status` |
| Métodos privados de UI | `_build...`, `_get...`, `_ao...` | `_buildBody`, `_getStatusColor`, `_aoTocarItem` |
| Widgets internos de um arquivo | Classe privada `_Nome`, no fim do arquivo, depois de um banner `// ===` | `_CabecalhoUsuario`, `_BotaoSair` |
| Imports | Relativos dentro de `lib/`; pacotes primeiro, locais depois, separados por uma linha em branco | — |

---

## Parte 2 — Manual prático: criando uma nova página

Exemplo usado: a tela **Agenda** (`/agenda`). Ela já aparece no `AppDrawer`, mas a rota ainda não existe. Troque `agenda`/`Agenda` pelo nome da sua feature.

### Passo 0 — Estrutura de pastas

```
lib/src/features/agenda/
├── domain/
│   ├── models/agenda_item_model.dart
│   └── repositories/agenda_repository.dart
├── data/
│   ├── data_sources/agenda_remote_data_source.dart
│   ├── dtos/agenda_item_dto.dart
│   └── repository/agenda_repository_impl.dart
├── application/
│   └── agenda_controller.dart
└── ui/
    ├── pages/agenda_screen.dart
    ├── states/agenda_state.dart
    └── widgets/agenda_list_widget.dart
```

> Uma tela **só visual**, sem dados (como a Splash), precisa apenas de `ui/pages/`. Crie as outras camadas quando surgir o primeiro dado.

### Passo 1 — Model de domínio

`domain/models/agenda_item_model.dart`

```dart
enum AgendaStatus { confirmed, pending, canceled }

class AgendaItemModel {
  final String id;
  final String patient;
  final String date;
  final String time;
  final String appointmentType;
  final AgendaStatus status;

  const AgendaItemModel({
    required this.id,
    required this.patient,
    required this.date,
    required this.time,
    required this.appointmentType,
    required this.status,
  });
}
```

Regras: Dart puro, campos `final`, construtor `const`, enums de status no mesmo arquivo.

### Passo 2 — Contrato do repositório

`domain/repositories/agenda_repository.dart`

```dart
import '../models/agenda_item_model.dart';

/// Contrato do repositório de agenda.
/// A camada de aplicação depende desta abstração, não da implementação.
abstract class AgendaRepository {
  Future<List<AgendaItemModel>> buscarAgenda();
}
```

### Passo 3 — DTO

`data/dtos/agenda_item_dto.dart`

```dart
import '../../domain/models/agenda_item_model.dart';

/// Representa os dados exatamente como a API envia
/// e sabe se converter para o model do domínio.
class AgendaItemDto {
  final String id;
  final String patientName;
  final String date;
  final String time;
  final String type;
  final String status;

  AgendaItemDto({
    required this.id,
    required this.patientName,
    required this.date,
    required this.time,
    required this.type,
    required this.status,
  });

  // JSON → DTO
  factory AgendaItemDto.fromJson(Map<String, dynamic> json) {
    return AgendaItemDto(
      id: json['id'],
      patientName: json['patient_name'],
      date: json['date'],
      time: json['time'],
      type: json['type'],
      status: json['status'],
    );
  }

  // DTO → Model de domínio
  AgendaItemModel toDomain() {
    return AgendaItemModel(
      id: id,
      patient: patientName,
      date: date,
      time: time,
      appointmentType: type,
      status: switch (status) {
        'confirmed' => AgendaStatus.confirmed,
        'canceled' => AgendaStatus.canceled,
        _ => AgendaStatus.pending,
      },
    );
  }
}
```

### Passo 4 — Data source

`data/data_sources/agenda_remote_data_source.dart`

```dart
import '../dtos/agenda_item_dto.dart';

/// Responsabilidade: fazer a chamada externa real (HTTP, GraphQL, etc.).
/// É o único lugar que "sabe" que existe uma API.
class AgendaDataSource {
  // Simula uma chamada de API com delay de 1 segundo.
  Future<List<AgendaItemDto>> buscarAgenda() async {
    await Future.delayed(const Duration(seconds: 1));

    final json = [
      {'id': '1', 'patient_name': 'Jorge Silva', 'date': '13/02', 'time': '13:30', 'type': 'Avaliação', 'status': 'confirmed'},
      {'id': '2', 'patient_name': 'Jonas Santos', 'date': '13/02', 'time': '15:00', 'type': 'Tratamento da dor', 'status': 'pending'},
    ];

    return json.map(AgendaItemDto.fromJson).toList();
  }
}
```

> Os **mocks ficam aqui**, nunca no controller. Quando a API existir, só este arquivo muda.

### Passo 5 — Implementação do repositório

`data/repository/agenda_repository_impl.dart`

```dart
import '../../domain/models/agenda_item_model.dart';
import '../../domain/repositories/agenda_repository.dart';
import '../data_sources/agenda_remote_data_source.dart';

/// Responsabilidade: fazer a ponte entre dados (DTO) e negócio (model).
class AgendaRepositoryImpl implements AgendaRepository {
  final AgendaDataSource _dataSource;

  AgendaRepositoryImpl(this._dataSource);

  @override
  Future<List<AgendaItemModel>> buscarAgenda() async {
    final dtos = await _dataSource.buscarAgenda();
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}
```

### Passo 6 — Estado da tela

Escolha o formato conforme a tabela da seção 1.7. A Agenda é uma tela de consulta, então usa o formato com `copyWith`:

`ui/states/agenda_state.dart`

```dart
import '../../domain/models/agenda_item_model.dart';

class AgendaState {
  final bool isLoading;
  final String? errorMessage;
  final List<AgendaItemModel> items;

  const AgendaState({
    this.isLoading = false,
    this.errorMessage,
    this.items = const [],
  });

  AgendaState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<AgendaItemModel>? items,
  }) {
    return AgendaState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      items: items ?? this.items,
    );
  }
}
```

Para uma tela de ação (formulário que salva e navega), use o formato `sealed`, igual ao `login_state.dart`:

```dart
sealed class NovoPacienteState { const NovoPacienteState(); }
class NovoPacienteInitial extends NovoPacienteState { const NovoPacienteInitial(); }
class NovoPacienteLoading extends NovoPacienteState { const NovoPacienteLoading(); }
class NovoPacienteSuccess extends NovoPacienteState { const NovoPacienteSuccess(); }
class NovoPacienteError extends NovoPacienteState {
  final String message;
  const NovoPacienteError(this.message);
}
```

### Passo 7 — Controller e providers

`application/agenda_controller.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/data_sources/agenda_remote_data_source.dart';
import '../data/repository/agenda_repository_impl.dart';
import '../domain/repositories/agenda_repository.dart';
import '../ui/states/agenda_state.dart';

class AgendaController extends Notifier<AgendaState> {
  AgendaRepository get _repository => ref.read(agendaRepositoryProvider);

  // Inicialização do estado vai no build().
  // O carregamento é agendado porque não se pode alterar `state` durante o build.
  @override
  AgendaState build() {
    Future.microtask(carregar);
    return const AgendaState(isLoading: true);
  }

  Future<void> carregar() async {
    state = state.copyWith(isLoading: true);

    try {
      final items = await _repository.buscarAgenda();
      // Estado novo: garante que um erro anterior seja limpo
      state = AgendaState(items: items);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

// ============================================================
// Providers
// ============================================================

final agendaDataSourceProvider =
    Provider<AgendaDataSource>((ref) => AgendaDataSource());

final agendaRepositoryProvider = Provider<AgendaRepository>((ref) {
  return AgendaRepositoryImpl(ref.watch(agendaDataSourceProvider));
});

final agendaControllerProvider =
    NotifierProvider<AgendaController, AgendaState>(AgendaController.new);
```

Regras:
- Use `Notifier` do `flutter_riverpod.dart`, **não** `StateNotifier` do `legacy.dart`.
- O controller recebe o **contrato** (`AgendaRepository`), nunca a implementação.
- Para usar o usuário logado, chame `ref.read(authControllerProvider)` (import `../../auth/application/auth_controller.dart`).

### Passo 8 — Widgets da tela

`ui/widgets/agenda_list_widget.dart`

```dart
import 'package:flutter/material.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_decorations.dart';
import '../../domain/models/agenda_item_model.dart';

class AgendaListWidget extends StatelessWidget {
  final List<AgendaItemModel> items;

  const AgendaListWidget({super.key, required this.items});

  Color _getStatusColor(AgendaStatus status) {
    switch (status) {
      case AgendaStatus.confirmed:
        return AppColors.statusConfirmed;
      case AgendaStatus.pending:
        return AppColors.statusPending;
      case AgendaStatus.canceled:
        return AppColors.statusCanceled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.card,
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    item.date,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    item.time,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.patient,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      item.appointmentType,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.circle, size: 12, color: _getStatusColor(item.status)),
            ],
          ),
        );
      },
    );
  }
}
```

Regras: `StatelessWidget`, dados chegam **por parâmetro** (o widget não lê providers), cores vêm de `AppColors` e o card de `AppDecorations.card`.

### Passo 9 — Página

`ui/pages/agenda_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../application/agenda_controller.dart';
import '../states/agenda_state.dart';
import '../widgets/agenda_list_widget.dart';

class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendaState = ref.watch(agendaControllerProvider);

    return AppScaffold(
      titulo: 'Agenda',
      rotaAtual: '/agenda', // mesmo path cadastrado no router e no drawer
      backgroundColor: AppColors.background,
      body: agendaState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : agendaState.errorMessage != null
          ? Center(child: Text(agendaState.errorMessage!))
          : _buildBody(agendaState),
    );
  }

  Widget _buildBody(AgendaState agendaState) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Container(
        color: AppColors.surfaceMuted,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
                child: Center(
                  child: Text(
                    'PRÓXIMOS ATENDIMENTOS',
                    style: AppTextStyles.sectionTitle,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'CONFIRA ABAIXO SUA AGENDA',
                    style: AppTextStyles.sectionSubtitle,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AgendaListWidget(items: agendaState.items),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
```

Regras:
- Tipar o parâmetro do `_buildBody` com o estado real (`AgendaState`), **nunca `dynamic`**.
- Telas logadas usam `AppScaffold`. Telas públicas (splash, login) usam `Scaffold` direto.
- Navegação e SnackBar vão em `ref.listen`, antes do `return`, igual à `LoginScreen`:

```dart
ref.listen<NovoPacienteState>(novoPacienteControllerProvider, (previous, next) {
  if (next is NovoPacienteSuccess) context.goNamed('agenda');
  if (next is NovoPacienteError) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(next.message)));
  }
});
```

### Passo 10 — Registrar a rota

`lib/src/routing/app_router.dart`

Se a rota já existe apontando para `EmConstrucaoScreen` (é o caso de `/usuario`, `/agenda`, `/prontuario`, `/historico` e `/financeiro`), só troque o `builder`. Remova o import de `em_construcao_screen.dart` quando nenhuma rota usar mais essa tela.

```dart
import '../features/agenda/ui/pages/agenda_screen.dart';

// dentro de routes: [...]
GoRoute(
  path: '/agenda',
  name: 'agenda',                    // ← usado por context.goNamed('agenda')
  builder: (context, state) => const AgendaScreen(),
),
```

### Passo 11 — Item no menu lateral (se aplicável)

Em `lib/src/core/ui/widgets/app_drawer.dart`, adicione (ou confira) a entrada em `_entradas`. A `rota` precisa ser **igual** ao `path` do router e ao `rotaAtual` da tela:

```dart
_DrawerEntry(label: 'Agenda', icon: Icons.calendar_today_outlined, rota: '/agenda'),
```

### Passo 12 — Testes

Os testes ficam em `test/`, espelhando `lib/src/`:

```
test/
├── app_flow_test.dart                          # Jornada completa: splash → login → home → menu → logout
└── features/
    ├── auth/application/auth_controller_test.dart
    ├── login/application/login_controller_test.dart
    ├── login/data/user_dto_test.dart
    ├── home/application/home_controller_test.dart
    └── home/data/home_dtos_test.dart
```

Para cada feature nova, crie no mínimo:

1. **Teste do controller**, com um repositório fake injetado pelo provider. É isso que a separação domínio/dados permite:

```dart
class _FakeAgendaRepository implements AgendaRepository {
  bool deveFalhar = false;

  @override
  Future<List<AgendaItemModel>> buscarAgenda() async {
    if (deveFalhar) throw Exception('falha');
    return const [/* ... */];
  }
}

test('sucesso preenche a lista', () async {
  final container = ProviderContainer.test(
    overrides: [
      agendaRepositoryProvider.overrideWithValue(_FakeAgendaRepository()),
    ],
  );

  container.read(agendaControllerProvider); // dispara o build()
  await container.read(agendaControllerProvider.notifier).carregar();

  expect(container.read(agendaControllerProvider).items, isNotEmpty);
});
```

2. **Teste do DTO**: `fromJson` + `toDomain()`, incluindo o valor padrão para status desconhecido.

3. Se a tela entrar no fluxo principal, **amplie o `app_flow_test.dart`**.

Dicas para testes de widget:
- Use `tester.view.physicalSize = const Size(4000, 8000)` (com `addTearDown(tester.view.reset)`). A fonte de teste, Ahem, é mais larga que a Nunito e gera overflow falso em telas estreitas.
- Enquanto houver `CircularProgressIndicator` na tela, use `tester.pump(duração)`, não `pumpAndSettle()`: a animação do indicador nunca "assenta" e o `pumpAndSettle` estoura o tempo.
- O `appRouter` é global. Testes que navegam pelo app inteiro precisam ficar em um único `testWidgets` por arquivo.

### Checklist final

- [ ] Pasta `features/<nome>/` com `domain`, `data`, `application` e `ui`.
- [ ] Model imutável, sem import de Flutter.
- [ ] Repositório abstrato em `domain/`, implementação em `data/repository/`.
- [ ] DTO com `fromJson` e `toDomain()`; mocks só no data source.
- [ ] Controller `extends Notifier<...>` (sem `legacy.dart`) em `application/`, com os providers no fim do arquivo.
- [ ] Estado em `ui/states/`: `sealed` para ação, `copyWith` para consulta.
- [ ] Página `ConsumerWidget` em `ui/pages/`, usando `AppScaffold` e `rotaAtual`.
- [ ] Widgets `StatelessWidget` recebendo dados por parâmetro; cores, textos e cards vindos de `AppColors`, `AppTextStyles` e `AppDecorations`, sem `fontFamily` nem hexadecimal soltos.
- [ ] Efeitos colaterais em `ref.listen`, nunca no `build`.
- [ ] Rota registrada com `path` e `name`; item do drawer com o mesmo path.
- [ ] Testes do controller e do DTO criados.
- [ ] `flutter analyze` sem avisos e `flutter test` passando.

---

## Parte 3 — Histórico de ajustes

### 3.1 Divergências corrigidas (25/09/2026)

| # | Divergência | Correção |
|---|---|---|
| 1 | `lib/src/auth/`: cópia legada e sem uso de `features/auth/` | Pasta removida. A sessão fica só em `features/auth/`. |
| 2 | Controller da Home em `ui/widgets/controllers/`, com `StateNotifier` (`legacy.dart`) | Movido para `features/home/application/home_controller.dart`, com `Notifier` + `NotifierProvider`. |
| 3 | Mocks dentro do controller; Home sem `data/` | Criados `domain/repositories/home_repository.dart`, `data/dtos/*_dto.dart`, `data/data_sources/home_remote_data_source.dart` (mocks em JSON) e `data/repository/home_repository_impl.dart`. As três buscas rodam em paralelo. |
| 4 | `HomeState.copyWith` não limpava `errorMessage` | O controller cria um `HomeState` novo no sucesso, o que descarta qualquer erro anterior. |
| 5 | `_buildBody(dynamic homeState, String? nomeUsuario)` | Tipado com `HomeState`. O parâmetro sem uso e a leitura do `authControllerProvider` na Home foram removidos. |
| 6 | Cores, estilos e decoração de card repetidos no código | Novos tokens em `AppColors`, novos estilos em `AppTextStyles`, novo `AppDecorations.card`. Aplicados em Home, Login, Splash e `AppScaffold`. O `LoginForm` ganhou o helper `_decoracaoCampo`, e a Home o widget `_TituloSecao`. |
| 7 | Itens do drawer sem rota no router | Rotas `/usuario`, `/agenda`, `/prontuario`, `/historico` e `/financeiro` registradas com `EmConstrucaoScreen`. |
| 8 | `screenWidth * 70` na Splash | Corrigido para `screenWidth * 0.7`. |
| 9 | Fonte `Nunito` sem declaração | TTFs estáticos (400/500/600/700/800, subset latin) e `OFL.txt` em `assets/fonts/`, declarados no `pubspec.yaml`. Os `fontFamily: 'Nunito'` repetidos nos widgets foram removidos. |
| 10 | Models da Home sem `const` | Construtores `const` nos três models e no `HomeState`. Igualdade (`==`/`hashCode`) não foi adicionada porque esses models não são comparados. |

### 3.2 Ajustes posteriores (25/09/2026)

| Onde | Correção |
|---|---|
| `test/` | O teste padrão do "contador" foi substituído por uma suíte de 19 testes: fluxo completo do app, controllers (auth, login, home) e DTOs. `flutter test` passa. |
| `LoginForm` | Os `TextEditingController` agora são liberados em `dispose()`. |

### 3.3 Pontos em aberto

| Onde | Observação |
|---|---|
| `HomeController.carregar` | Com as buscas em paralelo (`.wait`), um erro chega como `ParallelWaitError`, e a mensagem mostrada fica mais técnica. Quando houver API real, trate o erro de cada busca. |

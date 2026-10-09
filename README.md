# Poti Clínicas

Aplicativo Flutter da Poti Clínicas (pacote `multiclinica_app`), com alvo em Android, iOS, Web e macOS.

Para entender como o código em `lib/` está organizado e como criar novas telas, veja [arquitetura.md](arquitetura.md).

---

## Manual: como rodar o projeto

### 1. Pré-requisitos

| Ferramenta | Versão | Para quê |
|---|---|---|
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | 3.47 ou superior (canal `stable`), que traz o Dart 3.13+ | Obrigatório. O `pubspec.yaml` exige `sdk: ^3.13.3`. |
| Git | qualquer versão recente | Clonar o repositório. |
| Android Studio + Android SDK | recente, com JDK 17 | Rodar no Android (emulador ou celular). |
| Xcode + CocoaPods | Xcode recente; iOS 15.0 ou superior | Rodar no iOS ou no macOS (só funciona em um Mac). |
| Google Chrome | qualquer versão recente | Rodar na Web. |

Você só precisa das ferramentas da plataforma em que vai rodar. Para começar, o caminho mais simples é o Chrome (Web).

#### Instalando o Flutter

No macOS, com [Homebrew](https://brew.sh):

```bash
brew install --cask flutter
```

Em outros sistemas, siga o [guia oficial de instalação](https://docs.flutter.dev/get-started/install).

Se você já tem o Flutter instalado, atualize para a versão mais recente do canal estável:

```bash
flutter channel stable
flutter upgrade
```

Confira se está tudo certo:

```bash
flutter --version   # deve mostrar Flutter 3.47+ e Dart 3.13+
flutter doctor      # lista o que falta configurar para cada plataforma
```

Resolva os itens marcados com `✗` no `flutter doctor` para as plataformas que você vai usar. Os mais comuns são:

```bash
# Android: aceitar as licenças do SDK
flutter doctor --android-licenses

# iOS/macOS: configurar o Xcode e instalar o CocoaPods
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
brew install cocoapods
```

### 2. Clonar o repositório

```bash
git clone <url-do-repositorio> poti-clinicas
cd poti-clinicas
```

### 3. Baixar as dependências (libs)

Na raiz do projeto, rode:

```bash
flutter pub get
```

Esse comando lê o `pubspec.yaml` e baixa as bibliotecas usadas pelo app:

| Pacote | Uso |
|---|---|
| `flutter_riverpod` | Gerência de estado e injeção de dependências. |
| `go_router` | Navegação entre telas. |
| `flutter_map` + `latlong2` | Mapa (tiles do OpenStreetMap). |
| `http` | Requisições HTTP (ex.: busca de endereço via Nominatim). |
| `material_symbols_icons`, `cupertino_icons` | Ícones. |
| `flutter_lints`, `flutter_test`, `fake_async` | Lint e testes (apenas desenvolvimento). |

As versões exatas ficam travadas no `pubspec.lock`, que está versionado. Por isso, use `flutter pub get` e não `flutter pub upgrade`, a menos que a intenção seja atualizar as libs.

Para iOS/macOS, as dependências nativas (CocoaPods) são instaladas automaticamente na primeira vez que você roda o app nessas plataformas. Não é preciso rodar `pod install` manualmente.

> O projeto não usa geração de código (`build_runner`) nem arquivo `.env`. Depois do `flutter pub get`, ele já pode ser executado.

### 4. Rodar o app

Veja os dispositivos disponíveis (emuladores, celulares conectados, Chrome, macOS):

```bash
flutter devices
```

Rode no dispositivo desejado:

```bash
flutter run                 # usa o único dispositivo disponível ou pergunta qual usar
flutter run -d chrome       # Web
flutter run -d macos        # app desktop do macOS
flutter run -d <id>         # um dispositivo específico, com o id mostrado em `flutter devices`
```

Para abrir um emulador:

```bash
flutter emulators                       # lista os emuladores criados
flutter emulators --launch <id>         # abre um emulador Android
open -a Simulator                       # abre o simulador do iOS (macOS)
```

Com o app rodando no terminal:

- `r`: hot reload (aplica mudanças de código mantendo o estado)
- `R`: hot restart (reinicia o app)
- `q`: encerra

Pelo VS Code, também dá para rodar com **F5** (extensões *Flutter* e *Dart* instaladas), escolhendo o dispositivo na barra de status.

> O app precisa de internet para carregar o mapa (OpenStreetMap) e buscar endereços (Nominatim).

### 5. Testes e análise de código

```bash
flutter test                              # roda todos os testes da pasta test/
flutter test test/features/login          # roda apenas os testes de uma pasta
flutter analyze                           # verifica lint e erros estáticos
dart format lib test                      # formata o código
```

### 6. Gerar build

```bash
flutter build apk --release      # Android (APK) -> build/app/outputs/flutter-apk/
flutter build appbundle          # Android (AAB para a Play Store)
flutter build ios --release      # iOS (requer Mac e conta Apple configurada no Xcode)
flutter build web                # Web -> build/web/
flutter build macos              # macOS
```

> O build Android de release ainda está assinado com a chave de debug (veja `android/app/build.gradle.kts`). Antes de publicar na loja, é preciso configurar uma chave de assinatura própria.

### 7. Problemas comuns

| Problema | Solução |
|---|---|
| `The current Dart SDK version is X... requires SDK version ^3.13.3` | O Flutter está desatualizado. Rode `flutter upgrade`. |
| Erros estranhos depois de trocar de branch ou atualizar libs | Limpe e baixe tudo de novo: `flutter clean && flutter pub get`. |
| Erro de CocoaPods no iOS/macOS | `cd ios && pod repo update && pod install && cd ..` (ou `macos` no lugar de `ios`). |
| Licenças do Android não aceitas | `flutter doctor --android-licenses`. |
| Nenhum dispositivo aparece em `flutter devices` | Abra um emulador/simulador, conecte um celular com depuração USB ativada ou use `-d chrome`. |

### Resumo rápido

```bash
flutter doctor
flutter pub get
flutter run -d chrome
```

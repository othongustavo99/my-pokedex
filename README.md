<div align="center">

# 🔴 Othon's Pokédex

Uma Pokédex moderna e completa feita com Flutter.
Design limpo, animações suaves, suporte a tema claro/escuro e funcionamento offline.

</div>

---

<div align="center">

## 📱 Screenshots

### Tela de Boas-vindas

<img src="assets/screenshots/screenshot (2).png" width="300">

### Lista e Grade (Tema Claro)

|                             Lista                             |                             Grade                             |
| :-----------------------------------------------------------: | :-----------------------------------------------------------: |
| <img src="assets/screenshots/screenshot (1).png" width="250"> | <img src="assets/screenshots/screenshot (3).png" width="250"> |

### Tema Escuro

|                             Lista                             |                             Grade                             |
| :-----------------------------------------------------------: | :-----------------------------------------------------------: |
| <img src="assets/screenshots/screenshot (4).png" width="250"> | <img src="assets/screenshots/screenshot (5).png" width="250"> |

### Filtro por Tipo + Busca

<img src="assets/screenshots/screenshot (6).png" width="300">

### Página de Detalhes

|                             Stats                             |                           Evoluções                           |
| :-----------------------------------------------------------: | :-----------------------------------------------------------: |
| <img src="assets/screenshots/screenshot (7).png" width="250"> | <img src="assets/screenshots/screenshot (8).png" width="250"> |

### Favoritos

<img src="assets/screenshots/screenshot (9).png" width="300">

</div>

---

<div align="center">

## ✨ Funcionalidades

</div>

* 🏠 **Tela de boas-vindas** animada (fade + pulse)
* 📋 **Lista de Pokémon** com scroll infinito (paginação)
* 🗂️ **Modo Lista e Grade**
* 🔍 **Busca** por nome em tempo real
* 🎯 **Filtro por tipo** (Fire, Water, Dragon, etc.)
* ❤️ **Sistema de favoritos** persistente
* 🌙 **Tema claro / escuro / sistema**
* 📴 **Cache offline** (funciona sem internet após o primeiro uso)
* 📄 **Página de detalhes** completa:

  * Tipos
  * Altura, peso e total de stats
  * Habilidades
  * Status base com barras
  * Cadeia de evolução
* 🖼️ **Imagens em cache** com `cached_network_image`
* ✨ **Transições suaves** entre telas
* 📱 **Layout responsivo** e imersivo (esconde barras do sistema)

---

<div align="center">

## 🛠️ Tecnologias

|      Tecnologia      | Uso                                   |
| :------------------: | :------------------------------------ |
|        Flutter       | Framework principal                   |
|         Dart         | Linguagem                             |
|         http         | Requisições à PokéAPI                 |
| cached_network_image | Cache de imagens de rede              |
|  shared_preferences  | Persistência local (favoritos e tema) |
|      Material 3      | Design System                         |

---

## 🚀 Como rodar

### Pré-requisitos

* Flutter SDK **3.12+**
* Android Studio / VS Code / Cursor
* Emulador ou dispositivo físico

### Passos

</div>

```bash
# 1. Clone o repositório
git clone https://github.com/SEU_USUARIO/Othon_Pokedex.git
cd Othon_Pokedex

# 2. Instale as dependências
flutter pub get

# 3. Rode o app
flutter run
```

<div align="center">

## 📁 Estrutura do Projeto

</div>

```text
lib/
├── main.dart
├── models/
│   ├── pokemon_model.dart
│   ├── pokemon_details_model.dart
│   ├── pokemon_evolution_model.dart
│   └── pokemon_stat_model.dart
├── pages/
│   ├── welcome_page.dart
│   ├── home_page.dart
│   ├── pokemon_details.dart
│   └── favorites_page.dart
├── services/
│   └── api_service.dart
├── storage/
│   ├── favorites_storage.dart
│   ├── pokemon_cache.dart
│   ├── details_cache.dart
│   └── theme_storage.dart
├── utils/
│   ├── page_transitions.dart
│   └── pokemon_colors.dart
└── widgets/
    ├── pokemon_card.dart
    ├── pokemon_list.dart
    ├── search_bar.dart
    ├── type_filter.dart
    ├── shimmer.dart
    └── error_view.dart
```

<div align="center">

## 🎨 Assets

</div>

```text
assets/
├── back/
│   └── image.jpg              # Imagem da tela de boas-vindas
├── icons/
│   └── icon.png               # Ícone do aplicativo
└── screenshots/               # Screenshots do README
    ├── screenshot (1).png
    ├── screenshot (2).png
    ├── ...
    └── screenshot (9).png
```

<div align="center">

## 📡 API

Este projeto consome a **PokéAPI**.

---

## 📦 Dependências principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.5.0
  cached_network_image: ^3.4.1
  shared_preferences: ^2.5.3
```

---

## 📄 Licença

Este projeto está sob a licença MIT.

---

### Feito com ❤️ por Othon

</div>

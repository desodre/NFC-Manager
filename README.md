# NFC Manager

Aplicativo Android desenvolvido em Flutter para gerenciamento de tags NFC compatíveis com NDEF.

O app permite ler o conteúdo de uma tag, gravar textos ou URLs e limpar os registros NDEF. As operações são realizadas somente depois que uma tag é detectada e possuem uma janela de leitura de cinco segundos.

## Funcionalidades

- Read: leitura do tipo, capacidade, estado de gravação e registros NDEF.
- Edit: gravação de texto ou URL.
- Clean: remoção dos registros NDEF, com confirmação do usuário.
- Popup de detecção com limite de cinco segundos.
- Cancelamento da sessão NFC.
- Bloqueio de abertura automática de URLs, configurações Wi-Fi ou outros aplicativos durante a leitura.
- Histórico local das últimas 50 operações.
- Detalhamento, exclusão individual e limpeza completa do histórico.
- Navegação entre Gerenciar, Recentes e Configurações.

## Plataforma e requisitos

Atualmente o projeto está direcionado para Android.

Requisitos:

- Flutter instalado e configurado.
- Android SDK configurado.
- Dispositivo Android físico com NFC.
- Tag NFC compatível com NDEF para leitura e gravação.

Emuladores normalmente não são adequados para validar a comunicação com tags NFC físicas.

## Instalação

```bash
git clone <url-do-repositorio>
cd nfc_manager
flutter pub get
```

## Execução

Conecte um dispositivo Android com a depuração USB habilitada e execute:

```bash
flutter devices
flutter run
```

Para validar o projeto:

```bash
flutter analyze
flutter test
```

## Arquitetura

O código segue uma organização baseada em MVVM:

```text
lib/
├── app.dart
├── main.dart
├── models/
│   ├── tag_action.dart
│   ├── tag_history_entry.dart
│   └── tag_result.dart
├── services/
│   ├── history_service.dart
│   └── nfc_service.dart
├── viewmodels/
│   └── home_view_model.dart
├── views/
│   ├── home_page.dart
│   ├── manage_screen.dart
│   ├── recent_tags_screen.dart
│   └── settings_screen.dart
└── widgets/
    ├── action_card.dart
    ├── message_card.dart
    ├── nfc_waiting_dialog.dart
    └── result_card.dart
```

- `models`: estruturas de dados da aplicação.
- `services`: comunicação NFC e persistência local.
- `viewmodels`: estado, regras de negócio e integração entre telas e serviços.
- `views`: telas principais.
- `widgets`: componentes reutilizáveis da interface.

## Observações

- O UID da tag não é alterado.
- Tags somente leitura não podem ser editadas ou limpas.
- A limpeza remove os registros NDEF, mas não necessariamente apaga áreas protegidas ou dados de baixo nível da tag.
- A gravação pode ser irreversível dependendo do tipo de tag e de suas configurações de bloqueio.

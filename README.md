# FarmaAqui

Aplicativo Android desenvolvido em Flutter para a disciplina **Engenharia de Software para Dispositivos Móveis**.

## Integrantes

- **Aleksander Pires Calixto Negrão**
- **Jorge Lucas Firmino Silva de Sá**

## Proposta

O **FarmaAqui** tem como objetivo facilitar o acesso a medicamentos ao permitir que, futuramente, usuários consultem a disponibilidade em farmácias antes de se deslocarem. A motivação é especialmente relevante para pacientes e cuidadores de cidades pequenas, que podem precisar percorrer grandes distâncias para localizar determinados medicamentos.

Nesta entrega, o escopo é a **implementação da autenticação seguindo os princípios SOLID**, com foco na arquitetura e na testabilidade.

## Funcionalidades desta entrega

- Login por e-mail e senha.
- Fluxo de Google Sign-In representado por uma Strategy independente.
- Logout de acordo com o provedor ativo.
- Armazenamento seguro do token do fluxo e-mail/senha.
- Feedback de carregamento e erros na interface.
- Testes unitários do Controller, Strategies e TokenManager.

### Credenciais de demonstração

```text
E-mail: aluno@farmaaqui.app
Senha: 123456
```

> Para manter o trabalho executável sem chaves ou contas externas, a API e o Google Sign-In usam clients de demonstração. A arquitetura permite substituir esses clients por integrações reais sem alterar o `AuthController`.

## Arquitetura

```text
lib/
├── app/
│   └── farma_aqui_app.dart
└── features/auth/
    ├── presentation/
    │   ├── controllers/auth_controller.dart
    │   └── pages/auth_page.dart
    ├── domain/
    │   ├── contracts/auth_strategy.dart
    │   ├── contracts/token_manager.dart
    │   ├── entities/auth_session.dart
    │   └── errors/auth_exception.dart
    └── data/
        ├── clients/
        ├── strategies/
        └── token/
```

A composição das implementações concretas é feita fora da `AuthPage`. O Controller trabalha com o contrato `AuthStrategy` e não precisa saber se o fluxo escolhido é e-mail/senha ou Google.

## Como o SOLID aparece no código

| Princípio | Implementação |
| --- | --- |
| **S** — Single Responsibility | Page cuida da UI; Controller do estado; Strategies dos fluxos; TokenManager do token. |
| **O** — Open/Closed | Novos provedores podem ser novas classes `AuthStrategy` sem modificar o Controller. |
| **L** — Liskov Substitution | `AuthController.loginWith` pode receber qualquer `AuthStrategy` válida. |
| **I** — Interface Segregation | `AuthStrategy` possui somente `login`/`logout`; token fica em contrato separado. |
| **D** — Dependency Inversion | Presentation depende de abstrações do domínio; detalhes ficam em Data. |

Mais detalhes em [`docs/ARQUITETURA.md`](docs/ARQUITETURA.md).

## Executar

Caso a pasta `android/` ainda não exista, gere o scaffold nativo a partir do projeto Flutter:

```bash
flutter create --platforms=android --org br.edu.ufal --project-name farma_aqui .
flutter pub get
flutter test
flutter run
```

No Windows, o arquivo `tool/GERAR_ANDROID.bat` executa os três primeiros passos automaticamente.

## Branch da entrega

A implementação foi desenvolvida em:

```text
feat/autenticacao-solid
```

A Pull Request deve ter como destino a branch `main`.

## Validação automática

O repositório inclui um workflow do GitHub Actions que, a cada push/PR, gera o scaffold Android, executa `flutter analyze`, roda os testes e tenta compilar um APK de debug. Isso ajuda a detectar problemas de integração assim que o projeto for publicado.

## Implementação de autenticação - FarmaAqui

### O que foi implementado
- Autenticação por e-mail e senha em ambiente de demonstração.
- Estratégia de Google Sign-In simulada e isolada por contrato.
- Separação em `presentation`, `domain` e `data`.
- `AuthStrategy` para variação dos mecanismos de autenticação.
- `TokenManager` segregado e armazenamento via `flutter_secure_storage`.
- Injeção das dependências fora da `AuthPage`.
- Testes unitários dos principais componentes.

### SOLID
- **S**: Page, Controller, Strategies e TokenManager possuem responsabilidades distintas.
- **O**: novos provedores podem ser adicionados com novas Strategies sem alterar o Controller.
- **L**: qualquer `AuthStrategy` pode ser usada por `AuthController.loginWith`.
- **I**: `TokenManager` é separado de `AuthStrategy`.
- **D**: apresentação depende dos contratos do domínio, não de SDKs/armazenamentos concretos.

### Observação
O Google Sign-In utiliza um cliente de demonstração neste MVP para manter o projeto executável sem credenciais externas. A Strategy está pronta para receber um adapter real do SDK sem alterar o Controller.

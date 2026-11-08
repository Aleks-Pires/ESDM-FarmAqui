# Arquitetura da autenticação

A autenticação do FarmaAqui segue a divisão usada na disciplina: **presentation**, **domain** e **data**.

```text
PRESENTATION
AuthPage
   |
   v
AuthController
   |
   v
DOMAIN
AuthStrategy <-------- TokenManager
   ^                       ^
   |                       |
DATA                       |
EmailPasswordAuthStrategy--+
GoogleSignInAuthStrategy
SecureTokenManager
```

## Fluxo por e-mail e senha

```text
AuthPage
  -> cria EmailPasswordAuthStrategy
  -> AuthController.loginWith(strategy)
  -> AuthApiClient.login(email, senha)
  -> TokenManager.save(token)
  -> AuthSession
```

No logout, a Strategy lê o token, solicita o logout ao `AuthApiClient` e limpa o `TokenManager`.

## Fluxo Google

```text
AuthPage
  -> cria GoogleSignInAuthStrategy
  -> AuthController.loginWith(strategy)
  -> GoogleAuthClient.signIn()
  -> AuthSession
```

O fluxo Google não conhece o `TokenManager` usado pela API da aplicação.

## SOLID aplicado

| Princípio | Aplicação no FarmaAqui |
| --- | --- |
| S — Single Responsibility | `AuthPage` renderiza e envia eventos; `AuthController` coordena estado; cada Strategy implementa um fluxo; `SecureTokenManager` persiste token. |
| O — Open/Closed | Um novo provedor implementa `AuthStrategy`; `AuthController` não precisa ser alterado. |
| L — Liskov Substitution | O Controller recebe qualquer implementação válida de `AuthStrategy`. |
| I — Interface Segregation | `AuthStrategy` contém apenas `login()` e `logout()`; operações de token ficam em `TokenManager`. |
| D — Dependency Inversion | A camada de apresentação conhece abstrações do domínio; detalhes concretos ficam em `data`. |

## MVP acadêmico

A API de e-mail/senha e o provedor Google são simulados localmente para que o projeto não dependa de credenciais, backend ou configuração externa durante a avaliação. A implementação concreta pode ser trocada posteriormente sem alterar `AuthController`, preservando o objetivo do Strategy e do princípio de inversão de dependência.

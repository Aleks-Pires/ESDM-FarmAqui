# Checklist de entrega

## Integrantes

- **Aleksander Pires Calixto Negrão**
- **Jorge Lucas Firmino Silva de Sá**

O código já está preparado em duas branches Git:

- `main`: estrutura inicial.
- `feat/autenticacao-solid`: implementação completa da autenticação.

## Publicação

1. Crie um repositório **vazio** no GitHub chamado `FarmaAqui` (não marque README, .gitignore nem licença na criação).
2. Extraia o pacote **FarmaAqui-git-ready.zip**.
3. Dentro da pasta, execute `tool/PUBLICAR_NO_GITHUB.bat` e cole a URL do repositório vazio.
4. No GitHub, adicione o professor como colaborador do repositório usando o usuário informado por ele na disciplina.
5. Abra uma Pull Request de `feat/autenticacao-solid` para `main`.
6. Entregue no Classroom o link da Pull Request.
7. No formulário "Repositórios dos projetos", preencha o(s) nome(s) e a URL do repositório.

## Se os arquivos Android ainda não estiverem no repositório

O código Flutter, testes e configuração estão completos. Para gerar os arquivos nativos Android automaticamente em uma máquina com Flutter instalado, execute:

```text
tool/GERAR_ANDROID.bat
```

Depois faça commit dos arquivos gerados, se o professor exigir o scaffold nativo no repositório.

## Dados de demonstração

- E-mail: `aluno@farmaaqui.app`
- Senha: `123456`
- Google: fluxo simulado para o protótipo acadêmico.

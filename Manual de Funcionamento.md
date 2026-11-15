# Manual de Funcionamento - FarmaAqui

Guia simples para baixar, configurar e executar o projeto.

**Branch usada:** `feat/telas-farmaaqui`

## 1. O que precisa estar instalado

- Git
- Flutter
- Google Chrome
- Python 3

## 2. Primeira vez no computador

Abra o **CMD** e rode:

```cmd
git clone https://github.com/Aleks-Pires/ESDM-FarmAqui.git
cd ESDM-FarmAqui
git checkout feat/telas-farmaaqui
flutter pub get
```

## 3. Rodar o aplicativo

Na pasta principal do projeto:

```cmd
flutter run -d chrome
```

O Chrome deve abrir automaticamente. Deixe esse CMD aberto.

## 4. Rodar a API simulada

Abra **outro CMD** e, dentro do projeto, rode:

```cmd
cd mock_api
py -m pip install -r requirements.txt
py -m uvicorn server:app --reload --host 0.0.0.0 --port 8000
```

Quando aparecer `Uvicorn running on http://0.0.0.0:8000`, a API está funcionando. Deixe esse CMD aberto.

## 5. Como saber qual CMD é qual

- **Flutter:** mostra mensagens como `flutter run`, `Hot reload`, Chrome e Debug service.
- **API:** mostra `Uvicorn running`, `GET /medicamentos` e `POST /reservas`.

## 6. Se o projeto já estiver baixado

Use:

```cmd
git checkout feat/telas-farmaaqui
git pull origin feat/telas-farmaaqui
flutter pub get
flutter run -d chrome
```

## 7. Parar o aplicativo

No CMD do Flutter, pressione:

```text
q
```

## 8. Funcionalidades da demonstração

- Login por e-mail e senha.
- Login Google simulado.
- Cadastro com validação de e-mail e CPF.
- Endereço opcional no perfil.
- Estados e municípios com dados do IBGE.
- Busca de medicamentos.
- Farmácias simuladas em Arapiraca.
- Mapa com farmácias simuladas no Centro de Arapiraca.
- Reserva para retirada.
- Delivery com endereço obrigatório no pedido.
- Taxa de entrega simulada.
- Pagamento simulado.
- Histórico.
- Perfil com estatísticas e edição de informações.

## 9. Teste rápido antes da apresentação

1. Abra a API.
2. Abra o Flutter no Chrome.
3. Faça login.
4. Pesquise **Losartana 50 mg**.
5. Veja os resultados.
6. Abra o mapa.
7. Escolha uma farmácia.
8. Teste Retirada.
9. Teste Delivery.
10. Abra Histórico.
11. Abra Perfil.

## 10. Se alguma coisa der errado

### O Chrome não abriu

```cmd
flutter run -d chrome
```

### A API não iniciou

```cmd
cd mock_api
py -m pip install -r requirements.txt
py -m uvicorn server:app --reload --host 0.0.0.0 --port 8000
```

### O projeto está desatualizado

```cmd
git checkout feat/telas-farmaaqui
git pull origin feat/telas-farmaaqui
flutter pub get
```

### O terminal está preso no Flutter

Pressione `q`.

### A API caiu, mas o app abre

O FarmaAqui possui um JSON local de fallback. A busca pode funcionar offline, mas para mostrar a integração com a API simulada mantenha o servidor Python ligado.

## 11. Importante para a apresentação

As farmácias, preços, estoques, pedidos e pagamentos são simulados para fins acadêmicos. O mapa usa OpenStreetMap. Os municípios são obtidos pelo serviço de localidades do IBGE.

## 12. Ordem segura para apresentar

1. Inicie a API.
2. Inicie o Flutter.
3. Faça login.
4. Pesquise um medicamento.
5. Mostre farmácias e mapa.
6. Faça uma reserva ou delivery.
7. Mostre o Histórico.
8. Mostre o Perfil.

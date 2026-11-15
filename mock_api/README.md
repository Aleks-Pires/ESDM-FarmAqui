# FarmaAqui Mock API

API simulada usada na apresentação acadêmica do FarmaAqui.

## Executar no Windows

```bash
cd mock_api
py -m pip install -r requirements.txt
py -m uvicorn server:app --reload --host 0.0.0.0 --port 8000
```

A documentação interativa fica em:

```
http://127.0.0.1:8000/docs
```

Rotas principais:

- `GET /medicamentos?nome=Losartana%2050%20mg&cidade=Arapiraca%20-%20AL`
- `POST /reservas`

O Flutter tenta consumir a API. Se ela estiver indisponível, usa automaticamente o JSON local em `assets/mock/medications.json`, mantendo a demonstração funcional.

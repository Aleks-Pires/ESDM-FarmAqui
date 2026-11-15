from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from pathlib import Path
import json

app = FastAPI(title="FarmaAqui Mock API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

DATA_FILE = Path(__file__).parent / "data" / "medications.json"

with DATA_FILE.open("r", encoding="utf-8") as file:
    DATA = json.load(file)


class ReservationRequest(BaseModel):
    pharmacy: str
    medicine: str
    quantity: int
    delivery: bool
    payment: str


@app.get("/")
def root():
    return {
        "service": "FarmaAqui Mock API",
        "status": "online",
        "message": "API simulada para apresentação acadêmica."
    }


@app.get("/medicamentos")
def search_medications(nome: str, cidade: str = "Arapiraca - AL"):
    normalized = nome.strip().lower()
    matches = []

    for item in DATA["medications"]:
        item_name = item["name"].lower()
        if normalized in item_name or item_name in normalized:
            matches.extend(item["offers"])

    return {
        "medicine": nome,
        "city": cidade,
        "count": len(matches),
        "offers": matches,
        "source": "mock-api"
    }


@app.post("/reservas")
def create_reservation(payload: ReservationRequest):
    return {
        "success": True,
        "reservationId": "FARMA-DEMO-001",
        "status": "confirmada",
        "pharmacy": payload.pharmacy,
        "medicine": payload.medicine,
        "quantity": payload.quantity,
        "delivery": payload.delivery,
        "payment": payload.payment,
        "message": (
            "Pedido registrado para entrega."
            if payload.delivery
            else "Medicamento reservado para retirada."
        )
    }

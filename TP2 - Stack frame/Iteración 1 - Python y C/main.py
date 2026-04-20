import requests
import ctypes
import os
import sys

# 1. Configuración de la librería C
# Usamos os.path.abspath que busca en la misma dirección donde esta este script. Para evitar errores de "file not found"
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# Construye la ruta a la librería compartida "libgini.so".
SO_PATH = os.path.join(BASE_DIR, "libgini.so")

try:
    lib = ctypes.CDLL(SO_PATH)
    # Definimos el "contrato" con la función de C. El tipo de entrada y salida.
    lib.calcular_gini.argtypes = [ctypes.c_double]
    lib.calcular_gini.restype = ctypes.c_long
except OSError as e:
    print(f"[ERROR] No se pudo cargar la librería en {SO_PATH}: {e}")
    sys.exit(1)

# 2. Consumo de la API del Banco Mundial
# Traemos datos de todos los países para luego filtrar de acuerdo al pais deseado.
URL = (
    "https://api.worldbank.org/v2/en/country/all/indicator/SI.POV.GINI"
    "?format=json&date=2011:2020&per_page=32500&page=1"
)

print("\n[Python] Consultando API del Banco Mundial...")
try:
    # Hace la request y evita quedarse colgado con el timeout.
    response = requests.get(URL, timeout=15)
    # Si el servidor devuelve error (404, 500), lanza excepción
    response.raise_for_status()
    # Convierte la respuesta JSON a estructura Python
    data = response.json()
except requests.RequestException as e:
    print(f"[ERROR] Falló la conexión con la API: {e}")
    sys.exit(1)

# La API devuelve una lista: [metadatos, lista_de_registros]
registros = data[1] if len(data) > 1 else []

# 3. Filtrado de datos para Argentina
# Buscamos el ID "AR" y que el valor no sea None (nulo)
argentina = [
    r for r in registros
    if r.get("country", {}).get("id") == "AR" and r.get("value") is not None
]

if not argentina:
    print("[Python] No se encontraron datos válidos para Argentina en el periodo 2011-2020.")
    sys.exit(1)

# Ordenamos por año de forma descendente
argentina.sort(key=lambda r: r["date"], reverse=True)

# 4. Procesamiento y salida
print("\n" + "═" * 60)
print(f"{'AÑO':^10} | {'GINI ORIGINAL':^20} | {'RESULTADO (C + 1)':^20}")
print("─" * 60)

for registro in argentina:
    anio = registro["date"]
    valor_float = float(registro["value"])
    
    # Llamada a la capa intermedia en C
    resultado_c = lib.calcular_gini(valor_float)
    
    print(f"{anio:^10} | {valor_float:^20.2f} | {resultado_c:^20}")

print("═" * 60)
print("[Python] Proceso finalizado con éxito.\n")

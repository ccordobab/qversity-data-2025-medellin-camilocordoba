import requests

# Esta función toma un valor y lo convierte en un string JSON
def serialize_json(value):
    if isinstance(value, (dict,list)):
        try:
            return json.dumps(value)
        except Exception:
            return str(value)
    else:
        return str(value)

# Esta función hace una solicitud HTTP GET a la URL dada, ademas quita la metadata del objeto response    
def json_from_api(url):
    response = requests.get(url)
    data = response.json()
    return data
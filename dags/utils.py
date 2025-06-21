import requests
import json

# converts a value into a JSON string
def serialize_json(value):
    if isinstance(value, (dict,list)):
        try:
            return json.dumps(value)
        except Exception:
            return str(value)
    else:
        return str(value)

# makes a get http request to a url, waits for the response and takes the data of the reponse object without its metadata    
def json_from_api(url):
    response = requests.get(url)
    data = response.json()
    return data
# dataplane_request

Request your HAproxy's Data Plane API to get information about Frontend and Backend
- You can get all frontends and their associated backend's
```bash
Frontend: alone -> *:8095

Frontend: toaster -> 127.0.0.1:8000
- Backend: toast1 -> 127.0.0.1:9001
- Backend: toast2 -> 127.0.0.1:9002

Frontend: waf -> 127.0.0.1:8050
- Backend: meow1 -> 127.0.0.1:9051
- Backend: meow2 -> 127.0.0.1:9052
- Backend: meow3 -> 127.0.0.1:9053

Frontend: skiliak -> *:8080
- Backend: atoz -> 127.0.0.1:8011
- Backend: kakliak -> 127.0.0.1:8010

Frontend: zepp1 -> *:8080
- Backend: zepp2 -> 127.0.0.1:8008
- Backend: zepp3 -> 127.0.0.1:8009

Frontend: keyboard -> *:8082
- Backend: azerty -> 127.0.0.1:9000
- Backend: qwerty -> 127.0.0.1:9001
- Backend: qwertz -> 127.0.0.1:9002

Frontend: white -> *:8081
- Backend: blue -> 127.0.0.1:8011
- Backend: green -> 127.0.0.1:8012
- Backend: purple -> 127.0.0.1:8014
- Backend: red -> 127.0.0.1:8010
- Backend: yellow -> 127.0.0.1:8013
```

## How to use
- Add **IPs**, **username** and **password** to config file (you can contenerized it and manage secret with k8s)
```bash
# You can use comma
DP_URL="127.0.0.1:5555,127.0.0.1:5556,127.0.0.1:5557"

# Or whitespace
DP_URL="127.0.0.1:5555 127.0.0.1:5556 127.0.0.1:5557"

# Or even line return
DP_URL="127.0.0.1:5555
127.0.0.1:5556
127.0.0.1:5557"
```

- Launch it
```bash
bash dataplane_request.sh
```

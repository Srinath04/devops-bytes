"""
Identity Lab API

This service demonstrates:
- OAuth2 / OIDC authentication using Keycloak
- JWT access token validation
- JWKS public key verification
- Protected API endpoints

Used as part of Srinath DevOps Bytes - identity lab.
"""

from fastapi import FastAPI, Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt
import requests

app = FastAPI()

# Health endpoint
@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "identity-lab-api"
    }

# Replace with your Keycloak realm endpoint
KEYCLOAK_URL = "http://<keycloak-host>:8080/realms/dev-realm"
JWKS_URL = f"{KEYCLOAK_URL}/protocol/openid-connect/certs"
ALGORITHM = "RS256"

security = HTTPBearer()

jwks = requests.get(JWKS_URL).json()

# Middleware style dependency that validates incoming JWT tokens

def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    
    header = jwt.get_unverified_header(token)
    kid = header["kid"]

    key = next(k for k in jwks["keys"] if k["kid"] == kid)

    try:
        payload = jwt.decode(
            token,
            key,
            algorithms=[ALGORITHM],
            options={"verify_aud": False}
        )
        return payload
    except Exception as e:
        raise HTTPException(status_code=401, detail="Invalid or expired token")


@app.get("/protected")
def protected(user=Depends(verify_token)):
    return {
        "message": "Access granted",
        "note": "Real business data and logic follows",
        "user": user["preferred_username"]
    }

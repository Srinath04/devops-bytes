## Objective
Understand modern API authentication mechanisms including OAuth, JWT, Bearer tokens, and stateless architecture.

---

## Swagger Exploration

Accessed Codebeamer v3 Swagger UI:
https://trial.codebeamer.com/v3/swagger/editor.spr#

Observed supported authentication methods:
- API Key
- Basic Auth
- Bearer Auth (OpenID Token)

---
## Key Concepts Learned

### 1. Basic Auth
- Sends username and password with each request.
- Simple but not suitable for enterprise scale systems.

### 2. Bearer Authentication
- Uses token-based authentication.
- Token passed in header:
  Authorization: Bearer <token>

### 3. OAuth 2.0
- Authorization framework for issuing access tokens.
- Does not define token format.

### 4. JWT (JSON Web Token)
Structure:
Header.Payload.Signature

- Header: algorithm & type
- Payload: claims (sub, exp, iss, aud)
- Signature: cryptographic integrity validation

---

## JWT Verification Process

Server validates:
1. Signature (using secret or public key)
2. Expiry (exp claim)
3. Issuer (iss)
4. Audience (aud)

Prevents token tampering.

---

## RS256 Key Understanding

- Identity Provider signs JWT using Private Key.
- API Server verifies using Public Key.
- Private key never shared.

---

## Stateless vs Stateful Authentication

### Stateful (Session-Based)
- Server stores session in memory or DB.
- Requires sticky sessions or shared session store.
- Harder to scale horizontally.

### Stateless (JWT-Based)
- No session storage on server.
- Each request carries authentication data.
- Better for microservices and cloud scaling.

Tradeoff:
- Logout and token revocation require additional design.

---

## Security Insight

If a JWT is stolen:
- It remains valid until expiry.
- Mitigation strategies:
  - Short-lived access tokens
  - Refresh tokens
  - HTTPS
  - Token revocation mechanisms

---

## Architecture Understanding

Modern Enterprise Flow:

User → Identity Provider (OAuth/OpenID) → JWT → API Server → Resource Access

---

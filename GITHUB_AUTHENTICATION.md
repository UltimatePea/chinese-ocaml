You can use `github_auth.py` to complete the actions below.


# 🔑 Authenticating to GitHub as a GitHub App

This guide shows how to authenticate as a **GitHub App** and call GitHub REST API endpoints using `curl`.

---

## 📋 Prerequisites
- GitHub App ID (`1595512`)
- Installation ID (`75590650`)
- App’s private key (`../claudeai-v1.pem`)

---

## 🚀 Steps

### 1️⃣ Generate a JWT
- JWT is valid for max **10 minutes**.
- JWT payload example:

{
  "iat": <now>,
  "exp": <now + 600>,
  "iss": "<APP_ID>"
}

- Sign the JWT with your `private-key.pem` using `RS256`.

---

### 2️⃣ Get an Installation Token
- Call:

curl -X POST \
  -H "Authorization: Bearer <JWT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/app/installations/<INSTALLATION_ID>/access_tokens

- Response:

{
  "token": "<installation_token>",
  "expires_at": "<timestamp>"
}

- This `installation_token` is valid for **1 hour**.

---

### 3️⃣ Use the Installation Token
Use it in the `Authorization` header to call GitHub API:

curl -H "Authorization: token <installation_token>" \
     -H "Accept: application/vnd.github+json" \
     https://api.github.com/repos/UltimatePea/chinese-ocaml/issues

---

## 🔷 Notes
- JWT → installation token → use the token.
- Automate refresh before expiration.
- Never hard-code tokens; generate them when needed.

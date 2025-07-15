#!/usr/bin/env python3
import jwt
import time
import requests
import json
import os

# GitHub App credentials
APP_ID = "1595512"
INSTALLATION_ID = "75590650"
PRIVATE_KEY_PATH = "../claudeai-v1.pem"

def generate_jwt():
    """Generate a JWT for GitHub App authentication"""
    now = int(time.time())
    payload = {
        "iat": now,
        "exp": now + 600,  # 10 minutes
        "iss": APP_ID
    }

    with open(PRIVATE_KEY_PATH, 'r') as f:
        private_key = f.read()

    token = jwt.encode(payload, private_key, algorithm='RS256')
    return token

def get_installation_token():
    """Get an installation token using JWT"""
    jwt_token = generate_jwt()

    headers = {
        "Authorization": f"Bearer {jwt_token}",
        "Accept": "application/vnd.github+json"
    }

    url = f"https://api.github.com/app/installations/{INSTALLATION_ID}/access_tokens"
    response = requests.post(url, headers=headers)

    if response.status_code == 201:
        return response.json()["token"]
    else:
        raise Exception(f"Failed to get installation token: {response.status_code} {response.text}")

if __name__ == "__main__":
    try:
        token = get_installation_token()
        print(token)
    except Exception as e:
        print(f"Error: {e}")
        exit(1)
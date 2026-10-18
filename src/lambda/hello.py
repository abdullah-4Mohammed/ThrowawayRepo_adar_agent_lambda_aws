"""Tiny hello API: returns a JSON greeting."""
import json


def greet(name):
    # a missing or empty name falls back to "world"
    name = (name or "").strip() or "world"
    return f"Hello, {name}!"


def handler(event, context):
    params = event.get("queryStringParameters") or {}
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"message": greet(params.get("name"))}),
    }

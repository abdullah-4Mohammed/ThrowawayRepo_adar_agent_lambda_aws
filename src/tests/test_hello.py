import json

import hello


def test_greet_uses_the_name():
    assert hello.greet("Ada") == "Hello, Ada!"


def test_greet_falls_back_to_world():
    assert hello.greet("") == "Hello, world!"
    assert hello.greet(None) == "Hello, world!"


def test_handler_returns_json_greeting():
    res = hello.handler({"queryStringParameters": {"name": "Ada"}}, None)
    assert res["statusCode"] == 200
    assert json.loads(res["body"]) == {"message": "Hello, Ada!"}


def test_handler_without_query_string():
    res = hello.handler({}, None)
    assert json.loads(res["body"]) == {"message": "Hello, world!"}

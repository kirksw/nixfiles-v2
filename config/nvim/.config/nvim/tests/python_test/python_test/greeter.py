def say_hello(name) -> str:
    return f"hello, {name}"


def addx(name: str) -> str:
    return f"{name}x"


def test_addx():
    assert addx("12") == "12"

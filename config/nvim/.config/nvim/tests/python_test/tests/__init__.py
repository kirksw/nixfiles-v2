from python_test.greeter import say_hello


def test_greeter():
    assert say_hello("kirk") == "Hello, kirk"

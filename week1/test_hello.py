from hello import say_hello, add


def test_say_hello():
    assert (
        say_hello("Leo") == "Hello, Leo, welcome to Data Engineering Systems (IDS 706)!"
    )


def test_add():
    assert add(1, 2) == 3

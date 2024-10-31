from typing import Callable, Any


def func_typer(func: Callable) -> Callable:
    func_name = func.__name__
    arg_names = func.__code__.co_varnames[:func.__code__.co_argcount]

    def printer(msg: str) -> None:
        print(f"func_typer:{func_name}:{msg}")

    def wrapped(*args: Any) -> Any:
        for arg_name, arg in zip(arg_names, args):
            printer(f"{arg_name}:type= {type(arg)}")
            print('func_typer', arg)
        return func(*args)

    return wrapped

#  Copyright 2022 by Autodesk, Inc.
#  Permission to use, copy, modify, and distribute this software in object code form
#  for any purpose and without fee is hereby granted, provided that the above copyright
#  notice appears in all copies and that both that copyright notice and the limited
#  warranty and restricted rights notice below appear in all supporting documentation.
#
#  AUTODESK PROVIDES THIS PROGRAM "AS IS" AND WITH ALL FAULTS. AUTODESK SPECIFICALLY
#  DISCLAIMS ANY IMPLIED WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.
#  AUTODESK, INC. DOES NOT WARRANT THAT THE OPERATION OF THE PROGRAM WILL BE
#  UNINTERRUPTED OR ERROR FREE.

import sys
from typing import Callable

import adsk.core
from .general_utils import handle_error

_handlers = []


def add_handler(
        event: adsk.core.Event,
        callback: Callable,
        *,
        name: str = None,
        local_handlers: list = None
):
    module = sys.modules[event.__module__]
    handler_type = module.__dict__[event.add.__annotations__['handler']]
    handler = _create_handler(handler_type, callback, event, name, local_handlers)
    event.add(handler)
    return handler


def clear_handlers():
    global _handlers
    _handlers = []


def _create_handler(handler_type, callback, event, name=None, local_handlers=None):
    handler = _define_handler(handler_type, callback, name)()
    (local_handlers if local_handlers is not None else _handlers).append(handler)
    return handler


def _define_handler(handler_type, callback, name=None):
    name = name or handler_type.__name__

    class Handler(handler_type):
        def __init__(self):
            super().__init__()

        def notify(self, args):
            try:
                callback(args)
            except:
                handle_error(name)

    return Handler

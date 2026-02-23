from .commandCreatePanel import entry as commandCreatePanel
from .commandCreateRail import entry as commandCreateRail

commands = [
    commandCreatePanel,
    commandCreateRail,
]


def start():
    for command in commands:
        command.start()


def stop():
    for command in commands:
        command.stop()

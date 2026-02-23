import configparser
import os
import json

from . import fusion360utils as futil

CONFIG_FILE_NAME = 'config.ini'


def getDefaultConfig():
    config = configparser.ConfigParser()
    config['UI'] = {'IS_PROMOTED': 'yes'}
    return config


def readConfig(path: str):
    config = getDefaultConfig()
    config_file = os.path.join(path, CONFIG_FILE_NAME)
    if os.path.exists(config_file):
        try:
            config.read(config_file)
        except Exception as err:
            futil.log(f'Failed to read config: {err}')
    return config


def writeConfig(config, path: str):
    try:
        os.makedirs(path, exist_ok=True)
        config_file = os.path.join(path, CONFIG_FILE_NAME)
        with open(config_file, 'w') as f:
            config.write(f)
    except Exception as err:
        futil.log(f'Failed to write config: {err}')


def deleteConfigFile(path: str):
    if os.path.exists(path):
        try:
            os.remove(path)
        except Exception as err:
            futil.log(f'Failed to delete config file: {err}')


def readJsonConfig(path: str):
    if not os.path.exists(path):
        return None
    try:
        with open(path, 'r') as f:
            return json.load(f)
    except Exception as err:
        futil.log(f'Failed to read JSON config: {err}')
        return None


def dumpJsonConfig(path: str, config):
    try:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, 'w') as f:
            json.dump(config, f, indent=2)
        return True
    except Exception as err:
        futil.log(f'Failed to write JSON config: {err}')
        return False

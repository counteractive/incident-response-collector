from __future__ import print_function, unicode_literals
from PyInquirer import style_from_dict, Token, prompt, Separator
from pprint import pprint

import configparser

config = configparser.ConfigParser()
config.read('config.ini')

# Get the modules from the current config.ini
sections = config.sections()
choice_list = []

if len(sections) == 0:  # check if config file not already created. If not created create sections and modules
    config['memory'] = {
        'memory-image': 'false',
        'memory-files': 'false'
    }
    config['processed-volatile'] = {
        'network': 'false',
        'process': 'false'
    }
    config['filesystem'] = {
        'filesystem': 'false'
    }
    config['file'] = {
        'file': 'false'
    }
    config['processed=persistent'] = {
        'prefetch': 'false',
        'system': 'false',
        'autostart': 'false',
        'activity': 'false',
        'browsing': 'false',
        'dirwalk': 'false',
        'usb': 'false'
    }
sections = config.sections()

# creating the list of choices for the CLI
for section in sections:
    choice_list.append(Separator('--'+section+'--'))
    for module in config[section]:
        choice_list.append({
            'name': module,
            'checked': config[section].getboolean(module)
        })

# Set up for CLI
questions = [
    {
        'type': 'checkbox',
        'message': 'Select Which Modules You Would Like To Run',
        'name': 'modules',
        'choices': choice_list
    }
]

# running CLI prompt
updated_modules = prompt(questions)['modules']

# updating the config file
for section in sections:
    for module in config[section]:
        if module in updated_modules:
            config[section][module] = 'True'
        else:
            config[section][module] = 'False'

# saving the config file
with open('config.ini', 'w') as configfile:
    config.write(configfile)

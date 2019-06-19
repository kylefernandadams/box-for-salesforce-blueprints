#!/usr/bin/env python
import json
import argparse
from subprocess import Popen, PIPE

privateKey = ''
def parseCommandLineArgs():
    parser = argparse.ArgumentParser()
    parser.add_argument("box_config_path", help="Provide the absolute path to your downloaded Box Application configuration JSON file.")
    args = parser.parse_args()
    print("Using config json at path: " + args.box_config_path)
    return args.box_config_path

def parseBoxJsonSettings(boxConfigPath):
    with open(boxConfigPath) as jsonFile:
        jsonData = json.load(jsonFile)
        enterpriseID = jsonData['enterpriseID']
        clientID = jsonData['boxAppSettings']['clientID']
        clientSecret = jsonData['boxAppSettings']['clientSecret']
        publicKeyID = jsonData['boxAppSettings']['appAuth']['publicKeyID']
        privateKey = jsonData['boxAppSettings']['appAuth']['privateKey']
        passphrase = jsonData['boxAppSettings']['appAuth']['passphrase']
        print('Found enterprise id: ' + enterpriseID)
        print('Found clientID: ' + clientID)
        print('Found clientSecret: ' + clientSecret)
        print('Found publicKeyID: ' + publicKeyID)
        print('Found passphrase: ' + passphrase)
        print('Found privateKey: ' + privateKey)
        with open('tempKey.txt', 'w') as temp_key:
            temp_key.write(privateKey)
        return passphrase

def convertCryptoKey(passphrase):
    passIn = 'pass:' + passphrase
    results = Popen(['openssl', 'pkcs8', '-topk8', '-nocrypt', '-in', 'tempKey.txt', '-outform', 'PEM', '-passin', passIn], stdout=PIPE)
    newKey = results.communicate()[0]
    print('Found new private key: {}'.format(newKey))
    return newKey

def modifyPkString(newKey):
    withoutFirstLine = newKey.split('\n')[1:]
    withoutLastLine = withoutFirstLine[:len(withoutFirstLine)-2]
    privateKey = ''.join(withoutLastLine)
    print('New private key string: ' + privateKey)
    return privateKey

def createBoxJsonSettingsFile(privateKey):
    with open(boxConfigPath) as jsonFile:
        jsonData = json.load(jsonFile)
        jsonData['boxAppSettings']['appAuth']['privateKey'] = privateKey
        with open('sfdc_box_config.json', 'w') as sfdcJsonFile:
            json.dump(jsonData, sfdcJsonFile, indent=2)

boxConfigPath = parseCommandLineArgs()
passphrase = parseBoxJsonSettings(boxConfigPath)
convertedPk = convertCryptoKey(passphrase)
privateKey = modifyPkString(convertedPk)
createBoxJsonSettingsFile(privateKey)

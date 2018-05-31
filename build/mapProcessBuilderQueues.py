#!/usr/bin/python

import sys
import json

if len(sys.argv) < 4:
    print('mapProcessBuilderQueues.py <sourceMapping> <destinationMapping> <file>')
    sys.exit(1)

with open(sys.argv[1], 'r') as file:
    source = json.loads(file.read())

with open(sys.argv[2], 'r') as file:
    destination = json.loads(file.read())

fileName = sys.argv[3]

sourceIdToName      = {record['Id'] : record['DeveloperName'] for record in source['result']['records']}
destinationNameToId = {record['DeveloperName'] : record['Id'] for record in destination['result']['records']}

sourceIdToDestinationId = {id : destinationNameToId[sourceIdToName[id]] if sourceIdToName[id] in destinationNameToId else None for id in sourceIdToName.keys()}

with open(fileName, 'r') as file :
    filedata = file.read()

for sourceId, destinationId in sourceIdToDestinationId.items():
    if destinationId != None:
        filedata = filedata.replace(sourceId, destinationId)

with open(fileName, 'w') as file:
    file.write(filedata)
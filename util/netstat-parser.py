import re
import json

# Methods for parsing Connections 
def createDict(x,keys):
    connection = {}
    for i,j in enumerate(keys):
        # print(i,j)
        # print(x[i])
        if(connection.get("Proto") == 'UDP' and j.count("State")):
            connection[j] = None
        elif connection.get('Proto') == 'UDP' and j == 'PID':
            connection[j] = x[i-1]
        else:
            connection[j] = x[i]
    return connection

def addComponent(currentConnections, component):
    for connection in currentConnections:
        if 'Component' not in connection:
            connection['Component'] = component

def addExe(currentConnections, exe):
    for connection in currentConnections:
        if 'Exe' not in connection:
            connection['Exe'] = exe

def parseConnections(line):
    # getting the keys
    print(line)
    connectionKeys = x = re.split("[ ]{2,}", line)
    print(connectionKeys)
    # connections
    line = file.readline().strip()
    while(len(line) == 0):
        line = file.readline().strip()
    connectionsList = []
    while (len(line) > 0):
        if(line == "Can not obtain ownership information"):
            addExe(connectionsList,None)
            addComponent(connectionsList,None)
        elif(line[0] == '[' and line[-1] == ']'):
            addExe(connectionsList,line)
            addComponent(connectionsList,None)
        elif len(line.split()) > 1:
            x = line.split()
            connectionsList.append(createDict(x,connectionKeys))
        elif len(line.split()) == 1:
            addComponent(connectionsList,line)
        line = file.readline().strip()
    return connectionsList

# Methods for parsing rounting table
def parseInterfaceList(line):
    interfaceList = []
    while not line.endswith('='):
        interfaceList.append(line.strip())
        line = file.readline().strip()
    return interfaceList

def parseIPV4(line):
    activeList = []
    persistentList = []
    IPV4 = {
        'Active Routes': activeList,
        'Persistent Routes': persistentList
    }
    while len(line) > 0:
        if line == 'Active Routes:':
            line = file.readline().strip()
            parseActiveRoutes(line, activeList, True)
        elif line == 'Persistent Routes:':
            line = file.readline().strip()
            parsePersistentRoutes(line, persistentList, True)
        line = file.readline().strip()
    return IPV4

def parseIPV6(line):
    activeList = []
    persistentList = []
    IPV6 = {
        'Active Routes': activeList,
        'Persistent Routes': persistentList
    }
    while len(line) > 0:
        if line == 'Active Routes:':
            line = file.readline().strip()
            parseActiveRoutes(line, activeList, False)
        elif line == 'Persistent Routes:':
            line = file.readline().strip()
            parsePersistentRoutes(line, persistentList, False)
        line = file.readline().strip()
    return IPV6

def parsePersistentRoutes(line, routeList, isIPV4):
    if line == "None":
        return
    else:
        line = file.readline()
        while not line.endswith('='):
            route = line.split()
            if isIPV4:
                route = createIPV4Route(route)
            else:
                route = createIPV6Route(route)
            routeList.append(route)
            line = file.readline().strip()

def parseActiveRoutes(line, routeList, isIPV4):
    line = file.readline()
    while not line.endswith('='):
        route = line.split()
        if isIPV4:
            route = createIPV4Route(route)
        else:
            if len(route) < 4:
                route.append(file.readline().strip())
            route = createIPV6Route(route)
        routeList.append(route)
        line = file.readline().strip()

def createIPV4Route(route):
    route = {
        'Network Destination': route[0],
        'Netmask': route[1],
        'Gateway': route[2],
        'Interface': route[3],
        'Metric': route[4]
    }
    return route

def createIPV6Route(route):
    route = {
        'If': route[0],
        'Metric': route[1],
        'Network Destination': route[2],
        'Gateway': route[3]
    }
    return route


def readFile(currentLine):
    while(len(currentLine) > 0):
        currentLine = currentLine.strip()
        if currentLine == 'Active Connections':
            currentLine = file.readline().strip()
            while(len(currentLine) == 0): # parse out any white space
                currentLine = file.readline().strip()
            jsonObject['Active Connections'] = parseConnections(currentLine)
        elif currentLine == 'Interface List':
            currentLine = file.readline().strip()
            while(len(currentLine) == 0): # parse out any white space
                currentLine = file.readline().strip()
            jsonObject['Interface List'] = parseInterfaceList(currentLine)
        elif currentLine == 'IPv4 Route Table':
            currentLine = file.readline().strip()
            while(len(currentLine) == 0): # parse out any white space
                currentLine = file.readline().strip()
            jsonObject['IPV4'] = parseIPV4(currentLine)
        elif currentLine == 'IPv6 Route Table':
            currentLine = file.readline().strip()
            while(len(currentLine) == 0): # parse out any white space
                currentLine = file.readline().strip()
            jsonObject['IPV6'] = parseIPV6(currentLine)
        currentLine = file.readline()
    newFile.write(json.dumps(jsonObject, indent=1))

fileName = input("Enter name of netstat file to parse:") 
try:
    file = open(fileName + '.txt', "r")
except:
    print("Please enter a valid file name")
else:
    newFile = open(fileName+'-json.txt', 'w')
    currentLine = file.readline()
    jsonObject = {}
    readFile(currentLine)
    file.close()
    newFile.close()
    
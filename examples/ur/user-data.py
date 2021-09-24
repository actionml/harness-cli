import urllib.request
import json
import argparse
import csv
import time


def get_entity_data(url, engineId, entityId, offset, limit):
    with urllib.request.urlopen(f"{url}/engines/{engineId}/entities/{entityId}?from={offset}&num={limit}") as b:
        return json.loads(b.read().decode('utf-8'))

def parseCsv(file):
    with open(file) as csvfile:
        reader = csv.DictReader(csvfile, fieldnames=['entityId', 'event', 'targetEntityId'])
        result = []
        for row in reader:
            if row['event'] != "$set":
                for j in row.items():
                    result.append({'entityId': j[1]})
                    break
        return result

def filterByEntityId(entities, id):
    result = []
    for i in entities:
        if i['entityId'] == id:
            result.append(i)
    return result

def compareEntities(actual, expected):
    return len(actual) == len(expected)

def deleteEntities(url, engineId, entityId):
    req = urllib.request.Request(f"{url}/engines/{engineId}/entities/{entityId}", method="DELETE")
    with urllib.request.urlopen(req) as b:
        return


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--url', default="http://localhost:9090")
    parser.add_argument('--engineId')
    parser.add_argument('--entityId')
    parser.add_argument('--offset', default=0)
    parser.add_argument('--limit', default=1000)
    parser.add_argument('--compare-with')

    args = parser.parse_args()
    getPassed = compareEntities(get_entity_data(args.url, args.engineId, args.entityId, args.offset, args.limit),
                       filterByEntityId(parseCsv(args.compare_with), args.entityId))
    deleteEntities(args.url, args.engineId, args.entityId)
    time.sleep(2)
    deletePassed = not get_entity_data(args.url, args.engineId, args.entityId, args.offset, args.limit)

    if not getPassed:
        print("Get user data test fails")
    if not deletePassed:
        print("Delete user data test fails")

"""
Import sample data for recommendation engine
"""

import harness
import argparse
import random
import datetime
import pytz

RATE_ACTIONS_DELIMITER = ","
PROPERTIES_DELIMITER = ":"
SEED = 1

""" 
indicator event
{
    "event" : "event-name",
    "entityType" : "user",
    "entityId" : "user-id",
    "targetEntityType": "item",
    "targetEntityId" : "item-id",
    "eventTime": "ISO-8601 encoded string",
}

$set events
!!! We only use categorical properties in this import !!!
{
   "event":"$set",
   "entityType":"item",
   "entityId":"Mr Robot",
    "properties" : {
        "categorical-property-name": ["array", "of", "strings"]
        "date-property-name": "ISO-8601 encoded string",
        "ranking-property-name": float,
    },
    "eventTime": "ISO-8601 encoded string",
}
"""


def import_events(client, file, primary_event):
    f = open(file, 'r')
    random.seed(SEED)
    count = 0

    now_date = datetime.datetime.now(pytz.utc) - datetime.timedelta(days=2.7)
    current_date = now_date
    event_time_increment = datetime.timedelta(days= 0.8)
    print("Importing data...")

    for line in f:
        data = line.rstrip('\r\n').split(RATE_ACTIONS_DELIMITER)
        # For demonstration purpose action names are taken from input along with secondary actions on
        # For the UR add some item metadata

        if (data[1] != "$set"):
            client.create(
                event=data[1],
                entity_type="user",
                entity_id=data[0],
                target_entity_type="item",
                target_entity_id=data[2],
                event_time=current_date
            )

            print("Event: " + data[1] + " entity_id: " + data[0] + " target_entity_id: " + data[2])

        elif data[1] == "$set":  # must be a set event
            properties = data[2].split(PROPERTIES_DELIMITER)
            prop_name = properties.pop(0)
            prop_value = properties if not prop_name == 'defaultRank' else float(properties[0])

            client.create(
                event=data[1],
                entity_type="item",
                entity_id=data[0],
                event_time=current_date,
                properties={prop_name: prop_value}
            )

            print("Event: " + data[1] + " entity_id: " + data[0] + " properties/"+prop_name+": " + str(properties))
        count += 1
        current_date += event_time_increment

    f.close()
    print("%s events are imported." % count)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Import sample data for Universal Recommender Engine")
    parser.add_argument('--engine_id', default='test_ur')
    parser.add_argument('--url', default="http://localhost:9090")
    parser.add_argument('--input_file', default="examples/ur/sample-mobile-device-ur-data.csv")
    parser.add_argument('--primary_event', default="purchase")
    parser.add_argument('--secret', default=None)
    parser.add_argument('--secret_2', default=None)

    args = parser.parse_args()
    print(args)

    client = harness.EventsClient(
        engine_id=args.engine_id,
        url=args.url,
        threads=5,
        qsize=500 # ,
        # user_id=args.user_id,
        # user_secret=args.secret
        )
    import_events(client, args.input_file, args.primary_event)

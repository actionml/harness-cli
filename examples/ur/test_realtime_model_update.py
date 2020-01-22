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
$set events
We only use categorical properties in this test
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



def set_item_property(client):
    random.seed(SEED)
    now_date = datetime.datetime.now(pytz.utc) - datetime.timedelta(days=2.7)
    current_date = now_date
    event_time_increment = datetime.timedelta(days= -0.8)
    available_date_increment = datetime.timedelta(days= 0.8)
    event_date = now_date # - datetime.timedelta(days= 1.3)
    available_date = event_date + datetime.timedelta(days=-1)
    expire_date = event_date + datetime.timedelta(days=1)
    # print("Setting categories on iPhone XS")

    """
    event="$set",
    entity_type="item",
    entity_id=item,
    properties={"expireDate": expire_date.isoformat(timespec="milliseconds"),
                "availableDate": available_date.isoformat(timespec="milliseconds"),
                "date": event_date.isoformat(timespec="milliseconds")}
    """
    client.create(
        event="$set",
        entity_type="item",
        entity_id="iPhone XS",
        event_time=current_date,
        properties={"categories": ["Phones", "Electronics"]}
    )
    print("Event: $set, entity_id: iPhone XS, properties: categories = [\"Phones\", \"Electronics\"]" + \
          " current_date: " + current_date.isoformat(timespec="milliseconds"))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Import sample data for Universal Recommender Engine")
    parser.add_argument('--engine_id', default='test_ur')
    parser.add_argument('--url', default="http://localhost:9090")
    parser.add_argument('--secret', default=None)
    parser.add_argument('--secret_2', default=None)

    args = parser.parse_args()
    print(args)

    import_client = harness.EventsClient(
        engine_id=args.engine_id,
        url=args.url,
        threads=5,
        qsize=500 # ,
        # user_id=args.user_id,
        # user_secret=args.secret
    )
    query_client = harness.QueriesClient(
        engine_id=args.engine_id,
        url=args.url,
        threads=5,
        qsize=500 # ,
        # user_id=args.user_id,
        # user_secret=args.secret
    )
    set_item_property(import_client)

    return

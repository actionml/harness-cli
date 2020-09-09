#!/usr/bin/env python3

from harness import SystemClient, HttpError

from common import *

system_client = SystemClient(
    url=url,
    user_id=client_user_id,
    user_secret=client_user_secret
)

if args.action == 'info':
    try:
        res = system_client.info()
        # print(str(res))
        print_success(res, 'Harness server and system info:\n')
    except HttpError as err:
        print_failure(err, 'Error getting Harness system info.\n')

else:
    print_warning("Unknown options: %{}".format(args.action))

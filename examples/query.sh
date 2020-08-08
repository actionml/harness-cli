#!/usr/bin/env bash

echo
curl -H "Content-Type: application/json" -d '
{
  "item": "Galaxy 8"
}' http://localhost:9090/engines/test_ur/queries

echo
curl -H "Content-Type: application/json" -d '
{
  "itemSet": ["Galaxy 8"]
}' http://localhost:9090/engines/test_ur/queries

echo
curl -H "Content-Type: application/json" -d '
{
  "itemSet": ["Galaxy 8", "iPhone 8"]
}' http://localhost:9090/engines/test_ur/queries

#!/usr/bin/env bash

echo
curl -H "Content-Type: application/json" -d '
{
  "item": "Galaxy 8",
  "rules": [
    {
      "name": "categories",
      "values": ["Phones"],
      "bias": -1
    }
  ]
}' http://localhost:9090/engines/test_ur/queries

echo
curl -H "Content-Type: application/json" -d '
{
  "itemSet": ["Galaxy 8"],
  "rules": [
    {
      "name": "categories",
      "values": ["Phones"],
      "bias": -1
    }
  ]
}' http://localhost:9090/engines/test_ur/queries

echo
curl -H "Content-Type: application/json" -d '
{
  "itemSet": ["Galaxy 8", "iPhone 8"],
  "rules": [
    {
      "name": "categories",
      "values": ["Phones"],
      "bias": -1
    }
  ]
}' http://localhost:9090/engines/test_ur/queries

#!/usr/bin/env bash

echo
curl -H "Content-Type: application/json" -d '
{
  "item": "Galaxy 8",
  "rules": [
    {
      "name": "categories",
      "values": ["Apple"],
      "bias": 0
    }
  ]
}' http://localhost:9090/engines/test_ur/queries

echo
curl -H "Content-Type: application/json" -d '
{
  "itemSet": ["Galaxy 8"],
  "rules": [
    {
      "name": "categories",
      "values": ["Apple"],
      "bias": 0
    }
  ]
}' http://localhost:9090/engines/test_ur/queries

echo
curl -H "Content-Type: application/json" -d '
{
  "user": "",
  "rules": [
    {
      "name": "categories",
      "values": ["Apple"],
      "bias": 0
    }
  ]
}' http://localhost:9090/engines/test_ur/queries

curl -H "Content-Type: application/json" -d '
{
}' http://localhost:9090/engines/test_ur/queries

#!/usr/bin/env bash
curl -H "Content-Type: application/json" -d '
{
  "user": "u1"
}' http://localhost:9090/engines/test_ur/queries
echo

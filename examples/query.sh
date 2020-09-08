#!/usr/bin/env bash


curl -H "Content-Type: application/json" -d '
{
  "user": "U 2"
}' localhost:9090/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "blacklistItems": ["USB-C Ear Buds"]
}' localhost:9090/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "blacklistItems": ["USB-C Ear Buds", "iPhone Case"]
}' localhost:9090/engines/test_ur/queries
echo

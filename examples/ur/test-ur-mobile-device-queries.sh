#!/usr/bin/env bash

if [ -z "$1" ] ; then
  export host_url=http://localhost:9090
else
  export host_url=$1
fi

echo "Queries to: "${host_url}

echo
echo "+++++++++++++ User-based     +++++++++++++"
echo

# passes but with limited hand checking like exclusion of bought items
curl -H "Content-Type: application/json" -d '
{
  "num": 20
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "user": "u1"
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "user": "U 2"
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "user": "u-3"
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "user": "u-4"
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "user": "u5"
}' $host_url/engines/test_ur/queries
echo

echo
echo "++++ Personalized with Business Rules ++++"
echo "============= Inclusion      ============="
echo

curl -H "Content-Type: application/json" -d '
{
  "user": "U 2"
}' $host_url/engines/test_ur/queries
echo

# passes
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": -1
    }
  ]
}' $host_url/engines/test_ur/queries
echo

# passes
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "rules": [
    {
       "name": "categories",
       "values": ["Phones"],
       "bias": -1
    }
  ]
}' $host_url/engines/test_ur/queries
echo

# passes
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets", "Phones"],
       "bias": -1
    }
  ]
}' $host_url/engines/test_ur/queries
echo

echo
echo "============= Exclusion      ============="
echo

curl -H "Content-Type: application/json" -d '
{
  "user": "U 2"
}' $host_url/engines/test_ur/queries
echo

# passes
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": 0
    }
  ]
}' $host_url/engines/test_ur/queries
echo

# passes
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "rules": [
    {
       "name": "categories",
       "values": ["Phones"],
       "bias": 0
    }
  ]
}' $host_url/engines/test_ur/queries
echo

# passes
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets", "Phones"],
       "bias": 0
    }
  ]
}' $host_url/engines/test_ur/queries
echo

echo
echo "============= Boost          ============="
echo

curl -H "Content-Type: application/json" -d '
{
  "user": "U 2"
}' $host_url/engines/test_ur/queries
echo

# passes
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": 20
    }
  ]
}' $host_url/engines/test_ur/queries
echo

# passes
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "rules": [
    {
       "name": "categories",
       "values": ["Phones"],
       "bias": 20
    }
  ]
}' $host_url/engines/test_ur/queries
echo

# fail?
# todo: there results here look wrong, they should be ranked the same as no boost
# but have an odd shuffled ranking, neither no-boost, not no-boost time boost
# no item should have both of these categories so should only get one boost
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets", "Phones"],
       "bias": 20
    }
  ]
}' $host_url/engines/test_ur/queries
echo

echo
echo "============= Include A & B ============="
echo

curl -H "Content-Type: application/json" -d '
{
  "user": "U 2"
}' $host_url/engines/test_ur/queries
echo

# passes
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": -1
    },{
       "name": "categories",
       "values": ["Apple"],
       "bias": -1
    }
  ]
}' $host_url/engines/test_ur/queries
echo

# passes
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": -1
    },{
       "name": "categories",
       "values": ["Microsoft"],
       "bias": -1
    }
  ]
}' $host_url/engines/test_ur/queries
echo

# passes: "U 2" bought a Pixel Slate so no results
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": -1
    },{
       "name": "categories",
       "values": ["Google"],
       "bias": -1
    }
  ]
}' $host_url/engines/test_ur/queries
echo

echo
echo "+++++++++++++ Item-based     +++++++++++++"
echo

# fails, includes self: iPhone XS
curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XS"
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR"
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone 8"
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "item": "iPad Pro"
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "item": "Pixel Slate"
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "item": "Galaxy 8"
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "item": "Surface Pro"
}' $host_url/engines/test_ur/queries
echo

echo
echo "+++++ Item-based with Business Rules +++++"
echo "============= Inclusion      ============="
echo

echo "------------- iPhone XR all  -------------"
curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR"
}' $host_url/engines/test_ur/queries
echo

echo "------------- iPhone XR rules ------------"
curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": -1
    }
  ]
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR",
  "rules": [
    {
       "name": "categories",
       "values": ["Phones"],
       "bias": -1
    }
  ]
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets", "Phones"],
       "bias": -1
    }
  ]
}' $host_url/engines/test_ur/queries
echo

echo
echo "============= Exclusion      ============="
echo
echo "------------- iPhone XR all  -------------"
curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR"
}' $host_url/engines/test_ur/queries
echo

echo "------------- iPhone XR rules ------------"
curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": 0
    }
  ]
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR",
  "rules": [
    {
       "name": "categories",
       "values": ["Phones"],
       "bias": 0
    }
  ]
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets", "Phones"],
       "bias": 0
    }
  ]
}' $host_url/engines/test_ur/queries
echo

echo
echo "============= Boost          ============="
echo
echo "------------- iPhone XR all  -------------"
curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR"
}' $host_url/engines/test_ur/queries
echo

echo "------------- iPhone XR rules ------------"
curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": 20
    }
  ]
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR",
  "rules": [
    {
       "name": "categories",
       "values": ["Phones"],
       "bias": 20
    }
  ]
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets", "Phones"],
       "bias": 20
    }
  ]
}' $host_url/engines/test_ur/queries
echo

echo
echo "============= Include A & B ============="
echo

curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": -1
    },{
       "name": "categories",
       "values": ["Apple"],
       "bias": -1
    }
  ]
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": -1
    },{
       "name": "categories",
       "values": ["Microsoft"],
       "bias": -1
    }
  ]
}' $host_url/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": -1
    },{
       "name": "categories",
       "values": ["Google"],
       "bias": -1
    }
  ]
}' $host_url/engines/test_ur/queries

echo
echo
echo "+++++++++++++ Item-set-based +++++++++++++"
echo "---------- All Apple but iPhone 8 --------"
curl -H "Content-Type: application/json" -d '
{
  "itemSet": ["iPhone XR", "iPhone XS", "iPad Pro"]
}' $host_url/engines/test_ur/queries
echo

echo "----------- Include only Phone -----------"
curl -H "Content-Type: application/json" -d '
{
  "itemSet": ["iPhone XR", "iPhone XS", "iPad Pro"],
  "rules": [
    {
       "name": "categories",
       "values": ["Phones"],
       "bias": -1
    }
  ]
}' $host_url/engines/test_ur/queries
echo


echo "----------- Include only Phone -----------"
echo "----------- Boost Apple ------------------"
curl -H "Content-Type: application/json" -d '
{
  "itemSet": ["iPhone XR", "iPhone XS", "iPad Pro"],
  "rules": [
    {
       "name": "categories",
       "values": ["Phones"],
       "bias": -1
    },
    {
       "name": "categories",
       "values": ["Apple"],
       "bias": 20
    }
  ]
}' $host_url/engines/test_ur/queries
echo



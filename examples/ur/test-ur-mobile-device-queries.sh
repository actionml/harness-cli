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
  "user": "non-existent user"
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
echo "============= by categories  ============="
echo

echo "------------- all U 2       -------------"
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2"
}' $host_url/engines/test_ur/queries
echo

echo "------------- Tablets        -------------"
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

echo "------------- Phones         -------------"
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

echo "------------- Tablets OR Phones -------------"
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

echo "------------- Tablets AND Phones -------------"
echo "No results since no items have categories: Phones AND Tablets"
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": -1
    },
    {
       "name": "categories",
       "values": ["Phones"],
       "bias": -1
    }
  ]
}' $host_url/engines/test_ur/queries
echo

echo
echo "============= Exclusion      ============="
echo "============= by categories  ============="
echo

echo "------------- all            -------------"
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2"
}' $host_url/engines/test_ur/queries
echo

echo "------------- No Tablets     -------------"
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

echo "------------- No Phones     -------------"
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

echo "------------- No Tablets OR Phones -------------"
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

echo "------------- No Tablets AND no Phones -------------"
echo "No difference from OR"
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": 0
    },
    {
       "name": "categories",
       "values": ["Phones"],
       "bias": 0
    }
  ]
}' $host_url/engines/test_ur/queries
echo

echo
echo "============= Boost          ============="
echo "============= by categories  ============="
echo

echo "------------- all            -------------"
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2"
}' $host_url/engines/test_ur/queries
echo

echo "------------- Highly Boost Tablets -------------"
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

echo "------------- Highly Boost Phones -------------"
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
# todo: these results look wrong?
echo "------------- Highly Boost Tablets OR Phones ------------"
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

echo "------------- Highly Boost Tablets AND Phones -----------"
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": 20
    },
    {
       "name": "categories",
       "values": ["Phones"],
       "bias": 20
    }
  ]
}' $host_url/engines/test_ur/queries
echo

echo
echo "============= Include A & B ============="
echo "============= by categories  ============="

echo "------------- all            -------------"
curl -H "Content-Type: application/json" -d '
{
  "user": "U 2"
}' $host_url/engines/test_ur/queries
echo

echo "------------- Must Include Tablets AND Apple -------------"
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

echo "------------- Must Include Tablets AND Microsoft -------------"
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

echo "------------- Must Include Tablets AND Google -------------"
echo "Note: U 2 bought a Pixel Slate so no results"
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
  "item": "non-existent item"
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

echo "------------- Tablets ------------"
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

echo "------------- Phones ------------"
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

echo "------------- Tablets OR Phones ------------"
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

echo "------------- Tablets AND Phones ------------"
echo "No results since no item has categories: Tablets & Phones"
curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": -1
    },
    {
       "name": "categories",
       "values": ["Phones"],
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

echo "------------- Tablets ------------"
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

echo "------------- Phones ------------"
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

echo "------------- Tablets OR Phones ------------"
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

echo "------------- exclude Tablets AND exclude Phones ------------"
echo "No difference from OR"
curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": 0
    },
    {
       "name": "categories",
       "values": ["Phones"],
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

echo "------------- Tablets ------------"
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

echo "------------- Phones ------------"
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

echo "------------- Tablets OR Phones ------------"
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

echo "------------- Tablets AND Phones ------------"
echo "No different from OR"
curl -H "Content-Type: application/json" -d '
{
  "item": "iPhone XR",
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": 20
    },
    {
       "name": "categories",
       "values": ["Phones"],
       "bias": 20
    }
  ]
}' $host_url/engines/test_ur/queries
echo

echo
echo
echo "+++++++++++++ Item-set-based +++++++++++++"
echo "---------- All for Apple Phones --------"
curl -H "Content-Type: application/json" -d '
{
  "itemSet": ["iPhone XR", "iPhone XS", "iPad Pro"]
}' $host_url/engines/test_ur/queries
echo

echo "----------- Include only Phones -----------"
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

echo "----------- Include only Tablets -----------"
curl -H "Content-Type: application/json" -d '
{
  "itemSet": ["iPhone XR", "iPhone XS", "iPad Pro"],
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": -1
    }
  ]
}' $host_url/engines/test_ur/queries
echo

echo "----------- Include only Tablets OR Phones-----------"
curl -H "Content-Type: application/json" -d '
{
  "itemSet": ["iPhone XR", "iPhone XS", "iPad Pro"],
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets", "Phones"],
       "bias": -1
    }
  ]
}' $host_url/engines/test_ur/queries
echo

echo "----------- Include only Tablets AND Phones-----------"
curl -H "Content-Type: application/json" -d '
{
  "itemSet": ["iPhone XR", "iPhone XS", "iPad Pro"],
  "rules": [
    {
       "name": "categories",
       "values": ["Tablets"],
       "bias": -1
    },
    {
       "name": "categories",
       "values": ["Phones"],
       "bias": -1
    }
  ]
}' $host_url/engines/test_ur/queries
echo


echo "----------- Mixed Biases -----------------"
echo "----------- Include only Phones ----------"
echo "----------- AND Boosts Apple -------------"
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



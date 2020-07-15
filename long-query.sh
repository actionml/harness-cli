#!/usr/bin/env bash
echo

#curl -H "Content-Type: application/json" -d '
#{
#    "itemSet": ["323845-F", "323475-F", "325804-F", "325887-F", "316977-F"]
#}' http://gt:9090/engines/govtribe_opportunity_recommender_v6/queries

curl -H "Content-Type: application/json" -d '
{
    "user": "5c78388ba1c4c51f0867ef68"
}' http://gt:9090/engines/govtribe_opportunity_recommender_v6/queries

#curl -H "Content-Type: application/json" -d '
#{
#    "item": "581892440054995bfdb6aae7e36c6cc5"
#}' http://gt:9090/engines/govtribe_opportunity_recommender_v7/queries

echo
echo


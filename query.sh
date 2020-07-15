#!/usr/bin/env bash
curl -H "Content-Type: application/json" -d '
{
    "from": 0,
    "num": 2,
    "rules": [
    {
        "name": "opportunity-class",
        "values": ["FederalContractOpportunityModel"],
        "bias": -1
    },
    {
        "name": "set-aside",
        "values": ["No Set-Aside Used"],
        "bias": -1
    },
    {
        "name": "naics",
        "values": ["511210-N", "541519-N"],
        "bias": -1
    },
    {
        "name": "opp-type",
        "values": ["Solicitation", "Pre-Solicitation", "Special Notice", "Grant", "Cooperative Agreement", "Procurement Contract", "Other"],
        "bias": -1
    }],
    "dateRange":
    {
        "name": "due-date",
        "after": "2020-04-24T21:07:06Z"
    },
    "user": "YWFXNE5xYVhicmx3NkVsUXhnRm5yUT09"
}' http://gt:9090/engines/govtribe_opportunity_recommender_v7/queries
echo

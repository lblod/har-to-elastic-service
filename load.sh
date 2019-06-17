#!/usr/bin/env bash

#/ Usage: ./load.sh
#/ Description: Load every enriched .har file in the configure folder to ElasticSearch.
#/ Options:
#/     --help: Display this help message
usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage



# Convenience logging function.
info()    {
    now=`date +%Y%m%dT%H%M%S`
    echo "[INFO] $now:  $@";
}

# Poll the ElasticSearch container
poll() {
  local hostname=$1
  local result=$(curl -XGET http://${hostname}:9200 -I 2>/dev/null | head -n 1 | awk '{ print $2 }')
  if [[ $result == "200" ]]; then
    return 1 # ElasticSearch is up.
  else
    return 0 # It will execute as long as the return code is zero.
  fi
}


load_files() {
    # Find all .trans.har files in the specified folder/
    # For each one, post to ElasticSearch.
    for x in $HAR_FOLDER/*.trans.har;do
        count=`jq '.log.entries | length' < $x`
        if [[ "$count" -gt "0" ]]; then
            info "Posting $x to $ELASTIC_HOST"
            jq -c -r '.log.entries[]' < $x | while read -r entry
            do
                echo -e "$entry" > .post
                curl -XPOST -H 'Content-Type: application/json' -d '@.post'  "http://${ELASTIC_HOST}:9200/hars/har?pretty"
            done
            rm .post
            sleep 0.5
        else
            info "ignoring empty file $x"
        fi
        mv $x $PROCESSED_FOLDER
    done
}

LOAD_INTERVAL=${LOAD_INTERVAL:-60}
HAR_FOLDER=${HAR_FOLDER:-/data/hars}
PROCESSED_FOLDER=${PROCESSED_FOLDER:-/data/processed}

info "ElasticSearch host: ${ELASTIC_HOST}"
while poll $ELASTIC_HOST
do
    info "ElasticSearch is not up (yet?)"
    sleep 0.5
done

info "increasing total fields limit of hars index"
curl -XPUT "http://${ELASTIC_HOST}:9200/hars"
curl -XPUT -H 'Content-Type: application/json' -d '{"index.mapping.total_fields.limit": 10000}'  "http://${ELASTIC_HOST}:9200/hars/_settings"

if [ -z $LOAD_INTERVAL ];then
    load_files
else
    while true
    do
        load_files
        sleep $LOAD_INTERVAL
    done
fi





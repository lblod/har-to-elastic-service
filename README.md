# har-to-elastic-service
A docker container to load har files into elastic search. Each entry of the har file will be represented by an entity in elasticsearch.

## configuration
Configuration is done via environment variables

* `DATA_FOLDER`: folder that has har files to be stored in elastic search.
* `PROCESSED_FOLDER`: folder where uploaded har files are moved to
* `LOAD_INTERVAL`: interval to scan the data folder, set to empty string to disable.

## usage

# one off load
`docker run --rm -v /your/processed/folder:/data/processed -v /your/hars/folder:/data/hars -e LOAD_INTERVAL=false  lblod/har-to-elastic-service`

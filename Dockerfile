FROM ubuntu:16.04
ENV LOAD_INTERVAL=60 DATA_FOLDER=/data/hars PROCESSED_FOLDER=/data/processed ELASTIC_HOST=elastic
RUN apt-get update -y && apt-get install -y curl jq
COPY load.sh /app/load.sh
CMD ["/app/load.sh"]

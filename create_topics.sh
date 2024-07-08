#!/bin/bash

set -e

# Read topics configuration from JSON
TOPICS_JSON="/opt/topics.json"
KAFKA_CONTAINER="kafka"

# Loop through topics in JSON array
topics=$(jq -c '.[]' "$TOPICS_JSON")
while IFS= read -r topic; do
  name=$(echo "$topic" | jq -r '.name')
  partitions=$(echo "$topic" | jq -r '.partitions')
  replicationFactor=$(echo "$topic" | jq -r '.replicationFactor')

  # Create Kafka topic
  docker exec -it "$KAFKA_CONTAINER" \
    kafka-topics.sh --create \
      --topic "$name" \
      --partitions "$partitions" \
      --replication-factor "$replicationFactor" \
      --if-not-exists \
      --zookeeper zookeeper:2181

  echo "Kafka topic '$name' created with $partitions partitions and replication factor $replicationFactor."
done <<< "$topics"

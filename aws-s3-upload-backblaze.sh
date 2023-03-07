#!/bin/bash

# Set the name of the bucket and the path to the local folder
BUCKET_NAME=""
LOCAL_PATH=""
ENDPOINT_URL=""
PROFILE=""

# Set the path of the log file
LOG_FILE_PATH=""

aws s3 sync "$LOCAL_PATH" "$BUCKET_NAME" --endpoint-url="$ENDPOINT_URL" --noprogress --include "*" --log-file "$LOG_FILE_PATH" --profile "$PROFILE"

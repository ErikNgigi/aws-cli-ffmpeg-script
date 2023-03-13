#!/bin/bash

# --------------------------------------------------------------------------------------------------------
# FFMPEG
# --------------------------------------------------------------------------------------------------------

echo "Starting FFMPEG conversion of .wav files to .ogg mono 64kbps.........."

# Directory where folders will Set the source and destination directories
source_directory="$HOME/"
destination_directory="$HOME/AWS/output-files"
secondary_directory="$HOME/AWS/completed-files"
ffmpeg_log_directory="$HOME/AWS/log-files/ffmpeg-logs"

# Check if source directory exists and has .wav files
if [ ! -d "$source_directory" ]; then
  echo "No .wav files found at $source_directory directory"
  exit 1
elif [ ! "$(ls -A $source_directory/*.wav 2>/dev/null)" ]; then
  echo "No .wav files found in source directory"
  exit 0
fi

# Create the destination directory with the current timestamp
current_timestamp=$(date +%Y-%m)
mkdir -p "$destination_directory/$current_timestamp"
mkdir -p "$secondary_directory/$current_timestamp"

# Loop through each file in the source directory with a .wav extension
for file in "$source_directory"/*.wav; do
    # Get the filename and extension of the file
    filename=$(basename -- "$file")
    extension="${filename##*.}"

    # Check if the extension is .wav
    if [ "$extension" = "wav" ]; then
        # Set the output filename and path
        output_filename="${filename%.*}.ogg"
        output_path="$destination_directory/$current_timestamp/$output_filename"

        # Convert the file to .ogg mono 64kbps
        ffmpeg -hide_banner -loglevel panic -i "$file" -acodec libvorbis -ac 1 -ab 64000 "$output_path"

        # Check if the conversion was successful
        if [ $? -eq 0 ]; then
            echo "$(date +"%Y-%m-%d %H:%M:%S"): Converted $filename to $output_filename" >> "$ffmpeg_log_directory/ffmpeg-$current_timestamp"
        else
            echo "$(date +"%Y-%m-%d %H:%M:%S"): Failed to convert $filename" >> "$ffmpeg_log_directory/ffmpeg-$current_timestamp"
        fi

        # Move the original .wav file to the destination directory
        mv "$file" "$secondary_directory/$current_timestamp/"
    fi
done

echo "FFMPEG Conversion Done..........."

# --------------------------------------------------------------------------------------------------------
# Backblaze
# --------------------------------------------------------------------------------------------------------

echo "Starting Backblaze Transfer.........."

# Set the name of the bucket and the path to the local folder and other variables

backblaze_b2_bucket="<name_of_backblaze_b2_bucket>"
local_folder="<path_of_local_directory>"
backblaze_endpoint_url="<url_for_backblaze_b2_bucket>"
backblaze_profile="<profile_name_for_backblaze_b2_bucket>"
log_file_name="backblaze"
log_directory="<path_of_log_directory>"

#Get current date
current_date=$(date +"%Y-%m-%d")

# Set the path of the log file
backblaze_upload_logs="$log_directory/$log_file_name-$current_date.log"
backblaze_permissions_logs="$log_directory/backblaze-b2-permissions-$current_date.log"

# Check bucket permissions
echo "Checking Backblaze bucket permissions..."
aws s3api get-bucket-acl --bucket "$backblaze_b2_bucket" --endpoint-url="$backblaze_endpoint_url" --profile "$backblaze_profile" >> /dev/null 2>&1
if [ $? -eq 0 ]
then
  echo "User has write permission in the $backblaze_b2_bucket Backblaze bucket" >> "$backblaze_permissions_logs"
else
  echo "User does not have write permission in the $backblaze_b2_bucket Backblaze bucket" >> "$backblaze_permissions_logs"
  exit 1
fi

# Sync the local directory to the Backblaze B2 bucket, with logging enabled
echo "Uploading file/files to $backblaze_b2_bucket Backblaze bucket..."
aws s3 sync "$local_folder" s3://"$backblaze_b2_bucket"  --endpoint-url="$backblaze_endpoint_url" --no-progress --exclude "*" --include "*.ogg" --profile "$backblaze_profile" | awk '{print}' ORS='\n\n'>> "$backblaze_upload_logs"

# Message before termination
echo "Upload to the $backblaze_b2_bucket is complete.........."

#Log files message
echo "Logs report written to $log_file_name-$current_date.log in the directory $log_directory"
echo "Backblaze Transfer Complete"


# --------------------------------------------------------------------------------------------------------
# Bifrost
# --------------------------------------------------------------------------------------------------------

echo "Starting Bifrost Transfer...."
# Set the name of the bucket and the path to the local folder
bifrost_bucket="<name_of_bifrost_bucket>"
local_folder="<path_of_local_directory>"
bifrost_endpoint_url="<url_for_bifrost_bucket>"
bifrost_profile="<profile_name_for_bifrost_bucket>"
log_file_name="bifrost"
log_directory="<path_of_log_directory>"

#Get current date
current_date=$(date +"%Y-%m-%d")

# Set the path of the log file
bifrost_upload_logs="$log_directory/$log_file_name-$current_date.log"
bifrost_permissions_logs="$log_directory/$log_file_name-permissions-$current_date.log"

# Check if the user has write permission in the Bifrost bucket
echo "Checking Bifrost bucket permissions.........."

aws s3api get-bucket-acl --bucket "$bifrost_bucket" --endpoint-url="$bifrost_endpoint_url" --profile "$bifrost_profile" >> /dev/null 2>&1
if [ $? -eq 0 ]
then
  echo "User has write permission in the $bifrost_bucket Bifrost bucket" | awk '{print}' ORS='\n\n'>> "$bifrost_permissions_logs"
else
  echo "User does not have write permission in the $bifrost_bucket Bifrost bucket" | awk '{print}' ORS='\n\n'>> "$bifrost_permissions_logs"
  exit 1
fi

# Sync the local directory to the Bifrost bucket, with logging enabled
echo "Uploading file/files to $bifrost_bucket Bifrost bucket..."
aws s3 sync "$local_folder" s3://"$bifrost_bucket" --endpoint-url="$bifrost_endpoint_url" --no-progress --exclude "*" --include "*.ogg" --profile "$bifrost_profile" | awk '{print}' ORS='\n\n' >> "$bifrost_upload_logs"

# Message before termination
echo "$bifrost_bucket upload completed"

# Log files message
echo "Logs report written to $log_file_name-$current_date.log in the directory $log_directory"

echo "Bifrost Transfer Complete.........."


# --------------------------------------------------------------------------------------------------------
# Size Comparision of local folder and Bucket folders
# --------------------------------------------------------------------------------------------------------

# Starting message for comparision
echo "Starting the size comparision of Buckets to Local Directory.........."

# Set the timestamp prefix for the current month
prefix=$(date +%Y-%m)

# Log file for size comparision
size_log="$HOME/AWS/log-files/size-logs/size-logs-$current_date.log"

# Get the total size of the local folder
local_size=$(du -sb "$local_folder" | awk '{s+=$1} END {print s}')

# Get the total size of the B2 bucket
b2_size=$(aws s3api list-objects --bucket "$backblaze_b2_bucket" --prefix "$prefix" --endpoint-url="$backblaze_endpoint_url" --profile "$backblaze_profile"  --query "(sum(Contents[].Size))")

# Get the total size of the Bifrost bucket
bifrost_size=$(aws s3api list-objects --bucket "$bifrost_bucket" --prefix "$prefix" --endpoint-url="$bifrost_endpoint_url" --profile "$bifrost_profile"  --query "(sum(Contents[].Size))")

# Difference in sizes
diff=$(expr $b2_size - $local_size)

# Compare sizes
# Check if the sizes are greater than 1 Mb
if [[ $local_size -gt 1000000 && $b2_size -gt 1000000 && $bifrost_size -gt 1000000 ]]; then
  # Compare the sizes
  if [[ $local_size -eq $b2_size && $local_size -eq $bifrost_size ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Backblaze Bucket size: $b2_size bytes, Bifrost Bucket size: $bifrost_size, Local size: $local_size bytes, Folders are Equal" >> $size_log 
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Backblaze Bucket size: $b2_size bytes, Bifrost Bucket size: $bifrost_size, Local size: $local_size bytes, $diff" bytes >> $size_log
  fi
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Backblaze Bucket size: $b2_size bytes, Bifrost Bucket size: $bifrost_size, Local size: $local_size bytes, Folders are equal." >> $size_log
fi

# Ending message for size comparision.
echo "Ending the size comparision of Buckets to Local Directory.........."

# --------------------------------------------------------------------------------------------------------
# Logs Folder
# --------------------------------------------------------------------------------------------------------

# Upload the Log files to the Backblaze and Bifrost Buckets.
log_files_directory="$HOME/AWS/log-files"
echo "Transfering Logs to Backblaze............"

# Sync logs directory to the backblaze
aws s3 sync "$log_files_directory" s3://"$backblaze_b2_bucket" --endpoint-url="$backblaze_endpoint_url" --no-progress --profile "$backblaze_profile" >> /dev/null 2>&1
echo "Logs transfer to Backblaze complete..........."

# Sync logs directory to bitfrost
aws s3 sync "$log_files_directory" s3://"$bifrost_bucket" --endpoint-url="$bifrost_endpoint_url" --no-progress --profile "$bifrost_profile" >> /dev/null 2>&1
echo "Logs transfer to Bifrost complete.........."

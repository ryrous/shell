#!/bin/bash
# Clear the Safari browser history

# Define the path to the file
filePath="/Users/username/Library/Safari/History.db"

# Check if the file exists and remove it
if [ -f "$filePath" ]; then
    # Set Permissions
    chmod 777 "/Users/username/Library/Safari/History.db"
    # Remove File
    rm "$filePath"
    echo "Safari browser history has been cleared."
else
    echo "history.db file not found. History might have already been cleared."
fi
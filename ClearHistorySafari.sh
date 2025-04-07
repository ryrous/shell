#!/bin/bash
# Improved script to clear the Safari browser history by removing database files.
# WARNING: Directly deleting application support files can sometimes have unintended side effects.
#          It is strongly recommended to quit Safari before running this script.

echo "Attempting to clear Safari history..."

# Check if Safari is running
# The '-x' flag checks for exact match, '--' signifies end of options for pgrep
if pgrep -xq -- "Safari"; then
    echo "WARNING: Safari is currently running."
    echo "It is highly recommended to quit Safari manually before proceeding."
    # Optional: Add a prompt to quit or exit here if desired.
    # For now, we'll just warn and continue, but deletion might fail.
    sleep 3 # Give user a moment to read the warning
fi

# Define the path to Safari's Library folder using $HOME
safari_library_path="$HOME/Library/Safari"

# Define the files related to Browse history
# Note: This might need adjustment in future macOS versions
history_files=(
    "$safari_library_path/History.db"
    "$safari_library_path/History.db-shm"
    "$safari_library_path/History.db-wal"
    # Consider adding other files if needed, e.g., Downloads.plist, LastSession.plist for more thorough cleaning
    # "$safari_library_path/Downloads.plist"
    # "$safari_library_path/LastSession.plist"
)

# Check which history files exist
files_to_remove=()
found_files=false
for file in "${history_files[@]}"; do
    if [ -e "$file" ]; then # Use -e to check for general existence (file, symlink, etc.)
        files_to_remove+=("$file")
        found_files=true
    fi
done

# Exit if no relevant files were found
if ! $found_files; then
    echo "No Safari history files (History.db*) found in $safari_library_path."
    echo "History may already be clear or stored elsewhere."
    exit 0
fi

echo "The following Safari history-related files will be removed:"
printf " - %s\n" "${files_to_remove[@]}"

# Attempt to remove the files
# Use '-f' to force removal without prompting and ignore non-existent files (though we checked already)
rm -f "${files_to_remove[@]}"

# Verify removal and report status
all_removed=true
final_message="Safari history clearing process finished."

for file in "${files_to_remove[@]}"; do
    if [ -e "$file" ]; then
        echo "Error: Failed to remove $file."
        all_removed=false
    fi
done

if $all_removed; then
    echo "Successfully removed Safari history files."
    echo "Safari will recreate necessary files on its next launch."
else
    final_message="Error: Failed to remove one or more history files."
    echo "$final_message"
    echo "Possible reasons: Permissions issues, System Integrity Protection (SIP), or Safari is still running and locking the files."
    echo "Please ensure Safari is fully quit and try again. If issues persist, check permissions or consider SIP limitations."
    exit 1 # Exit with an error code
fi

echo "$final_message"
exit 0
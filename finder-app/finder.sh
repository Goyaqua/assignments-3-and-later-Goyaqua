#!/bin/bash

if [$# -ne 2]; then
	echo "Error: Incorrect number of arguments. Usage: $0 <filesdir> <searchstr>"
	exit 1
fi

filesdir=$1
searchstr=$2

if[ ! -d "$filesdir" ]; then
	echo "Error:Directory "$filesdir" does not exist."
	exit 1
fi

file_count=$(find "$filesdir" -type f | wc -1)

match_count=$(grep -r "$searchstr" "$filesdir" 2>/dev/null | wc -1)

echo "THe number of files are $file_count and number of matching lines are $match_count"

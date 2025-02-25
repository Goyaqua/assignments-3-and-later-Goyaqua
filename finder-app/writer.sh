#!/bin/bash

if [ $# -ne 2 ]; then
	echo "Error: Two arguments required. Usage: $0"
	exit 1
fi

writefile="$1"
writestr="$2"

mkdir -p $(dirname "$writefile")

if [ $? -ne 0 ]; then
	echo "Error: Failed to create directory $writefile."
	exit 1
fi

echo "$writestr" > "$writefile"

if [ $? -ne 0 ]; then
	echo "Error: Failed to write to file $writefile."
	exit 1
fi

echo "Successfully wrote to $writefile."

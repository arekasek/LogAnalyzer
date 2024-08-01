#!/bin/bash
reverse=false
num=""
sort_order=""
log_file=""

help() {
    echo "Usage: $0 -f <path_to_log_file> -n <number_of_events> [-r (descending/ascending)]"
    echo
    echo "Options:"
    echo "  -f <path_to_log_file>  Path to the log file"
    echo "  -n <number_of_events>  Specifies the number of events to display (from 1 to infinity)"
    echo "  -r                     Optional, sort in descending order"
    echo "  -h                     Display this help and exit"
}

while getopts ":f:n:rh" opt; do
  case $opt in
    f) 
        log_file="$OPTARG";;
    n) 
        if ! [[ "$OPTARG" =~ ^[1-9][0-9]*$ ]]; 
         then
            echo "Error: The number of events must be an integer greater than zero." >&2
            exit 1
        fi
        num="$OPTARG"
        ;;
    r) 
       reverse=true
       ;;
    h) 
       help
       exit 0
       ;;
    \?)
       echo "Invalid option: -$OPTARG requires an argument." >&2
       exit 1
       ;;
  esac
done

if [ -z "$log_file" ]; 
 then
  echo "Error: Specify the path to the log file: -f <path_to_log_file>" >&2
  exit 1
fi

if [ ! -f "$log_file" ]; 
 then
  echo "Error: File $log_file does not exist." >&2
  exit 1
fi

if [ -z "$num" ]; 
 then
  echo "Error: Specify the number of events to display: -n <number_of_events>" >&2
  exit 1
fi

if [ "$reverse" = true ]; 
 then
    sort_order="-r"
fi

grep ".*kernel.*" "$log_file" | \
tail -n "$num" | \
sed -E 's/^([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]+[+-][0-9]+:[0-9]+) .*kernel.*: (.*)/Date: \1, Description: \2/' | \
sort $sort_order

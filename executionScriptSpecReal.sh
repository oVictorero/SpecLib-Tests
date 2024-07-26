#!/bin/bash

script_dir="$(cd "$(dirname "$0")" && pwd)"

# Change working directory
cd "$script_dir" || exit

# Directory where the executables are located
directories=(
    "./build/basic_tests"
)

# List of executables
executables=(
    "mean_specReal_test"
)

## Arguments
# Float size
l_values=(1 4 7 10 13 16)
# Tolerance
o_values=(0.0001 0.01 1 100 10000)

counter=0

if [ "$1" != "-s" ]; then
    echo "Delete previous executions' results and logs? (y/N):"
    read delete

    delete=${delete:-N}

    delete=$(echo "$delete" | tr '[:upper:]' '[:lower:]')

    if [ "$delete" = "y" ]; then
        find . -type f -name "*.csv" -exec rm {} +
        rm -r logs/* > /dev/null > /dev/null 2>&1
        echo "Files successfully deleted."
    fi
fi
for directory in "${directories[@]}"; do
    # Check if the directory exists
    echo "Executing directory $directory."
    if [ ! -d "$directory" ]; then
        echo "The directory $directory does not exist."
        continue
    fi

    for executable in "${executables[@]}"; do
        file="$directory/$executable"
        if [ -x "$file" ] && [ -f "$file" ]; then
            for l in "${l_values[@]}"; do
                for o in "${o_values[@]}"; do
                    # Execution
                    ((counter++))
                    echo "Executing $file with -c 500000 -m 2 -N 5 -n 100000000 -t 8 -l $l -o $o"
                    "$file" "-c 500000" "-m 2" "-N 5" "-n 100000000" "-t 8" "-l $l" "-o $o" > /dev/null

                    if [ $? -ne 0 ]; then
                        echo "Error executing $file with arguments $  -c 500000 -m 2 -N 5 -n 100000000 -t 8 -l $l -o $o ." >> logs/execution.log
                    fi
                done      
            done
        else
            echo "$file is not an executable."
            exit 1
        fi
    done
done



echo "| Done. Number of executions: $counter |"
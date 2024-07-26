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
    "max_vec_norm_test"
    "max_int_test"
    "max_vec_test"
)

## Arguments
# Number of chunks
c_values=(10000 100000 1000000 100000000)
# (Simulated) percentage of misscalculations
s_values=(0 0.25 0.5 1)
# Minimum number of threads
m_values=(2 3 4 5)
# Iterations
n_values=(100000000)
# Number of threads
t_values=(4 6 8 10)

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
            for c in "${c_values[@]}"; do
                for m in "${m_values[@]}"; do
                    for n in "${n_values[@]}"; do
                        for t in "${t_values[@]}"; do
                            for s in "${s_values[@]}"; do
                                # General execution
                                ((counter++))
                                echo "|${counter}| Executing $file with -c $c -m $m -N 1 -n $n -t $t -s $s"
                                "$file" "-c $c" "-m $m" "-N 1" "-n $n" "-t $t" "-s $s" > /dev/null

                                if [ $? -ne 0 ]; then
                                    echo "Error executing $file with arguments -c $c -m $m -N 1 -n $n -t $t -s $s." >> logs/execution.log
                                fi
                            done
                        done
                    done
                done            
            done
        else
            echo "$file is not an executable."
            exit 1
        fi
    done
done

echo "| Done. Number of executions: $counter |"

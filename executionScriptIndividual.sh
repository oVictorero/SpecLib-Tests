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
c_values=(10 20 50 80 100 250 400 500 750 800 900 1000 1500 2000 2500 3000 4000 5000 6000 7000 8000 9000 10000 12500 15000 17500 20000 25000 25000 30000 40000 50000 60000 70000 80000 90000 100000 120000 140000 160000 180000 200000 300000 400000 500000 750000 1000000 1500000 2000000 2500000 3000000 3500000 4000000 4500000 5000000 7500000 10000000)
# (Simulated) percentage of positive validations
s_values=(0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1)
# Minimum number of threads
m_values=(2 3 4 5 6 7)
# Iterations
n_values=(100000000 200000000 300000000 400000000 500000000 600000000 700000000 800000000 900000000 1000000000)
# Number of threads
t_values=(3 4 5 6 7 8 9 10)


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
            for n in "${n_values[@]}"; do
                ((counter++))
                echo "|$counter| Executing $file with -c 5000000 -m 2 -N 10 -n $n -t 8 -s 0.75"
                "$file" "-c 5000000" "-m 2" "-N 10" "-n $n" "-t 8" "-s 0.75" > /dev/null
                if [ $? -ne 0 ]; then
                    echo "Error executing $file with arguments $  -c 5000000 -m 2 -N 10 -n $n -t 8 -s 0.75." >> logs/execution.log
                fi              
            done

            for t in "${t_values[@]}"; do
                ((counter++))
                echo "|$counter| Executing $file with -c 5000000 -m 2 -N 10 -n 100000000 -t $t -s 0.75"
                "$file" "-c 5000000" "-m 2" "-N 10" "-n 100000000" "-t $t" "-s 0.75" > /dev/null
                if [ $? -ne 0 ]; then
                    echo "Error executing $file with arguments $  -c 5000000 -m 2 -N 10 -n 100000000 -t $t -s 0.75." >> logs/execution.log
                fi             
            done

            for c in "${c_values[@]}"; do
                ((counter++))
                echo "|$counter| Executing $file with -c $c -m 2 -N 2 -n 1000000 -t 8 -s 0.75"
                "$file" "-c $c" "-m 2" "-N 2" "-n 1000000" "-t 8" "-s 0.75" > /dev/null

                if [ $? -ne 0 ]; then
                    echo "Error executing $file with arguments $  -c 500000 -m 2 -N 10 -n $n -t 8 -s 0.75." >> logs/execution.log
                fi           
            done

            for m in "${m_values[@]}"; do
                ((counter++))
                echo "|$counter| Executing $file with -c 5000000 -m $m -N 2 -n 1000000 -t 8 -s 0.75"
                "$file" "-c 5000000" "-m $m" "-N 2" "-n 1000000" "-t 8" "-s 0.75" > /dev/null

                if [ $? -ne 0 ]; then
                    echo "Error executing $file with arguments $  -c 5000000 -m 2 -N 10 -n $n -t 8 -s 0.75." >> logs/execution.log
                fi      
            done

        else
            echo "$file is not an executable."
            exit 1
        fi
    done
done

echo "| Done. Number of executions: $counter |"

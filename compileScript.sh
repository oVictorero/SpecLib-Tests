#!/bin/bash

# Basic Tests
g++ -I ./include -O0 tests/basic_tests/max_int_test.cpp -o build/basic_tests/max_int_test
g++ -I ./include -O0 tests/basic_tests/max_vec_test.cpp -o build/basic_tests/max_vec_test
g++ -I ./include -O0 tests/basic_tests/max_vec_norm_test.cpp -o build/basic_tests/max_vec_norm_test
g++ -I ./include -O0 tests/basic_tests/mean_specReal_test.cpp -o build/basic_tests/mean_specReal_test
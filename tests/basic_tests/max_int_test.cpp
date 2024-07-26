/*
 SpecLib: Library for speculative execution of loops
 Copyright (C) 2023 Millan A. Martinez, Basilio B. Fraguela, Jose C. Cabaleiro, Francisco F. Rivera. Universidade da Coruna
 
 Distributed under the MIT License. (See accompanying file LICENSE)
*/

///
/// \file     max_int_test.cpp
/// \brief    Test based on finding the largest integer in a vector
/// \author   Millan A. Martinez  <millan.alvarez@udc.es>
/// \author   Basilio B. Fraguela <basilio.fraguela@udc.es>
/// \author   Jose C. Cabaleiro   <jc.cabaleiro@usc.es>
/// \author   Francisco F. Rivera <ff.rivera@usc.es>
///

#include "speclib/speclib.h"
#include "../common_files/common_test.cpp"
#include <random>
#include <functional>
#include <limits>

#define NN 300

constexpr int RAND_SEED = 981;

size_t N = 1000;
int MaxSeq;
int *Vals;

void seq_test()
{ int max_seq = 0;
  
  auto tseq_begin = profile_clock_t::now();
  for (size_t i = 0; i < N; i++) {
    for(int j = 0; j < NN; j++ ) {
      if (Vals[i] > max_seq) {
        max_seq = Vals[i];
      }
    }
  }
  auto tseq_end = profile_clock_t::now();
  
  MaxSeq = max_seq;

  escribirCSV("max_int_test/basic_test/max_int_test_seq.csv", N, std::chrono::duration<double>(tseq_end - tseq_begin).count());

  std::cout << "Seq   : " <<  max_seq << std::endl;
  std::cout << "Time  : " << std::chrono::duration<double>(tseq_end - tseq_begin).count() << std::endl << std::endl;
}

int max_spec;
double avg_time;

const auto reset_result = [] () { max_spec = 0; };
const auto test_f = [] () { return (max_spec == MaxSeq); };

bool lambda_test()
{
  const auto loop_f = [&](const size_t iteration, int& result) {
    for(int j = 0; j < NN; j++) {
      if (Vals[iteration] > result) {
        result = Vals[iteration];
      }
    }
  };

  const bool test_ok = bench(0, N, 1, loop_f, reset_result, test_f, avg_time, max_spec);

  escribirCSV("max_int_test/basic_test/max_int_test_lambda.csv", N, avg_time);

  std::cout << "Lambda: " << max_spec << " " << (test_ok ? 'Y' : 'N') << std::endl;
  std::cout << "Time  : " << avg_time << std::endl << std::endl;

  return test_ok;
}


int main(int argc, char **argv)
{
  process_args(argc, argv, "hc:d:m:N:n:t:s:v", N);
  
  Vals = new int[N];
  auto mt_rand_gen = std::bind(std::uniform_int_distribution<int>(std::numeric_limits<int>::min(), std::numeric_limits<int>::max()), std::mt19937(static_cast<std::mt19937::result_type>(static_cast<int>(RAND_SEED))));
  for (size_t i = 0; i < N; i++) {
    Vals[i] = mt_rand_gen();
  }

  seq_test();
  
  do_preheat(); // Preheat

  return lambda_test() ? 0 : -1;
}

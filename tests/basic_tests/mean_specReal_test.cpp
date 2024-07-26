#include "speclib/speclib.h"
#include "../common_files/common_test.cpp"
#include <random>
#include <functional>
#include <limits>
#include <cmath>  // Necesario para std::pow
#include <iomanip>  // Necesario para std::setprecision y std::fixed


#define NN 100

constexpr int RAND_SEED = 981;

using SpecLib::SpecReal;
using SpecLib::EPS_ABSOLUTE;
using SpecLib::EPS_RELATIVE;
using SpecLib::EPS_ULP;
using SpecLib::EPS_ABSOLUTE_AND_RELATIVE;
using SpecLib::EPS_ABSOLUTE_AND_ULP;

size_t N = 1000;
float MeanSeq;
float *Vals;

void seq_test()
{ float mean_seq = 0;
  
  auto tseq_begin = profile_clock_t::now();
  for (size_t i = 0; i < N; i++) {
    for(int j = 0; j < NN; j++) {
#ifdef ENABLE_DELAY
    mywait(DelaySeconds);
#endif
    mean_seq += (Vals[i]-mean_seq)/(i+1);
    }
  }
  auto tseq_end = profile_clock_t::now();
  
  MeanSeq = mean_seq;

  escribirCSV("mean_specReal_test/basic_test/mean_specReal_test_seq.csv", N, std::chrono::duration<double>(tseq_end - tseq_begin).count(), mean_seq);

  std::cout << "Seq   : " <<  mean_seq << std::endl;
  std::cout << "Time  : " << std::chrono::duration<double>(tseq_end - tseq_begin).count() << std::endl << std::endl;
}

float xd = 1000;
  

double avg_time;

bool absolute_test(SpecReal<double, EPS_ABSOLUTE>& mean_spec) {
  const auto reset_result = [&mean_spec] () { mean_spec = 0; };
  const auto test_f = [&mean_spec] () { return (mean_spec == MeanSeq); };

  const auto func1 = [](const size_t iter, SpecReal<double, EPS_ABSOLUTE>& result) {
    for(int j = 0; j < NN; j++) {
      result += (Vals[iter] - result) / (iter + 1);
    }
  };

  const bool test_ok = bench(0, N, 1, func1, reset_result, test_f, avg_time, mean_spec);

  escribirCSV("mean_specReal_test/basic_test/mean_specReal_test_absolute.csv", N, avg_time, (float)mean_spec);


  std::cout << "Maximum value of array: " << mean_spec << std::endl;
  std::cout << "Time  : " << avg_time << std::endl << std::endl;

  return test_ok;
}

bool relative_test(SpecReal<double, EPS_RELATIVE>& mean_spec) {
  const auto reset_result = [&mean_spec] () { mean_spec = 0; };
  const auto test_f = [&mean_spec] () { return (mean_spec == MeanSeq); };

  const auto func1 = [](const size_t iter, SpecReal<double, EPS_RELATIVE>& result) {
    for(int j = 0; j < NN; j++) {
      result += (Vals[iter] - result) / (iter + 1);
    }
  };

  const bool test_ok = bench(0, N, 1, func1, reset_result, test_f, avg_time, mean_spec);

  escribirCSV("mean_specReal_test/basic_test/mean_specReal_test_relative.csv", N, avg_time, (float)mean_spec);


  std::cout << "Maximum value of array: " << mean_spec << std::endl;
  std::cout << "Time  : " << avg_time << std::endl << std::endl;

  return test_ok;
}


int main(int argc, char **argv) {
  process_args(argc, argv, "hc:d:m:N:n:t:s:l:o:v", N);

  Vals = new float[N];
  
  std::mt19937 mt(RAND_SEED);

  std::uniform_real_distribution<float> dist(pow(10, FloatSize-1), pow(10, FloatSize)-1);

  for (size_t i = 0; i < N; i++) {
    Vals[i] =  dist(mt);
  }

  SpecReal<double, EPS_ABSOLUTE> mean_spec1(0, Tolerance);
  SpecReal<double, EPS_RELATIVE> mean_spec2(0, Tolerance);

  seq_test();
  
  do_preheat(); // Preheat

  absolute_test(mean_spec1);

  relative_test(mean_spec2);


  return 0;
}

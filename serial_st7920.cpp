#include "Vst7920_driver.h"
#include "svdpi.h"
#include "verilated.h"
#include "verilated_vpi.h" // Required to get definitions
#include <inttypes.h>
#include <iostream>
#include <memory.h>
#include <string>
#include "./signal_decoder.cpp"


int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
  const std::unique_ptr<Vst7920_driver> top{new Vst7920_driver{contextp.get()}};

  top->sys_clk = 0;
  top->eval();
  top->sys_rst_n_ms = 1;

  SignalDecoder sd;

  bool clk_flip = false;

  std::cout << "Commands will be shown to you line-by-line. Press any key to see next decoded command\n";

  for (int i = 0; !contextp->gotFinish(); i++) {
    top->sys_clk ^= 1;
    top->eval();

    if (top->lcd_clk == 1 && clk_flip) {

      sd.absorb_bit(top->lcd_data);

      if (sd.is_command_ready()) {
          std::cout << sd.get_command().to_string() << "\n";
          getchar();
      }

    
      clk_flip = false;
    } else if (top->lcd_clk == 0) {
      clk_flip = true;
    }
  }

  return 0;
}

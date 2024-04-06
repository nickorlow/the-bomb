#include <inttypes.h>
#include <stdio.h>
#include <string>

class ST7920Command {
private:
  uint8_t command_bits;
  bool rw;
  bool rs;
  bool valid;

public:
  ST7920Command(uint8_t *bit_arr) {
    valid = true;
    command_bits = 0;
    for (int i = 0; i < 24; i++) {
      switch (i) {
      case 0 ... 4:
        if (bit_arr[i] != 1)
          valid = false;
        break;
      case 5:
        rw = bit_arr[i] == 1;
        break;
      case 6:
        rs = bit_arr[i] == 1;
        break;
      case 7:
        if (bit_arr[i] != 0)
          valid = false;
        break;
      case 8 ... 11: {
        uint8_t cb = bit_arr[i] << (7 - (i - 8));
        command_bits = cb | command_bits;
        break;
      }
      case 12 ... 15:
        if (bit_arr[i] != 0)
          valid = false;
        break;
      case 16 ... 19: {
        uint8_t cb = bit_arr[i] << (3 - (i - 16));
        command_bits = cb | command_bits;
        break;
      }
      case 20 ... 23:
        if (bit_arr[i] != 0)
          valid = false;
        break;
      }
    }
  }

  std::string to_string() {
    //TODO: Add all commands, not just writes

    std::string ret = "";
    if (rs && !rw) {
      // Write data
      ret += "WRITE RAM: ";
      ret += (char)command_bits;
      ret += "(";
      for (int i = 0; i < 8; i++) 
          ret += ((command_bits >> (8 - 1 - i)) & 1) == 1 ? " 1 " : " 0 ";
      ret += ") ";
      return ret;
    }

    if (!rs && rw) {
      ret = "Unknown Command";
    }

    if (!rs && !rw) {
      ret = "Unknown Command";
    }

    if (!rs && !rw) {
      uint8_t disp_on_off_mask = 0b11111000 & command_bits;
      if (disp_on_off_mask == 0b00001000) {
        ret = "DISPLAY ON/OFF";
        return ret;
      }
      
      uint8_t set_func_mask = 0b11100000 & command_bits;
      if (set_func_mask == 0b00100000) {
        ret = "SET FUNCTION";
        return ret;
      }
      
      uint8_t set_ram_mask = 0b10000000 & command_bits;
      if (set_ram_mask == 0b10000000) {
        uint8_t val = 0b01111111 & command_bits;
        ret = "SET RAM_ADDR ";
        ret += std::to_string(val);
        return ret;
      }
      
      ret = "Unknown Command";
    }

    return ret;
  }
};

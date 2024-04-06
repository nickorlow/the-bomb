#include <string.h>
#include <inttypes.h>
#include <iostream>
#include "./st7920_command.cpp"

class SignalDecoder {
    private:
        uint8_t one_cnt;
        uint8_t comm_bits[25];
        uint8_t comm_idx;
        bool reading;

        enum READER_PHASE {
            SYNC,
            RW_BIT,
            RS_BIT,
            SEP_BIT,
            DATA_HI,
            DATA_HI_PAD,
            DATA_LO,
            DATA_LO_PAD,
            UNKNOWN
        };

        READER_PHASE get_phasename(int x) {
          switch (x) {
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
              return READER_PHASE::SYNC;
            case 6:
              return READER_PHASE::RW_BIT;
            case 7:
              return READER_PHASE::RS_BIT;
            case 8:
              return READER_PHASE::SEP_BIT;
            case 9:
            case 10:
            case 11:
            case 12:
              return READER_PHASE::DATA_HI;
            case 13:
            case 14:
            case 15:
            case 16:
              return READER_PHASE::DATA_HI_PAD;
            case 17:
            case 18:
            case 19:
            case 20:
              return READER_PHASE::DATA_LO;
            case 21:
            case 22:
            case 23:
            case 24:
              return READER_PHASE::DATA_LO_PAD;
            default:
              return READER_PHASE::UNKNOWN;
          }
        }

        bool should_be_zero(READER_PHASE phase) {
            return phase == READER_PHASE::SEP_BIT ||
                    phase == READER_PHASE::DATA_HI_PAD ||
                    phase == READER_PHASE::DATA_LO_PAD;
        }

    public:
        SignalDecoder() {
            one_cnt = 0;
            reading = false;
            comm_idx = 0;
            for(int i = 0; i < 25; i++)
                comm_bits[i] = i < 5 ? 1 : 0; // first 5 bits will always be 1
        }

        void absorb_bit(uint8_t bit) {

            if (comm_idx == 24)
                comm_idx = 0;

            if (bit == 1) {
                one_cnt++;
            } else {
                one_cnt = 0;
            }
            
            if (one_cnt == 5) {
                if(reading) {
                   std::cout << "WARN: Throwing out command (This should never happen!)\n";
                }            
                comm_idx = 5;
                reading = true;
            } else if (reading) {
                if (bit == 1 && should_be_zero(get_phasename(comm_idx+1))) {
                    std::cout << "WARN: SEP / PAD bits should all be 0\n";
                }
                comm_bits[comm_idx] = bit;
                comm_idx++;
            }


            if (comm_idx == 24) {
                reading = false;
                one_cnt = 0;
            }
        }

        bool is_command_ready() {
            return comm_idx == 24;
        }

        ST7920Command get_command() {
          ST7920Command sc(comm_bits);
          return sc;
        }
};

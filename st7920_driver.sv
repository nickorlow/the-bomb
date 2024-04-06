`define DELAY_BITS 10

module st7920_driver (
    input wire sys_clk,
    input wire sys_rst_n_ms,
    output logic lcd_clk,  // This goes to the E pin
    output logic lcd_data,  // This goes to the R/W pin
    output logic [5:0] led
);


  logic start;
  logic [9:0] command;
  logic [`DELAY_BITS:0] counter;

  int i;
  int c;
  int line_cnt;
  int line_idx;

  logic [7:0] memory[0:63];

  logic [9:0] commands[0:7];
  assign commands[0] = 10'b0000110000;  // set 8-bit mode
  assign commands[1] = 10'b0000001100;  // turn display on
  assign commands[2] = 10'b0000000011;  // set cursor to origin
  assign commands[3] = 10'b0000000001;  // clear ram

  assign commands[4] = 10'b0000000011;  // set cursor to origin (repeated but wtv)
  assign commands[5] = 10'b0010010000;  // move line down
  assign commands[6] = 10'b0010001000;  // move line down again
  assign commands[7] = 10'b0010011000;  // move line down again (again!)


  assign led = {
    lcd_clk, 3'b101, start, |memory[i-4][4:0]
  };  //{1'b0, lcd_data, 1'b1, start, lcd_clk, 1'b0};
  commander com (
      lcd_clk,
      command[9],
      command[8],
      command[7:0],
      start,
      lcd_data
  );

  // Remove metastability from signal
  logic sys_rst_n;
  d_flip_flop dff (
      sys_rst_n_ms,
      sys_clk,
      sys_rst_n
  );

  initial begin
    lcd_clk = 0;
    counter = 0;
    start = 0;
    i = 0;
    c = 0;
    line_cnt = 0;
    line_idx = 0;
    $readmemb("text.bin", memory);
  end

  always_ff @(negedge lcd_clk) begin
    if (sys_rst_n) begin
      if (i == 0 || c >= 24) begin
        if (i < 4) begin
          command <= commands[i];
          i <= i + 1;
        end else begin
          if (memory[i-4] == 8'b00001010 || line_cnt == 15) begin

            command  <= commands[4+((line_idx+1)%4)];
            line_cnt <= 0;
            line_idx <= (line_idx + 1) % 4;
            if (line_cnt != 15) begin
              i <= i + 1;
            end
          end else if (memory[i-4] == 8'b00000000) begin
            command <= commands[1];
            i <= i;
          end else begin
            command <= {2'b10, memory[i-4]};
            i <= i + 1;
          end
        end

        start <= 1'b1;
        c <= 0;
      end else begin
        start <= 1'b0;
        c <= c + 1;
      end
    end else begin
      start <= 0;
      i <= 0;
      c <= 0;
      line_idx <= 0;
      line_cnt <= 0;
    end
  end

  always_ff @(posedge sys_clk) begin
    // Downclock
    if (counter[`DELAY_BITS]) begin
      lcd_clk <= !lcd_clk;
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end

endmodule

module d_flip_flop (
    input  wire  data_in,
    input  wire  clk_in,
    output logic data_out
);
  always @(posedge clk_in) begin
    data_out <= data_in;
  end
endmodule

module commander (
    input wire lcd_clk,
    input wire rs,
    input wire rw,
    input wire [7:0] data,
    input wire start,

    output logic lcd_data
);
  int i;
  logic [23:0] full_command_bits;
  localparam num_cycles = 5  /* sync */ + 3  /* RW + RS */ + 16  /* D0-7 */;

  always_ff @(posedge lcd_clk) begin
    if (start) begin
      i <= 0;
      full_command_bits <= {5'b11111, rw, rs, 1'b0, data[7:4], 4'b0000, data[3:0], 4'b0000};
    end else if (i < num_cycles) begin
      lcd_data <= full_command_bits[23];
      full_command_bits <= full_command_bits << 1;
      i <= i + 1;
    end
  end
endmodule

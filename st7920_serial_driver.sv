`define DELAY_BITS 8 
`define BOOTSTRAP_INSTRS 6 

module st7920_serial_driver (
    input wire sys_clk,
    input wire sys_rst_n_ms,
    input wire [7:0] memory [0:1023],
    output logic lcd_clk,  // This goes to the E pin
    output logic lcd_data,  // This goes to the R/W pin
    output logic [5:0] led
);

  logic start;
  logic [9:0] command;
  logic [`DELAY_BITS:0] counter;

  logic [6:0] y;
  logic [5:0] x;

  int i;
  int c;
  int line_cnt;
  int line_idx;


  logic [9:0] commands[0:10];
  assign commands[0] = 10'b0000110000;      // set 8 bit 
  assign commands[1] = 10'b0000001100;      // turn display on
  assign commands[2] = 10'b0000110110;      // set extended IS 
  assign commands[3] = 10'b0000110110;      // set graphic mode   
  assign commands[4] = {3'b001, y};         // set y to y pos 
  assign commands[5] = {10'b0010000000};    // set x to line start 

  assign led = {sys_rst_n, i[4:0]}; 
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
    y = 0;
    x = 0;
  end

  always_ff @(negedge lcd_clk) begin
    if (sys_rst_n) begin
      if (i == 0 || c >= 24) begin
        if (i < `BOOTSTRAP_INSTRS) begin
          command <= commands[i];
          i <= i + 1;
          if (i == 4) begin
            y <= y + 1;
          end
        end else begin
          if (line_cnt == 32) begin

            if (x != 0) begin
                // write out y, reset x
                command  <= commands[4];
                x <= 0;
            end else begin 
                // write out x, set y
                command  <= commands[5];
                line_cnt <= 0;
                y <= y + 1;
            end

          end else if (y == 33) begin
            // Done! NOP
            command <= commands[0];
            i <= 1;
            y <= 0;
            x <= 0;
            line_cnt <= 0;
          end else begin
            if (line_cnt < 16) begin
                /* verilator lint_off WIDTHEXPAND */
                command <= {2'b10, memory[(i-((y-1)*16)-`BOOTSTRAP_INSTRS)]};
            end else  begin
                /* verilator lint_off WIDTHEXPAND */
                command <= {2'b10, memory[(i-((y)*16)-`BOOTSTRAP_INSTRS) + 512]};
            end
            i <= i + 1;
            x <= x + 1;
            line_cnt <= line_cnt + 1;
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
      y <= 0;
      x <= 0;
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

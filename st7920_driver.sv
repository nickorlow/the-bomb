`define DELAY_BITS 8 
`define BOOTSTRAP_INSTRS 6 

module st7920_driver (
    input wire sys_clk,
    input wire sys_rst_n_ms,
    output logic lcd_clk,  // This goes to the E pin
    output logic lcd_data,  // This goes to the R/W pin
    output logic [5:0] led
);
  logic [20:0] counter;
  int c2;
  logic rst;
  logic [7:0] memory[0:1023];

  st7920_serial_driver driver(sys_clk, sys_rst_n_ms, memory, lcd_clk, lcd_data, led);


  initial begin
      rst = 1;
      c2 = 0;
    $readmemb("image.bin", memory);
  end

  always_ff @(posedge sys_clk) begin
    if(counter[20] == 1) begin
        memory[c2] <= memory[c2] ^  8'b11111111;
        c2 <= c2 + 1;
        counter <= 0; 
    end else begin
        counter <= counter + 1;
    end
  end

endmodule

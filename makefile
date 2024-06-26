SV_FILES=st7920_driver.sv st7920_serial_driver.sv

build: build-rom
	verilator --cc --exe --build --timing -j 0 --top-module st7920_driver -o st7920_driver ${SV_FILES} serial_st7920.cpp 

build-debug: build-rom
	verilator --cc --exe --build --timing -j 0 --top-module st7920_driver -o st7920_driver ${SV_FILES} serial_st7920.cpp -DDEBUG_PRINT

run: build
	./obj_dir/st7920_driver

debug: build-debug
	./obj_dir/st7920_driver

format:
	verible-verilog-format ${SV_FILES} --inplace && clang-format *.cpp -i

build-rom: image.png
	python3 ./gen_rom.py 

build-fpga: *.sv *.qsf *.qpf image.bin build-rom
	quartus_sh --flow compile st7920_driver && ./make_cdf.sh

run-fpga: build-fpga
	quartus_pgm -m jtag -o "p;./output_files/st7920_driver.sof" ./output_files/st7920_driver.cdf

lint:
	verilator --lint-only --timing ${SV_FILES}

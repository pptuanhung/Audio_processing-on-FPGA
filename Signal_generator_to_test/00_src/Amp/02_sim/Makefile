filelist="-f ../00_src/flist.f"
tb_file="../01_tb/testbench.sv"
time_unit="-timescale 1ns/1ns"
acc_debug="+access+rcw"
seed = +ntb_random_seed=automatic
wave_data="waves.shm/"

PHONY:	sim
sim:	
	@echo "-> SIMULATION"
	xrun $(GUI) +xm64bit -sv \
	$(filelist) \
	$(tb_file) \
	$(time_unit) \
	$(seed) \
	$(acc_debug)
.PHONY: gui
gui:
	@echo "-> SIMULATION WITH GUI"
	make sim GUI="-gui" &


PHONY: wave
wave:	
	@echo "-> WAVE"
	simvision $(wave_data) &
.PHONY: sim wave all
all: sim wave

clean:
	@echo "-> CLEANING SIMULATION FILES"
	rm -rf INCA_libs *.shm *.history *.log *.ucdb *.fsdb xcelium.d xrun.* cov_work

distclean: clean
	@echo "-> DISTRIBUTION CLEAN REMOVING ALL FILES EXCEPT MAKEFILE, makefile, .f"
	find . -mindepth 1 ! -name "Makefile" ! -name "makefile" ! -name "*.f" -exec rm -rf {} +
.PHONY: kill
kill:
	@echo "-> KILLING SimVision"
	pkill -f simvision



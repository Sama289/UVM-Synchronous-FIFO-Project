vlib work
vlog +define+SIM -f src_files.list +cover -covercells
vsim -voptargs=+acc work.FIFO_TOP -cover
coverage save fifo_tb.ucdb -onexit
add wave -position insertpoint sim:/FIFO_TOP/fifo_if/*
run -all
#vcover report fifo_tb.ucdb -details -all -output coverage_rpt_fifo.txt
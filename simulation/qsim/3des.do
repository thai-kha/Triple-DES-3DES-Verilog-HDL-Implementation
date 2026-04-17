onerror {quit -f}
vlib work
vlog -work work 3des.vo
vlog -work work 3des.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.des3_top_vlg_vec_tst
vcd file -direction 3des.msim.vcd
vcd add -internal des3_top_vlg_vec_tst/*
vcd add -internal des3_top_vlg_vec_tst/i1/*
add wave /*
run -all

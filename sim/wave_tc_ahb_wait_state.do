onerror {resume}
quietly virtual function -install /tb_top/dut/bridge_inst/fsm -env /tb_top/dut/bridge_inst/fsm { (((state[2:0]  == 3'b101) or (state[2:0]  == 3'b110)) or (state[2:0]  == 3'b111))} dbgTemp20_46
quietly virtual function -install /tb_top/dut/bridge_inst/fsm -env /tb_top/dut/bridge_inst/fsm { (state[2:0]  == 3'b000)} dbgTemp19_46
quietly virtual function -install /tb_top/dut/bridge_inst/fsm -env /tb_top/dut/bridge_inst/fsm { ((bool)dbgTemp19_46  ? 1'b1 : 1'b0)} dbgTemp4_HREADYout_2
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top/dut/HCLK
add wave -noupdate /tb_top/dut/HTRANS
add wave -noupdate /tb_top/dut/HADDR
add wave -noupdate /tb_top/dut/HWDATA
add wave -noupdate /tb_top/dut/HREADY1
add wave -noupdate /tb_top/dut/HREADYin
add wave -noupdate /tb_top/dut/HREADYout
add wave -noupdate /tb_top/dut/HRESETn
add wave -noupdate /tb_top/dut/PSEL1
add wave -noupdate /tb_top/dut/PENABLE
add wave -noupdate /tb_top/dut/PREADY1
add wave -noupdate /tb_top/dut/PADDR
add wave -noupdate /tb_top/dut/PWDATA
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {43523 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {194250 ps}

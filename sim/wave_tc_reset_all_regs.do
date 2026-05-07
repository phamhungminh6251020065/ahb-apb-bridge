onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top/dut/HCLK
add wave -noupdate /tb_top/dut/HRESETn
add wave -noupdate /tb_top/dut/HADDR
add wave -noupdate /tb_top/dut/HWRITE
add wave -noupdate /tb_top/dut/HTRANS
add wave -noupdate /tb_top/dut/HWDATA
add wave -noupdate /tb_top/dut/HRDATA
add wave -noupdate /tb_top/dut/HREADY1
add wave -noupdate /tb_top/dut/HREADYin
add wave -noupdate /tb_top/dut/HREADYout
add wave -noupdate /tb_top/dut/PADDR
add wave -noupdate /tb_top/dut/PENABLE
add wave -noupdate /tb_top/dut/PWRITE
add wave -noupdate /tb_top/dut/PWDATA
add wave -noupdate /tb_top/dut/PSEL1
add wave -noupdate /tb_top/dut/PSEL2
add wave -noupdate /tb_top/dut/PSEL3
add wave -noupdate /tb_top/dut/PRDATA1
add wave -noupdate /tb_top/dut/PRDATA2
add wave -noupdate /tb_top/dut/PRDATA3
add wave -noupdate /tb_top/dut/PREADY1
add wave -noupdate /tb_top/dut/PREADY2
add wave -noupdate /tb_top/dut/PREADY3
add wave -noupdate /tb_top/dut/TIMER_IRQ
add wave -noupdate /tb_top/dut/GPIO_OUT
add wave -noupdate /tb_top/dut/bridge_inst/fsm/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 146
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
WaveRestoreZoom {0 ps} {1459592 ps}

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top/dut/HCLK
add wave -noupdate /tb_top/dut/HRESETn
add wave -noupdate /tb_top/dut/HADDR
add wave -noupdate /tb_top/dut/HWDATA
add wave -noupdate /tb_top/dut/HRDATA
add wave -noupdate /tb_top/dut/HBUSREQ1
add wave -noupdate /tb_top/dut/HBUSREQ2
add wave -noupdate /tb_top/dut/HGRANT1
add wave -noupdate /tb_top/dut/HGRANT2
add wave -noupdate /tb_top/dut/HREADY1
add wave -noupdate /tb_top/dut/HREADY2
add wave -noupdate /tb_top/dut/HREADYin
add wave -noupdate /tb_top/dut/HREADYout
add wave -noupdate /tb_top/dut/PADDR
add wave -noupdate /tb_top/dut/PWDATA
add wave -noupdate /tb_top/dut/PRDATA3
add wave -noupdate /tb_top/dut/PSEL3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {118230 ps} 0}
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
WaveRestoreZoom {0 ps} {351750 ps}

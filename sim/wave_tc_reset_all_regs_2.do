onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top/dut/HCLK
add wave -noupdate /tb_top/dut/HRESETn
add wave -noupdate /tb_top/dut/HWRITE
add wave -noupdate /tb_top/dut/HADDR
add wave -noupdate /tb_top/dut/HWDATA
add wave -noupdate /tb_top/dut/HRDATA
add wave -noupdate /tb_top/dut/HREADY1
add wave -noupdate /tb_top/dut/PADDR
add wave -noupdate /tb_top/dut/PENABLE
add wave -noupdate /tb_top/dut/PWRITE
add wave -noupdate /tb_top/dut/PWDATA
add wave -noupdate /tb_top/dut/PRDATA3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {Trace {0 ps} 0} {{Cursor 3} {65000 ps} 1} {{Cursor 4} {75000 ps} 1} {{Cursor 5} {95000 ps} 1} {{Cursor 6} {105000 ps} 1} {{Cursor 7} {115000 ps} 1} {{Cursor 8} {125000 ps} 1} {{Cursor 9} {145000 ps} 1} {{Cursor 10} {245000 ps} 1} {{Cursor 11} {255000 ps} 1} {{Cursor 12} {275000 ps} 1}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 95
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
WaveRestoreZoom {0 ps} {257827 ps}

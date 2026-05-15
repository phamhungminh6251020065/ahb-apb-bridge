onerror {resume}
quietly virtual function -install /tb_top/dut/timer_inst -env /tb_top/dut/timer_inst { ( ~(bool)(PRESETn ) )} dbgTemp0_11
quietly virtual function -install /tb_top/dut/timer_inst -env /tb_top/dut/timer_inst { ((PADDR[3:2]  == 2'b00) ? PWDATA[0] : ((PADDR[3:2]  == 2'b10) ? ctrl_reg : ctrl_reg))} dbgTemp2_ctrl_reg_3
quietly virtual function -install /tb_top/dut/timer_inst -env /tb_top/dut/timer_inst { (((PSEL  and PENABLE ) and PWRITE ) and addr_valid )} dbgTemp1_11
quietly virtual function -install /tb_top/dut/timer_inst -env /tb_top/dut/timer_inst { ((bool)dbgTemp1_11  ? dbgTemp2_ctrl_reg_3 : ctrl_reg)} dbgTemp2_ctrl_reg_4
quietly virtual function -install /tb_top/dut/timer_inst -env /tb_top/dut/timer_inst { ( ~(bool)(PRESETn ) )} dbgTemp2_11
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top/dut/timer_inst/PCLK
add wave -noupdate /tb_top/dut/timer_inst/PENABLE
add wave -noupdate /tb_top/dut/timer_inst/ctrl_reg
add wave -noupdate -radix decimal /tb_top/dut/timer_inst/cnt_reg
add wave -noupdate /tb_top/dut/timer_inst/period_reg
add wave -noupdate /tb_top/dut/timer_inst/TIMER_IRQ
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {78832 ps} 0}
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
WaveRestoreZoom {0 ps} {383250 ps}

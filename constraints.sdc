puts "\[INFO\]: Creating Clocks"
create_clock [get_ports rclk] -name rclk -period 7
set_propagated_clock rclk
create_clock [get_ports wclk] -name wclk -period 14
set_propagated_clock wclk

set_clock_groups -asynchronous -group [get_clocks {rclk wclk}]

puts "\[INFO\]: Setting Max Delay"

set read_period     [get_property -object_type clock [get_clocks {rclk}] period]
set write_period    [get_property -object_type clock [get_clocks {wclk}] period]
set min_period      [expr {min(${read_period}, ${write_period})}]

set_max_delay -from [get_pins sync_w2r.din*df*/CLK] -to [get_pins empty_flag.rq2_wptr*df*/D] $min_period
set_max_delay -from [get_pins sync_r2w.q1*df*/CLK] -to [get_pins empty_flag.rgray_next*df*/D] $min_period

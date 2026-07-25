# create_project.tcl
# Vivado project generation script for Protocol-Monitor-IP

set project_name "protocol_monitor"
set target_part "xc7z020clg484-1"
set target_board "em.avnet.com:zed:part0:1.3"

# Create build directory and initialize project
create_project -force $project_name ./build -part $target_part
set_property board_part $target_board [current_project]

# Add RTL Source Files
add_files [glob ./rtl/*.v]

# Add Testbench Files
add_files -fileset sim_1 [glob ./tb/*.v]

# Add Constraints
add_files -fileset constrs_1 [glob ./constraints/*.xdc]

# Set Top Modules
set_property top top [current_fileset]
set_property top tb [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Vivado project $project_name created successfully in ./build"

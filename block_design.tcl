
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z010clg400-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_bram_ctrl:4.0\
xilinx.com:ip:axi_clock_converter:2.1\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:xadc_wiz:3.3\
koheron:user:address_counter:1.0\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:fir_compiler:7.2\
xilinx.com:ip:xlslice:1.0\
pavel-demin:user:redp_adc:1.0\
pavel-demin:user:redp_dac:1.0\
xilinx.com:ip:clk_wiz:6.0\
pavel-demin:user:axi_sts_register:1.0\
pavel-demin:user:dna_reader:1.0\
pavel-demin:user:axi_ctl_register:1.0\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: DAC
proc create_hier_cell_DAC { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_DAC() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:bram_rtl:1.0 BRAM_PORTA

  # Create pins
  create_bd_pin -dir O -from 13 -to 0 Dout1
  create_bd_pin -dir O -from 13 -to 0 Dout2
  create_bd_pin -dir I -type clk clkb
  create_bd_pin -dir O -from 0 -to 0 dout
  create_bd_pin -dir I enb
  create_bd_pin -dir I trig

  # Create instance: address_counter, and set properties
  set address_counter [ create_bd_cell -type ip -vlnv koheron:user:address_counter:1.0 address_counter ]
  set_property -dict [ list \
   CONFIG.COUNT_WIDTH {14} \
 ] $address_counter

  # Create instance: blk_mem_gen_dac, and set properties
  set blk_mem_gen_dac [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_dac ]
  set_property -dict [ list \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
 ] $blk_mem_gen_dac

  # Create instance: const_v0_w1, and set properties
  set const_v0_w1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_v0_w1 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {1} \
 ] $const_v0_w1

  # Create instance: const_v0_w4, and set properties
  set const_v0_w4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_v0_w4 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {4} \
 ] $const_v0_w4

  # Create instance: slice_13_0_blk_mem_gen_dac_doutb, and set properties
  set slice_13_0_blk_mem_gen_dac_doutb [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_13_0_blk_mem_gen_dac_doutb ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {13} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {32} \
 ] $slice_13_0_blk_mem_gen_dac_doutb

  # Create instance: slice_29_16_blk_mem_gen_dac_doutb, and set properties
  set slice_29_16_blk_mem_gen_dac_doutb [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_29_16_blk_mem_gen_dac_doutb ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {29} \
   CONFIG.DIN_TO {16} \
   CONFIG.DIN_WIDTH {32} \
 ] $slice_29_16_blk_mem_gen_dac_doutb

  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_dac_BRAM_PORTA [get_bd_intf_pins BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_dac/BRAM_PORTA]

  # Create port connections
  connect_bd_net -net adc_dac_adc_clk [get_bd_pins clkb] [get_bd_pins address_counter/clk] [get_bd_pins blk_mem_gen_dac/clkb]
  connect_bd_net -net address_counter_address [get_bd_pins address_counter/address] [get_bd_pins blk_mem_gen_dac/addrb]
  connect_bd_net -net blk_mem_gen_dac_doutb [get_bd_pins blk_mem_gen_dac/doutb] [get_bd_pins slice_13_0_blk_mem_gen_dac_doutb/Din] [get_bd_pins slice_29_16_blk_mem_gen_dac_doutb/Din]
  connect_bd_net -net const_v0_w1_dout [get_bd_pins dout] [get_bd_pins blk_mem_gen_dac/rstb] [get_bd_pins const_v0_w1/dout]
  connect_bd_net -net const_v0_w4_dout [get_bd_pins blk_mem_gen_dac/web] [get_bd_pins const_v0_w4/dout]
  connect_bd_net -net const_v1_w1_dout [get_bd_pins enb] [get_bd_pins address_counter/clken] [get_bd_pins blk_mem_gen_dac/enb]
  connect_bd_net -net dac1_1 [get_bd_pins Dout1] [get_bd_pins slice_13_0_blk_mem_gen_dac_doutb/Dout]
  connect_bd_net -net dac2_1 [get_bd_pins Dout2] [get_bd_pins slice_29_16_blk_mem_gen_dac_doutb/Dout]
  connect_bd_net -net trig_1 [get_bd_pins trig] [get_bd_pins address_counter/trig]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: ctl
proc create_hier_cell_ctl { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_ctl() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  # Create pins
  create_bd_pin -dir O -from 31 -to 0 led
  create_bd_pin -dir I -type clk m_axi_aclk
  create_bd_pin -dir I -type rst m_axi_aresetn
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_pin -dir O -from 31 -to 0 trig

  # Create instance: axi_clock_converter_0, and set properties
  set axi_clock_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_clock_converter:2.1 axi_clock_converter_0 ]

  # Create instance: axi_ctl_register_0, and set properties
  set axi_ctl_register_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axi_ctl_register:1.0 axi_ctl_register_0 ]
  set_property -dict [ list \
   CONFIG.CTL_DATA_WIDTH {64} \
 ] $axi_ctl_register_0

  # Create instance: slice_31_0_axi_ctl_register_0_ctl_data, and set properties
  set slice_31_0_axi_ctl_register_0_ctl_data [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_31_0_axi_ctl_register_0_ctl_data ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {31} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {64} \
 ] $slice_31_0_axi_ctl_register_0_ctl_data

  # Create instance: slice_63_32_axi_ctl_register_0_ctl_data, and set properties
  set slice_63_32_axi_ctl_register_0_ctl_data [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_63_32_axi_ctl_register_0_ctl_data ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {63} \
   CONFIG.DIN_TO {32} \
   CONFIG.DIN_WIDTH {64} \
 ] $slice_63_32_axi_ctl_register_0_ctl_data

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_clock_converter_0/S_AXI]
  connect_bd_intf_net -intf_net axi_clock_converter_0_M_AXI [get_bd_intf_pins axi_clock_converter_0/M_AXI] [get_bd_intf_pins axi_ctl_register_0/S_AXI]

  # Create port connections
  connect_bd_net -net axi_ctl_register_0_ctl_data [get_bd_pins axi_ctl_register_0/ctl_data] [get_bd_pins slice_31_0_axi_ctl_register_0_ctl_data/Din] [get_bd_pins slice_63_32_axi_ctl_register_0_ctl_data/Din]
  connect_bd_net -net m_axi_aclk_1 [get_bd_pins m_axi_aclk] [get_bd_pins axi_clock_converter_0/m_axi_aclk] [get_bd_pins axi_ctl_register_0/aclk]
  connect_bd_net -net m_axi_aresetn_1 [get_bd_pins m_axi_aresetn] [get_bd_pins axi_clock_converter_0/m_axi_aresetn] [get_bd_pins axi_ctl_register_0/aresetn]
  connect_bd_net -net s_axi_aclk_1 [get_bd_pins s_axi_aclk] [get_bd_pins axi_clock_converter_0/s_axi_aclk]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins s_axi_aresetn] [get_bd_pins axi_clock_converter_0/s_axi_aresetn]
  connect_bd_net -net slice_31_0_axi_ctl_register_0_ctl_data_Dout [get_bd_pins led] [get_bd_pins slice_31_0_axi_ctl_register_0_ctl_data/Dout]
  connect_bd_net -net slice_63_32_axi_ctl_register_0_ctl_data_Dout [get_bd_pins trig] [get_bd_pins slice_63_32_axi_ctl_register_0_ctl_data/Dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: DAC_TOP
proc create_hier_cell_DAC_TOP { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_DAC_TOP() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:bram_rtl:1.0 BRAM_PORTA

  # Create pins
  create_bd_pin -dir O -from 13 -to 0 Dout1
  create_bd_pin -dir O -from 13 -to 0 Dout2
  create_bd_pin -dir I -type clk clkb
  create_bd_pin -dir O -from 0 -to 0 dout
  create_bd_pin -dir I enb
  create_bd_pin -dir I trig

  # Create instance: DAC
  create_hier_cell_DAC $hier_obj DAC

  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_dac_BRAM_PORTA [get_bd_intf_pins BRAM_PORTA] [get_bd_intf_pins DAC/BRAM_PORTA]

  # Create port connections
  connect_bd_net -net adc_dac_adc_clk [get_bd_pins clkb] [get_bd_pins DAC/clkb]
  connect_bd_net -net const_v0_w1_dout [get_bd_pins dout] [get_bd_pins DAC/dout]
  connect_bd_net -net const_v1_w1_dout [get_bd_pins enb] [get_bd_pins DAC/enb]
  connect_bd_net -net dac1_1 [get_bd_pins Dout1] [get_bd_pins DAC/Dout1]
  connect_bd_net -net dac2_1 [get_bd_pins Dout2] [get_bd_pins DAC/Dout2]
  connect_bd_net -net trig_1 [get_bd_pins trig] [get_bd_pins DAC/trig]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: sts
proc create_hier_cell_sts { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_sts() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  # Create pins
  create_bd_pin -dir I -type clk m_axi_aclk
  create_bd_pin -dir I -type rst m_axi_aresetn
  create_bd_pin -dir I -from 31 -to 0 reg1
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn

  # Create instance: axi_clock_converter_0, and set properties
  set axi_clock_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_clock_converter:2.1 axi_clock_converter_0 ]

  # Create instance: axi_sts_register_0, and set properties
  set axi_sts_register_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axi_sts_register:1.0 axi_sts_register_0 ]
  set_property -dict [ list \
   CONFIG.STS_DATA_WIDTH {96} \
 ] $axi_sts_register_0

  # Create instance: concat_0, and set properties
  set concat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 concat_0 ]
  set_property -dict [ list \
   CONFIG.IN0_WIDTH {32} \
   CONFIG.IN1_WIDTH {32} \
   CONFIG.IN2_WIDTH {32} \
   CONFIG.NUM_PORTS {3} \
 ] $concat_0

  # Create instance: concat_concat, and set properties
  set concat_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 concat_concat ]
  set_property -dict [ list \
   CONFIG.IN0_WIDTH {96} \
   CONFIG.NUM_PORTS {1} \
 ] $concat_concat

  # Create instance: dna, and set properties
  set dna [ create_bd_cell -type ip -vlnv pavel-demin:user:dna_reader:1.0 dna ]

  # Create instance: slice_31_0_dna_dna_data, and set properties
  set slice_31_0_dna_dna_data [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_31_0_dna_dna_data ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {31} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {57} \
 ] $slice_31_0_dna_dna_data

  # Create instance: slice_56_32_dna_dna_data, and set properties
  set slice_56_32_dna_dna_data [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_56_32_dna_dna_data ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {56} \
   CONFIG.DIN_TO {32} \
   CONFIG.DIN_WIDTH {57} \
 ] $slice_56_32_dna_dna_data

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_clock_converter_0/S_AXI]
  connect_bd_intf_net -intf_net axi_clock_converter_0_M_AXI [get_bd_intf_pins axi_clock_converter_0/M_AXI] [get_bd_intf_pins axi_sts_register_0/S_AXI]

  # Create port connections
  connect_bd_net -net concat_0_dout [get_bd_pins concat_0/dout] [get_bd_pins concat_concat/In0]
  connect_bd_net -net concat_concat_dout [get_bd_pins axi_sts_register_0/sts_data] [get_bd_pins concat_concat/dout]
  connect_bd_net -net dna_dna_data [get_bd_pins dna/dna_data] [get_bd_pins slice_31_0_dna_dna_data/Din] [get_bd_pins slice_56_32_dna_dna_data/Din]
  connect_bd_net -net m_axi_aclk_1 [get_bd_pins m_axi_aclk] [get_bd_pins axi_clock_converter_0/m_axi_aclk] [get_bd_pins axi_sts_register_0/aclk] [get_bd_pins dna/aclk]
  connect_bd_net -net m_axi_aresetn_1 [get_bd_pins m_axi_aresetn] [get_bd_pins axi_clock_converter_0/m_axi_aresetn] [get_bd_pins axi_sts_register_0/aresetn] [get_bd_pins dna/aresetn]
  connect_bd_net -net reg1_1 [get_bd_pins reg1] [get_bd_pins concat_0/In2]
  connect_bd_net -net s_axi_aclk_1 [get_bd_pins s_axi_aclk] [get_bd_pins axi_clock_converter_0/s_axi_aclk]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins s_axi_aresetn] [get_bd_pins axi_clock_converter_0/s_axi_aresetn]
  connect_bd_net -net slice_31_0_dna_dna_data_Dout [get_bd_pins concat_0/In0] [get_bd_pins slice_31_0_dna_dna_data/Dout]
  connect_bd_net -net slice_56_32_dna_dna_data_Dout [get_bd_pins concat_0/In1] [get_bd_pins slice_56_32_dna_dna_data/Dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: adc_dac
proc create_hier_cell_adc_dac { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_adc_dac() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir O -from 13 -to 0 adc1
  create_bd_pin -dir O -from 13 -to 0 adc2
  create_bd_pin -dir O adc_cdcs_o
  create_bd_pin -dir O adc_clk
  create_bd_pin -dir I -type clk adc_clk_n_i
  create_bd_pin -dir I -type clk adc_clk_p_i
  create_bd_pin -dir O -from 1 -to 0 adc_clk_source
  create_bd_pin -dir I -from 13 -to 0 adc_dat_a_i
  create_bd_pin -dir I -from 13 -to 0 adc_dat_b_i
  create_bd_pin -dir I -from 13 -to 0 dac1
  create_bd_pin -dir I -from 13 -to 0 dac2
  create_bd_pin -dir O dac_clk_o
  create_bd_pin -dir O -from 13 -to 0 dac_dat_o
  create_bd_pin -dir O dac_rst_o
  create_bd_pin -dir O dac_sel_o
  create_bd_pin -dir O dac_wrt_o
  create_bd_pin -dir O pwm_clk
  create_bd_pin -dir O ser_clk

  # Create instance: adc, and set properties
  set adc [ create_bd_cell -type ip -vlnv pavel-demin:user:redp_adc:1.0 adc ]

  # Create instance: adc_rst, and set properties
  set adc_rst [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 adc_rst ]

  # Create instance: dac, and set properties
  set dac [ create_bd_cell -type ip -vlnv pavel-demin:user:redp_dac:1.0 dac ]

  # Create instance: pll, and set properties
  set pll [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 pll ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125.0} \
   CONFIG.CLKOUT1_USED {true} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125.0} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {250.0} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {250.0} \
   CONFIG.CLKOUT4_REQUESTED_PHASE {-45} \
   CONFIG.CLKOUT4_USED {true} \
   CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {250.0} \
   CONFIG.CLKOUT5_USED {true} \
   CONFIG.CLKOUT6_REQUESTED_OUT_FREQ {250.0} \
   CONFIG.CLKOUT6_USED {true} \
   CONFIG.PRIMITIVE {PLL} \
   CONFIG.PRIM_IN_FREQ {125.0} \
   CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
   CONFIG.USE_RESET {false} \
 ] $pll

  # Create port connections
  connect_bd_net -net adc_adc_cdcs_o [get_bd_pins adc_cdcs_o] [get_bd_pins adc/adc_cdcs_o]
  connect_bd_net -net adc_adc_clk_source [get_bd_pins adc_clk_source] [get_bd_pins adc/adc_clk_source]
  connect_bd_net -net adc_adc_dat_a_o [get_bd_pins adc1] [get_bd_pins adc/adc_dat_a_o]
  connect_bd_net -net adc_adc_dat_b_o [get_bd_pins adc2] [get_bd_pins adc/adc_dat_b_o]
  connect_bd_net -net adc_clk_n_i_1 [get_bd_pins adc_clk_n_i] [get_bd_pins pll/clk_in1_n]
  connect_bd_net -net adc_clk_p_i_1 [get_bd_pins adc_clk_p_i] [get_bd_pins pll/clk_in1_p]
  connect_bd_net -net adc_dat_a_i_1 [get_bd_pins adc_dat_a_i] [get_bd_pins adc/adc_dat_a_i]
  connect_bd_net -net adc_dat_b_i_1 [get_bd_pins adc_dat_b_i] [get_bd_pins adc/adc_dat_b_i]
  connect_bd_net -net adc_rst_dout [get_bd_pins adc/adc_rst_i] [get_bd_pins adc_rst/dout]
  connect_bd_net -net dac1_1 [get_bd_pins dac1] [get_bd_pins dac/dac_dat_a_i]
  connect_bd_net -net dac2_1 [get_bd_pins dac2] [get_bd_pins dac/dac_dat_b_i]
  connect_bd_net -net dac_dac_clk_o [get_bd_pins dac_clk_o] [get_bd_pins dac/dac_clk_o]
  connect_bd_net -net dac_dac_dat_o [get_bd_pins dac_dat_o] [get_bd_pins dac/dac_dat_o]
  connect_bd_net -net dac_dac_rst_o [get_bd_pins dac_rst_o] [get_bd_pins dac/dac_rst_o]
  connect_bd_net -net dac_dac_sel_o [get_bd_pins dac_sel_o] [get_bd_pins dac/dac_sel_o]
  connect_bd_net -net dac_dac_wrt_o [get_bd_pins dac_wrt_o] [get_bd_pins dac/dac_wrt_o]
  connect_bd_net -net pll_clk_out1 [get_bd_pins adc_clk] [get_bd_pins adc/adc_clk] [get_bd_pins pll/clk_out1]
  connect_bd_net -net pll_clk_out2 [get_bd_pins dac/dac_clk_1x] [get_bd_pins pll/clk_out2]
  connect_bd_net -net pll_clk_out3 [get_bd_pins dac/dac_clk_2x] [get_bd_pins pll/clk_out3]
  connect_bd_net -net pll_clk_out4 [get_bd_pins dac/dac_clk_2p] [get_bd_pins pll/clk_out4]
  connect_bd_net -net pll_clk_out5 [get_bd_pins ser_clk] [get_bd_pins pll/clk_out5]
  connect_bd_net -net pll_clk_out6 [get_bd_pins pwm_clk] [get_bd_pins pll/clk_out6]
  connect_bd_net -net pll_locked [get_bd_pins dac/dac_locked] [get_bd_pins pll/locked]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: HIER
proc create_hier_cell_HIER { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_HIER() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  # Create pins
  create_bd_pin -dir O -from 0 -to 0 Dout
  create_bd_pin -dir O -from 7 -to 0 led_o
  create_bd_pin -dir I -type clk m_axi_aclk
  create_bd_pin -dir I -type rst m_axi_aresetn
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn

  # Create instance: ctl
  create_hier_cell_ctl $hier_obj ctl

  # Create instance: slice_0_0_ctl_trig, and set properties
  set slice_0_0_ctl_trig [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_0_0_ctl_trig ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {0} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {32} \
 ] $slice_0_0_ctl_trig

  # Create instance: slice_7_0_ctl_led, and set properties
  set slice_7_0_ctl_led [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_7_0_ctl_led ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {7} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {32} \
 ] $slice_7_0_ctl_led

  # Create interface connections
  connect_bd_intf_net -intf_net axi_mem_intercon_0_M00_AXI [get_bd_intf_pins S_AXI] [get_bd_intf_pins ctl/S_AXI]

  # Create port connections
  connect_bd_net -net S00_ARESETN_1 [get_bd_pins s_axi_aresetn] [get_bd_pins ctl/s_axi_aresetn]
  connect_bd_net -net adc_dac_adc_clk [get_bd_pins m_axi_aclk] [get_bd_pins ctl/m_axi_aclk]
  connect_bd_net -net ctl_led [get_bd_pins ctl/led] [get_bd_pins slice_7_0_ctl_led/Din]
  connect_bd_net -net ctl_trig [get_bd_pins ctl/trig] [get_bd_pins slice_0_0_ctl_trig/Din]
  connect_bd_net -net proc_sys_reset_adc_clk_peripheral_aresetn [get_bd_pins m_axi_aresetn] [get_bd_pins ctl/m_axi_aresetn]
  connect_bd_net -net ps_0_FCLK_CLK0 [get_bd_pins s_axi_aclk] [get_bd_pins ctl/s_axi_aclk]
  connect_bd_net -net slice_0_0_ctl_trig_Dout [get_bd_pins Dout] [get_bd_pins slice_0_0_ctl_trig/Dout]
  connect_bd_net -net slice_7_0_ctl_led_Dout [get_bd_pins led_o] [get_bd_pins slice_7_0_ctl_led/Dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: FIR_interoikation
proc create_hier_cell_FIR_interoikation { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_FIR_interoikation() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir O -from 13 -to 0 Dout
  create_bd_pin -dir O -from 13 -to 0 Dout1
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -from 13 -to 0 s_axis_data_tdata

  # Create instance: fir_compiler_0, and set properties
  set fir_compiler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_compiler_0 ]
  set_property -dict [ list \
   CONFIG.Channel_Sequence {Basic} \
   CONFIG.Clock_Frequency {250} \
   CONFIG.CoefficientVector {-0.0396967295357296,-0.0634993036329725,-0.0555103381530743,3.84804626171436e-12,0.273877954673197,0.563489487367677,0.821314800896760,0.999999999992429,0.821314800896760,0.563489487367677,0.273877954673197,3.84804626171436e-12,-0.0555103381530743,-0.0634993036329725,-0.0396967295357296} \
   CONFIG.Coefficient_Fractional_Bits {14} \
   CONFIG.Coefficient_Sets {1} \
   CONFIG.Coefficient_Sign {Signed} \
   CONFIG.Coefficient_Structure {Inferred} \
   CONFIG.Coefficient_Width {16} \
   CONFIG.ColumnConfig {4} \
   CONFIG.DATA_Has_TLAST {Not_Required} \
   CONFIG.Data_Sign {Signed} \
   CONFIG.Data_Width {14} \
   CONFIG.Decimation_Rate {1} \
   CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
   CONFIG.Filter_Type {Interpolation} \
   CONFIG.Interpolation_Rate {4} \
   CONFIG.M_DATA_Has_TUSER {Not_Required} \
   CONFIG.Number_Channels {1} \
   CONFIG.Output_Rounding_Mode {Convergent_Rounding_to_Even} \
   CONFIG.Output_Width {16} \
   CONFIG.Quantization {Quantize_Only} \
   CONFIG.RateSpecification {Frequency_Specification} \
   CONFIG.S_DATA_Has_TUSER {Not_Required} \
   CONFIG.Sample_Frequency {125} \
   CONFIG.Select_Pattern {All} \
   CONFIG.Zero_Pack_Factor {1} \
 ] $fir_compiler_0

  # Create instance: slice_0_0_ctl_trig1, and set properties
  set slice_0_0_ctl_trig1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_0_0_ctl_trig1 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {14} \
   CONFIG.DIN_TO {1} \
   CONFIG.DIN_WIDTH {16} \
   CONFIG.DOUT_WIDTH {14} \
 ] $slice_0_0_ctl_trig1

  # Create instance: slice_0_0_ctl_trig2, and set properties
  set slice_0_0_ctl_trig2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_0_0_ctl_trig2 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {30} \
   CONFIG.DIN_TO {17} \
   CONFIG.DIN_WIDTH {32} \
   CONFIG.DOUT_WIDTH {14} \
 ] $slice_0_0_ctl_trig2

  # Create port connections
  connect_bd_net -net adc_dac_adc1 [get_bd_pins s_axis_data_tdata] [get_bd_pins fir_compiler_0/s_axis_data_tdata]
  connect_bd_net -net fir_compiler_0_m_axis_data_tdata [get_bd_pins fir_compiler_0/m_axis_data_tdata] [get_bd_pins slice_0_0_ctl_trig1/Din] [get_bd_pins slice_0_0_ctl_trig2/Din]
  connect_bd_net -net fir_compiler_0_s_axis_data_tready [get_bd_pins fir_compiler_0/s_axis_data_tready] [get_bd_pins fir_compiler_0/s_axis_data_tvalid]
  connect_bd_net -net ps_0_FCLK_CLK0 [get_bd_pins aclk] [get_bd_pins fir_compiler_0/aclk]
  connect_bd_net -net slice_0_0_ctl_trig1_Dout [get_bd_pins Dout] [get_bd_pins slice_0_0_ctl_trig1/Dout]
  connect_bd_net -net slice_0_0_ctl_trig2_Dout [get_bd_pins Dout1] [get_bd_pins slice_0_0_ctl_trig2/Dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: DAT_CTRL
proc create_hier_cell_DAT_CTRL { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_DAT_CTRL() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:bram_rtl:1.0 BRAM_PORTA

  # Create pins
  create_bd_pin -dir O -from 13 -to 0 Dout1
  create_bd_pin -dir O -from 13 -to 0 Dout2
  create_bd_pin -dir I -type clk clkb
  create_bd_pin -dir O -from 0 -to 0 dout
  create_bd_pin -dir I enb
  create_bd_pin -dir I trig

  # Create instance: DAC_TOP
  create_hier_cell_DAC_TOP $hier_obj DAC_TOP

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins BRAM_PORTA] [get_bd_intf_pins DAC_TOP/BRAM_PORTA]

  # Create port connections
  connect_bd_net -net adc_dac_adc_clk [get_bd_pins clkb] [get_bd_pins DAC_TOP/clkb]
  connect_bd_net -net const_v0_w1_dout [get_bd_pins dout] [get_bd_pins DAC_TOP/dout]
  connect_bd_net -net const_v1_w1_dout [get_bd_pins enb] [get_bd_pins DAC_TOP/enb]
  connect_bd_net -net dac1_1 [get_bd_pins Dout1] [get_bd_pins DAC_TOP/Dout1]
  connect_bd_net -net dac2_1 [get_bd_pins Dout2] [get_bd_pins DAC_TOP/Dout2]
  connect_bd_net -net slice_0_0_ctl_trig_Dout [get_bd_pins trig] [get_bd_pins DAC_TOP/trig]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: ADC_TOP
proc create_hier_cell_ADC_TOP { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_ADC_TOP() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  # Create pins
  create_bd_pin -dir I -from 13 -to 0 In0
  create_bd_pin -dir I -from 13 -to 0 In2
  create_bd_pin -dir I -from 31 -to 0 dinb
  create_bd_pin -dir I enb
  create_bd_pin -dir I -type rst rstb
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_pin -dir I trig

  # Create instance: address_counter1, and set properties
  set address_counter1 [ create_bd_cell -type ip -vlnv koheron:user:address_counter:1.0 address_counter1 ]
  set_property -dict [ list \
   CONFIG.COUNT_WIDTH {14} \
 ] $address_counter1

  # Create instance: axi_bram_ctrl_adc, and set properties
  set axi_bram_ctrl_adc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_adc ]
  set_property -dict [ list \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_adc

  # Create instance: blk_mem_gen_adc, and set properties
  set blk_mem_gen_adc [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_adc ]
  set_property -dict [ list \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
 ] $blk_mem_gen_adc

  # Create instance: concat_adc1_dout_adc2_dout, and set properties
  set concat_adc1_dout_adc2_dout [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 concat_adc1_dout_adc2_dout ]
  set_property -dict [ list \
   CONFIG.IN0_WIDTH {14} \
   CONFIG.IN1_WIDTH {2} \
   CONFIG.IN2_WIDTH {14} \
   CONFIG.IN3_WIDTH {2} \
   CONFIG.NUM_PORTS {4} \
 ] $concat_adc1_dout_adc2_dout

  # Create instance: const_v0_w2, and set properties
  set const_v0_w2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_v0_w2 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {2} \
 ] $const_v0_w2

  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_adc_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_adc/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_adc/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_mem_intercon_0_M03_AXI [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_bram_ctrl_adc/S_AXI]

  # Create port connections
  connect_bd_net -net S00_ARESETN_1 [get_bd_pins s_axi_aresetn] [get_bd_pins axi_bram_ctrl_adc/s_axi_aresetn]
  connect_bd_net -net adc_dac_adc2 [get_bd_pins In2] [get_bd_pins concat_adc1_dout_adc2_dout/In2]
  connect_bd_net -net address_counter1_address [get_bd_pins address_counter1/address] [get_bd_pins blk_mem_gen_adc/addrb]
  connect_bd_net -net address_counter1_wen [get_bd_pins address_counter1/wen] [get_bd_pins blk_mem_gen_adc/web]
  connect_bd_net -net concat_adc1_dout_adc2_dout_dout [get_bd_pins blk_mem_gen_adc/dinb] [get_bd_pins concat_adc1_dout_adc2_dout/dout]
  connect_bd_net -net const_v0_w1_dout [get_bd_pins rstb] [get_bd_pins blk_mem_gen_adc/rstb]
  connect_bd_net -net const_v0_w2_dout [get_bd_pins concat_adc1_dout_adc2_dout/In1] [get_bd_pins concat_adc1_dout_adc2_dout/In3] [get_bd_pins const_v0_w2/dout]
  connect_bd_net -net const_v1_w1_dout [get_bd_pins enb] [get_bd_pins address_counter1/clken] [get_bd_pins blk_mem_gen_adc/enb]
  connect_bd_net -net ps_0_FCLK_CLK0 [get_bd_pins s_axi_aclk] [get_bd_pins address_counter1/clk] [get_bd_pins axi_bram_ctrl_adc/s_axi_aclk] [get_bd_pins blk_mem_gen_adc/clkb]
  connect_bd_net -net slice_0_0_ctl_trig1_Dout [get_bd_pins In0] [get_bd_pins concat_adc1_dout_adc2_dout/In0]
  connect_bd_net -net slice_0_0_ctl_trig_Dout [get_bd_pins trig] [get_bd_pins address_counter1/trig]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set Vaux0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux0 ]
  set Vaux1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux1 ]
  set Vaux8 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux8 ]
  set Vaux9 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux9 ]
  set Vp_Vn [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vp_Vn ]

  # Create ports
  set adc_cdcs_o [ create_bd_port -dir O adc_cdcs_o ]
  set adc_clk_n_i [ create_bd_port -dir I adc_clk_n_i ]
  set adc_clk_p_i [ create_bd_port -dir I adc_clk_p_i ]
  set adc_clk_source [ create_bd_port -dir O -from 1 -to 0 adc_clk_source ]
  set adc_dat_a_i [ create_bd_port -dir I -from 13 -to 0 adc_dat_a_i ]
  set adc_dat_b_i [ create_bd_port -dir I -from 13 -to 0 adc_dat_b_i ]
  set dac_clk_o [ create_bd_port -dir O dac_clk_o ]
  set dac_dat_o [ create_bd_port -dir O -from 13 -to 0 dac_dat_o ]
  set dac_pwm_o [ create_bd_port -dir O -from 3 -to 0 dac_pwm_o ]
  set dac_rst_o [ create_bd_port -dir O dac_rst_o ]
  set dac_sel_o [ create_bd_port -dir O dac_sel_o ]
  set dac_wrt_o [ create_bd_port -dir O dac_wrt_o ]
  set led_o [ create_bd_port -dir O -from 7 -to 0 led_o ]

  # Create instance: ADC_TOP
  create_hier_cell_ADC_TOP [current_bd_instance .] ADC_TOP

  # Create instance: DAT_CTRL
  create_hier_cell_DAT_CTRL [current_bd_instance .] DAT_CTRL

  # Create instance: FIR_interoikation
  create_hier_cell_FIR_interoikation [current_bd_instance .] FIR_interoikation

  # Create instance: HIER
  create_hier_cell_HIER [current_bd_instance .] HIER

  # Create instance: adc_dac
  create_hier_cell_adc_dac [current_bd_instance .] adc_dac

  # Create instance: axi_bram_ctrl_dac, and set properties
  set axi_bram_ctrl_dac [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_dac ]
  set_property -dict [ list \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_dac

  # Create instance: axi_clk_conv_xadc, and set properties
  set axi_clk_conv_xadc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_clock_converter:2.1 axi_clk_conv_xadc ]

  # Create instance: axi_mem_intercon_0, and set properties
  set axi_mem_intercon_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon_0 ]
  set_property -dict [ list \
   CONFIG.M03_HAS_REGSLICE {1} \
   CONFIG.M04_HAS_REGSLICE {1} \
   CONFIG.NUM_MI {5} \
 ] $axi_mem_intercon_0

  # Create instance: const_v1_w1, and set properties
  set const_v1_w1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_v1_w1 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {1} \
   CONFIG.CONST_WIDTH {1} \
 ] $const_v1_w1

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: proc_sys_reset_adc_clk, and set properties
  set proc_sys_reset_adc_clk [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_adc_clk ]

  # Create instance: ps_0, and set properties
  set ps_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps_0 ]
  set_property -dict [ list \
   CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} \
   CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
   CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} \
   CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {250.000000} \
   CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {125.000000} \
   CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {100.000000} \
   CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {166.666672} \
   CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} \
   CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ARMPLL_CTRL_FBDIV {40} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_CLK0_FREQ {250000000} \
   CONFIG.PCW_CLK1_FREQ {200000000} \
   CONFIG.PCW_CLK2_FREQ {10000000} \
   CONFIG.PCW_CLK3_FREQ {10000000} \
   CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1333.333} \
   CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {15} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {7} \
   CONFIG.PCW_DDRPLL_CTRL_FBDIV {32} \
   CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1066.667} \
   CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_DDR_RAM_HIGHADDR {0x1FFFFFFF} \
   CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
   CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
   CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {8} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
   CONFIG.PCW_ENET0_RESET_ENABLE {0} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET1_RESET_ENABLE {0} \
   CONFIG.PCW_ENET_RESET_ENABLE {1} \
   CONFIG.PCW_ENET_RESET_SELECT {Share reset pin} \
   CONFIG.PCW_EN_CLK1_PORT {1} \
   CONFIG.PCW_EN_EMIO_SPI0 {1} \
   CONFIG.PCW_EN_EMIO_SPI1 {0} \
   CONFIG.PCW_EN_EMIO_TTC0 {1} \
   CONFIG.PCW_EN_EMIO_UART0 {0} \
   CONFIG.PCW_EN_ENET0 {1} \
   CONFIG.PCW_EN_GPIO {1} \
   CONFIG.PCW_EN_I2C0 {1} \
   CONFIG.PCW_EN_QSPI {1} \
   CONFIG.PCW_EN_SDIO0 {1} \
   CONFIG.PCW_EN_SPI0 {1} \
   CONFIG.PCW_EN_SPI1 {1} \
   CONFIG.PCW_EN_TTC0 {1} \
   CONFIG.PCW_EN_UART0 {1} \
   CONFIG.PCW_EN_UART1 {1} \
   CONFIG.PCW_EN_USB0 {1} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {2} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK_CLK1_BUF {TRUE} \
   CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {250} \
   CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {200} \
   CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {200} \
   CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
   CONFIG.PCW_FPGA_FCLK1_ENABLE {1} \
   CONFIG.PCW_FPGA_FCLK2_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK3_ENABLE {0} \
   CONFIG.PCW_FTM_CTI_IN0 {<Select>} \
   CONFIG.PCW_FTM_CTI_IN1 {<Select>} \
   CONFIG.PCW_FTM_CTI_IN2 {<Select>} \
   CONFIG.PCW_FTM_CTI_IN3 {<Select>} \
   CONFIG.PCW_FTM_CTI_OUT0 {<Select>} \
   CONFIG.PCW_FTM_CTI_OUT1 {<Select>} \
   CONFIG.PCW_FTM_CTI_OUT2 {<Select>} \
   CONFIG.PCW_FTM_CTI_OUT3 {<Select>} \
   CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
   CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
   CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_I2C0_GRP_INT_ENABLE {0} \
   CONFIG.PCW_I2C0_I2C0_IO {MIO 50 .. 51} \
   CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_I2C0_RESET_ENABLE {0} \
   CONFIG.PCW_I2C1_RESET_ENABLE {0} \
   CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_I2C_RESET_ENABLE {1} \
   CONFIG.PCW_I2C_RESET_SELECT {Share reset pin} \
   CONFIG.PCW_IOPLL_CTRL_FBDIV {30} \
   CONFIG.PCW_IO_IO_PLL_FREQMHZ {1000.000} \
   CONFIG.PCW_MIO_0_DIRECTION {inout} \
   CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_0_PULLUP {disabled} \
   CONFIG.PCW_MIO_0_SLEW {slow} \
   CONFIG.PCW_MIO_10_DIRECTION {inout} \
   CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_10_PULLUP {enabled} \
   CONFIG.PCW_MIO_10_SLEW {slow} \
   CONFIG.PCW_MIO_11_DIRECTION {inout} \
   CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_11_PULLUP {enabled} \
   CONFIG.PCW_MIO_11_SLEW {slow} \
   CONFIG.PCW_MIO_12_DIRECTION {inout} \
   CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_12_PULLUP {enabled} \
   CONFIG.PCW_MIO_12_SLEW {slow} \
   CONFIG.PCW_MIO_13_DIRECTION {inout} \
   CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_13_PULLUP {enabled} \
   CONFIG.PCW_MIO_13_SLEW {slow} \
   CONFIG.PCW_MIO_14_DIRECTION {in} \
   CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_14_PULLUP {enabled} \
   CONFIG.PCW_MIO_14_SLEW {slow} \
   CONFIG.PCW_MIO_15_DIRECTION {out} \
   CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_15_PULLUP {enabled} \
   CONFIG.PCW_MIO_15_SLEW {slow} \
   CONFIG.PCW_MIO_16_DIRECTION {out} \
   CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_16_PULLUP {disabled} \
   CONFIG.PCW_MIO_16_SLEW {fast} \
   CONFIG.PCW_MIO_17_DIRECTION {out} \
   CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_17_PULLUP {disabled} \
   CONFIG.PCW_MIO_17_SLEW {fast} \
   CONFIG.PCW_MIO_18_DIRECTION {out} \
   CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_18_PULLUP {disabled} \
   CONFIG.PCW_MIO_18_SLEW {fast} \
   CONFIG.PCW_MIO_19_DIRECTION {out} \
   CONFIG.PCW_MIO_19_IOTYPE {out} \
   CONFIG.PCW_MIO_19_PULLUP {disabled} \
   CONFIG.PCW_MIO_19_SLEW {fast} \
   CONFIG.PCW_MIO_1_DIRECTION {out} \
   CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_1_PULLUP {enabled} \
   CONFIG.PCW_MIO_1_SLEW {slow} \
   CONFIG.PCW_MIO_20_DIRECTION {out} \
   CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_20_PULLUP {disabled} \
   CONFIG.PCW_MIO_20_SLEW {fast} \
   CONFIG.PCW_MIO_21_DIRECTION {out} \
   CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_21_PULLUP {disabled} \
   CONFIG.PCW_MIO_21_SLEW {fast} \
   CONFIG.PCW_MIO_22_DIRECTION {in} \
   CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_22_PULLUP {disabled} \
   CONFIG.PCW_MIO_22_SLEW {fast} \
   CONFIG.PCW_MIO_23_DIRECTION {in} \
   CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_23_PULLUP {disabled} \
   CONFIG.PCW_MIO_23_SLEW {fast} \
   CONFIG.PCW_MIO_24_DIRECTION {in} \
   CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_24_PULLUP {disabled} \
   CONFIG.PCW_MIO_24_SLEW {fast} \
   CONFIG.PCW_MIO_25_DIRECTION {in} \
   CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_25_PULLUP {disabled} \
   CONFIG.PCW_MIO_25_SLEW {fast} \
   CONFIG.PCW_MIO_26_DIRECTION {in} \
   CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_26_PULLUP {disabled} \
   CONFIG.PCW_MIO_26_SLEW {fast} \
   CONFIG.PCW_MIO_27_DIRECTION {in} \
   CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_27_PULLUP {disabled} \
   CONFIG.PCW_MIO_27_SLEW {fast} \
   CONFIG.PCW_MIO_28_DIRECTION {inout} \
   CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_28_PULLUP {enabled} \
   CONFIG.PCW_MIO_28_SLEW {fast} \
   CONFIG.PCW_MIO_29_DIRECTION {in} \
   CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_29_PULLUP {enabled} \
   CONFIG.PCW_MIO_29_SLEW {fast} \
   CONFIG.PCW_MIO_2_DIRECTION {inout} \
   CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_2_PULLUP {disabled} \
   CONFIG.PCW_MIO_2_SLEW {slow} \
   CONFIG.PCW_MIO_30_DIRECTION {out} \
   CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_30_PULLUP {enabled} \
   CONFIG.PCW_MIO_30_SLEW {fast} \
   CONFIG.PCW_MIO_31_DIRECTION {in} \
   CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_31_PULLUP {enabled} \
   CONFIG.PCW_MIO_31_SLEW {fast} \
   CONFIG.PCW_MIO_32_DIRECTION {inout} \
   CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_32_PULLUP {enabled} \
   CONFIG.PCW_MIO_32_SLEW {fast} \
   CONFIG.PCW_MIO_33_DIRECTION {inout} \
   CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_33_PULLUP {enabled} \
   CONFIG.PCW_MIO_33_SLEW {fast} \
   CONFIG.PCW_MIO_34_DIRECTION {inout} \
   CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_34_PULLUP {enabled} \
   CONFIG.PCW_MIO_34_SLEW {fast} \
   CONFIG.PCW_MIO_35_DIRECTION {inout} \
   CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_35_PULLUP {enabled} \
   CONFIG.PCW_MIO_35_SLEW {fast} \
   CONFIG.PCW_MIO_36_DIRECTION {in} \
   CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_36_PULLUP {enabled} \
   CONFIG.PCW_MIO_36_SLEW {fast} \
   CONFIG.PCW_MIO_37_DIRECTION {inout} \
   CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_37_PULLUP {enabled} \
   CONFIG.PCW_MIO_37_SLEW {fast} \
   CONFIG.PCW_MIO_38_DIRECTION {inout} \
   CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_38_PULLUP {enabled} \
   CONFIG.PCW_MIO_38_SLEW {fast} \
   CONFIG.PCW_MIO_39_DIRECTION {inout} \
   CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_39_PULLUP {enabled} \
   CONFIG.PCW_MIO_39_SLEW {fast} \
   CONFIG.PCW_MIO_3_DIRECTION {inout} \
   CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_3_PULLUP {disabled} \
   CONFIG.PCW_MIO_3_SLEW {slow} \
   CONFIG.PCW_MIO_40_DIRECTION {inout} \
   CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_40_PULLUP {enabled} \
   CONFIG.PCW_MIO_40_SLEW {slow} \
   CONFIG.PCW_MIO_41_DIRECTION {inout} \
   CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_41_PULLUP {enabled} \
   CONFIG.PCW_MIO_41_SLEW {slow} \
   CONFIG.PCW_MIO_42_DIRECTION {inout} \
   CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_42_PULLUP {enabled} \
   CONFIG.PCW_MIO_42_SLEW {slow} \
   CONFIG.PCW_MIO_43_DIRECTION {inout} \
   CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_43_PULLUP {enabled} \
   CONFIG.PCW_MIO_43_SLEW {slow} \
   CONFIG.PCW_MIO_44_DIRECTION {inout} \
   CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_44_PULLUP {enabled} \
   CONFIG.PCW_MIO_44_SLEW {slow} \
   CONFIG.PCW_MIO_45_DIRECTION {inout} \
   CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_45_PULLUP {enabled} \
   CONFIG.PCW_MIO_45_SLEW {slow} \
   CONFIG.PCW_MIO_46_DIRECTION {in} \
   CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_46_PULLUP {enabled} \
   CONFIG.PCW_MIO_46_SLEW {slow} \
   CONFIG.PCW_MIO_47_DIRECTION {in} \
   CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_47_PULLUP {enabled} \
   CONFIG.PCW_MIO_47_SLEW {slow} \
   CONFIG.PCW_MIO_48_DIRECTION {out} \
   CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_48_PULLUP {enabled} \
   CONFIG.PCW_MIO_48_SLEW {slow} \
   CONFIG.PCW_MIO_49_DIRECTION {inout} \
   CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_49_PULLUP {enabled} \
   CONFIG.PCW_MIO_49_SLEW {slow} \
   CONFIG.PCW_MIO_4_DIRECTION {inout} \
   CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_4_PULLUP {disabled} \
   CONFIG.PCW_MIO_4_SLEW {slow} \
   CONFIG.PCW_MIO_50_DIRECTION {inout} \
   CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_50_PULLUP {enabled} \
   CONFIG.PCW_MIO_50_SLEW {slow} \
   CONFIG.PCW_MIO_51_DIRECTION {inout} \
   CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_51_PULLUP {enabled} \
   CONFIG.PCW_MIO_51_SLEW {slow} \
   CONFIG.PCW_MIO_52_DIRECTION {out} \
   CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_52_PULLUP {enabled} \
   CONFIG.PCW_MIO_52_SLEW {slow} \
   CONFIG.PCW_MIO_53_DIRECTION {inout} \
   CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 2.5V} \
   CONFIG.PCW_MIO_53_PULLUP {enabled} \
   CONFIG.PCW_MIO_53_SLEW {slow} \
   CONFIG.PCW_MIO_5_DIRECTION {inout} \
   CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_5_PULLUP {disabled} \
   CONFIG.PCW_MIO_5_SLEW {slow} \
   CONFIG.PCW_MIO_6_DIRECTION {out} \
   CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_6_PULLUP {disabled} \
   CONFIG.PCW_MIO_6_SLEW {slow} \
   CONFIG.PCW_MIO_7_DIRECTION {out} \
   CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_7_PULLUP {disabled} \
   CONFIG.PCW_MIO_7_SLEW {slow} \
   CONFIG.PCW_MIO_8_DIRECTION {out} \
   CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_8_PULLUP {disabled} \
   CONFIG.PCW_MIO_8_SLEW {slow} \
   CONFIG.PCW_MIO_9_DIRECTION {in} \
   CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_9_PULLUP {enabled} \
   CONFIG.PCW_MIO_9_SLEW {slow} \
   CONFIG.PCW_MIO_TREE_PERIPHERALS {GPIO#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#GPIO#UART 1#UART 1#SPI 1#SPI 1#SPI 1#SPI 1#UART 0#UART 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#USB Reset#GPIO#I2C 0#I2C 0#Enet 0#Enet 0} \
   CONFIG.PCW_MIO_TREE_SIGNALS {gpio[0]#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]/HOLD_B#qspi0_sclk#gpio[7]#tx#rx#mosi#miso#sclk#ss[0]#rx#tx#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#clk#cmd#data[0]#data[1]#data[2]#data[3]#cd#wp#reset#gpio[49]#scl#sda#mdc#mdio} \
   CONFIG.PCW_NAND_GRP_D8_ENABLE {0} \
   CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_A25_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_CS0_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_CS1_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE {0} \
   CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 2.5V} \
   CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {0} \
   CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0} \
   CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
   CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} \
   CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} \
   CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {8} \
   CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {125} \
   CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
   CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
   CONFIG.PCW_SD0_GRP_CD_IO {MIO 46} \
   CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
   CONFIG.PCW_SD0_GRP_WP_ENABLE {1} \
   CONFIG.PCW_SD0_GRP_WP_IO {MIO 47} \
   CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
   CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {10} \
   CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
   CONFIG.PCW_SINGLE_QSPI_DATA_MODE {x4} \
   CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_SPI0_GRP_SS0_ENABLE {1} \
   CONFIG.PCW_SPI0_GRP_SS0_IO {EMIO} \
   CONFIG.PCW_SPI0_GRP_SS1_ENABLE {1} \
   CONFIG.PCW_SPI0_GRP_SS1_IO {EMIO} \
   CONFIG.PCW_SPI0_GRP_SS2_ENABLE {1} \
   CONFIG.PCW_SPI0_GRP_SS2_IO {EMIO} \
   CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_SPI0_SPI0_IO {EMIO} \
   CONFIG.PCW_SPI1_GRP_SS0_ENABLE {1} \
   CONFIG.PCW_SPI1_GRP_SS0_IO {MIO 13} \
   CONFIG.PCW_SPI1_GRP_SS1_ENABLE {0} \
   CONFIG.PCW_SPI1_GRP_SS2_ENABLE {0} \
   CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_SPI1_SPI1_IO {MIO 10 .. 15} \
   CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {6} \
   CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {166.666666} \
   CONFIG.PCW_SPI_PERIPHERAL_VALID {1} \
   CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TTC0_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC0_CLK1_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC0_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_TTC0_TTC0_IO {EMIO} \
   CONFIG.PCW_TTC_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
   CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_UART0_UART0_IO {MIO 14 .. 15} \
   CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
   CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_UART1_UART1_IO {MIO 8 .. 9} \
   CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {10} \
   CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
   CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} \
   CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT {3} \
   CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {16 Bit} \
   CONFIG.PCW_UIPARAM_DDR_CL {7} \
   CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10} \
   CONFIG.PCW_UIPARAM_DDR_CWL {6} \
   CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {4096 MBits} \
   CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {16 Bits} \
   CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
   CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} \
   CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {15} \
   CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} \
   CONFIG.PCW_UIPARAM_DDR_T_FAW {40.0} \
   CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {35.0} \
   CONFIG.PCW_UIPARAM_DDR_T_RC {48.91} \
   CONFIG.PCW_UIPARAM_DDR_T_RCD {7} \
   CONFIG.PCW_UIPARAM_DDR_T_RP {7} \
   CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ {60} \
   CONFIG.PCW_USB0_RESET_ENABLE {1} \
   CONFIG.PCW_USB0_RESET_IO {MIO 48} \
   CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} \
   CONFIG.PCW_USB1_RESET_ENABLE {0} \
   CONFIG.PCW_USB_RESET_ENABLE {1} \
   CONFIG.PCW_USB_RESET_SELECT {Share reset pin} \
   CONFIG.PCW_USE_M_AXI_GP0 {1} \
   CONFIG.PCW_USE_S_AXI_HP0 {0} \
 ] $ps_0

  # Create instance: sts
  create_hier_cell_sts [current_bd_instance .] sts

  # Create instance: xadc, and set properties
  set xadc [ create_bd_cell -type ip -vlnv xilinx.com:ip:xadc_wiz:3.3 xadc ]
  set_property -dict [ list \
   CONFIG.ADC_CONVERSION_RATE {1000} \
   CONFIG.CHANNEL_ENABLE_VAUXP0_VAUXN0 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP1_VAUXN1 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP8_VAUXN8 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP9_VAUXN9 {true} \
   CONFIG.CHANNEL_ENABLE_VP_VN {true} \
   CONFIG.DCLK_FREQUENCY {125} \
   CONFIG.XADC_STARUP_SELECTION {independent_adc} \
 ] $xadc

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins axi_mem_intercon_0/S00_AXI] [get_bd_intf_pins ps_0/M_AXI_GP0]
  connect_bd_intf_net -intf_net Vaux0_1 [get_bd_intf_ports Vaux0] [get_bd_intf_pins xadc/Vaux0]
  connect_bd_intf_net -intf_net Vaux1_1 [get_bd_intf_ports Vaux1] [get_bd_intf_pins xadc/Vaux1]
  connect_bd_intf_net -intf_net Vaux8_1 [get_bd_intf_ports Vaux8] [get_bd_intf_pins xadc/Vaux8]
  connect_bd_intf_net -intf_net Vaux9_1 [get_bd_intf_ports Vaux9] [get_bd_intf_pins xadc/Vaux9]
  connect_bd_intf_net -intf_net Vp_Vn_1 [get_bd_intf_ports Vp_Vn] [get_bd_intf_pins xadc/Vp_Vn]
  connect_bd_intf_net -intf_net axi_bram_ctrl_dac_BRAM_PORTA [get_bd_intf_pins DAT_CTRL/BRAM_PORTA] [get_bd_intf_pins axi_bram_ctrl_dac/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_clk_conv_xadc_M_AXI [get_bd_intf_pins axi_clk_conv_xadc/M_AXI] [get_bd_intf_pins xadc/s_axi_lite]
  connect_bd_intf_net -intf_net axi_mem_intercon_0_M00_AXI [get_bd_intf_pins HIER/S_AXI] [get_bd_intf_pins axi_mem_intercon_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_mem_intercon_0_M01_AXI [get_bd_intf_pins axi_mem_intercon_0/M01_AXI] [get_bd_intf_pins sts/S_AXI]
  connect_bd_intf_net -intf_net axi_mem_intercon_0_M02_AXI [get_bd_intf_pins axi_clk_conv_xadc/S_AXI] [get_bd_intf_pins axi_mem_intercon_0/M02_AXI]
  connect_bd_intf_net -intf_net axi_mem_intercon_0_M03_AXI [get_bd_intf_pins ADC_TOP/S_AXI] [get_bd_intf_pins axi_mem_intercon_0/M03_AXI]
  connect_bd_intf_net -intf_net axi_mem_intercon_0_M04_AXI [get_bd_intf_pins axi_bram_ctrl_dac/S_AXI] [get_bd_intf_pins axi_mem_intercon_0/M04_AXI]
  connect_bd_intf_net -intf_net ps_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins ps_0/DDR]
  connect_bd_intf_net -intf_net ps_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins ps_0/FIXED_IO]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins axi_mem_intercon_0/ARESETN] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
  connect_bd_net -net In2_1 [get_bd_pins ADC_TOP/In2] [get_bd_pins FIR_interoikation/Dout1]
  connect_bd_net -net S00_ARESETN_1 [get_bd_pins ADC_TOP/s_axi_aresetn] [get_bd_pins HIER/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_dac/s_axi_aresetn] [get_bd_pins axi_clk_conv_xadc/s_axi_aresetn] [get_bd_pins axi_mem_intercon_0/M00_ARESETN] [get_bd_pins axi_mem_intercon_0/M01_ARESETN] [get_bd_pins axi_mem_intercon_0/M02_ARESETN] [get_bd_pins axi_mem_intercon_0/M03_ARESETN] [get_bd_pins axi_mem_intercon_0/M04_ARESETN] [get_bd_pins axi_mem_intercon_0/S00_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins sts/s_axi_aresetn]
  connect_bd_net -net adc_clk_n_i_1 [get_bd_ports adc_clk_n_i] [get_bd_pins adc_dac/adc_clk_n_i]
  connect_bd_net -net adc_clk_p_i_1 [get_bd_ports adc_clk_p_i] [get_bd_pins adc_dac/adc_clk_p_i]
  connect_bd_net -net adc_dac_adc1 [get_bd_pins FIR_interoikation/s_axis_data_tdata] [get_bd_pins adc_dac/adc1]
  connect_bd_net -net adc_dac_adc_cdcs_o [get_bd_ports adc_cdcs_o] [get_bd_pins adc_dac/adc_cdcs_o]
  connect_bd_net -net adc_dac_adc_clk [get_bd_pins DAT_CTRL/clkb] [get_bd_pins HIER/m_axi_aclk] [get_bd_pins adc_dac/adc_clk] [get_bd_pins axi_clk_conv_xadc/m_axi_aclk] [get_bd_pins proc_sys_reset_adc_clk/slowest_sync_clk] [get_bd_pins sts/m_axi_aclk] [get_bd_pins xadc/s_axi_aclk]
  connect_bd_net -net adc_dac_adc_clk_source [get_bd_ports adc_clk_source] [get_bd_pins adc_dac/adc_clk_source]
  connect_bd_net -net adc_dac_dac_clk_o [get_bd_ports dac_clk_o] [get_bd_pins adc_dac/dac_clk_o]
  connect_bd_net -net adc_dac_dac_dat_o [get_bd_ports dac_dat_o] [get_bd_pins adc_dac/dac_dat_o]
  connect_bd_net -net adc_dac_dac_rst_o [get_bd_ports dac_rst_o] [get_bd_pins adc_dac/dac_rst_o]
  connect_bd_net -net adc_dac_dac_sel_o [get_bd_ports dac_sel_o] [get_bd_pins adc_dac/dac_sel_o]
  connect_bd_net -net adc_dac_dac_wrt_o [get_bd_ports dac_wrt_o] [get_bd_pins adc_dac/dac_wrt_o]
  connect_bd_net -net adc_dat_a_i_1 [get_bd_ports adc_dat_a_i] [get_bd_pins adc_dac/adc_dat_a_i]
  connect_bd_net -net adc_dat_b_i_1 [get_bd_ports adc_dat_b_i] [get_bd_pins adc_dac/adc_dat_b_i]
  connect_bd_net -net const_v0_w1_dout [get_bd_pins ADC_TOP/rstb] [get_bd_pins DAT_CTRL/dout]
  connect_bd_net -net const_v1_w1_dout [get_bd_pins ADC_TOP/enb] [get_bd_pins DAT_CTRL/enb] [get_bd_pins const_v1_w1/dout]
  connect_bd_net -net dac1_1 [get_bd_pins DAT_CTRL/Dout1] [get_bd_pins adc_dac/dac1]
  connect_bd_net -net dac2_1 [get_bd_pins DAT_CTRL/Dout2] [get_bd_pins adc_dac/dac2]
  connect_bd_net -net proc_sys_reset_adc_clk_peripheral_aresetn [get_bd_pins HIER/m_axi_aresetn] [get_bd_pins axi_clk_conv_xadc/m_axi_aresetn] [get_bd_pins proc_sys_reset_adc_clk/peripheral_aresetn] [get_bd_pins sts/m_axi_aresetn] [get_bd_pins xadc/s_axi_aresetn]
  connect_bd_net -net ps_0_FCLK_CLK0 [get_bd_pins ADC_TOP/s_axi_aclk] [get_bd_pins FIR_interoikation/aclk] [get_bd_pins HIER/s_axi_aclk] [get_bd_pins axi_bram_ctrl_dac/s_axi_aclk] [get_bd_pins axi_clk_conv_xadc/s_axi_aclk] [get_bd_pins axi_mem_intercon_0/ACLK] [get_bd_pins axi_mem_intercon_0/M00_ACLK] [get_bd_pins axi_mem_intercon_0/M01_ACLK] [get_bd_pins axi_mem_intercon_0/M02_ACLK] [get_bd_pins axi_mem_intercon_0/M03_ACLK] [get_bd_pins axi_mem_intercon_0/M04_ACLK] [get_bd_pins axi_mem_intercon_0/S00_ACLK] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins ps_0/FCLK_CLK0] [get_bd_pins ps_0/M_AXI_GP0_ACLK] [get_bd_pins sts/s_axi_aclk]
  connect_bd_net -net ps_0_FCLK_RESET0_N [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins proc_sys_reset_adc_clk/ext_reset_in] [get_bd_pins ps_0/FCLK_RESET0_N]
  connect_bd_net -net slice_0_0_ctl_trig1_Dout [get_bd_pins ADC_TOP/In0] [get_bd_pins FIR_interoikation/Dout]
  connect_bd_net -net slice_0_0_ctl_trig_Dout [get_bd_pins ADC_TOP/trig] [get_bd_pins DAT_CTRL/trig] [get_bd_pins HIER/Dout]
  connect_bd_net -net slice_7_0_ctl_led_Dout [get_bd_ports led_o] [get_bd_pins HIER/led_o]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x40000000 [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs ADC_TOP/axi_bram_ctrl_adc/S_AXI/Mem0] SEG_axi_bram_ctrl_adc_Mem0
  create_bd_addr_seg -range 0x00010000 -offset 0x40040000 [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs axi_bram_ctrl_dac/S_AXI/Mem0] SEG_axi_bram_ctrl_dac_Mem0
  create_bd_addr_seg -range 0x00001000 -offset 0x60000000 [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs HIER/ctl/axi_ctl_register_0/s_axi/reg0] SEG_axi_ctl_register_0_reg0
  create_bd_addr_seg -range 0x00001000 -offset 0x50001000 [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs sts/axi_sts_register_0/s_axi/reg0] SEG_axi_sts_register_0_reg0
  create_bd_addr_seg -range 0x00010000 -offset 0x43C00000 [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs xadc/s_axi_lite/Reg] SEG_xadc_Reg


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""



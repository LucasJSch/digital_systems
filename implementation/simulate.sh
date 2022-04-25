#!/bin/bash -i

# Script to compile and simulate a VHDL-descripted component.
# Compilation is done with GHDL, while simulation with GTKWAVE.

# Execution example: ./simulate.sh PATH_TO_SRC_FILE ENTITY_NAME PATH_TO_SAVE_VCD_FILE

GHDL=/usr/bin/ghdl
GTKWAVE=/usr/local/bin/gtkwave
STOP_TIME=1000ns
CURRENT_PATH=$(pwd)
FILEPATH=$CURRENT_PATH$1
ENTITY=$2
VCD_FILE_PATH=$CURRENT_PATH$3

echo "Path of source file is: "
echo $FILEPATH
echo ""

echo "Saving VCD file in: "
echo $VCD_FILE_PATH
echo ""

# Syntax check
echo "Syntax checking..."
$GHDL -s $FILEPATH

# Analysis/compilation step (generates objetcs files)
echo "Analyizing..."
$GHDL -a $FILEPATH

# Elaboration step
echo "Elaborating..."
$GHDL -e $ENTITY

# Run command (simulates a design)
echo "Running..."
$GHDL -r $ENTITY --vcd=$ENTITY.vcd --stop-time=$STOP_TIME

# Simulate in GTKWAVE
echo "Simulating..."
$GTKWAVE $ENTITY.vcd

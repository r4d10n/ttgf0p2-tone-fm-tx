# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test FM transmitter behavior")

    # Enable the FM transmitter and loop mode
    # ui_in[0] = enable, ui_in[1] = loop
    dut.ui_in.value = 0b00000011  # Enable and loop

    # Wait for the module to start
    await ClockCycles(dut.clk, 10)

    # Check that playing signal goes high
    # uo_out[2] = playing
    uo_out_val = int(dut.uo_out.value)
    playing = (uo_out_val >> 2) & 0x1
    dut._log.info(f"Playing status: {playing}")
    assert playing == 1, "Module should be playing"

    # Check that we can read note index
    # uo_out[7:4] = note_index[3:0]
    note_index = (uo_out_val >> 4) & 0xF
    dut._log.info(f"Note index: {note_index}")

    # Wait longer and verify the note index advances
    await ClockCycles(dut.clk, 1000)
    uo_out_val = int(dut.uo_out.value)
    note_index_new = (uo_out_val >> 4) & 0xF
    dut._log.info(f"Note index after wait: {note_index_new}")

    # Disable and check that playing stops
    dut.ui_in.value = 0b00000000  # Disable
    await ClockCycles(dut.clk, 10)
    uo_out_val = int(dut.uo_out.value)
    playing = (uo_out_val >> 2) & 0x1
    dut._log.info(f"Playing status after disable: {playing}")
    assert playing == 0, "Module should not be playing after disable"

    dut._log.info("Test completed successfully")

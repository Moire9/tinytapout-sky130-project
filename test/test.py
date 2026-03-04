# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

# import code

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    async def log_7seg():
        sevenseg = 0
        dut._log.info("Logging 7-segment:")
        while (v(dut.uio_out) & 0b00001111) != 0b1110: await ClockCycles(dut.clk, 1) # get to end of cycle
        while (v(dut.uio_out) & 0b00000001) != 1: await ClockCycles(dut.clk, 1) # get to start of cycle
        sevenseg = v(dut.uo_out)
        await ClockCycles(dut.clk, 20)
        sevenseg = sevenseg << 8 | v(dut.uo_out)
        await ClockCycles(dut.clk, 20)
        sevenseg = sevenseg << 8 | v(dut.uo_out)
        dut._log.info(hex(sevenseg))

    ass = True

    try: # check if we can access submodules
        dut.user_project.top
    except AttributeError:
        dut._log.info("Skipping assert - we are not able to evaluate gate-level because cocotb does not"
            + "give us access to the datapaths directly (or maybe I'm missing something obvious)")
        ass = False

    v = lambda logic_array_object: logic_array_object.get().to_unsigned()
    dut._log.info("Start")

    clock = Clock(dut.clk, 20, unit="ns")
    cocotb.start_soon(clock.start())

    # You. Reader. Make your debugging sessions interactive with THIS. So awesome.

    # code.InteractiveConsole(locals=globals() | locals()).interact()

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 100)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    await log_7seg()

    # For some reason the logic runs 13.2 times slower than expected

    # Test incrementation
    for i in range(256):
        if i == 13: await log_7seg()

        # dut._log.info(f"Turkeys: {dut.user_project.top.turkeys}")
        if ass: assert v(dut.user_project.top.turkeys) == i

        dut.ui_in.value = 0b00000001

        await ClockCycles(dut.clk, 60)

        dut.ui_in.value = 0b00000011

        await ClockCycles(dut.clk, 60)

        dut.ui_in.value = 0b00000010

        await ClockCycles(dut.clk, 60)

        dut.ui_in.value = 0b00000000

        await ClockCycles(dut.clk, 60)

    if ass: assert v(dut.user_project.top.turkeys) == 0

    # Test decrementation
    for i in range(255):
        if i == 242: await log_7seg()

        dut.ui_in.value = 0b00000010
        await ClockCycles(dut.clk, 60)
        dut.ui_in.value = 0b00000011
        await ClockCycles(dut.clk, 60)
        dut.ui_in.value = 0b00000001
        await ClockCycles(dut.clk, 60)
        dut.ui_in.value = 0b00000000
        await ClockCycles(dut.clk, 60)
        
        # the number is stored unsigned and when displaying it on the 7seg it's
        # converted into 2's complement
        if ass: assert v(dut.user_project.top.turkeys) == 255 - i

    await log_7seg()


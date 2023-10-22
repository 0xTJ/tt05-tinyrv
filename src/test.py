import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

def set_instr(dut, val):
    dut.ui_in.value = (val >> 8) & 0xFF
    dut.uio_in.value = (val >> 0) & 0xFF

@cocotb.test()
async def test_my_design(dut):
    dut._log.info("start")

    clock = Clock(dut.clk, 1, units="us")
    cocotb.start_soon(clock.start())

    dut.rst_n.value = 0 # low to reset
    await ClockCycles(dut.clk, 5)
    set_instr(dut, 0x0F0F)
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1 # take out of reset

    await ClockCycles(dut.clk, 10)
    set_instr(dut, 0b000_001_000_0000_000)
    await ClockCycles(dut.clk, 1)
    set_instr(dut, 0b000_010_000_0000_000)
    await ClockCycles(dut.clk, 1)
    set_instr(dut, 0b000_011_000_0000_000)
    await ClockCycles(dut.clk, 1)
    set_instr(dut, 0b000_100_000_0000_000)
    await ClockCycles(dut.clk, 1)
    set_instr(dut, 0b000_101_000_0000_000)
    await ClockCycles(dut.clk, 1)
    set_instr(dut, 0b000_110_000_0000_000)
    await ClockCycles(dut.clk, 1)
    set_instr(dut, 0b000_111_000_0000_000)
    await ClockCycles(dut.clk, 1)
    set_instr(dut, 0b110_110_000_0010000)
    await ClockCycles(dut.clk, 1)
    set_instr(dut, 0b111_100_000_0000000)
    await ClockCycles(dut.clk, 1)
    set_instr(dut, 0b000_000_000_0000_000)
    await ClockCycles(dut.clk, 10)

    dut._log.info("end")

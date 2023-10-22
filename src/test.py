import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

@cocotb.test()
async def test_my_design(dut):
    dut._log.info("start")

    clock = Clock(dut.clk, 1, units="us")
    cocotb.start_soon(clock.start())

    dut.rst_n.value = 0 # low to reset
    await ClockCycles(dut.clk, 5)
    dut.ui_in.value = 0x0F
    dut.uio_in.value = 0x0F
    dut.ena.value = 1
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1 # take out of reset

    await ClockCycles(dut.clk, 10)
    dut.ui_in.value = 0x00
    dut.uio_in.value = 0x00
    await ClockCycles(dut.clk, 10)
    dut.ui_in.value = 0xFF
    dut.uio_in.value = 0xFF
    await ClockCycles(dut.clk, 10)

    dut._log.info("end")

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

def lpc_lframe(dut):
    return ((dut.uo_out.value >> 0) & 0x1) != 0x1

def lpc_lad(dut, peri_lad, peri_lad_oe):
    dut_lad = (dut.uio_out.value >> 0) & 0xF
    dut_lad_oe = (dut.uio_oe.value >> 0) & 0xF
    no_lad_oe = (~(dut_lad_oe | peri_lad_oe)) & 0xF
    assert (dut_lad_oe & peri_lad_oe) == 0x0
    return (dut_lad & dut_lad_oe) | (peri_lad & peri_lad_oe) | (0xF & no_lad_oe)

@cocotb.test()
async def test_my_design(dut):
    dut._log.info("start")

    clock = Clock(dut.clk, 30, units="ns")
    cocotb.start_soon(clock.start())

    dut.rst_n.value = 0 # low to reset
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1 # take out of reset

    lframe = 0
    peri_lad = 0xF
    peri_lad_oe = 0x0

    lad = lpc_lad(dut, peri_lad, peri_lad_oe)

    last_lad = lad
    dut.uio_in.value = lpc_lad(dut, peri_lad, peri_lad_oe)
    await ClockCycles(dut.clk, 1)
    lad = lpc_lad(dut, peri_lad, peri_lad_oe)
    lframe = lpc_lframe(dut)


    while not lframe:
        last_lad = lad
        dut.uio_in.value = lpc_lad(dut, peri_lad, peri_lad_oe)
        await ClockCycles(dut.clk, 1)
        lad = lpc_lad(dut, peri_lad, peri_lad_oe)
        lframe = lpc_lframe(dut)
        
    while lframe:
        last_lad = lad
        dut.uio_in.value = lpc_lad(dut, peri_lad, peri_lad_oe)
        await ClockCycles(dut.clk, 1)
        lad = lpc_lad(dut, peri_lad, peri_lad_oe)
        lframe = lpc_lframe(dut)

    # Now we are after rising edge in CYCTYPE/DIR
    assert ((lad >> 2) & 0x3) == 0b01   # Assert memory cycle
    cyc_dir = ((lad >> 1) & 0x1)
    assert ((lad >> 0) & 0x1) == 0b0    # Assert reserved bit is clear

    addr = 0
    for i in range(8):
        last_lad = lad
        dut.uio_in.value = lpc_lad(dut, peri_lad, peri_lad_oe)
        await ClockCycles(dut.clk, 1)
        lad = lpc_lad(dut, peri_lad, peri_lad_oe)
        lframe = lpc_lframe(dut)
        assert lframe == False

        addr <<= 4
        addr |= lad

    if cyc_dir == 0:
        # Read
        last_lad = lad
        dut.uio_in.value = lpc_lad(dut, peri_lad, peri_lad_oe)
        await ClockCycles(dut.clk, 1)
        lad = lpc_lad(dut, peri_lad, peri_lad_oe)
        lframe = lpc_lframe(dut)
        assert lframe == False
        assert lad == 0xF

        last_lad = lad
        dut.uio_in.value = lpc_lad(dut, peri_lad, peri_lad_oe)
        await ClockCycles(dut.clk, 1)
        lad = lpc_lad(dut, peri_lad, peri_lad_oe)
        lframe = lpc_lframe(dut)
        assert lframe == False
        assert lad == 0xF

        peri_lad = 0x0
        peri_lad_oe = 0xF

        last_lad = lad
        dut.uio_in.value = lpc_lad(dut, peri_lad, peri_lad_oe)
        await ClockCycles(dut.clk, 1)
        lad = lpc_lad(dut, peri_lad, peri_lad_oe)
        lframe = lpc_lframe(dut)
        assert lframe == False

        peri_lad = 0xA

        last_lad = lad
        dut.uio_in.value = lpc_lad(dut, peri_lad, peri_lad_oe)
        await ClockCycles(dut.clk, 1)
        lad = lpc_lad(dut, peri_lad, peri_lad_oe)
        lframe = lpc_lframe(dut)
        assert lframe == False

        peri_lad = 0x5

        last_lad = lad
        dut.uio_in.value = lpc_lad(dut, peri_lad, peri_lad_oe)
        await ClockCycles(dut.clk, 1)
        lad = lpc_lad(dut, peri_lad, peri_lad_oe)
        lframe = lpc_lframe(dut)
        assert lframe == False

        peri_lad = 0xF

        last_lad = lad
        dut.uio_in.value = lpc_lad(dut, peri_lad, peri_lad_oe)
        await ClockCycles(dut.clk, 1)
        lad = lpc_lad(dut, peri_lad, peri_lad_oe)
        lframe = lpc_lframe(dut)
        assert lframe == False

        peri_lad_oe = 0x0

    else:
        # Write
        data = 0
        for i in range(2):
            last_lad = lad
            dut.uio_in.value = lpc_lad(dut, peri_lad, peri_lad_oe)
            await ClockCycles(dut.clk, 1)
            lad = lpc_lad(dut, peri_lad, peri_lad_oe)
            lframe = lpc_lframe(dut)
            assert lframe == False

            data |= (lad << (4 * i))

    dut._log.info("end")

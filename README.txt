
This repository contains two designs. Full adder for simplicity and a MIPS processor.

start tool: innvn_s (stylus mode)

steps to run flows for mips:
	from syn/work:
		synthesis:
			source ../scripts/genus_mips.tcl

	from apr/work:
		APR:
			source ../scripts/innov_stylus.tcl

steps to run flows for full adder:
	from syn/work:
		synthesis:
			source ../scripts/genus_fa.tcl

	from apr/work:
		APR:
			source ../scripts/innov_stylus_fa.tcl

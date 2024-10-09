create_clock -name clk_50 -period "50MHz" [get_ports clk_50]
derive_clock_uncertainty
derive_pll_clocks
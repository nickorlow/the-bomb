#!/bin/bash

cat << EOF > output_files/st7920_driver.cdf
    /* Quartus Prime Version 23.1std.0 Build 991 11/28/2023 SC Lite Edition */
    JedecChain;
        FileRevision(JESD32A);
        DefaultMfr(6E);
    
        P ActionCode(Ign)
            Device PartName(SOCVHPS) MfrSpec(OpMask(0));
        P ActionCode(Cfg)
            Device PartName(5CSEBA6U23) Path("$(pwd)/output_files/") File("st7920_driver.sof") MfrSpec(OpMask(1));
    
    ChainEnd;
    
    AlteraBegin;
        ChainType(JTAG);
    AlteraEnd;
EOF

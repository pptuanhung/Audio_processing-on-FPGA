set_global_assignment -entity "gen12Mhz" -library "lib_gen12Mhz" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "gen12Mhz" -library "lib_gen12Mhz" -name IP_TOOL_VERSION "23.1"
set_global_assignment -entity "gen12Mhz" -library "lib_gen12Mhz" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_gen12Mhz" -name SPD_FILE [file join $::quartus(sip_path) "gen12Mhz.spd"]

set_global_assignment -library "lib_gen12Mhz" -name MISC_FILE [file join $::quartus(sip_path) "gen12Mhz_sim/gen12Mhz.vo"]

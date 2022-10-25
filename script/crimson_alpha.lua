-- initialize script extensions
Duel.LoadScript ("constant_ext.lua")
Duel.LoadScript ("utility_ext.lua")
Duel.LoadScript ("cards_specific_functions_ext.lua")
Duel.LoadScript ("proc_ritual_ext.lua")
Duel.LoadScript ("proc_pendulum_ext.lua")
Duel.LoadScript ("custom_set_codes.lua")

-- update globals
regeff_list[REGISTER_FLAG_FLIP]=TYPE_FLIP
regeff_list[CUSTOM_REGISTER_LIMIT]=EFFECT_UNIQUE_CHECK

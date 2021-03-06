/*
    Author: Dorbedo

    Description:
        Opens the crate-interface

*/
#include "script_component.hpp"
SCRIPT(ui_crate_OpenMenu);
[] call FM(ui_crate_createlists);

if (isnil "DORB_CRATE_CURRENT") then {
    DORB_CRATE_CURRENT = [[],[],[],[],[],[]];
};

if (isnil "DORB_CRATE_CURRENT_BOXID") then {
    DORB_CRATE_CURRENT_BOXID = 0;
};

createDialog "dorb_crate";
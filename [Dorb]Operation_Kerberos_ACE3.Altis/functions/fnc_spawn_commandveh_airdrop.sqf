/*
	Author: Dorbedo
	
	Description:
		Commandveh Airdrop
*/
#include "script_component.hpp"

LOG("Commandveh Airdrop");
PARAMS_1(_position);
private["_spawnposition","_einheit","_veh","_dir","_attack_pos","_return"];
_spawnposition=[];
_einheit = dorb_commandveh_radio SELRND;
_spawnposition = [_position,200,0] call FM(random_pos);
_spawnposition = _spawnposition findEmptyPosition [1,100,_einheit];
if (count _spawnposition < 1) exitWith {ERROR("Keine Spawnposition | Commandveh Airdrop");};
_dir = floor(random 360);
_return = [_spawnposition,_dir,_einheit,dorb_commandveh_side] call BIS_fnc_spawnVehicle;
_veh = (_return select 0);
_veh setFuel 0;
_veh lock 3;
If (DORB_PLAYERSIDE == east) then {
	[_veh,1] spawn rhs_fnc_fmtv_Deploy;
}else{
	[_veh,1,true] spawn RHS_fnc_gaz66_radioDeploy;
};
while {alive _veh} do {
	LOG("COMMANDVEH-CHECK | Airdrop");
	_attack_pos=[];
	_attack_pos=[getPos _veh,0] call FM(spawn_commandveh_check);
	if ((count _attack_pos)>1) then {
		LOG("COMMANDVEH | Call Airdrop");
		[_attack_pos,0,40] call FM(spawn_attack_airdrop);
		sleep (200 + (random 300));
	};
	sleep 240;
};

/*
	Author: Dorbedo
	
	Description:
		Spawns Units at arraypositions
	
	
	Parameter(s):
		0 : ARRAY	- Spawnpositions
		(Optional)
		1 : SIDE		- Side of spawned Units
		2 : ARRAY	- Array with Units who can be spawned
	
	Return
	ARRAY - spawned Units
*/
#include "script_component.hpp"
SCRIPT(city_spawn_unit);
PARAMS_1(_spawnposarray);
DEFAULT_PARAM(1,_side,dorb_side);
DEFAULT_PARAM(2,_unitarray,dorb_menlist);
CHECK(!IS_ARRAY(_spawnposarray))
Private["_spawnedunit","_spawnedunits","_typ","_gruppe","_dir","_position"];

For "_i" from 0 to ((count _spawnposarray)-1) do {
	_typ = _unitarray SELRND;
	_gruppe = createGroup _side;
	/// Prevent ASR-AI Option "JoinLast" - No compatibility Issues if no ASR-AI is enabled
	SETPVAR(_gruppe,asr_ai3_main_initgroupsize,1);
	_dir = (_spawnposarray select _i)select 3;
	_position = [(_spawnposarray select _i)select 0,(_spawnposarray select _i)select 1,(_spawnposarray select _i)select 2];
	_spawnedunit = _gruppe createUnit [_typ,_position, [], 0, "NONE"];
	_spawnedunit setDir _dir;
	[_gruppe,_position] call FM(city_patrol_building);
	[_gruppe] call FM(moveToHC);
	_spawnedunits pushBack _spawnedunit;
};
_spawnedunits

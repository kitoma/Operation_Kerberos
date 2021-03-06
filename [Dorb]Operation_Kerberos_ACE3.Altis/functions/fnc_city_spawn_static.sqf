/*
	Author: Dorbedo
	
	Description:
		Spawns Staticunits at arraypositions
	
	
	Parameter(s):
		0 : ARRAY	- Spawnpositions
		(Optional)
		1 : STRING	- side
		2 : ARRAY	- array with possible men, who can be spawned
	
	Return
	ARRAY - spawned Units
*/
#include "script_component.hpp"
SCRIPT(city_spawn_static);
PARAMS_1(_spawnposarray);
DEFAULT_PARAM(1,_side,dorb_side);
DEFAULT_PARAM(2,_unitarray,dorb_staticlist);
CHECK(!IS_ARRAY(_spawnposarray))
Private["_spawnedunit","_spawnedunits","_typ","_gruppe","_dir","_position"];

For "_i" from 0 to ((count _spawnposarray)-1) do {
	_typ = _unitarray SELRND;
	_gruppe = createGroup _side;
	_dir = (_spawnposarray select _i)select 3;
	_position = [(_spawnposarray select _i)select 0,(_spawnposarray select _i)select 1,(_spawnposarray select _i)select 2];
	_spawnedunit = _gruppe createVehicle [_typ,_position, [], _dir, "NONE"];
	If (!((crew _spawnedunit)isEqualTo [])) then {
		{_spawnedunit deleteVehicleCrew _x} forEach crew _spawnedunit;
		[_spawnedunit,_side] call FM(spawn_crew);
	}else{
		[_spawnedunit,_side] call FM(spawn_crew);
	};
	_spawnedunits pushBack _spawnedunit;
};
_spawnedunits

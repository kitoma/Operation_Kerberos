/*
	Author: Dorbedo
	
	Description:
	
	Requirements:
	
	Parameter(s):
		0 : ARRAY	- Example
		1 : ARRAY	- Example
		2 : STRIN	- Example
	
	Return
	BOOL
*/
#include "script_component.hpp"
SCRIPT(spawn_attack_air);
CHECK(!isServer)

private ["_gruppe","_units","_rand"];
PARAMS_1(_position);
DEFAULT_PARAM(1,_suchradius,400);
DEFAULT_PARAM(2,_anzahl_heli,0);
DEFAULT_PARAM(3,_anzahl_plane,0);
DEFAULT_PARAM(4,_radius,2000);
LOG_5(_position,_suchradius,_anzahl_heli,_anzahl_plane,_radius);

_vehicles=[];
_einheit="";
for "_i" from 0 to (_anzahl_heli) do {
	_pos = [_position, _radius,1] call FM(random_pos);
	_spawnpos = [(_pos select 0),(_pos select 1),400];
	_einheit = dorb_attack_heli_list SELRND;
	if (count _spawnpos > 1) then {
		_return = [_spawnpos,(random(360)),_einheit,dorb_side] call BIS_fnc_spawnVehicle;
		_vehicles pushBack (_return select 0);
		[(_return select 2), _position, _suchradius] call CBA_fnc_taskAttack;
		[(_return select 2)] call FM(moveToHC);
	};
};

for "_i" from 0 to (_anzahl_plane) do {
	_pos = [_position, _radius,1] call FM(random_pos);
	_spawnpos = [(_pos select 0),(_pos select 1),800];
	_einheit = dorb_attack_heli_list SELRND;
	if (count _spawnpos > 1) then {
		_return = [_spawnpos,(random(360)),_einheit,dorb_side] call BIS_fnc_spawnVehicle;
		_vehicles pushBack (_return select 0);
		[(_return select 2), _position, _suchradius] call CBA_fnc_taskAttack;
		[(_return select 2)] call FM(moveToHC);
	};
};


LOG(FORMAT_1("Spawned Vehicles \n %1 ",_vehicles));


if (dorb_debug) then {
	{
		_mrkr = createMarker [format["veh-%1",_x],getPos _x];
		_mrkr setMarkerShape "ICON";
		_mrkr setMarkerColor "ColorRed";
		_mrkr setMarkerType "o_inf";
		
	}forEach _vehicles;
};
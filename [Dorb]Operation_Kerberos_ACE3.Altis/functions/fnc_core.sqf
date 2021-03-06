/*
	Author: Dorbedo
	
	Description:
		Core function
	Requirements:
	
*/
#include "script_component.hpp"
SCRIPT(core);
CHECK(!isServer)

private ["_aufgabennummer","_aktuelle_aufgabe","_return"];

dorb_debug=false; //Marker für Missionen
dorb_debug_log=true;
dorb_debug_loc=false; //Marker für Orte
Anzahl_Aufgaben=1;

_aufgabennummer=0;

_return = [] call FM(get_cfglocations);

SETMVAR(DORB_STADT,(_return select 0));
SETMVAR(DORB_INDUSTRIE,(_return select 1));
SETMVAR(DORB_MILITAER,(_return select 2));
SETMVAR(DORB_WASSER,(_return select 3));
SETMVAR(DORB_SONSTIGES,(_return select 4));

/// Cleanup script (small version)
[] spawn {
	SCRIPT(CORE_CLEANUP);
	while {true} do {
	For "_i" from 0 to 6 do {
		If ((count allDead)>20) then {
			private["_allDead","_anzahl"];
			_allDead = allDead;
			_anzahl = floor(((count allDead)/3)*2);
			_allDead resize _anzahl;
			{_x TILGE;}forEach _allDead;
		};
		uisleep 180;
	};
	[] spawn FM(cleanup_small);
	false
	};

};
/// Rescue Point;
[] spawn {
	SCRIPT(CORE_RESCUEPOINT);
	private "_markerpos";
	_markerpos = getMarkerPos "rescue_marker";
	If ((_markerpos distance [0,0,0])<1) exitWith {};
	while {true} do {
		private "_units";
		_units = _markerpos nearEntities [["Man","Ship_F","LandVehicle"], 15];
		{
			[_x,"DORB_RESCUEPOINT",[_x]] call BIS_fnc_callScriptedEventHandler;
		}forEach _units;
		uisleep 30;
	};
};
/// Diag
[] spawn {
	SCRIPT(CORE_DIAG);
	while {true} do {
	For "_i" from 0 to 4 do {
		[false,false] call FM(debug_performance);
		uisleep 60;
	};
	[true,false] call FM(debug_performance);
	uisleep 60;
	false
	};

};

sleep 20;

for "_u" from 0 to 120 do {
	
	sleep 5;
	INC(_aufgabennummer);
	_aktuelle_aufgabe = FORMAT_1("task_%1",_aufgabennummer);
	LOG_2(_aufgabennummer,_aktuelle_aufgabe);
	[_aktuelle_aufgabe] call FM(obj_choose);
};
ERROR("CORE LOOP CRASHED");
endMission "End1";
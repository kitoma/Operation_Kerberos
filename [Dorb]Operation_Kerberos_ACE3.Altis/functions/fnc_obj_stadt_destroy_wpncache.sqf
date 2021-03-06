/*
	Author: Dorbedo

	Description:
	Creates Mission "Destroy Weaponcache".
	


	Parameter(s):
		0 :	ARRAY - Position
		1 :	ARRAY - Ziele
		2 : STRING - Aufgabenname für Taskmaster
		
	Returns:
	BOOL
*/
#include "script_component.hpp"
SCRIPT(obj_stadt_destoy_wpncache);
CHECK(!isServer)


private["_position","_task","_ort","_position_rescue","_a"];

_ort=_this select 0;
_position=_this select 1;
_task=_this select 2;
_target=[];

//////////////////////////////////////////////////
////// Gebäudearray erstellen				 /////
//////////////////////////////////////////////////

_rad = 260;
_gebaeudepos_arr = [];
_gebaeudepos_arr = [_position,_rad] call FM(get_buildings);

//////////////////////////////////////////////////
////// Ziel erstellen						 /////
//////////////////////////////////////////////////

_rand = ((floor(random 5)) + 8);

for "_i" from 1 to _rand do{
	_einheit = dorb_wpncache_list SELRND;
	_spawngebaeude = _gebaeudepos_arr SELRND;
	_spawnposition = _spawngebaeude SELRND;
	_unit = createVehicle [_einheit,_spawnposition, [], 0, "NONE"];
	_target pushBack _unit;
};
LOG(FORMAT_2("Anzahl Waffenkisten=%1 \n Waffenkisten=%2",_rand,_target));

//////////////////////////////////////////////////
////// Ziel bearbeiten						 /////
//////////////////////////////////////////////////

if (dorb_debug) then {
	_a=1;
	{
		INC(_a);
		_mrkr = createMarker [format ["Box %2-%1",_a,_task],getPos _x];
		_mrkr setMarkerShape "ICON";
		_mrkr setMarkerColor "ColorBlack";
		_mrkr setMarkerType "hd_destroy";
		
	}forEach _target;
};

//////////////////////////////////////////////////
////// Gegner erstellen 					 /////
//////////////////////////////////////////////////

[_position,_gebaeudepos_arr] call FM(spawn_obj_stadt);

//////////////////////////////////////////////////
////// Aufgabe erstellen 					 /////
//////////////////////////////////////////////////

[_task,true,[["STR_DORB_DEST_WPN_TASK_DESC",_ort],"STR_DORB_DEST_WPN_TASK","STR_DORB_DESTROY"],_position,"AUTOASSIGNED",0,false,true,"",true] spawn BIS_fnc_setTask;
[-1,{_this spawn FM(disp_info)},["STR_DORB_DESTROY",["STR_DORB_DEST_WPN_TASK"],"data\icon\icon_destroy.paa",true]] FMP;
sleep 10;
{
	_x addEventHandler ["killed",{"Bo_Mk82" createVehicle (getpos (_this select 0));}];
}forEach _target;



//////////////////////////////////////////////////
////// Überprüfung + Ende 					 /////
//////////////////////////////////////////////////
["init",_target] spawn FM(examine);
#define INTERVALL 10
#define TASK _task
#define CONDITION {_a=0;_a = {(!(alive _x))}count (_this select 0);If (_a > ((count _target)-4)) then {true}else{false};}
#define CONDITIONARGS [_target]
#define SUCESSCONDITION {true}
#define ONSUCESS {[-1,{_this spawn FM(disp_info)},["STR_DORB_DESTROY",["STR_DORB_FINISHED"],"data\icon\icon_destroy.paa",true]] FMP;['destroy'] spawn FM(examine);{deleteVehicle _x}forEach (_this select 0);}
#define ONFAILURE {}
#define SUCESSARG [_target]
#define ONLOOP {['check'] spawn FM(examine);}
[INTERVALL,TASK,CONDITION,CONDITIONARGS,SUCESSCONDITION,ONSUCESS,ONFAILURE,SUCESSARG,ONLOOP] call FM(taskhandler);

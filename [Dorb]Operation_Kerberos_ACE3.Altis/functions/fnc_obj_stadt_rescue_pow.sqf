/*
	Author: Dorbedo

	Description:
	Creates Mission "Rescue".
	


	Parameter(s):
		0 :	ARRAY - Position
		1 :	ARRAY - Trigger Area [A,B,Winkel,BOOL]
		2 : STRING - Aufgabenname für Taskmaster
		
*/
#include "script_component.hpp"
SCRIPT(obj_stadt_rescue_pow);
CHECK(!isServer)
PARAMS_3(_ort,_position,_task);
private["_position_rescue","_pow"];

LOG("Generiere Stadt-POW");

_position_rescue = getMarkerPos "rescue_marker";
_pow=[];

//////////////////////////////////////////////////
////// Gebäudearray erstellen				 /////
//////////////////////////////////////////////////

_rad = 260;
_gebaeudepos_arr = [];
_gebaeudepos_arr = [_position,_rad] call FM(get_buildings);

//////////////////////////////////////////////////
////// Geiseln erstellen 					 /////
//////////////////////////////////////////////////
_rand = floor(random 4) + 3;

for "_i" from 1 to _rand do{
	_gruppe = createGroup civilian;
	_einheit = dorb_pow SELRND;
	_spawngebaeude = _gebaeudepos_arr SELRND;
	_spawnposition = _spawngebaeude SELRND;
	_unit = [_spawnposition,_gruppe,_einheit] call FM(spawn_unit);
	SETPVAR(_unit,DORB_ISTARGET,true);
	_pow pushBack _unit;
};


//////////////////////////////////////////////////
////// Gegner erstellen 					 /////
//////////////////////////////////////////////////

[_position,_gebaeudepos_arr] call FM(spawn_obj_stadt);

//////////////////////////////////////////////////
////// Aufgabe erstellen 					 /////
//////////////////////////////////////////////////



[_task,true,[["STR_DORB_RESC_TASK_DESC",count _pow,_ort],"STR_DORB_RESC_TASK","STR_DORB_RESCUE"],_position,"AUTOASSIGNED",0,false,true,"",true] spawn BIS_fnc_setTask;

["STR_DORB_RESCUE",["STR_DORB_RESC_TASK"],"data\icon\icon_rescue.paa",true] spawn FM(disp_info_global);

//////////////////////////////////////////////////
////// Geiseln bearbeiten					 /////
//////////////////////////////////////////////////

{
	_x setCaptive true;
	removeAllAssignedItems _x;
	removeallweapons _x;
	removeHeadgear _x;
	removeBackpack _x;
	_x setunitpos "UP";
	_x setBehaviour "Careless";
	dostop _x;
	_x playmove "amovpercmstpsnonwnondnon_amovpercmstpssurwnondnon";
	_x disableAI "MOVE";

	if (dorb_debug) then {
		_mrkr = createMarker [format ["%1-POW:%2",_task,_x],(getPos _x)];
		_mrkr setMarkerShape "ICON";
		_mrkr setMarkerColor "ColorBlack";
		_mrkr setMarkerType "hd_destroy";
	};
	[_x,"DORB_RESCUEPOINT","DORB_RESCUE_COUNTER=DORB_RESCUE_COUNTER+1;moveOut (_this select 0);sleep 0.2;deleteVehicle(_this select 0);"] call BIS_fnc_addScriptedEventHandler;
	
}forEach _pow;



//////////////////////////////////////////////////
////// Überprüfung + Ende 					 /////
//////////////////////////////////////////////////

DORB_RESCUE_COUNTER = 0;

["init",_pow] spawn FM(examine);

#define INTERVALL 10
#define TASK _task
#define CONDITION {_a={alive _x}count (_this select 0);If((DORB_RESCUE_COUNTER==count(_this select 0))||(_a==0)) then {true}else{false};}
#define CONDITIONARGS [_pow]
#define SUCESSCONDITION {If (DORB_RESCUE_COUNTER>0) then {true}else{false};}
#define ONSUCESS {["STR_DORB_RESCUE",["STR_DORB_FINISHED"],"data\icon\icon_rescue.paa",true] spawn FM(disp_info_global);['destroy'] spawn FM(examine);}
#define ONFAILURE {["STR_DORB_RESCUE",["STR_DORB_FAILED"],"data\icon\icon_rescue.paa",true] spawn FM(disp_info_global);['destroy'] spawn FM(examine);}
#define SUCESSARG []
#define ONLOOP {['check'] spawn FM(examine);}
[INTERVALL,TASK,CONDITION,CONDITIONARGS,SUCESSCONDITION,ONSUCESS,ONFAILURE,SUCESSARG,ONLOOP] call FM(taskhandler);


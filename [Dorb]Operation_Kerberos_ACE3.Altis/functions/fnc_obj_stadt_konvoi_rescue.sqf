/*
	Author: Dorbedo

	Description:
	Creates Mission "Rescue".
	


	Parameter(s):
		0 :	ARRAY - Position
		1 :	ARRAY - Trigger Area [A,B,Winkel,BOOL]
		2 : STRING - Aufgabenname für Taskmaster
		3 : STRING - Name des Missionsortes
		4 : ARRAY - Namen der Geiseln

	Returns:
	Trigger - Serverside with Rescue
*/
#include "script_component.hpp"
SCRIPT(obj_stadt_konvoi_rescue);
CHECK(!isServer)


private["_position","_task","_ort","_position_rescue","_pow","_einheit"];

_ort=_this select 0;
_position=_this select 1;
_task=_this select 2;
_stadt = GETMVAR(DORB_STADT,[]);

_position_rescue = getMarkerPos "rescue_marker";
_pow=[];
_startort=[];
_vehicles=[];

LOG("Konvoi_Mission - Rescue");

 _b = true;
 for [{_i = 0},{_i < 100 && _b},{_i = _i + 1}] do {
	_startort = _stadt call BIS_fnc_selectRandom;
	if ((((_startort select 1)distance _position)>6000)&&(((_startort select 1)distance _position)<11000)) then {
		_b = false;
	};
 };


//////////////////////////////////////////////////
////// Konvoi erstellen, Wegpunkt setzen	 /////
////////////////////////////////////////////////// 

_gruppe = createGroup dorb_side;
_gruppe addWaypoint [_position,100];
_gruppe setFormation "COLUMN";
[_gruppe,0] setWaypointBehaviour "AWARE";
[_gruppe,0] setWaypointCombatMode "RED";
[_gruppe,0] setWaypointSpeed "LIMITED";
[_gruppe,0] setWaypointFormation "COLUMN";

for "_i" from 0 to 2 do {
	
	_spawn_rad = ((random 100) + 50);
	_spawn_pos = [(_startort select 1), _spawn_rad,0] call FM(random_pos);
	_road=[_spawn_pos,500,[]] call BIS_fnc_nearestRoad;
	_roadConnectedTo = roadsConnectedTo _road;
	_connectedRoad = _roadConnectedTo select 0;
	_direction = [_road, _connectedRoad] call BIS_fnc_DirTo;
	_spawnpos = getPos _road;
	
	_einheit = dorb_veh_unarmored SELRND;
	
	LOG(FORMAT_2("Konvoi 1:%2 ",_i,_einheit));
		
	_spawnpos = _spawn_pos findEmptyPosition [1,20,_einheit];
	_return = [_spawnpos,_direction,_einheit,_gruppe] call BIS_fnc_spawnVehicle;
	SETPVAR((_return select 0),DORB_ISTARGET,true);
	
	_vehicles pushBack (_return select 0);
	sleep 0.4;
};


//////////////////////////////////////////////////
////// Geiseln erstellen 					 /////
//////////////////////////////////////////////////

_spawn_rad = ((random 100) + 50);
_spawn_pos = [(_startort select 1), _spawn_rad,0] call FM(random_pos);
_road=[_spawn_pos,500,[]] call BIS_fnc_nearestRoad;
_roadConnectedTo = roadsConnectedTo _road;
_connectedRoad = _roadConnectedTo select 0;
_direction = [_road, _connectedRoad] call BIS_fnc_DirTo;
_spawnpos = getPos _road;


_start_mrkr = createMarker [format["start-%1",(_startort select 1)],(_startort select 1)];
_start_mrkr setMarkerShape "ICON";
_start_mrkr setMarkerColor "ColorBlack";
_start_mrkr setMarkerType "hd_start";


_einheit = dorb_veh_car call BIS_fnc_selectRandom;
_spawnpos = _spawnpos findEmptyPosition [1,30,_einheit];
_return = [_spawnpos,_direction,_einheit,_gruppe] call BIS_fnc_spawnVehicle;
_geiseltransport = (_return select 0);
_vehicles pushBack _geiseltransport;

[_gruppe] call FM(moveToHC);

for "_i" from 1 to 3 do{
	_gruppe = createGroup civilian;
	_einheit = dorb_pow call BIS_fnc_selectRandom;
	_unit = [_spawn_pos,_gruppe,_einheit] call FM(spawn_unit);
	sleep 0.5;
	_unit setCaptive true;
	removeAllAssignedItems _unit;
	removeallweapons _unit;
	removeHeadgear _unit;
	removeBackpack _unit;
	_unit setunitpos "UP";
	_unit setBehaviour "Careless";
	dostop _unit;
	_unit playmove "amovpercmstpsnonwnondnon_amovpercmstpssurwnondnon";
	_unit disableAI "MOVE";
	_unit moveInCargo _geiseltransport;
	SETPVAR(_unit,DORB_ISTARGET,true);
	_pow pushBack _unit;
};
//[_gruppe] call FM(moveToHC);
//{_x moveInCargo _geiseltransport;}forEach pow;

//////////////////////////////////////////////////
////// Aufgabe erstellen 					 /////
//////////////////////////////////////////////////

["STR_DORB_RESCUE",["STR_DORB_RESC_CONV_TASK"],"data\icon\icon_rescue.paa",true] spawn FM(disp_info_global);
[_task,true,[["STR_DORB_RESC_CONV_TASK_DESC",count _pow,(_startort select 0),_ort],"STR_DORB_RESC_CONV_TASK","STR_DORB_RESCUE"],_position,"AUTOASSIGNED",0,false,true,"",true] spawn BIS_fnc_setTask;

//////////////////////////////////////////////////
////// Überprüfung + Ende 					 /////
//////////////////////////////////////////////////

DORB_RESCUE_COUNTER = 0;
{[_x,"DORB_RESCUEPOINT","DORB_RESCUE_COUNTER=DORB_RESCUE_COUNTER+1;moveOut (_this select 0);sleep 0.2;deleteVehicle(_this select 0);"] call BIS_fnc_addScriptedEventHandler;}forEach _pow;

#define INTERVALL 10
#define TASK _task
#define CONDITION {_a={(_x distance (_this select 1))<200}count (_this select 0);_alivecounter={alive _x}count (_this select 0);If((DORB_RESCUE_COUNTER==count(_this select 0))||(_a>0)||(_alivecounter==0)) then {true}else{false};}
#define CONDITIONARGS [_pow,_position]
#define SUCESSCONDITION {If (DORB_RESCUE_COUNTER>0) then {true}else{false};}
#define ONSUCESS {["STR_DORB_RESCUE",["STR_DORB_FINISHED"],"data\icon\icon_rescue.paa",true] spawn FM(disp_info_global);}
#define ONFAILURE {["STR_DORB_RESCUE",["STR_DORB_FAILED"],"data\icon\icon_rescue.paa",true] spawn FM(disp_info_global);}
#define SUCESSARG []
#define ONLOOP {['check'] spawn FM(examine);}
[INTERVALL,TASK,CONDITION,CONDITIONARGS,SUCESSCONDITION,ONSUCESS,ONFAILURE,SUCESSARG,ONLOOP] call FM(taskhandler);

{_x TILGE;}forEach _vehicles;
deleteMarker _start_mrkr;

local _, NeP = ...

-- Local stuff for speed
local UnitExists = ObjectExists or UnitExists
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local UnitGUID = UnitGUID
local UnitName = UnitName
local strsplit = strsplit
local select = select
local tonumber = tonumber
local pairs = pairs
local C_Timer = C_Timer
local UnitInPhase = UnitInPhase

--Advanced
local ObjectIsType = ObjectIsType
local ObjectTypes  = ObjectTypes

NeP.OM = {
	Enemy    = {},
	Friendly = {},
	Dead     = {},
	Objects  = {},
	Roster   = {},
	max_distance = 100
}

local OM_c = NeP.OM
local clean = {}

-- This cleans/updates the tables and then returns it
-- Due to Generic OM, a unit can still exist (target) but no longer be the same unit,
-- To counter this we compare GUID's.

local function MergeTable_Insert(table, Obj, GUID)
	if not table[GUID]
	and UnitExists(Obj.key)
	and UnitInPhase(Obj.key)
	and GUID == UnitGUID(Obj.key) then
		table[GUID] = Obj
		Obj.distance = NeP.Protected.Distance('player', Obj.key)
	end
end

local function MergeTable(ref)
	local temp = {}
	for GUID, Obj in pairs(NeP.Protected.nPlates[ref]) do
		MergeTable_Insert(temp, Obj, GUID)
	end
	for GUID, Obj in pairs(OM_c[ref]) do
		MergeTable_Insert(temp, Obj, GUID)
	end
	return temp
end

function clean.Objects(ref)
	for GUID, Obj in pairs(OM_c[ref]) do
		if Obj.distance > NeP.OM.max_distance
		or not UnitExists(Obj.key)
		or GUID ~= UnitGUID(Obj.key) then
			OM_c[ref][GUID] = nil
		end
	end
end

function clean.Others(ref)
	for GUID, Obj in pairs(OM_c[ref]) do
		-- remove invalid units
		if Obj.distance > NeP.OM.max_distance
		or not UnitExists(Obj.key)
		or not UnitInPhase(Obj.key)
		or GUID ~= UnitGUID(Obj.key)
		or ref ~= 'Dead' and UnitIsDeadOrGhost(Obj.key) then
			OM_c[ref][GUID] = nil
		end
	end
end

function NeP.OM.Get(_, ref, want_plates)
	if ref == 'Objects' then
		clean.Objects(ref)
	elseif want_plates and NeP.Protected.nPlates then
		return MergeTable(ref)
	else
		clean.Others(ref)
	end
	return OM_c[ref]
end

function NeP.OM.Insert(_, Tbl, Obj, GUID)
	local distance = NeP.Protected.Distance('player', Obj) or 999
	if distance <= NeP.OM.max_distance then
		local ObjID = select(6, strsplit('-', GUID))
		Tbl[GUID] = {
			key = Obj,
			name = UnitName(Obj),
			distance = distance,
			id = tonumber(ObjID or 0),
			guid = GUID,
			isdummy = NeP.DSL:Get('isdummy')(Obj)
		}
	end
end

function NeP.OM.Add(_, Obj)
	if not UnitExists(Obj) then return end
	local GUID = UnitGUID(Obj) or '0'
	--units
	if UnitInPhase(Obj) then
		-- Dead Units
		if UnitIsDeadOrGhost(Obj) then
			NeP.OM:Insert(OM_c['Dead'], Obj, GUID)
		-- Friendly
		elseif UnitIsFriend('player', Obj) then
			NeP.OM:Insert(OM_c['Friendly'], Obj, GUID)
		-- Enemie
		elseif UnitCanAttack('player', Obj) then
			NeP.OM:Insert(OM_c['Enemy'], Obj, GUID)
		end
	-- Objects
	elseif ObjectIsType and ObjectIsType(Obj, ObjectTypes.GameObject) then
		NeP.OM:Insert(OM_c['Objects'], Obj, GUID)
	end
end

-- Regular
C_Timer.NewTicker(1, function()
	if NeP.DSL:Get("toggle")(nil, "mastertoggle") then
		NeP.Protected:OM_Maker()
	end
end, nil)

-- Gobals
NeP.Globals.OM = {
	Add = NeP.OM.Add,
	Get = NeP.OM.Get
}

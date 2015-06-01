local addonName, T = ...
if T.Mark ~= 40 then
	local m = "You must restart World of Warcraft after installing this update."
	if type(T.L) == "table" and type(T.L[m]) == "string" then m = T.L[m] end
	return print("|cffffffff[Master Plan]: |cffff8000" .. m)
end

local L = newproxy(true) do
	local LL = type(T.L) == "table" and T.L or {}
	getmetatable(L).__call = function(_, k)
		return LL[k] or k
	end
	T.L = L
end

local EV, conf, api = T.Evie, setmetatable({}, {__index={
	availableMissionSort="reward",
	sortFollowers=true,
	batchMissions=true,
	riskReward=1,
	xpPerCopper=1e-5,
	xpPerResource=5e-1,
	xpWithToken=1,
	xpCapGrace=2000,
	goldRewardThreshold=100e4,
	levelDecay=0.9,
	currencyWasteThreshold=0.20,
	legendStep=0,
	timeHorizon=0,
	timeHorizonMin=300,
	crateLevelGrace=25,
	interestMask=0,
	ignore={},
	complete={},
}})
T.config, api = conf, setmetatable({}, {__index={GarrisonAPI=T.Garrison}})

function EV:ADDON_LOADED(addon)
	if addon ~= addonName then
		return
	end
	function EV:PLAYER_LOGOUT()
		local complete = securecall(T._GetMissionSeenTable)
		MasterPlanPC, conf.ignore, conf.complete = conf, next(conf.ignore) and conf.ignore, complete or conf.complete
	end
	
	local pc
	if type(MasterPlanPC) == "table" then
		pc, MasterPlanPC = MasterPlanPC
	else
		pc = {}
	end
	
	for k,v in pairs(pc) do
		local tv = type(v)
		if k ~= "ignore" and k ~= "complete" and tv == type(conf[k]) then
			conf[k] = v
		elseif k == "ignore" and tv == "table" then
			for k,v in pairs(v) do
				conf.ignore[k] = v
			end
		end
	end
	T._SetMissionSeenTable(pc.complete)
	conf.version = GetAddOnMetadata(addonName, "Version")
	EV("MP_SETTINGS_CHANGED")
	
	return "remove"
end

function api:GetSortFollowers()
	return conf.sortFollowers
end
function api:SetSortFollowers(sort)
	assert(type(sort) == "boolean", 'Syntax: MasterPlan:SetSortFollowers(sort)')
	conf.sortFollowers = sort
	EV("MP_SETTINGS_CHANGED", "sortFollowers")
end

function api:SetMissionOrder(order)
	assert(type(order) == "string", 'Syntax: MasterPlan:SetMissionOrder("order")')
	conf.availableMissionSort = order
	EV("MP_SETTINGS_CHANGED", "availableMissionSort")
end
function api:GetMissionOrder()
	return conf.availableMissionSort
end
function api:SetTimeHorizon(sec)
	assert(type(sec) == "number" and sec >= 0, 'Syntax: MasterPlan:SetTimeHorizon(sec)')
	conf.timeHorizon = sec
	EV("MP_SETTINGS_CHANGED", "timeHorizon")
end

local parties, tentativeState = {}, {}
T.tentativeState = tentativeState
local function dissolve(mid, doNotUpdate)
	local p = parties[mid]
	if p then
		local f1, f2, f3 = p[1], p[2], p[3]
		parties[mid], tentativeState[f1 or 0], tentativeState[f2 or 0], tentativeState[f3 or 0] = nil
		if not doNotUpdate then
			EV("MP_TENTATIVE_PARTY_UPDATE")
		end
		return f1, f2, f3
	end
end
local function tentativeFullNext(self, mid)
	local mid, p = next(parties, mid)
	if mid then
		if #p == C_Garrison.GetMissionMaxFollowers(mid) then
			return mid, p[1], p[2], p[3]
		end
		return tentativeFullNext(self, mid)
	end
end
function api:GetMissionParty(mid, quiet)
	return dissolve(mid, quiet)
end
function api:SaveMissionParty(mid, f1, f2, f3)
	dissolve(mid, true)
	dissolve(tentativeState[f1], true)
	dissolve(tentativeState[f2], true)
	dissolve(tentativeState[f3], true)
	if not f1 then f1, f2, f3 = f2, f3 end
	parties[mid] = (f1 or f2 or f3) and {f1, f2, f3} or nil
	tentativeState[f1 or 0], tentativeState[f2 or 0], tentativeState[f3 or 0] = mid, mid, mid
	EV("MP_TENTATIVE_PARTY_UPDATE")
end
function api:HasTentativeParty(mid)
	local p = parties[mid]
	return p and #p or 0
end
function api:HasFullTentativeParties()
	for k,v in pairs(parties) do
		if #v == C_Garrison.GetMissionMaxFollowers(k) then
			return true
		end
	end
end
function api:GetFullTentativeParties()
	return tentativeFullNext
end
function api:GetFollowerTentativeMission(fid)
	return tentativeState[fid]
end
function api:DissolveMissionByFollower(fid)
	dissolve(tentativeState[fid])
end
function api:DissolveAllMissions()
	if next(parties) or next(tentativeState) then
		wipe(parties)
		wipe(tentativeState)
		EV("MP_TENTATIVE_PARTY_UPDATE")
	end
end
function EV:MP_MISSION_START(mid, f1, f2, f3)
	dissolve(mid, true)
	dissolve(tentativeState[f1], true)
	dissolve(tentativeState[f2], true)
	dissolve(tentativeState[f3], true)
	EV("MP_TENTATIVE_PARTY_UPDATE")
end
function EV:GARRISON_MISSION_STARTED(id)
	dissolve(id)
end

function api:IsFollowerIgnored(fid)
	return not not conf.ignore[fid]
end
function api:SetFollowerIgnored(fid, ignore)
	assert(type(fid) == "string", 'Syntax: MasterPlan:SetFollowerIgnored("followerID", ignore)')
	conf.ignore[fid] = ignore and 1 or nil
end
function api:FireRelease()
	EV("MP_RELEASE_CACHES")
end

MasterPlan = api
local api, _, T = {}, ...

local f, data, mechanics = CreateFrame("Frame"), {}, {}
f:SetScript("OnUpdate", function() wipe(data) f:Hide() end)

local function AddCounterMechanic(fit, fabid)
	if fabid and fabid > 0 then
		local mid, _, tex = C_Garrison.GetFollowerAbilityCounterMechanicInfo(fabid)
		if tex then
			fit.counters[mid], mechanics[mid], mechanics[tex:lower():gsub("%.blp$","")] = fabid, fabid, fabid
		end
	end
end
function api.GetFollowerInfo()
	if not data.followers then
		local ft = {}
		local t = C_Garrison.GetFollowers()
		for i=1,#t do
			local v = t[i]
			if v.isCollected then
				local fid, fit = v.followerID, {counters={}, gfid=v.garrFollowerID, level=v.level, name=v.name}
				for i=1,4 do
					AddCounterMechanic(fit, C_Garrison.GetFollowerAbilityAtIndex(fid, i))
					AddCounterMechanic(fit, C_Garrison.GetFollowerTraitAtIndex(fid, i))
				end
				ft[fid] = fit
			end
		end
		for k, v in pairs(C_Garrison.GetInProgressMissions()) do
			for i=1,#v.followers do
				ft[v.followers[i]].mission, ft[v.followers[i]].missionTimeLeft = v.missionID, v.timeLeft
			end
		end
		data.followers = ft
		f:Show()
	end
	return data.followers
end
function api.GetCounterInfo()
	if not data.counters then
		local ci = {}
		for fid, info in pairs(api.GetFollowerInfo()) do
			for k,v in pairs(info.counters) do
				ci[k] = ci[k] or {}
				ci[k][#ci[k]+1] = fid
			end
		end
		data.counters = ci
		f:Show()
	end
	return data.counters
end
function api.GetMechanicInfo(mid)
	if not mechanics[mid] then api.GetFollowerInfo() end
	if mechanics[mid] then
		return C_Garrison.GetFollowerAbilityCounterMechanicInfo(mechanics[mid])
	end
end
function api.GetMissionThreats(missionID)
	local ret, rn, en = {}, 1, select(8,C_Garrison.GetMissionInfo(missionID))
	for i=1,#en do
		for id in pairs(en[i].mechanics) do
			ret[rn], rn = id, rn + 1
		end
	end
	return ret
end
do -- sortByFollowerLevels
	local lvl
	local function cmp(a,b)
		local ac, bc = lvl[a], lvl[b]
		ac, bc = ac and ac.level or 0, bc and bc.level or 0
		if ac == bc then ac, bc = a, b end
		return ac > bc
	end
	function api.sortByFollowerLevels(counters, finfo)
		lvl = finfo
		table.sort(counters, cmp)
		return counters
	end
end

T.Garrison = api
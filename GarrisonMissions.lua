local _, T = ...

local GetFollowerInfo, GetCounterInfo = T.Garrison.GetFollowerInfo, T.Garrison.GetCounterInfo

local Hide do
	local dungeon = CreateFrame("Frame")
	dungeon:Hide()
	function Hide(f, ...)
		if f then
			f:SetParent(dungeon)
			return Hide(...)
		end
	end
end

Hide(GarrisonMissionFrameMissionsTab1, GarrisonMissionFrameMissionsTab2)
local tab = CreateFrame("Button", "GarrisonMissionFrameTab3", GarrisonMissionFrame, "GarrisonMissionFrameTabTemplate", 1)
tab:SetScript("OnClick", function()
	if GarrisonMissionFrame.MissionTab.MissionPage:IsShown() then
		GarrisonMissionFrame.MissionTab.MissionPage.CloseButton:Click()
	end
	GarrisonMissionFrame_SelectTab(1)
	GarrisonMissionList_UpdateMissions()
	GarrisonMissionFrameMissionsTab2:Click()
	PanelTemplates_SetTab(GarrisonMissionFrame, 3)
end)
tab.Text:SetText("Active Missions")
GarrisonMissionFrameTab1:SetText("Available Missions")
tab:SetPoint("LEFT", GarrisonMissionFrameTab1, "RIGHT", -5, 0)
GarrisonMissionFrameTab2:SetPoint("LEFT", tab, "RIGHT", -5, 0)
PanelTemplates_DeselectTab(tab)
hooksecurefunc("PanelTemplates_UpdateTabs", function(frame)
	if frame == GarrisonMissionFrame then
		if tab.isDisabled then
			PanelTemplates_SetDisabledTabState(tab)
		else
			(frame.selectedTab == 3 and PanelTemplates_SelectTab or PanelTemplates_DeselectTab)(tab)
		end
	end
end)
GarrisonMissionFrameTab1:SetScript("OnClick", function()
	GarrisonMissionFrame_SelectTab(1)
	GarrisonMissionFrameMissionsTab1:Click()
end)
hooksecurefunc("GarrisonMissionList_SetTab", function(id)
	(id == 2 and PanelTemplates_SelectTab or PanelTemplates_DeselectTab)(tab)
end)

local remainingTimeSort do
	local units, midOrder, midExpire = {hr=3600, min=60, sec=1}, {}, {}
	local tt = setmetatable({}, {__index=function(self, k)
		local v = 0
		for n,u in k:gmatch("(%d+)%s+(%a+)") do
			v = v + tonumber(n)*(units[u] or 1)
		end
		self[k] = v
		return v
	end})
	local function cmp(a,b)
		local c = true
		if a.missionID > b.missionID then
			a, b, c = b, a, false
		end
		local ac, bc, aid, bid = tt[a.timeLeft], tt[b.timeLeft], a.missionID, b.missionID
		local ikey = aid * 1e6 + bid
		if ac ~= bc then
			midOrder[ikey], midExpire[ikey] = ac < bc, GetTime()+math.min(ac, bc)-60
			return (ac < bc) == c
		elseif midOrder[ikey] ~= nil and midExpire[ikey] > GetTime() then
			return midOrder[ikey] == c
		else
			return (aid < bid) == c
		end
	end
	function remainingTimeSort(t)
		table.sort(t, cmp)
		wipe(tt)
	end
end
hooksecurefunc(C_Garrison, "GetInProgressMissions", function(t)
	if t then
		remainingTimeSort(t)
	end
end)
local mitigatedThreatSort do
	local finfo, cinfo
	local function computeThreat(a)
		local ret, threats, lvl = 0, T.Garrison.GetMissionThreats(a.missionID), a.level
		for i=1,#threats do
			local c, quality = cinfo[threats[i]], 0
			for i=1,c and #c or 0 do
				local ld, mt = finfo[c[i]].level - lvl, finfo[c[i]].missionTimeLeft
				if ld >= 0 then
					quality = math.max(quality, mt and 2 or 4)
				elseif ld >= -2 then
					quality = math.max(quality, mt and 1 or 3)
				end
				if quality == 4 then break end
			end
			ret = ret + (quality-4)*100
		end
		return ret, ret
	end
	local function cmp(a, b)
		local ac, bc = a.mitigatedThreatScore, b.mitigatedThreatScore
		if ac == nil then
			ac, a.mitigatedThreatScore = computeThreat(a)
		end
		if bc == nil then
			bc, b.mitigatedThreatScore = computeThreat(b)
		end
		if ac == bc or (ac == 0) == (bc == 0) then
			ac, bc = a.level, b.level
		end
		if ac == bc then
			ac, bc = a.iLevel, b.iLevel
		end
		if ac == bc then
			ac, bc = 0, strcmputf8i(a.name, b.name)
		end
		if ac == bc then
			ac, bc = a.missionID, b.missionID
		end
		return ac > bc
	end
	function mitigatedThreatSort(t)
		finfo, cinfo = GetFollowerInfo(), GetCounterInfo()
		table.sort(t, cmp)
		finfo, cinfo = nil, nil
	end
end
_G.Garrison_SortMissions = mitigatedThreatSort

local missionFollowerSort do
	local finfo, cinfo, tinfo, mlvl
	local statusPriority = {
	  [GARRISON_FOLLOWER_IN_PARTY] = 1,
	  [GARRISON_FOLLOWER_WORKING] = 2,
	  [GARRISON_FOLLOWER_ON_MISSION] = 3,
	  [GARRISON_FOLLOWER_EXHAUSTED] = 4,
	  [GARRISON_FOLLOWER_INACTIVE] = 5,
	}
	local function cmp(a, b)
		local af, bf = finfo[a], finfo[b]
		if af.isCollected ~= bf.isCollected then
			return af.isCollected
		end
		local ac, bc = af.status ~= GARRISON_FOLLOWER_IN_PARTY and af.status or nil, bf.status ~= GARRISON_FOLLOWER_IN_PARTY and bf.status or nil
		if ac ~= bc then
			if (not ac) ~= (not bc) then
				return not ac
			end
			-- TODO: maybe check mission time here
			ac, bc = statusPriority[ac], statusPriority[bc]
		else
			ac, bc = 0, 0
		end
		if ac == bc then
			ac, bc = cinfo[af.followerID] and (#cinfo[af.followerID])*100 or 0, cinfo[bf.followerID] and (#cinfo[bf.followerID])*100 or 0
			ac, bc = ac + (tinfo[af.followerID] and #tinfo[af.followerID] or 0), bc + (tinfo[bf.followerID] and #tinfo[bf.followerID] or 0)
		end
		if (ac > 0) ~= (bc > 0) then
			return ac > 0
		elseif ac > 0 and ((af.level >= mlvl) ~= (bf.level >= mlvl)) then
			return af.level >= mlvl
		end
		if ac == bc then
			ac, bc = af.level, bf.level
		end
		if ac == bc then
			ac, bc = af.iLevel, bf.iLevel
		end
		if ac == bc then
			ac, bc = af.quality, bf.quality
		end
		if ac == bc then
			ac, bc = 0, strcmputf8i(af.name, bf.name)
		end
		return ac > bc
	end
	function missionFollowerSort(t, followers, counters, traits, level)
		finfo, cinfo, tinfo, mlvl = followers, counters, traits, level
		table.sort(t, cmp)
		finfo, cinfo, tinfo, mlvl = nil
	end
end
local oldSortFollowers = GarrisonFollowerList_SortFollowers
function GarrisonFollowerList_SortFollowers(self)
   local followerCounters = GarrisonMissionFrame.followerCounters
   local followerTraits = GarrisonMissionFrame.followerTraits
   if followerCounters and followerTraits and GarrisonMissionFrame.MissionTab:IsVisible() then
		return missionFollowerSort(self.followersList, self.followers, followerCounters, followerTraits, GarrisonMissionFrame.MissionTab.MissionPage.missionInfo.level)
	end
	return oldSortFollowers(self)
end

local threatColors={[0]={1,0,0}, {0.15, 0.45, 1}, {0.20, 0.45, 1}, {1, 0.25, 0}, {0,1,0}}
hooksecurefunc("GarrisonMissionButton_AddThreatsToTooltip", function(mid)
	local missionLevel
	for k, v in pairs(C_Garrison.GetAvailableMissions()) do
		if v.missionID == mid then
			missionLevel = v.level
			break
		end
	end
	
	local threats, finfo, cinfo = GarrisonMissionListTooltipThreatsFrame.Threats, GetFollowerInfo(), GetCounterInfo()
	for i=1,#threats do
		local f = threats[i]
		if f:IsShown() then
			local c, quality = cinfo[T.Garrison.GetMechanicInfo(f.Icon:GetTexture():lower())], 0
			for i=1,c and #c or 0 do
				local ld, mt = finfo[c[i]].level - missionLevel, finfo[c[i]].missionTimeLeft
				if ld >= 0 then
					quality = math.max(quality, mt and 2 or 4)
				elseif ld >= -2 then
					quality = math.max(quality, mt and 1 or 3)
				end
			end
			f.Border:SetVertexColor(unpack(threatColors[quality]))
		end
	end
end)
hooksecurefunc("GarrisonFollowerList_Update", function(self)
	local buttons, fl = self.FollowerList.listScroll.buttons, GetFollowerInfo()
	for i=1, #buttons do
		local f, fi = buttons[i], fl[buttons[i].id]
		if f:IsShown() and fi and fi.missionTimeLeft then
			f.Status:SetFormattedText("%s (%s)", f.Status:GetText(), fi.missionTimeLeft)
		end
	end
end)

GarrisonMissionMechanicTooltip:HookScript("OnShow", function(self)
	local finfo, cinfo = GetFollowerInfo(), GetCounterInfo()
	local c = cinfo[T.Garrison.GetMechanicInfo(self.Icon:GetTexture():lower())]
	if c then
		local t = {}
		T.Garrison.sortByFollowerLevels(c, finfo)
		for i=1,#c do
			local fid = c[i]
			local q = C_Garrison.GetFollowerQuality(fid)
			if GarrisonMissionFrame.MissionTab.MissionPage.missionInfo and finfo[fid].level - GarrisonMissionFrame.MissionTab.MissionPage.missionInfo.level < -2 then
				q = 0
			end
			local away = finfo[fid].missionTimeLeft
			away = away and (GRAY_FONT_COLOR_CODE .. " (" .. away .. ")") or ""
			t[#t+1] = ("%s[%d]|r %s%s|r%s"):format(ITEM_QUALITY_COLORS[q].hex, finfo[fid].level, HIGHLIGHT_FONT_COLOR_CODE, finfo[fid].name, away)
		end
		if #t > 0 then
			local height = self:GetHeight()-self.Description:GetHeight()
			self.Description:SetText(self.Description:GetText() .. NORMAL_FONT_COLOR_CODE .. "\n\nCountered by:\n" .. table.concat(t, "\n"))
			self:SetHeight(height + self.Description:GetHeight())
		end
	end
end)
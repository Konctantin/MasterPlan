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

local GetFollowerInfo, GetCounterInfo do
	local f, data = CreateFrame("Frame"), {}
	f:SetScript("OnUpdate", function() wipe(data) f:Hide() end)
	local function AddCounterMechanic(fit, fabid)
		if fabid and fabid > 0 then
			local _, _, tex = C_Garrison.GetFollowerAbilityCounterMechanicInfo(fabid)
			if tex then
				fit.counters[tex:lower():gsub("%.blp$", "")] = fabid
			end
		end
	end
	function GetFollowerInfo()
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
	function GetCounterInfo()
		if not data.counters then
			local ci = {}
			for fid, info in pairs(GetFollowerInfo()) do
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
			local c, quality = cinfo[f.Icon:GetTexture():lower()], 0
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

local sortByFollowerLevels do
	local lvl
	local function cmp(a,b)
		local ac, bc = lvl[a], lvl[b]
		ac, bc = ac and ac.level or 0, bc and bc.level or 0
		if ac == bc then ac, bc = a, b end
		return ac > bc
	end
	function sortByFollowerLevels(counters, finfo)
		lvl = finfo
		table.sort(counters, cmp)
		return counters
	end
end
GarrisonMissionMechanicTooltip:HookScript("OnShow", function(self)
	local finfo, cinfo = GetFollowerInfo(), GetCounterInfo()
	local c = cinfo[self.Icon:GetTexture():lower()]
	if c then
		local t = {}
		sortByFollowerLevels(c, finfo)
		for i=1,#c do
			local fid = c[i]
			local q = C_Garrison.GetFollowerQuality(fid)
			if finfo[fid].level - GarrisonMissionFrame.MissionTab.MissionPage.missionInfo.level < -2 then
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
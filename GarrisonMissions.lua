local _, T = ...
local EV, G, L = T.Evie, T.Garrison, T.L

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

local sortIndicator = CreateFrame("Button", nil, GarrisonMissionFrameMissions, nil) do
	local bg = sortIndicator:CreateTexture(nil, "BACKGROUND")
	bg:SetAtlas("Garr_Mission_MaterialFrame", true)
	bg:SetAllPoints()
	local lab = sortIndicator:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	lab:SetPoint("LEFT", 15, 0) lab:SetText(L"Mission order:")
	sortIndicator.label = lab
	sortIndicator:SetNormalFontObject(GameFontHighlight)
	sortIndicator:SetHighlightFontObject(GameFontGreen)
	sortIndicator:SetText("!")
	local fs = sortIndicator:GetFontString()
	fs:ClearAllPoints() fs:SetPoint("RIGHT", -15, 0)
	sortIndicator:SetPoint("BOTTOMLEFT", GarrisonMissionFrameMissions, "TOPLEFT", 6, -1)
	sortIndicator:SetSize(300, 43)
	EV.RegisterEvent("MP_SETTINGS_CHANGED", function(ev, s)
		if s == nil or s == "availableMissionSort" then
			sortIndicator:SetText(MasterPlan:GetMissionOrder() == "threats" and L"Mitigated threats" or L"Mission level")
		end
	end)
	sortIndicator:SetScript("OnClick", function()
		MasterPlan:SetMissionOrder(MasterPlan:GetMissionOrder() == "threats" and "level" or "threats")
	end)
end
do -- Active Missions tab
	local tab = CreateFrame("Button", "GarrisonMissionFrameTab3", GarrisonMissionFrame, "GarrisonMissionFrameTabTemplate", 1)
	tab:SetScript("OnClick", function()
		if GarrisonMissionFrame.MissionTab.MissionPage:IsShown() then
			if GarrisonMissionFrame.MissionTab.MissionPage.MinimizeButton then
				GarrisonMissionFrame.MissionTab.MissionPage.MinimizeButton:Click()
			else
				GarrisonMissionFrame.MissionTab.MissionPage.CloseButton:Click()
			end
		end
		GarrisonMissionFrame_SelectTab(1)
		GarrisonMissionList_UpdateMissions()
		GarrisonMissionFrameMissionsTab2:Click()
		PanelTemplates_SetTab(GarrisonMissionFrame, 3)
		sortIndicator:Hide()
		GarrisonMissionFrame_CheckCompleteMissions()
	end)
	tab:SetPoint("LEFT", GarrisonMissionFrameTab1, "RIGHT", -5, 0)
	GarrisonMissionFrameTab2:SetPoint("LEFT", tab, "RIGHT", -5, 0)
	PanelTemplates_DeselectTab(tab)
	local function updateMissionCounts(useCachedData)
		if not useCachedData then
			C_Garrison.GetAvailableMissions(GarrisonMissionFrameMissions.availableMissions)
			Garrison_SortMissions(GarrisonMissionFrameMissions.availableMissions)
			C_Garrison.GetInProgressMissions(GarrisonMissionFrameMissions.inProgressMissions)
		end
		tab:SetFormattedText(L"Active Missions (%d)", #GarrisonMissionFrameMissions.inProgressMissions)
		GarrisonMissionFrameTab1:SetFormattedText(L"Available Missions (%d)", #GarrisonMissionFrameMissions.availableMissions)
		PanelTemplates_TabResize(tab, 10)
		PanelTemplates_TabResize(GarrisonMissionFrameTab1, 10)
		if #GarrisonMissionFrameMissions.inProgressMissions == 0 then
			PanelTemplates_SetDisabledTabState(tab)
		else
			(GarrisonMissionFrame.selectedTab == 3 and PanelTemplates_SelectTab or PanelTemplates_DeselectTab)(tab)
		end
	end
	hooksecurefunc("GarrisonMissionList_UpdateMissions", function() updateMissionCounts(true) end)
	hooksecurefunc("PanelTemplates_UpdateTabs", function(frame)
		if frame == GarrisonMissionFrame then
			updateMissionCounts()
			if #GarrisonMissionFrameMissions.inProgressMissions == 0 then
				PanelTemplates_SetDisabledTabState(tab)
			elseif frame.selectedTab == 3 then
				PanelTemplates_SelectTab(tab)
				sortIndicator:Hide()
			else
				PanelTemplates_DeselectTab(tab)
				sortIndicator:Show()
			end
		end
	end)
	GarrisonMissionFrameTab1:SetScript("OnClick", function()
		GarrisonMissionFrame_SelectTab(1)
		GarrisonMissionFrameMissionsTab1:Click()
	end)
	hooksecurefunc("GarrisonMissionList_SetTab", function(id)
		PanelTemplates_UpdateTabs(GarrisonMissionFrame)
	end)
end

local landingSort do
	local order = {}
	local function cmp(a,b)
		if a.timeLeft == b.timeLeft and ("/" .. a.timeLeft .. "/"):match("%D0%D") then
			if a.level ~= b.level then return a.level > b.level end
			return strcmputf8i(a.name, b.name) < 0
		end
		return (order[a.missionID] or 0) < (order[b.missionID] or 0)
	end
	function landingSort(t)
		for k,v in pairs(C_Garrison.GetLandingPageItems()) do
			if v and v.missionID then order[v.missionID] = k end
		end
		table.sort(t, cmp)
		wipe(order)
	end
end
hooksecurefunc(C_Garrison, "GetInProgressMissions", function(t) if t then landingSort(t) end end)
do -- Garrison_SortMissions
	local used, finfo, cinfo, numIdle = {}
	local function computeThreat(a)
		local ret, threats, lvl = 0, T.Garrison.GetMissionThreats(a.missionID), G.GetFMLevel(a)
		for i=1,#threats do
			local c, quality, bk = cinfo[threats[i]], 0
			for j=1,c and #c or 0 do
				local fi = finfo[c[j]]
				local ld, mt = G.GetLevelEfficiency(G.GetFMLevel(fi), lvl), fi.missionTimeLeft and 0 or 2
				local uk = fi.isCombat and (threats[i] .. "#" .. fi.followerID)
				if not fi.isCombat or used[uk] then
				elseif ld == 1 and quality < (2+mt) then
					quality, bk = 2+mt, uk
					if mt == 2 then break end
				elseif ld > 0 and quality < (1+mt) then
					quality, bk = 1+mt, uk
				end
			end
			ret, used[bk or 1] = ret + (quality-4)*100, 1
		end
		wipe(used)
		if a.numFollowers > numIdle then
			ret = ret - 1
		end
		return ret, ret
	end
	local function cmpThreats(a, b)
		local ac, bc = a.mitigatedThreatScore, b.mitigatedThreatScore
		if ac == nil then
			ac, a.mitigatedThreatScore = computeThreat(a)
		end
		if bc == nil then
			bc, b.mitigatedThreatScore = computeThreat(b)
		end
		if (ac == 0) == (bc == 0) then
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

	local origSort = Garrison_SortMissions
	function Garrison_SortMissions(...)
		if MasterPlan:GetMissionOrder() == "threats" then
			finfo, cinfo, numIdle = G.GetFollowerInfo(), G.GetCounterInfo(), G.GetNumIdleCombatFollowers()
			table.sort(..., cmpThreats)
			finfo, cinfo = nil, nil
		else
			origSort(...)
		end
	end
end
do -- GarrisonFollowerList_SortFollowers
	local missionFollowerSort do
		local finfo, cinfo, tinfo, mlvl
		local statusPriority = {
		  [GARRISON_FOLLOWER_WORKING] = 5,
		  [GARRISON_FOLLOWER_ON_MISSION] = 4,
		  [GARRISON_FOLLOWER_EXHAUSTED] = 3,
		  [GARRISON_FOLLOWER_INACTIVE] = 2,
		  [""]=1,
		}
		local function cmp(a, b)
			local af, bf = finfo[a], finfo[b]
			local ac, bc = af.isCollected and 1 or 0, bf.isCollected and 1 or 0
			if ac == bc then
				ac, bc = statusPriority[af.status] or 6, statusPriority[bf.status] or 6
			end
			if ac == bc then
				ac, bc = cinfo[af.followerID] and (#cinfo[af.followerID])*100 or 0, cinfo[bf.followerID] and (#cinfo[bf.followerID])*100 or 0
				ac, bc = ac + (tinfo[af.followerID] and #tinfo[af.followerID] or 0), bc + (tinfo[bf.followerID] and #tinfo[bf.followerID] or 0)
				if (ac > 0) ~= (bc > 0) then
					return ac > 0
				elseif ac > 0 and ((af.level >= mlvl) ~= (bf.level >= mlvl)) then
					return af.level >= mlvl
				end
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
		for k,v in pairs(self.followers) do
			local tmid = MasterPlan:GetFollowerTentativeMission(v.followerID)
			if tmid and v.status == nil then
				v.status = GARRISON_FOLLOWER_IN_PARTY
			end
		end
		local mi = GarrisonMissionFrame.MissionTab.MissionPage.missionInfo
	   if followerCounters and followerTraits and GarrisonMissionFrame.MissionTab:IsVisible() and mi then
			return missionFollowerSort(self.followersList, self.followers, followerCounters, followerTraits, mi.level)
		end
		return oldSortFollowers(self)
	end
end
local function GarrisonFollower_OnDoubleClick(self)
	if self.PortraitFrame and self.PortraitFrame:IsMouseOver() then
		local mi = GarrisonMissionFrame.MissionTab.MissionPage.missionInfo
		local fi = self.info
		if fi and fi.followerID and mi and mi.missionID and fi.status == nil then
			local f = GarrisonMissionFrame.MissionTab.MissionPage.Followers
			for i=1, #f do
				if not f[i].info then
					GarrisonMissionPage_SetFollower(f[i], fi)
					GarrisonFollowerButton_Collapse(self)
					break
				end
			end
		end
	end
end
do
	local old = GarrisonFollowerListButton_OnClick
	local function resetAndReturn(followerFrame, ...)
		followerFrame.FollowerList.canExpand = true
		GarrisonFollowerList_Update(followerFrame)
		return ...
	end
	function GarrisonFollowerListButton_OnClick(self, ...)
		local followerFrame = self:GetParent():GetParent().followerFrame
		if self.PortraitFrame and self.PortraitFrame:IsMouseOver() and GarrisonMissionFrame.MissionTab.MissionPage.missionInfo and GarrisonMissionFrame.MissionTab.MissionPage:IsShown() then
			followerFrame.FollowerList.canExpand = false
			return resetAndReturn(followerFrame, old(self, ...))
		end
		return old(self, ...)
	end
end
hooksecurefunc("GarrisonFollowerList_Update", function(self)
	local buttons = self.FollowerList.listScroll.buttons
	local mi = GarrisonMissionFrame.MissionTab.MissionPage:IsShown() and GarrisonMissionFrame.MissionTab.MissionPage.missionInfo
	local mlvl = mi and G.GetFMLevel(mi)
	for i=1, #buttons do
		local btn = buttons[i]
		if btn:IsShown() then
			local follower, st = btn.info, btn.XPBar.statusText
			if not st then
				st = btn:CreateFontString(nil, "ARTWORK", "TextStatusBarText")
				st:SetTextColor(0.7, 0.6, 0.85)
				st:SetPoint("TOPRIGHT", -4, -44)
				btn.UpArrow:ClearAllPoints() btn.UpArrow:SetPoint("TOP", 16, -38)
				btn.DownArrow:ClearAllPoints() btn.DownArrow:SetPoint("TOP", 16, -38)
				btn.XPBar.statusText = st
				btn:SetScript("OnDoubleClick", GarrisonFollower_OnDoubleClick)
			end
			if mi then
				local ef = G.GetLevelEfficiency(G.GetFMLevel(follower), mlvl)
				if ef == 0 then
					btn.PortraitFrame.Level:SetTextColor(1, 0.1, 0.1)
				elseif ef < 1 then
					btn.PortraitFrame.Level:SetTextColor(1, 0.5, 0.25)
				else
					btn.PortraitFrame.Level:SetTextColor(1, 1, 1)
				end
			else
				btn.PortraitFrame.Level:SetTextColor(1, 1, 1)
			end
			if not follower.isCollected or follower.status == GARRISON_FOLLOWER_INACTIVE or follower.levelXP == 0 then
				st:SetText("")
			else
				st:SetFormattedText(L"%s XP", BreakUpLargeNumbers(follower.levelXP - follower.xp))
			end
		end
	end
end)

local GetThreatColor do
	local threatColors={[0]={1,0,0}, {0.15, 0.45, 1}, {0.20, 0.45, 1}, {1, 0.55, 0}, {0,1,0}}
	function GetThreatColor(counters, missionLevel, finfo, threatID, used)
		if not missionLevel then return 1,1,1 end
		local finfo, quality, bk = finfo or G.GetFollowerInfo(), 0
		for i=1,counters and #counters or 0 do
			local fi = finfo[counters[i]]
			local ld, mt = G.GetLevelEfficiency(G.GetFMLevel(fi), missionLevel), fi.missionTimeLeft and 0 or 2
			local uk = fi.isCombat and (threatID .. "#" .. fi.followerID)
			if not fi.isCombat or (used and used[uk]) then
			elseif ld == 1 and quality < (2+mt) then
				quality, bk = 2+mt, uk
				if mt == 2 then break end
			elseif ld > 0 and quality < (1+mt) then
				quality, bk = 1+mt, uk
			end
		end
		if bk then used[bk] = 1 end
		return unpack(threatColors[quality])
	end
end
hooksecurefunc("GarrisonMissionButton_AddThreatsToTooltip", function(mid)
	local missionLevel
	for k, v in pairs(C_Garrison.GetAvailableMissions()) do
		if v.missionID == mid then
			missionLevel = v.level
			break
		end
	end
	
	local threats, finfo, cinfo = GarrisonMissionListTooltipThreatsFrame.Threats, G.GetFollowerInfo(), G.GetCounterInfo()
	local used = {}
	for i=1,#threats do
		local f = threats[i]
		if f:IsShown() then
			local tid = T.Garrison.GetMechanicInfo(f.Icon:GetTexture():lower())
			f.Border:SetVertexColor(GetThreatColor(cinfo[tid], missionLevel, finfo, tid, used))
		end
	end
end)
hooksecurefunc("GarrisonFollowerList_Update", function(self)
	local buttons, fl = self.FollowerList.listScroll.buttons, G.GetFollowerInfo()
	local mi = GarrisonMissionFrame.MissionTab.MissionPage.missionInfo
	for i=1, #buttons do
		local f, fi = buttons[i], fl[buttons[i].id]
		local tmid = fi and MasterPlan:GetFollowerTentativeMission(fi.followerID)
		local status = fi and fi.status or tmid and tmid ~= (mi and mi.missionID) and L"In Tentative Party" or tmid and mi and tmid == mi.missionID and GARRISON_FOLLOWER_IN_PARTY or ""
		if f:IsShown() and fi and fi.missionTimeLeft then
			f.Status:SetFormattedText("%s (%s)", status, fi.missionTimeLeft)
		elseif f:IsShown() and fi then
			f.Status:SetText(status)
		end
	end
end)
local function Mechanic_OnClick(self)
	if self:IsMouseOver() and self.info and self.info.name then
		GarrisonMissionFrameFollowers.SearchBox:SetText(self.info.name)
		GarrisonMissionFrameFollowers.SearchBox.clearText = self.info.name
	end
end
hooksecurefunc("GarrisonMissionPage_SetEnemies", function(enemies)
	local f = GarrisonMissionFrame.MissionTab.MissionPage
	for i=1, #enemies do
		local m = f.Enemies[i] and f.Enemies[i].Mechanics
		for i=1,m and #m or 0 do
			if not m[i].highlight then
				m[i].highlight = m[i]:CreateTexture(nil, "HIGHLIGHT")
				m[i].highlight:SetAllPoints()
				m[i].highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
				m[i].highlight:SetBlendMode("ADD")
			end
			m[i]:SetScript("OnMouseUp", Mechanic_OnClick)
		end
	end
end)
hooksecurefunc("GarrisonMissionPage_ShowMission", function()
	local sb = GarrisonMissionFrameFollowers.SearchBox
	if sb:GetText() == sb.clearText then
		sb:SetText("")
	end
	sb.clearText = nil
end)

GarrisonMissionMechanicTooltip:HookScript("OnShow", function(self)
	local finfo, cinfo = G.GetFollowerInfo(), G.GetCounterInfo()
	local c = cinfo[T.Garrison.GetMechanicInfo((self.Icon:GetTexture() or ""):lower())]
	if c then
		local mi = GarrisonMissionFrame.MissionTab.MissionPage.missionInfo
		local t, mlvl = {}, GarrisonMissionMechanicTooltip.missionLevel or (mi and G.GetFMLevel(mi))
		T.Garrison.sortByFollowerLevels(c, finfo)
		for i=1,#c do
			t[#t+1] = T.Garrison.GetFollowerLevelDescription(c[i], mlvl, finfo[c[i]])
		end
		if #t > 0 then
			local height = self:GetHeight()-self.Description:GetHeight()
			self.Description:SetText(self.Description:GetText() .. NORMAL_FONT_COLOR_CODE .. "\n\n" .. L"Countered by:" .. "\n" .. table.concat(t, "\n"))
			self:SetHeight(height + self.Description:GetHeight() + 4)
		end
	end
end)

do -- Minimize mission
	local min = CreateFrame("Button", nil, GarrisonMissionFrame.MissionTab.MissionPage, "UIPanelCloseButton")
	GarrisonMissionFrame.MissionTab.MissionPage.MinimizeButton = min
	min:SetNormalTexture("Interface\\Buttons\\UI-Panel-HideButton-Up")
	min:SetPushedTexture("Interface\\Buttons\\UI-Panel-HideButton-Down")
	min:SetPoint("RIGHT", GarrisonMissionFrame.MissionTab.MissionPage.CloseButton, "LEFT", 8, 0)
	min:SetHitRectInsets(0,8,0,0)
	min:SetScript("OnClick", function(self)
		local mi = GarrisonMissionFrame.MissionTab.MissionPage.missionInfo
		local f1, f2, f3
		for i=1, mi.numFollowers do
			local fi = GarrisonMissionFrame.MissionTab.MissionPage.Followers[mi.numFollowers+1-i].info
			f1, f2, f3 = fi and fi.followerID, f1, f2
		end
		MasterPlan:SaveMissionParty(mi.missionID, f1, f2, f3)
		GarrisonMissionFrame.MissionTab.MissionPage.CloseButton:Click()
	end)
	min:SetScript("OnHide", function(self)
		if GarrisonMissionFrame.MissionTab.MissionPage.missionInfo then
			if GarrisonMissionFrame.MissionTab.MissionPage:IsShown() and self:IsShown() then
				self:Click()
			end
		end
	end)
	
	local shortcut  = false
	hooksecurefunc("GarrisonMissionPage_CheckCounter", function()
		if not shortcut then return end
		local mp = GarrisonMissionFrame.MissionTab.MissionPage
		for i = 1, #mp.Enemies do
			local enemyFrame = mp.Enemies[i]
			for mechanicIndex = 1, #enemyFrame.Mechanics do
				local mech = enemyFrame.Mechanics[mechanicIndex]
				if mech.hasCounter then
					mech.Check:SetAlpha(1)
					mech.Check:Show()
				end
			end
		end
	end)
	securecall(setfenv, GarrisonMissionPage_SetFollower, setmetatable({PlaySound = function(...) if not shortcut then _G.PlaySound(...) end end}, {__index=_G}))
	hooksecurefunc("GarrisonMissionPage_SetFollower", function(slot, info)
		if info and info.followerID then
			MasterPlan:DissolveMissionByFollower(info.followerID)
		end
		G.PushFollowerPartyStatus(info.followerID)
	end)
	hooksecurefunc("GarrisonMissionPage_SetPartySize", function()
		local mp = GarrisonMissionFrame.MissionTab.MissionPage
		local info = mp.missionInfo
		local f1, f2, f3 = MasterPlan:GetMissionParty(info.missionID)
		if not (f1 or f2 or f3) then
			return
		end

		GarrisonMissionFrame.followerCounters = C_Garrison.GetBuffedFollowersForMission(info.missionID)
		GarrisonMissionFrame.followerTraits = C_Garrison.GetFollowersTraitsForMission(info.missionID)
		shortcut = true
		for i=1, info.numFollowers do
			if f1 then
				GarrisonMissionPage_SetFollower(mp.Followers[i], C_Garrison.GetFollowerInfo(f1))
			end
			f1, f2, f3 = f2, f3, f1
		end
		shortcut = false
	end)
	EV.RegisterEvent("GARRISON_MISSION_NPC_CLOSED", function()
		MasterPlan:DissolveAllMissions()
	end)
end

local threatListMT = {} do
	local function HideTip(self)
		GarrisonMissionMechanicTooltip:Hide()
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
		self:GetParent():UnlockHighlight()
	end
	local function OnEnter(self)
		if self.info and self.info.isFollowers then
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
			GameTooltip:AddLine(self.info.name)
			GameTooltip:Show()
		else
			GarrisonMissionMechanicTooltip.missionLevel = self.missionLevel
			GarrisonMissionMechanic_OnEnter(self)
			GarrisonMissionMechanicTooltip.missionLevel = nil
		end
		self:GetParent():LockHighlight()
	end
	local function SetThreat(self, info, level, counters, followers, threatID, used)
		if info then
			self.info, self.missionLevel = info, level
			self.Icon:SetTexture(info.icon)
			self.Border:SetShown(not (info.isEnvironment or info.isFollowers))
			self.Border:SetVertexColor(GetThreatColor(counters, level, followers, threatID, used))
			self.Count:SetText(info.count or "")
			self:Show()
		else
			self:Hide()
		end
	end
	function threatListMT:__index(k)
		if k == 0 then return nil end
		local sib = self[k-1]
		local b = CreateFrame("Button", nil, sib and sib:GetParent(), "GarrisonAbilityCounterTemplate")
		b.Count = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightOutline")
		b.Count:SetPoint("BOTTOMRIGHT", 0, 2)
		if sib then
			b:SetPoint("LEFT", sib, "RIGHT", 10, 0)
		end
		b:SetScript("OnEnter", OnEnter)
		b:SetScript("OnLeave", HideTip)
		self[k], b.SetThreat = b, SetThreat
		return b
	end
end
local function MissionButton_OnEnter(self)
	if self.info.inProgress or IsAddOnLoaded("GarrisonCommander") then
		GarrisonMissionButton_OnEnter(self)
	end
end
hooksecurefunc("GarrisonMissionButton_SetRewards", function(self, rewards, numRewards)
	local index = 1
	for id, reward in pairs(rewards) do
		local btn = self.Rewards[index]
		btn.Quantity:SetPoint("BOTTOMRIGHT", -14, 14)
		if reward.followerXP then
			btn.Quantity:SetText(reward.followerXP)
			btn.Quantity:Show()
		elseif reward.currencyID == 0 and reward.quantity >= 10000 then
			btn.Quantity:SetFormattedText("%d", reward.quantity/10000)
			btn.Quantity:Show()
		elseif reward.itemID and reward.quantity == 1 then
			local _, _, q, l = GetItemInfo(reward.itemID)
			if q and l and l > 500 then
				btn.Quantity:SetText(ITEM_QUALITY_COLORS[q].hex .. l)
				btn.Quantity:Show()
			end
		end
		index = index + 1
	end
	if not self.Threats then
		self.Threats = setmetatable({}, threatListMT)
		self.Threats[1]:SetParent(self)
		self.Threats[1]:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT", 0, -5)
		self.Threats[2]:SetPoint("LEFT", self.Threats[1], "RIGHT", 5, 0)
		self.Threats[3]:SetPoint("LEFT", self.Threats[2], "RIGHT", 7.5, 0)
		self:SetScript("OnEnter", MissionButton_OnEnter)
	end
		
	local nt, tt, mi = 1, self.Threats, self.info
	local cinfo, finfo = G.GetCounterInfo(), G.GetFollowerInfo()
	local mlvl = G.GetFMLevel(mi)
	if not mi.inProgress then
		self.Title:SetPoint("LEFT", 165, 15)
		local _, _xp, ename, edesc, etex, _, _, enemies = C_Garrison.GetMissionInfo(mi.missionID)
		nt = nt + 1, tt[nt]:SetThreat({name=GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS:format(mi.numFollowers), count="|cffffcc33".. mi.numFollowers, icon="Interface/Icons/INV_MISC_GroupLooking", isFollowers=true})
		nt = nt + 1, tt[nt]:SetThreat({name=ename, icon=etex, description=edesc, isEnvironment=true})
	
		local used = {}
		for i=1,#enemies do
			for id, minfo in pairs(enemies[i].mechanics) do
				nt = nt + 1, tt[nt]:SetThreat(minfo, mlvl, cinfo[id], finfo, id, used)
			end
		end
	end
		
	for i=nt,#tt do
		tt[i]:Hide()
	end
end)

local UpdateCompletedMissionList do -- Rearranged completion dialog
	local updateMissionStatusList, displayedMissionSet
	local bf = GarrisonMissionFrameMissions.CompleteDialog.BorderFrame
	local bm, ownCompleteMissions = bf.Model
	local w, h = bf:GetSize()
	bf:SetSize(w*1.10, h*1.15)
	w, h = bf.Stage:GetSize()
	bf.Stage:SetSize(w*1.10, h*1.15 + 1.5)
	bm:SetWidth(320)
	bm:SetPoint("BOTTOMLEFT", -80, 0)
	bm.Title:ClearAllPoints()
	bm.Title:SetPoint("TOPLEFT", bm:GetParent(), "TOPLEFT", 200, -10)
	bm.Title:SetPoint("TOPRIGHT", bm:GetParent(), "TOPRIGHT", -50, -10)
	bm.Title:SetText((bm.Title:GetText():gsub("%s+", " ")))
	bf.CompleteAll = CreateFrame("Button", nil, bf, "UIPanelButtonTemplate")
	bf.CompleteAll:SetWidth(200)
	bf.CompleteAll:SetText(L"Complete All")
	bf.CompleteAll:SetPoint("BOTTOM", 80, 20)
	local function Misson_OnClick(self)
		local mi = ownCompleteMissions[self:GetID()]
		if bf.CompleteAll:IsShown() and not (mi.succeeded or mi.failed) then
			GarrisonMissionFrame.MissionTab.MissionList.CompleteDialog:Hide();
			GarrisonMissionFrame.MissionComplete:Show();
			GarrisonMissionFrame.MissionCompleteBackground:Show();
			GarrisonMissionFrame.MissionComplete.currentIndex = 1
			GarrisonMissionComplete_Initialize({mi}, 1)
			GarrisonMissionFrame.MissionComplete.NextMissionButton.returnToOverview = false
			for i=1,#ownCompleteMissions do
				local v = ownCompleteMissions[i]
				if v ~= mi and not (v.succeeded or v.failed) then
					GarrisonMissionFrame.MissionComplete.NextMissionButton.returnToOverview = self:GetID()
					break
				end
			end
		end
	end
	bf.missions = setmetatable({}, {__index=function(self, k)
		local b = CreateFrame("Button", nil, bf, nil, k)
		b:SetSize(485, 17) b:SetNormalFontObject(GameFontHighlight) b:SetText("!")
		b:SetHighlightTexture("?") b:GetHighlightTexture():SetTexture(1,1,1) b:GetHighlightTexture():SetAlpha(0.15)
		if k > 1 then b:SetPoint("TOP", self[k-1], "BOTTOM") end
		local l, n, s, r = b:CreateFontString(nil, "ARTWORK", "GameFontGreen"), b:GetFontString(), b:CreateFontString(nil, "ARTWORK", "GameFontNormal"), b:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		l:SetPoint("RIGHT", n, "LEFT", -2, 0)
		n:ClearAllPoints() n:SetPoint("LEFT", 42, 0)
		s:SetPoint("LEFT", 245, 0)
		r:SetPoint("RIGHT", -2, 0)
		b:SetScript("OnClick", Misson_OnClick)
		self[k], b.level, b.status, b.rewards = b, l, s, r
		return b
	end})
	bf.missions[1]:SetPoint("TOPLEFT", 240, -65)
	bf.missions[1]:Hide()
	bf.batch = CreateFrame("CheckButton", nil, bm, "InterfaceOptionsCheckButtonTemplate")
	bf.batch:SetSize(16, 16)
	bf.batch:SetPoint("BOTTOMLEFT", bf, "BOTTOMLEFT", 8, 4)
	bf.batch.Text:SetText(L"Expedited mission completion")
	bf.batch.Text:SetFontObject(GameFontHighlightSmall)
	bf.batch:SetScript("OnClick", function(self)
		MasterPlan:SetBatchMissionCompletion(self:GetChecked())
	end)
	bf.batch:SetHitRectInsets(0,-bf.batch.Text:GetStringWidth()-6,0,0)
	EV.RegisterEvent("MP_SETTINGS_CHANGED", function(ev, set)
		if set == "batchMissions" or set == nil then
			bf.batch:SetChecked(MasterPlan:GetBatchMissionCompletion())
		end
	end)
	
	bf.ViewButton:Hide()
	local close = CreateFrame("Button", nil, bf, "UIPanelCloseButton")
	close:SetSize(28,28) close:SetPoint("TOPRIGHT")
	close:SetScript("OnClick", function()
		GarrisonMissionFrameMissions.CompleteDialog:Hide()
		GarrisonMissionList_UpdateMissions()
	end)
	local lootContainer = CreateFrame("Frame", nil, GarrisonMissionFrameMissions.CompleteDialog.BorderFrame)
	lootContainer:SetSize(490, 205)
	lootContainer:SetPoint("TOPRIGHT", -40, -70)
	lootContainer.noBagSlots = lootContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	lootContainer.noBagSlots:SetPoint("BOTTOM")
	lootContainer.noBagSlots:SetText(("|cffff2020%s|r|n%s"):format(L"You have no free bag slots.", L"Additional mission loot may be delivered via mail."))
	lootContainer:Hide()
	lootContainer:SetScript("OnShow", function(self)
		local totalFree = 0
		for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
			local freeSlots, bagFamily = GetContainerNumFreeSlots(i)
			if bagFamily == 0 then
				totalFree = totalFree + freeSlots
			end
		end
		lootContainer.noBagSlots:SetShown(totalFree == 0)
		if self.onShowSound then
			PlaySound(self.onShowSound)
			self.onShowSound = nil
		end
	end)
	lootContainer:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	lootContainer:SetScript("OnEvent", function(self)
		for i=1,#self.items do
			local ii = self.items[i]
			if ii.itemID and ii:IsShown() then
				ii:SetIcon(select(10, GetItemInfo(ii.itemID)) or "Interface\\Icons\\Temp")
			end
		end
		if not self:IsShown() and displayedMissionSet then
			updateMissionStatusList(displayedMissionSet)
		end
	end)
	local SetFollower do
		local function AnimateXP(self, elapsed)
			if self.levelUp:IsShown() then return end
			local elapsed = self.xpGainElapsed + elapsed
			local prog = elapsed > 0.75 and 1 or (elapsed/0.75)
			self.xpProgressTex2:SetWidth(math.max(0.01, sin(90*prog) * self.xpGainWidth))
			if prog == 1 then
				self.xpGainWidth, self.xpGainElapsed = nil
				self:SetScript("OnUpdate", nil)
			else
				self.xpGainElapsed = elapsed
			end
		end
		function SetFollower(btn, info, award, oldQuality)
			GarrisonMissionFrame_SetFollowerPortrait(btn, info, false)
			if info.levelXP > info.xp and award > 0 then
				local baseXP = info.xp - math.min(info.xp, award)
				btn.xpProgressTex:SetWidth(math.max(0.01,46*baseXP/info.levelXP))
				btn.xpProgressTex2:SetWidth(0.01)
				btn.xpGainWidth, btn.xpGainElapsed = 46*math.min(info.xp - baseXP, award)/info.levelXP, 0
				btn.xpProgressTex2:Show()
				btn:SetScript("OnUpdate", AnimateXP)
				btn.xpProgressTex:SetShown(baseXP > 0)
				btn.xpProgressTex2:Show()
			else
				btn:SetScript("OnUpdate", nil)
				btn.xpProgressTex:Hide()
				btn.xpProgressTex2:Hide()
			end
			btn.info = info
			if award and award > (info.xp or 0) or (oldQuality and oldQuality ~= info.quality) then
				lootContainer.onShowSound = "UI_Garrison_CommandTable_Follower_LevelUp"
				btn.levelUp:Show()
				btn.levelUp:SetAlpha(1)
				btn.levelUp.Anim:Play()
				btn.Level:SetFontObject(GameFontNormalSmall)
			else
				btn.levelUp:SetAlpha(0)
				btn.levelUp:Hide()
				btn.Level:SetFontObject(GameFontHighlightSmall)
			end
			btn:Show()
		end
	end
	lootContainer.followers = {} do
		local function createFollowerButton()
			local b = CreateFrame("Button", nil, lootContainer, "GarrisonFollowerPortraitTemplate")
			b.levelUp = CreateFrame("Frame", nil, b, "GarrisonFollowerLevelUpTemplate")
			b.levelUp:SetScale(0.5)
			b.levelUp:SetPoint("BOTTOM", 0, -47)
			b.xpProgressTex = b:CreateTexture(nil, "ARTWORK", nil, 2)
			b.xpProgressTex:SetPoint("TOPLEFT", b.LevelBorder, "TOPLEFT", 6, -6)
			b.xpProgressTex:SetTexture("Interface\\Buttons\\GradBlue")
			b.xpProgressTex:SetAlpha(0.4)
			b.xpProgressTex:SetSize(30, 12)
			b.xpProgressTex2 = b:CreateTexture(nil, "ARTWORK", nil, 2)
			b.xpProgressTex2:SetTexture("Interface\\Buttons\\GradBlue")
			b.xpProgressTex2:SetAlpha(0.6)
			b.xpProgressTex2:SetSize(30, 12)
			b.xpProgressTex2:SetPoint("LEFT", b.xpProgressTex, "RIGHT")
			b:SetScript("OnEnter", GarrisonMissionPageFollowerFrame_OnEnter)
			b:SetScript("OnLeave", GarrisonMissionPageFollowerFrame_OnLeave)
			b:Hide()
			return b
		end
		setmetatable(lootContainer.followers, {__index=function(self, k)
			local b = createFollowerButton()
			self[k] = b
			return b
		end})
	end
	lootContainer.items = {} do
		local function OnEnter(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			if self.itemID then
				GameTooltip:SetItemByID(self.itemID)
			elseif self.tooltipHeader and self.tooltipText then
				GameTooltip:AddLine(self.tooltipHeader)
				GameTooltip:AddLine(self.tooltipText, 1,1,1)
			elseif self.currencyID then
				GameTooltip:SetCurrencyByID(self.currencyID)
			else
				GameTooltip:Hide()
				return
			end
			if self.tooltipExtra then
				GameTooltip:AddLine(self.tooltipExtra, 1,1,1)
			end
			GameTooltip:Show()
		end
		local function OnLeave(self)
			if GameTooltip:IsOwned(self) then
				GameTooltip:Hide()
			end
		end
		local function SetIcon(self, texture)
			self.Icon:SetTexture(texture)
			self.Icon:SetTexCoord(4/64, 60/64, 4/64, 60/64)
		end
		setmetatable(lootContainer.items, {__index=function(self, k)
			local i = CreateFrame("Button", nil, lootContainer)
			i:SetSize(46, 46)
			i.Icon = i:CreateTexture(nil, "ARTWORK")
			i.Icon:SetPoint("TOPLEFT", 3*46/64, -3*46/64)
			i.Icon:SetPoint("BOTTOMRIGHT", -3*46/64, 3*46/64)
			i.Border = i:CreateTexture(nil, "ARTWORK", 2)
			i.Border:SetAllPoints()
			i.Border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
			i.Border:SetTexCoord(12/64,52/64,12/64,52/64)
			i.Quantity = i:CreateFontString(nil, "OVERLAY", "GameFontHighlightOutline")
			i.Quantity:SetPoint("BOTTOMRIGHT", -3, 4)
			i:SetScript("OnEnter", OnEnter)
			i:SetScript("OnLeave", OnLeave)
			self[k], i.SetIcon = i, SetIcon
			return i
		end})
	end
	function lootContainer:Layout(numTotal)
		local perRow, baseX, baseY = 9, 0, 0
		if numTotal <= 9 then
			perRow, baseX, baseY = 9, 56*(9-numTotal)/2, -76
		elseif numTotal <= 18 then
			perRow, baseX, baseY = 6, 56, numTotal <= 12 and -64 or -32
		elseif numTotal <= 32 then
			perRow, baseX, baseY = 8, 32, numTotal <= 24 and -24 or 0
		end
		for i=1,numTotal do
			self.followers[i]:SetPoint("TOPLEFT", baseX + ((i-1) % perRow) * 56, baseY - 64*floor((i-1)/perRow))
		end
		self.count = numTotal
	end
	
	local function UpdateCompleteButton(isBusy, isFinished, hasLoot)
		bf.CompleteAll:SetShown(not isBusy)
		bf.CompleteAll:SetText(isFinished and ((lootContainer:IsShown() or not hasLoot) and L"Done" or L"View Rewards") or L"Complete Missions")
		bf.CompleteAll.isFinished = isFinished
	end
	function updateMissionStatusList(completeMissions)
		for i=1,#completeMissions do
			local mi, mb = completeMissions[i], bf.missions[i]
			local _, _, _, sc, _, _, _, mm = C_Garrison.GetPartyMissionInfo(mi.missionID)
			if mi.successChance then sc = mi.successChance end
			if mi.materialMultiplier then mm = mi.materialMultiplier end
			mi.successChance, mi.materialMultiplier = sc, mm
			mb:SetText(mi.name)
			mb.level:SetFormattedText("%s[%d]", ITEM_QUALITY_COLORS[mi.isRare and 3 or 2].hex or "", mi.level)
			local sct = sc and " (" .. floor(sc)  .. "%)" or ""
			mb.status:SetText(mi.failed and ("|cffff2020%s%s|r"):format(L"Failed", sct) or (mi.state >= 0 or mi.succeeded) and ("|cff20ff20%s%s|r"):format(L"Success", sct) or (NORMAL_FONT_COLOR_CODE .. L"Ready" .. sct))
			if sc and mm then
				local rew, tail = "", ":0:0:0:0:64:64:4:60:4:60|t"
				for k,v in pairs(mi.rewards) do
					if v.followerXP then
						rew = rew .. " " .. AbbreviateLargeNumbers(v.followerXP) .. " |T" .. v.icon .. tail
					elseif v.currencyID == GARRISON_CURRENCY then
						rew = rew .. " " .. AbbreviateLargeNumbers(floor(v.quantity * mm)) .. " |T" .. v.icon .. tail
					elseif v.currencyID == 0 then
						rew = rew .. " " .. GOLD_AMOUNT_TEXTURE:format(v.quantity/10000, 0, 0)
					elseif v.itemID then
						rew = rew .. " " .. (v.quantity > 1 and AbbreviateLargeNumbers(v.quantity) .. " |T" or "|T") .. (select(10, GetItemInfo(v.itemID)) or "Interface\\Icons\\Temp") .. tail
					elseif v.icon then
						rew = rew .. " " .. (v.quantity > 1 and AbbreviateLargeNumbers(v.quantity) .. " |T" or "|T") .. v.icon .. tail
					end
				end
				mb.rewards:SetText(rew)
			elseif mb.mid ~= mi.missionID then
				mb.rewards:SetText("")
			end
			mb.mid, mb.info = mi.missionID, mi
			mb:SetEnabled(not (mi.succeeded or mi.failed))
			mb:Show()
		end
		for i=#completeMissions+1,#bf.missions do
			bf.missions[i]:Hide()
		end
		displayedMissionSet = completeMissions
	end
	function UpdateCompletedMissionList(reset)
		local self = GarrisonMissionFrame
		self.MissionComplete.completeMissions = C_Garrison.GetCompleteMissions()
		if reset then
			ownCompleteMissions = self.MissionComplete.completeMissions
			lootContainer:Hide()
			UpdateCompleteButton(false, false, false)
		end
		updateMissionStatusList(ownCompleteMissions)
	end
	local function completionCallback(state, stack, rewards, followers)
		updateMissionStatusList(stack)
		UpdateCompleteButton(state == "STEP", state == "DONE", rewards and next(rewards) or followers and next(followers))
		if state == "DONE" then
			lootContainer.onShowSound = rewards and next(rewards) and "UI_Garrison_CommandTable_ChestUnlock_Gold_Success" or "UI_Garrison_CommandTable_ChestUnlock"
			local fi, fn = G.GetFollowerInfo(), 1
			for k,v in pairs(followers) do
				SetFollower(lootContainer.followers[fn], fi[k], v.xpAward, v.oqual)
				fn = fn + 1
			end
			for i=fn, #lootContainer.followers do
				lootContainer.followers[i]:Hide()
			end

			local ni = 1
			for k,v in pairs(rewards) do
				local quantity, icon, tooltipHeader, tooltipText, _, tooltipExtra = v.quantity
				if v.itemID then
					icon, tooltipExtra = select(10, GetItemInfo(v.itemID)) or "Interface\\Icons\\Temp", v.itemID == 120205 and rewards.xp and rewards.xp.playerXP and XP_GAIN:format(BreakUpLargeNumbers(rewards.xp.playerXP)) or nil
				elseif v.currencyID == 0 then
					icon, tooltipHeader, tooltipText = "Interface\\Icons\\INV_Misc_Coin_02", GARRISON_REWARD_MONEY, GetMoneyString(v.quantity)
					quantity = floor(quantity/10000)
				elseif v.currencyID then
					_, _, icon = GetCurrencyInfo(v.currencyID)
				end
				if icon then
					local ib = lootContainer.items[ni]
					ib:SetPoint("CENTER", lootContainer.followers[fn], "CENTER", 0, 4)
					ib:SetIcon(icon)
					ib.Quantity:SetText(quantity > 1 and quantity)
					ib.itemID, ib.currencyID, ib.tooltipHeader, ib.tooltipText, ib.tooltipExtra = v.itemID, v.currencyID, tooltipHeader, tooltipText, tooltipExtra
					ni, fn = ni + 1, fn + 1
				end
			end
			for i=ni,#lootContainer.items do
				lootContainer.items[i]:Hide()
			end
			lootContainer:Layout(fn - 1)
		end
	end
	bf.CompleteAll:SetScript("OnClick", function(self)
		if #ownCompleteMissions == 0 or lootContainer:IsShown() or (self.isFinished and lootContainer.count == 0) then
			PlaySound("UI_Garrison_CommandTable_ViewMissionReport")
			GarrisonMissionFrameMissions.CompleteDialog:Hide()
			GarrisonMissionList_UpdateMissions()
		elseif self.isFinished then
			displayedMissionSet = nil
			for i=1,#bf.missions do
				bf.missions[i]:Hide()
			end
			lootContainer:Show()
			self:SetText(L"Done")
		elseif IsAltKeyDown() == bf.batch:GetChecked() then
			bf.ViewButton:Click()
		else
			PlaySound("UI_Garrison_CommandTable_ViewMissionReport")
			G.CompleteMissions(ownCompleteMissions, completionCallback)
		end
	end)
	GarrisonMissionFrame.MissionComplete.NextMissionButton:SetScript("OnClick", function(self, ...)
		local mi, cmi = ownCompleteMissions and ownCompleteMissions[self.returnToOverview], GarrisonMissionFrame.MissionComplete.currentMission
		if self.returnToOverview == false then
			GarrisonMissionComplete_Initialize()
		elseif not (mi and cmi and mi.missionID == cmi.missionID) then
			GarrisonMissionCompleteNextButton_OnClick(self, ...)
		else
			mi.failed, mi.succeeded = not cmi.succeeded or nil, cmi.succeeded or nil
			GarrisonMissionComplete_Initialize()
			GarrisonMissionFrameMissions.CompleteDialog:Show()
			updateMissionStatusList(ownCompleteMissions)
		end
		self.returnToOverview = nil
	end)
	GarrisonMissionFrame.MissionComplete.NextMissionButton:SetScript("OnHide", function(self)
		self.returnToOverview = nil
	end)
end

function GarrisonMissionFrame_CheckCompleteMissions(onShow)
	local self = GarrisonMissionFrame
	if self.MissionComplete:IsShown() then return end
	UpdateCompletedMissionList(true)
	if #self.MissionComplete.completeMissions == 0 or not self:IsShown() then return end
	self.MissionTab.MissionList.CompleteDialog.BorderFrame.Model.Summary:SetFormattedText(GARRISON_NUM_COMPLETED_MISSIONS, #self.MissionComplete.completeMissions)
	self.MissionTab.MissionList.CompleteDialog:Show()
	self.MissionTab.MissionList.CompleteDialog.BorderFrame.ViewButton:SetEnabled(true)
	self.MissionTab.MissionList.CompleteDialog.BorderFrame.LoadingFrame:Hide()
	if onShow then
		GarrisonMissionFrame_SelectTab(1)
		GarrisonMissionList_SetTab(self.MissionTab.MissionList.Tab1)
	end
end
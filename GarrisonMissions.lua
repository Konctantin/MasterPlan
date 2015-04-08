local _, T = ...
if T.Mark ~= 16 then return end
local EV, G, L = T.Evie, T.Garrison, T.L

local MISSION_PAGE_FRAME = GarrisonMissionFrame.MissionTab.MissionPage

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

local easyDrop = CreateFrame("Frame", "MasterPlanDropDown", nil, "UIDropDownMenuTemplate") do
	function easyDrop:IsOpen(owner)
		return self.owner == owner and UIDROPDOWNMENU_OPEN_MENU == self and DropDownList1:IsShown()
	end
	local function CheckOwner(self)
		if self.owner and UIDROPDOWNMENU_OPEN_MENU == self and DropDownList1:IsShown() then
			if self.owner:IsVisible() then
				return
			end
			CloseDropDownMenus()
		end
		self:SetScript("OnUpdate", nil)
	end
	function easyDrop:Open(owner, menu, ...)
		self.owner = owner
		self:SetScript("OnUpdate", CheckOwner)
		EasyMenu(menu, self, "cursor", 9000, 9000, "MENU", 4)
		DropDownList1:ClearAllPoints()
		DropDownList1:SetPoint(...)
	end
end

local sortIndicator = CreateFrame("Button", nil, GarrisonMissionFrameMissions) do
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
	local function test(self)
		return sortIndicator.value == self.arg1
	end
	local menu, sortOrders = {
		{text=L"Chance of success", checked=test, func=MasterPlan.SetMissionOrder, arg1="threats"},
		{text=L"Follower experience", checked=test, func=MasterPlan.SetMissionOrder, arg1="xp"},
		{text=L"Mitigated threats", checked=test, func=MasterPlan.SetMissionOrder, arg1="threats2"},
		{text=L"Mission level", checked=test, func=MasterPlan.SetMissionOrder, arg1="level"},
		{text=L"Mission duration", checked=test, func=MasterPlan.SetMissionOrder, arg1="duration"},
		{text=L"Mission expiration", checked=test, func=MasterPlan.SetMissionOrder, arg1="expire"},
	}, {}
	for i=1,#menu do sortOrders[menu[i].arg1] = menu[i].text end
	EV.RegisterEvent("MP_SETTINGS_CHANGED", function(ev, s)
		if s == nil or s == "availableMissionSort" then
			local nv = MasterPlan:GetMissionOrder()
			nv = sortOrders[nv] and nv or "threats"
			sortIndicator:SetText(sortOrders[nv])
			sortIndicator.value = nv
		end
	end)

	sortIndicator:SetScript("OnClick", function(self)
		if easyDrop:IsOpen(self) then
			CloseDropDownMenus()
			return
		end
		easyDrop:Open(self, menu, "TOPRIGHT", self, "BOTTOMRIGHT", -6, 12)
	end)
	sortIndicator:SetScript("OnHide", function(self)
		if easyDrop:IsOpen(self) then
			CloseDropDownMenus()
		end
	end)
end
local roamingParty = CreateFrame("Frame", nil, GarrisonMissionFrameMissions) do
	roamingParty:SetPoint("BOTTOM", GarrisonMissionFrameMissions, "TOP", 0, 2)
	roamingParty:SetSize(120, 36)
	function roamingParty:GetFollowers()
		return self[1].followerID, self[2].followerID, self[3].followerID
	end
	function roamingParty:Update()
		local changed = false
		for i=1,3 do
			local f, fi = self[i].followerID
			if f then
				fi = C_Garrison.GetFollowerInfo(f)
				if not fi or ((fi.status or "") ~= "" and fi.status ~= GARRISON_FOLLOWER_IN_PARTY) then
					changed, f = true
				end
			end
			if f then
				self[i].portrait:SetToFileData(fi.portraitIconID)
				self[i].portrait:SetVertexColor(1, 1, 1)
			else
				self[i].portrait:SetTexture("Interface\\Garrison\\Portraits\\FollowerPortrait_NoPortrait")
				self[i].portrait:SetVertexColor(0.50, 0.50, 0.50)
			end
			self[i].followerID = f
		end
		if changed and GarrisonMissionFrame:IsVisible() and GarrisonMissionFrame.selectedTab == 1 then
			GarrisonMissionList_UpdateMissions()
		end
	end
	function roamingParty:Clear()
		for i=1,3 do
			self[i].followerID = nil
		end
		self:Update()
	end
	local function Roamer_SetFollower(_, slot, follower)
		if roamingParty[slot].followerID ~= follower then
			for i=1,3 do
				if roamingParty[slot].followerID == follower then
					roamingParty[slot].followerID = nil
				end
			end
			PlaySound(follower and "UI_Garrison_CommandTable_AssignFollower" or "UI_Garrison_CommandTable_UnassignFollower")
			roamingParty[slot].followerID = follower
			GarrisonMissionList_UpdateMissions()
		end
	end
	local function cmp(a,b)
		if a.level ~= b.level then
			return a.level > b.level
		elseif floor(a.iLevel/15) ~= floor(b.iLevel/15) then
			return a.iLevel > b.iLevel
		elseif a.quality ~= b.quality then
			return a.quality > b.quality
		else
			return strcmputf8i(a.name, b.name) < 0
		end
	end
	local function Roamer_OnEnter(self)
		if self.followerID and not easyDrop:IsOpen(self) then
			for i=1,#roamingParty do
				if easyDrop:IsOpen(roamingParty[i]) then
					return
				end
			end
			local info, id = C_Garrison.GetFollowerInfo(self.followerID), self.followerID
			GarrisonFollowerTooltip:ClearAllPoints()
			GarrisonFollowerTooltip:SetPoint("TOP", self, "BOTTOM", 0, -2)
			GarrisonFollowerTooltip_Show(info.garrFollowerID,
				info.isCollected,
				C_Garrison.GetFollowerQuality(id),
				C_Garrison.GetFollowerLevel(id),
				C_Garrison.GetFollowerXP(id),
				C_Garrison.GetFollowerLevelXP(id),
				C_Garrison.GetFollowerItemLevelAverage(id),
				C_Garrison.GetFollowerAbilityAtIndex(id, 1),
				C_Garrison.GetFollowerAbilityAtIndex(id, 2),
				C_Garrison.GetFollowerAbilityAtIndex(id, 3),
				C_Garrison.GetFollowerAbilityAtIndex(id, 4),
				C_Garrison.GetFollowerTraitAtIndex(id, 1),
				C_Garrison.GetFollowerTraitAtIndex(id, 2),
				C_Garrison.GetFollowerTraitAtIndex(id, 3),
				C_Garrison.GetFollowerTraitAtIndex(id, 4),
				true
			)
		end
	end
	local function Roamer_OnLeave(self)
		GarrisonFollowerTooltip:Hide()
	end
	local function Roamer_OnClick(self, button)
		if button == "RightButton" then
			Roamer_SetFollower(nil, self:GetID(), nil)
			GarrisonFollowerTooltip:Hide()
		elseif easyDrop:IsOpen(self) then
			CloseDropDownMenus()
			PlaySound("UChatScrollButton")
		else
			PlaySound("UChatScrollButton")
			local mn, f2, slot, cur = {}, C_Garrison.GetFollowers(), self:GetID(), self.followerID
			local a1, a2, a3 = roamingParty:GetFollowers()
			table.sort(f2, cmp)
			for i=1,#f2 do
				local fi, fid = f2[i], f2[i].followerID
				if fi.isCollected and (fi.status or "") == "" and (fid == cur or (fid ~= a1 and fid ~= a2 and fid ~= a3)) and not T.config.ignore[fid] and not MasterPlan:GetFollowerTentativeMission(fid) then
					local tt = ""
					for i=1,4 do
						local id = C_Garrison.GetFollowerTraitAtIndex(fid, i)
						if id and id > 0 then
							tt = (i > 1 and tt .. "|n" or "") .. "|TInterface\\Buttons\\UI-Quickslot2:20:1:-1:0:64:64:31:32:31:32|t|T" .. (C_Garrison.GetFollowerAbilityIcon(id) or "?") .. ":16:16:0:0:64:64:4:60:4:60|t " .. (C_Garrison.GetFollowerAbilityName(id) or "?")
						end
					end
					mn[#mn+1] = {text=G.GetFollowerLevelDescription(fi.followerID, nil), tooltipTitle=GARRISON_TRAITS, tooltipText=tt, tooltipOnButton=true, func=Roamer_SetFollower, arg1=slot, arg2=fi.followerID, checked=cur==fi.followerID}
				end
			end
			if cur then
				mn[#mn+1] = {text=REMOVE, func=Roamer_SetFollower, arg1=slot, justifyH="CENTER", notCheckable=true}
			end
			easyDrop:Open(self, mn, "TOP", self, "BOTTOM", 0, -2)
			GarrisonFollowerTooltip:Hide()
		end
	end
	local function Roamer_OnHide(self)
		if easyDrop:IsOpen(self) then
			CloseDropDownMenus()
		end
	end
	for i=1,3 do
		local x = CreateFrame("Button", nil, roamingParty, nil, i)
		x:SetSize(36, 36)	x:SetPoint("LEFT", 40*i-36, 0) x:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		local v = x:CreateTexture(nil, "ARTWORK", nil, 1) v:SetPoint("TOPLEFT", 3, -3) v:SetPoint("BOTTOMRIGHT", -3, 3) v:SetTexture("Interface\\Garrison\\Portraits\\FollowerPortrait_NoPortrait")
		roamingParty[i], x.portrait = x, v
		local v = x:CreateTexture(nil, "ARTWORK", nil, 2) v:SetAllPoints() v:SetAtlas("Garr_FollowerPortrait_Ring", true)
		local v = x:CreateTexture(nil, "HIGHLIGHT") v:SetPoint("TOPLEFT", -2, 2) v:SetPoint("BOTTOMRIGHT", 1, -1) v:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight") v:SetBlendMode("ADD")
		x:SetScript("OnClick", Roamer_OnClick)
		x:SetScript("OnEnter", Roamer_OnEnter)
		x:SetScript("OnLeave", Roamer_OnLeave)
		x:SetScript("OnHide", Roamer_OnHide)
	end
	EV.RegisterEvent("GARRISON_MISSION_NPC_CLOSED", function() roamingParty:Clear() end)
end
do -- Missions tab split
	local function clone(parent, key)
		local t, o = parent:CreateTexture(nil, "BORDER"), parent[key]
		t:SetTexture(o:GetTexture())
		t:SetTexCoord(o:GetTexCoord())
		t:SetAllPoints(o)
		t:SetBlendMode(o:GetBlendMode())
		return t
	end
	local tab = CreateFrame("Button", "GarrisonMissionFrameTab3", GarrisonMissionFrame, "GarrisonMissionFrameTabTemplate", 1)
	tab:SetPoint("LEFT", GarrisonMissionFrameTab1, "RIGHT", -5, 0)
	tab.Pulse = tab:CreateAnimationGroup() do
		local ag = tab.Pulse
		ag:SetLooping("BOUNCE")
		tab.p1, tab.p2, tab.p3 = clone(tab, "LeftHighlight"), clone(tab, "RightHighlight"), clone(tab, "MiddleHighlight")
		local t = tab:CreateTexture(nil, "BACKGROUND", nil, 1)
		t:SetPoint("TOPLEFT", tab.p3, "TOPLEFT", -16, -1)
		t:SetPoint("BOTTOMRIGHT", tab.p3, "BOTTOMRIGHT", 6, 12)
		t:SetTexture("Interface\\Buttons\\UI-ListBox-Highlight")
		t:SetBlendMode("ADD")
		t:SetTexCoord(16/128, 112/128, 0, 1)
		tab.p4 = t
		for i=1,4 do
			local ap = ag:CreateAnimation("Alpha")
			ap:SetDuration(1.25)
			ap:SetFromAlpha(0)
			ap:SetToAlpha(i == 4 and 0.20 or 0.5)
			ap:SetChildKey("p" .. i)
		end
		ag:Play()
		ag:SetScript("OnStop", function()
			for i=1,4 do
				tab["p" .. i]:SetAlpha(0)
			end
		end)
	end
	
	GarrisonMissionFrameTab2:SetPoint("LEFT", tab, "RIGHT", -5, 0)
	PanelTemplates_DeselectTab(tab)
	local function ResizeTabs()
		PanelTemplates_TabResize(tab, 10)
		PanelTemplates_TabResize(GarrisonMissionFrameTab1, 10)
	end
	local updateFlag
	local function updateMissionTabs()
		updateFlag = nil
		local cm = GarrisonMissionFrame.MissionComplete.completeMissions
		tab:SetFormattedText(L"Active Missions (%d)", math.max(#GarrisonMissionFrameMissions.inProgressMissions, cm and #cm or 0))
		GarrisonMissionFrameTab1:SetFormattedText(L"Available Missions (%d)", #GarrisonMissionFrameMissions.availableMissions)
		ResizeTabs()
		C_Timer.After(0, ResizeTabs)
		if #GarrisonMissionFrameMissions.inProgressMissions == 0 and (cm and #cm or 0) == 0 then
			PanelTemplates_SetDisabledTabState(tab)
		elseif GarrisonMissionFrame.selectedTab == 3 then
			PanelTemplates_SelectTab(tab)
		else
			PanelTemplates_DeselectTab(tab)
		end
		sortIndicator:SetShown(GarrisonMissionFrame.selectedTab == 1)
		roamingParty:SetShown(GarrisonMissionFrame.selectedTab == 1)
		roamingParty:Update()
		if T.InProgressUI then
			T.InProgressUI:SetShown(GarrisonMissionFrame.selectedTab == 3)
		end
		if GarrisonMissionFrame.selectedTab == 3 or #C_Garrison.GetCompleteMissions() == 0 then
			tab.Pulse:Stop()
		else
			tab.Pulse:Play()
		end
	end
	T.UpdateMissionTabs = updateMissionTabs
	hooksecurefunc("GarrisonMissionList_UpdateMissions", updateMissionTabs)
	hooksecurefunc("PanelTemplates_UpdateTabs", function(frame)
		if frame == GarrisonMissionFrame then
			updateMissionTabs()
		end
	end)
	tab:SetScript("OnClick", function()
		PlaySound("UI_Garrison_Nav_Tabs")
		if GarrisonMissionFrame.MissionTab.MissionPage:IsShown() then
			if GarrisonMissionFrame.MissionTab.MissionPage.MinimizeButton then
				GarrisonMissionFrame.MissionTab.MissionPage.MinimizeButton:Click()
			else
				GarrisonMissionFrame.MissionTab.MissionPage.CloseButton:Click()
			end
		end
		if GarrisonMissionFrame.selectedTab ~= 1 and GarrisonMissionFrame.selectedTab ~= 3 then
			GarrisonMissionFrame_SelectTab(1)
		end
		PanelTemplates_SetTab(GarrisonMissionFrame, 3)
		sortIndicator:Hide()
		GarrisonMissionFrame_CheckCompleteMissions()
	end)
	GarrisonMissionFrameTab1:SetScript("OnClick", function()
		PlaySound("UI_Garrison_Nav_Tabs")
		GarrisonMissionFrame_SelectTab(1)
		GarrisonMissionList_SetTab(GarrisonMissionFrameMissionsTab1)
	end)
	hooksecurefunc("GarrisonMissionList_SetTab", updateMissionTabs)
	EV.RegisterEvent("GARRISON_MISSION_FINISHED", function()
		if GarrisonMissionFrame:IsVisible() and not updateFlag and GarrisonMissionFrame.selectedTab ~= 3 then
			updateFlag = true
			C_Timer.After(0, updateMissionTabs)
			PlaySound("UI_Garrison_Toast_MissionComplete")
		end
	end)
end

local significantRewardsRank = {[false]="xp", [true]="threats", resource="resources"}
do -- Garrison_SortMissions
	local origSort, used, cinfo, finfo = Garrison_SortMissions, {}
	local function cmp(a,b)
		local ac, bc = a.ord, b.ord
		if ac == bc then
			ac, bc = a.level, b.level
		end
		if ac == bc then
			ac, bc = a.iLevel, b.iLevel
		end
		if ac == bc then
			ac, bc = 0, strcmputf8i(a.name, b.name)
		end
		return ac > bc
	end
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
		return ret < 0 and -1 or 0
	end
	local fields = {threats=1, resources=3, xp="equivXP"}
	function Garrison_SortMissions(missions, ...)
		local order, ml = sortIndicator.value, GarrisonMissionFrame.MissionTab.MissionList
		if ml.showInProgress or missions ~= ml.availableMissions or not GarrisonMissionFrame:IsShown() then
			origSort(missions, ...)
		else
			G.PrepareAllMissionGroups()
			for i=1,#missions do
				missions[i].significantRewards = G.HasSignificantRewards(missions[i])
			end
			local defaultRank, GR = G.GroupRank[order] or G.GroupRank.threats, G.GroupRank
			local field = fields[order] or 1
			for i=1, #missions do
				local mi = missions[i]
				local rank = GR[significantRewardsRank[mi.significantRewards]] or defaultRank
				local g = G.GetBackfillMissionGroups(mi, G.GroupFilter.IDLE, rank, 1, roamingParty:GetFollowers())
				g = g and g[1]
				local g2 = (g and g[1]) ~= 100 and G.GetBackfillMissionGroups(mi, G.GroupFilter.COMBAT, rank, 1, roamingParty:GetFollowers())
				g2 = g2 and g2[1] or g
				if g2 then G.AnnotateMissionParty(g2, nil, mi) end
				mi.ord = g and g[field] or -math.huge
				mi.successChance, mi.successChance2, mi.timeOfParty2 = g and g[1] or 0, g2 and g2[1] or 0, g2 and g2.earliestDeparture
			end
			if order == "duration" then
				for i=1, #missions do
					missions[i].ord = -missions[i].durationSeconds
				end
				table.sort(missions, cmp)
			elseif order == "expire" then
				for i=1, #missions do
					local mi = missions[i]
					local max, _, dur = G.GetMissionSeen(mi.missionID)
					mi.ord = dur and min(0, floor(max/1800 - dur*2)) or -math.huge
				end
				table.sort(missions, cmp)
			elseif order == "level" then
				origSort(missions, ...)
			elseif order == "threats2" then
				cinfo, finfo = G.GetCounterInfo(), G.GetFollowerInfo()
				for i=1, #missions do
					local mi = missions[i]
					local g = G.GetBackfillMissionGroups(mi, G.GroupFilter.IDLE, G.GroupRank.threats, 1, roamingParty:GetFollowers())
					mi.ord = g and g[1] and g[1][1] == 100 and computeThreat(mi) or -1
				end
				table.sort(missions, cmp)
			else
				table.sort(missions, cmp)
			end
		end
	end
	GarrisonMissionFrame.MissionTab.MissionPage.StartMissionButton:SetScript("OnClick", function(self)
		if (not MISSION_PAGE_FRAME.missionInfo.missionID) then
			return
		end
		C_Garrison.StartMission(MISSION_PAGE_FRAME.missionInfo.missionID)
		PlaySound("UI_Garrison_CommandTable_MissionStart")
		GarrisonMissionPage_Close()
		if (not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_LANDING)) then
			GarrisonLandingPageTutorialBox:Show()
		end
	end)
end
do -- GarrisonFollowerList_SortFollowers
	local toggle = CreateFrame("CheckButton", nil, GarrisonMissionFrameFollowers, "InterfaceOptionsCheckButtonTemplate")
	toggle:SetSize(24, 24) toggle:SetHitRectInsets(0,0,0,0)
	toggle:SetPoint("LEFT", GarrisonMissionFrameFollowers.SearchBox, "RIGHT", 12, 0)
	toggle:SetScript("OnClick", function(self)
		MasterPlan:SetSortFollowers(self:GetChecked())
	end)
	
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
			if tmid and (v.status or "") == "" then
				v.status = GARRISON_FOLLOWER_IN_PARTY
			elseif (v.status or "") == "" and T.config.ignore[v.followerID] then
				v.status = GARRISON_FOLLOWER_WORKING
			end
		end
		toggle:SetShown(GarrisonMissionFrame.MissionTab:IsShown())
		local mi = GarrisonMissionFrame.MissionTab.MissionPage.missionInfo
	   if followerCounters and followerTraits and GarrisonMissionFrame.MissionTab:IsVisible() and mi and MasterPlan:GetSortFollowers() then
			return missionFollowerSort(self.followersList, self.followers, followerCounters, followerTraits, mi.level)
		end
		return oldSortFollowers(self)
	end
	EV.RegisterEvent("MP_SETTINGS_CHANGED", function(_, s)
		if (s == nil or s == "sortFollowers") then
			if GarrisonMissionFrame:IsVisible() then
				GarrisonFollowerList_UpdateFollowers(GarrisonMissionFrame.FollowerList)
			end
			toggle:SetChecked(MasterPlan:GetSortFollowers())
		end
	end)
end

local GarrisonFollower_OnDoubleClick do
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
	function GarrisonFollower_OnDoubleClick(self)
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
			elseif fi and fi.status == GARRISON_FOLLOWER_IN_PARTY then
				local f = GarrisonMissionFrame.MissionTab.MissionPage.Followers
				for i=1, #f do
					if f[i].info and f[i].info.followerID == fi.followerID then
						GarrisonMissionPage_ClearFollower(f[i], true)
						break
					end
				end
			end
		end
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
			if not fi.isCombat or (used and used[uk]) or T.config.ignore[fi.followerID] then
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
	
	local threats, finfo, cinfo, used = GarrisonMissionListTooltipThreatsFrame.Threats, G.GetFollowerInfo(), G.GetCounterInfo(), {}
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
	local mid = mi and mi.missionID
	for i=1, #buttons do
		local fi = fl[buttons[i].id]
		if fi then
			local tmid = MasterPlan:GetFollowerTentativeMission(fi.followerID)
			local status = buttons[i].info.status or ""
			if tmid then
				status = tmid == mid and GARRISON_FOLLOWER_IN_PARTY or L"In Tentative Party"
			elseif fi.status == nil and status == GARRISON_FOLLOWER_WORKING and T.config.ignore[fi.followerID] then
				status = L"Ignored"
			end
			if fi.missionTimeLeft then
				buttons[i].Status:SetFormattedText("%s (%s)", status, fi.missionTimeLeft)
			else
				buttons[i].Status:SetText(status)
			end
			if status == "" and fi.level == 100 then
				local _weaponItemID, weaponItemLevel, _armorItemID, armorItemLevel = C_Garrison.GetFollowerItems(fi.followerID)
				if weaponItemLevel ~= armorItemLevel then
					buttons[i].ILevel:SetText(ITEM_LEVEL_ABBR .. " " .. fi.iLevel .. " (" .. weaponItemLevel .. "/" .. armorItemLevel .. ")")
				end
			end
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
				m[i]:SetScript("OnMouseUp", Mechanic_OnClick)
			end
		end
	end
end)

local lfgButton, GetSuggestedGroups do
	local seen = GarrisonMissionFrame.MissionTab.MissionPage.Stage:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
	seen:SetPoint("TOPLEFT", GarrisonMissionFrame.MissionTab.MissionPage.Stage.MissionEnv, "BOTTOMLEFT", 0, -3)
	seen:SetJustifyH("LEFT")
	GarrisonMissionFrame.MissionTab.MissionPage.Stage.MissionSeen = seen
	
	lfgButton = CreateFrame("Button", nil, GarrisonMissionFrame.MissionTab.MissionPage.Stage)
	lfgButton:SetSize(33,33)
	lfgButton:SetHighlightTexture("?") local hi = lfgButton:GetHighlightTexture()
	hi:SetAtlas("groupfinder-eye-highlight", true)
	hi:SetBlendMode("ADD")
	hi:SetAlpha(0.25)
	local border = lfgButton:CreateTexture("OVERLAY")
	border:SetSize(52, 52)
	border:SetPoint("TOPLEFT", 1, -1.5)
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	local ico = lfgButton:CreateTexture(nil, "ARTWORK")
	ico:SetTexture("Interface\\LFGFrame\\BattlenetWorking28")
	ico:SetAllPoints()
	lfgButton:SetPoint("TOPRIGHT", GarrisonMissionFrame.MissionTab.MissionPage.Stage, "TOPRIGHT", -6, -25)
	local curIco, nextSwap, overTime, overTimeState = 28, 0.08, 0
	lfgButton:SetScript("OnUpdate", function(self, elapsed)
		local goal, isOver
		if easyDrop:IsOpen(self) then
			goal, isOver = 17, self:IsMouseOver() or (DropDownList1:IsVisible() and DropDownList1:IsMouseOver(4,-4,-4,4))
			if isOver ~= overTimeState then overTimeState, overTime = isOver, 0 end
			overTime = overTime + elapsed
			if not overTimeState and self.clickOpen == "hover" and overTime > 0.20 then
				CloseDropDownMenus()
				self.clickOpen = false
			end
		else
			goal, isOver = 28, self:IsMouseOver()
			if isOver ~= overTimeState then
				overTimeState, overTime = isOver, 0
				if overTimeState == false and self.clickOpen then
					self.clickOpen = false
				end
			end
			overTime = overTime + elapsed
			if overTimeState and overTime > 0.15 and not easyDrop:IsOpen(self) and not self.clickOpen then
				self:Click()
				self.clickOpen = "hover"
			end
		end
		if curIco ~= goal or (goal ~= 17 and overTimeState) then
			if nextSwap < elapsed then
				curIco, nextSwap = (curIco + 1) % 29, 0.08
				local curIco = curIco > 4 and curIco < 9 and (8-curIco) or (curIco == 16 and 15) or curIco
				ico:SetTexture("Interface\\LFGFrame\\BattlenetWorking" .. curIco)
			else
				nextSwap = nextSwap - elapsed
			end
		end
	end)
	lfgButton:SetScript("OnHide", function(self)
		curIco, nextSwap, self.clickOpen = 28, 0.08
		ico:SetTexture("Interface\\LFGFrame\\BattlenetWorking28")
		if easyDrop:IsOpen(self) then
			CloseDropDownMenus()
		end
	end)
	local function SetGroup(self, group)
		local mi = GarrisonMissionFrame.MissionTab.MissionPage.missionInfo
		GarrisonMissionPage_ClearParty()
		for i=1,mi.numFollowers do
			GarrisonMissionPage_AddFollower(group[4+i])
		end
	end
	local function SecondsToTime(sec)
		local m, s, out = (sec % 3600) / 60, sec % 60
		if sec >= 3600 then out = HOUR_ONELETTER_ABBR:format(sec/3600) end
		if m > 0 then out = (out and out .. " " or "") .. MINUTE_ONELETTER_ABBR:format(m) end
		if s > 0 then out = (out and out .. " " or "") .. SECOND_ONELETTER_ABBR:format(s) end
		return out or ""
	end
	local function addToMenu(mm, groups, mi, finfo, base)
		local ml = G.GetFMLevel(mi)
		for i=1,#groups do
			local gi, tg = groups[i]
			for i=1,mi.numFollowers do
				tg = (i > 1 and tg .. "|n" or "") .. G.GetFollowerLevelDescription(gi[4+i], ml, finfo[gi[4+i]])
			end
			G.AnnotateMissionParty(gi, finfo, mi)
			local text = gi[1] .. "%"
			if gi.expectedXP and gi.expectedXP > 0 then
				local exp = BreakUpLargeNumbers(floor(gi.expectedXP))
				text, tg = text .. "; " .. (L"%s XP"):format(exp), tg .. "|n" .. (L"+%s experience expected"):format(exp)
			end
			text = text .. "; " .. SecondsToTime(gi[4])
			mm[#mm+1] = { text = text, notCheckable=true, tooltipText=tg, tooltipTitle=NORMAL_FONT_COLOR_CODE .. (L"Group %d"):format((base or 0) + i), tooltipOnButton=true, func=SetGroup, arg1=gi, arg2=mi}
		end
	end
	local function extend(g, mi, f1, f2, f3)
		local best = 0
		if type(g) ~= "table" then g = {} end
		for i=1,g and #g or 0 do
			if g[i][1] and g[i][1] > best then
				best = g[i][1]
			end
		end
		if best < 100 then
			local bg = G.GetBackfillMissionGroups(mi, G.GroupFilter.IDLE, G.GroupRank.threats, 1, f1, f2, f3)
			if bg and bg[1] and bg[1][1] > best then
				g[#g + 1] = bg[1]
			end
		end
		return g
	end
	function GetSuggestedGroups(mi, rank, onlyBackfill, f1, f2, f3)
		local mm, finfo = {}, G.GetFollowerInfo()
		local sg
		if not onlyBackfill then
			sg = G.GetFilteredMissionGroups(mi, G.GroupFilter.IDLE, rank, 3)
			sg = extend(sg, mi)
		elseif (f1 and 1 or 0) + (f2 and 1 or 0) + (f3 and 1 or 0) == mi.numFollowers then
			sg = G.GetBackfillMissionGroups(mi, G.GroupFilter.IDLE, rank, 1, f1, f2, f3)
		end
		if sg and #sg > 0 then
			mm[1] = {text=L"Suggested groups", isTitle=true, notCheckable=true}
			addToMenu(mm, sg, mi, finfo)
		end
		local fc = (f1 and 1 or 0) + (f2 and 1 or 0) + (f3 and 1 or 0)
		if fc < mi.numFollowers and fc > 0 then
			local g3 = G.GetBackfillMissionGroups(mi, G.GroupFilter.IDLE, rank, 3, f1, f2, f3)
			g3 = extend(g3, mi, f1, f2, f3)
			if #g3 > 0 then
				mm[#mm+1] = {text = L"Complete party", isTitle=true, notCheckable=true}
				addToMenu(mm, g3, mi, finfo, sg and #sg or 0)
			end
		end
		return mm
	end
	lfgButton:SetScript("OnClick", function(self)
		if easyDrop:IsOpen(self) and (not overTimeState or overTime > 0.85 or self.clickOpen ~= "hover") then
			self.clickOpen = true
			CloseDropDownMenus()
			return
		end
		self.clickOpen = true

		local mi = GarrisonMissionFrame.MissionTab.MissionPage.missionInfo
		local ff = GarrisonMissionFrame.MissionTab.MissionPage.Followers
		local f1, f2, f3 = ff[1].info, ff[2].info, ff[3].info
		f1, f2, f3 = f1 and f1.followerID, mi.numFollowers > 1 and f2 and f2.followerID, mi.numFollowers > 1 and f3 and f3.followerID

		local mm = GetSuggestedGroups(mi, self.rank, false, f1, f2, f3)
		if #mm > 1 then
			easyDrop:Open(self, mm, "TOPRIGHT", self, "TOPLEFT", -2, 12)
		end
	end)
end
hooksecurefunc("GarrisonMissionPage_ShowMission", function()
	local sb = GarrisonMissionFrameFollowers.SearchBox
	if sb:GetText() == sb.clearText then
		sb:SetText("")
	end
	sb.clearText = nil
	local mi = GarrisonMissionFrame.MissionTab.MissionPage.missionInfo
	local xseen, nseen, expire = G.GetMissionSeen(mi and mi.missionID)
	local text = floor(xseen/3600+0.5)
	if xseen - nseen >= 3600 then
		text = floor(nseen/3600+0.5) .. "-" .. text
	end
	if expire > 0 then
		text = text .. "/" .. expire
	end
	GarrisonMissionFrame.MissionTab.MissionPage.Stage.MissionSeen:SetFormattedText((L"Pending: %s |4hour:hours;"), HIGHLIGHT_FONT_COLOR_CODE .. text)
	lfgButton.rank = G.GetMissionDefaultGroupRank(mi)
	lfgButton:SetShown(true)
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
		roamingParty:Clear()
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
	pcall(setfenv, GarrisonMissionPage_SetFollower, setmetatable({PlaySound = function(...) if not shortcut then _G.PlaySound(...) end end}, {__index=_G}))
	hooksecurefunc("GarrisonMissionPage_SetFollower", function(slot, info)
		if info and info.followerID then
			MasterPlan:DissolveMissionByFollower(info.followerID)
		end
		G.PushFollowerPartyStatus(info.followerID)
	end)
	hooksecurefunc("GarrisonMissionPage_SetEnemies", function()
		local mp = GarrisonMissionFrame.MissionTab.MissionPage
		local info = mp.missionInfo
		local f1, f2, f3 = MasterPlan:GetMissionParty(info.missionID)
		if not (f1 or f2 or f3) then
			f1, f2, f3 = roamingParty:GetFollowers()
			if not (f1 or f2 or f3) then
				return
			end
		end
		if not f2 then
			f2, f3 = f3
		end
		if not f1 then
			f1, f2, f3 = f2, f3
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
		GarrisonMissionFrame.MissionTab.MissionPage.RewardsFrame.ChanceGlowAnim:Stop()
		shortcut = false
	end)
	EV.RegisterEvent("GARRISON_MISSION_NPC_CLOSED", function()
		MasterPlan:DissolveAllMissions()
	end)
end

local threatListMT = {} do
	local openFollowers
	local function HideTip(self)
		GarrisonMissionMechanicTooltip:Hide()
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
		self:GetParent():UnlockHighlight()
	end
	local function OnUpdate(self, elapsed)
		if not easyDrop:IsOpen(self) then
			self.expire = nil
			self:SetScript("OnUpdate", nil)
		elseif self:IsMouseOver(2,-2,-2,4) or DropDownList1:IsMouseOver(4,-4,-4,4) then
			self.expire = 0
		else
			self.expire = (self.expire or 0) + elapsed
			if self.expire > 0.25 then
				CloseDropDownMenus()
			end
		end
	end
	local function OpenMission(_, group, mission)
		MasterPlan:SaveMissionParty(mission.missionID, group[5], group[6], group[7])
		PlaySound("UI_Garrison_CommandTable_SelectMission")
		GarrisonMissionFrame.MissionTab.MissionList:Hide()
		GarrisonMissionFrame.MissionTab.MissionPage:Show()
		GarrisonMissionPage_ShowMission(mission)
		GarrisonMissionFrame.followerCounters = C_Garrison.GetBuffedFollowersForMission(mission.missionID)
		GarrisonMissionFrame.followerTraits = C_Garrison.GetFollowersTraitsForMission(mission.missionID)
		GarrisonFollowerList_UpdateFollowers(GarrisonMissionFrame.FollowerList)
	end
	local function OnEnter(self)
		if openFollowers and easyDrop:IsOpen(openFollowers) then
			CloseDropDownMenus()
		end
		if self.info and self.info.isFollowers then
			local mi = self.info.info
			local rank = G.GetMissionDefaultGroupRank(mi)
			local f1, f2, f3 = roamingParty:GetFollowers()
			local menu = GetSuggestedGroups(mi, rank, (f1 or f2 or f3) ~= nil, f1, f2, f3)
			if #menu < 1 then
				GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
				GameTooltip:AddLine(self.info.name)
				GameTooltip:Show()
			else
				C_Timer.After(0.1, function()
					if self:IsMouseOver() then
						for i=1,#menu do
							menu[i].func = menu[i].func and OpenMission
						end
						openFollowers, menu[1].text = self, self.info.name
						easyDrop:Open(self, menu, "TOP", self, "BOTTOM", 0, -2)
						self:SetScript("OnUpdate", OnUpdate)
					end
				end)
			end
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
	if self.info.inProgress then
		GarrisonMissionButton_OnEnter(self)
	end
end
local function createProjectionFrame(parent)
	local r = CreateFrame("Frame", nil, parent)
	r:SetSize(50, 16)
	r.Text = r:CreateFontString(nil, "ARTWORK")
	r.Text:SetFont(GameFontNormalOutline:GetFont(), 11, "OUTLINE")
	r.Text:SetPoint("BOTTOM")
	r.Text:SetSize(80, 10)
	return r
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
		self.Threats[3]:SetPoint("LEFT", self.Threats[2], "RIGHT", 12, 0)
		self.Projections = CreateFrame("Frame", nil, self)
		self.Projections:SetSize(1,1)
		for i=1,3 do
			self.Projections[i] = createProjectionFrame(self.Projections)
			self.Projections[i]:SetPoint("BOTTOM", i > 0 and self.Projections[i-1] or nil, "TOP", 0, 4)
		end
		self.Projections[1]:SetPoint("BOTTOM")
		self:SetScript("OnEnter", MissionButton_OnEnter)
		self.Expire = CreateFrame("Frame", nil, self)
		self.Expire:SetSize(100, 20)
		self.Expire.Icon = self.Expire:CreateTexture()
		self.Expire.Icon:SetSize(20,20)
		self.Expire.Icon:SetPoint("LEFT")
		self.Expire.Icon:SetTexture("Interface\\Icons\\INV_Misc_PocketWatch_01")
		self.Expire.Text = self.Expire:CreateFontString(nil, nil, "GameFontHighlight")
		self.Expire.Text:SetTextColor(0.85, 0.85, 0.85)
		self.Expire.Text:SetPoint("LEFT", self.Expire.Icon, "RIGHT", 2, 0)
	end
		
	local nt, tt, mi = 1, self.Threats, self.info
	local cinfo, finfo = G.GetCounterInfo(), G.GetFollowerInfo()
	local mlvl = G.GetFMLevel(mi)
	self.Expire:Hide()
	if not mi.inProgress then
		self.Title:SetPoint("LEFT", 165, 15)
		local _, _xp, ename, edesc, etex, _, _, enemies = C_Garrison.GetMissionInfo(mi.missionID)
		nt = nt + 1, tt[nt]:SetThreat({name=GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS:format(mi.numFollowers), count="|cffffcc33".. mi.numFollowers, icon="Interface/Icons/INV_MISC_GroupLooking", info=mi, isFollowers=true})
		nt = nt + 1, tt[nt]:SetThreat({name=ename, icon=etex, description=edesc, isEnvironment=true})
	
		local used = {}
		for i=1,#enemies do
			for id, minfo in pairs(enemies[i].mechanics) do
				nt = nt + 1, tt[nt]:SetThreat(minfo, mlvl, cinfo[id], finfo, id, used)
			end
		end
		self.Projections:SetShown(mi.successChance ~= nil)
		self.Projections:SetPoint("BOTTOM", self, "BOTTOMLEFT", 105, 16)
		local s1, s2 = mi.successChance or 0, mi.successChance2 or 0
		self.Projections[1].Text:SetFormattedText("|TInterface\\FriendsFrame\\StatusIcon-Online:0|t%d%%", s1)
		if s1 < 100 and s2 > 0 and s2 ~= s1 then
			local text, tl = floor(s2) .. "%", mi.timeOfParty2 and max(0, mi.timeOfParty2 - time()) or -1
			if tl < math.huge and tl >= 0 then
				text = format(SecondsToTimeAbbrev(tl)) .. ": " .. text
			end
			self.Projections[2].Text:SetText("|TInterface\\FriendsFrame\\StatusIcon-Away:0|t" .. text)
			self.Projections[2]:Show()
		else
			self.Projections[2]:Hide()
		end
		local numMembers = MasterPlan:HasTentativeParty(mi.missionID)
		if numMembers == 0 then
			self.Projections[3].Text:SetText("")
		else
			self.Projections[3].Text:SetText("|TInterface\\QuestFrame\\QuestTypeIcons:0:0:0:1:128:64:19:34:19:35|t" .. numMembers .. "/" .. mi.numFollowers)
		end
		local min, max, exp = G.GetMissionSeen(mi.missionID)
		if exp and exp > 0 then
			local text = math.max(0,exp-floor(max/3600+0.5))
			if min - max >= 3600 and text > 0 then
				text = math.max(0, exp-floor(min/3600+0.5)) .. "-" .. text
			end
			self.Expire:SetPoint("TOPLEFT", 400, (self.Threats[1]:GetTop() - self:GetTop())*self:GetScale())
			self.Expire.Text:SetFormattedText(LASTONLINE_HOURS:gsub("%%[%d$]*d", "%%s"), text)
			self.Expire:Show()
		end
	else
		self.Projections:Hide()
	end
		
	for i=nt,#tt do
		tt[i]:Hide()
	end
end)

do -- GarrisonFollowerTooltip xp textures
	GarrisonFollowerTooltip.XPGained = GarrisonFollowerTooltip:CreateTexture(nil, "ARTWORK", nil, 2)
	GarrisonFollowerTooltip.XPGained:SetTexture(1, 0.8, 0.2)
	GarrisonFollowerTooltip.XPRewardBase = GarrisonFollowerTooltip:CreateTexture(nil, "ARTWORK", nil, 2)
	GarrisonFollowerTooltip.XPRewardBase:SetTexture(0.6, 1, 0)
	GarrisonFollowerTooltip.XPRewardBase:SetPoint("TOPLEFT", GarrisonFollowerTooltip.XPBar, "TOPRIGHT")
	GarrisonFollowerTooltip.XPRewardBase:SetPoint("BOTTOMLEFT", GarrisonFollowerTooltip.XPBar, "BOTTOMRIGHT")
	GarrisonFollowerTooltip.XPRewardBonus = GarrisonFollowerTooltip:CreateTexture(nil, "ARTWORK", nil, 2)
	GarrisonFollowerTooltip.XPRewardBonus:SetTexture(0, 0.75, 1)
	GarrisonFollowerTooltip.XPRewardBonus:SetPoint("TOPLEFT", GarrisonFollowerTooltip.XPRewardBase, "TOPRIGHT")
	GarrisonFollowerTooltip.XPRewardBonus:SetPoint("BOTTOMLEFT", GarrisonFollowerTooltip.XPRewardBase, "BOTTOMRIGHT")
	hooksecurefunc("GarrisonFollowerTooltipTemplate_SetGarrisonFollower", function(self, data)
		self.lastShownData = data
		if self.XPGained then
			self.XPGained:Hide()
			self.XPRewardBase:Hide()
			self.XPRewardBonus:Hide()
		end
	end)
end
do -- Projected XP rewards
	local function MissionFollower_OnEnter(self)
		G.ExtendFollowerTooltipMissionRewardXP(MISSION_PAGE_FRAME.missionInfo, self.info)
	end
	for i=1,3 do
		GarrisonMissionFrame.MissionTab.MissionPage.Followers[i]:HookScript("OnEnter", MissionFollower_OnEnter)
	end
end
do -- Counter-follower lists
	local function GetCounterListText(mech, mlvl)
		local finfo, cinfo = G.GetFollowerInfo(), G.GetCounterInfo()
		local c, t = cinfo[mech], ""
		if c then
			local mi = GarrisonMissionFrame.MissionTab.MissionPage.missionInfo
			t, mlvl = {}, mlvl or (mi and G.GetFMLevel(mi))
			T.Garrison.sortByFollowerLevels(c, finfo)
			for i=1,#c do
				t[#t+1] = T.Garrison.GetFollowerLevelDescription(c[i], mlvl, finfo[c[i]])
			end
			t = #t > 0 and NORMAL_FONT_COLOR_CODE .. L"Can be countered by:" .. "|r\n" .. table.concat(t, "\n") or ""
		end
		return t
	end
	local function GetTraitListText(trait, mlvl)
		local finfo, c, cn = G.GetFollowerInfo(), {}, 1
		for k,v in pairs(finfo) do
			if v.isCollected and v.traits and v.traits[trait] then
				c[cn], cn = k, cn + 1
			end
		end
		local mi = GarrisonMissionFrame.MissionTab.MissionPage.missionInfo
		local mlvl = mlvl or mi and G.GetFMLevel(mi) or 0
		T.Garrison.sortByFollowerLevels(c, finfo)
		for i=1,#c do
			c[i] = T.Garrison.GetFollowerLevelDescription(c[i], mlvl, finfo[c[i]])
		end
		return cn > 1 and (NORMAL_FONT_COLOR_CODE .. L"Followers with this trait:" .. "|r\n" .. table.concat(c, "\n")) or ""
	end
	
	local atip = GarrisonFollowerAbilityTooltip
	atip.CounterOthers = atip:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	atip.CounterOthers:SetJustifyH("LEFT")
	local function atip_Resize()
		atip:SetWidth(math.max(245, 46 + atip.CounterOthers:GetStringWidth()))
		atip.Description:SetWidth(atip:GetWidth()-245+190)
		if atip.Details:IsShown() then
			atip.CounterOthers:SetPoint("TOPLEFT", atip.Details, "BOTTOMLEFT", -26, -16)
		else
			atip.CounterOthers:SetPoint("TOPLEFT", atip.Description, "BOTTOMLEFT", 0, -8)
		end
		if not atip:GetTop() then
		elseif atip.CounterOthers:GetText() ~= "" then
			atip:SetHeight(atip:GetTop()-atip.CounterOthers:GetBottom() + 12)
		else
			atip:SetHeight(atip:GetTop()-atip.Details:GetBottom() + 18)
		end
	end
	hooksecurefunc("GarrisonFollowerAbilityTooltipTemplate_SetAbility", function(self, aid)
		if self.CounterOthers then
			local text
			if self.Details:IsShown() then
				text = GetCounterListText((C_Garrison.GetFollowerAbilityCounterMechanicInfo(aid))) or ""
				self.CounterIcon:SetMask("")
				self.CounterIcon:SetTexCoord(4/64,60/64,4/64,60/64)
			else
				text = GetTraitListText(aid) or ""
			end
			self.CounterOthers:SetText(text)
			if text ~= "" then
				atip_Resize() C_Timer.After(0.03, atip_Resize)
			end
		end
	end)
	
	local ctip = GarrisonMissionMechanicFollowerCounterTooltip
	ctip.CounterOthers = ctip:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	ctip.CounterOthers:SetJustifyH("LEFT")
	local function ctip_Resize()
		ctip:SetWidth(math.max(280, 20 + ctip.CounterOthers:GetStringWidth()))
		if ctip:GetTop() and ctip.CounterOthers:GetBottom() then
			ctip:SetHeight(ctip:GetTop() - ctip.CounterOthers:GetBottom() + 12)
		end
	end
	ctip:HookScript("OnShow", function(self)
		local mech = G.GetMechanicInfo((self.Icon:GetTexture() or ""):lower())
		local text = GetCounterListText(mech)
		self.CounterOthers:SetText(text)
		if self.CounterName:IsShown() then
			self.CounterOthers:SetPoint("TOPLEFT", ctip.CounterName, "BOTTOMLEFT", -24, -16)
		else
			self.CounterOthers:SetPoint("TOPLEFT", ctip.Name, "BOTTOMLEFT", -24, -12)
		end
		ctip_Resize() C_Timer.After(0.03, ctip_Resize)
	end)
	
	GarrisonMissionMechanicTooltip:HookScript("OnShow", function(self)
		local mech = T.Garrison.GetMechanicInfo((self.Icon:GetTexture() or ""):lower())
		local text = GetCounterListText(mech, self.missionLevel)
		if text ~= "" then
			local height = self:GetHeight()-self.Description:GetHeight()
			self.Description:SetText(self.Description:GetText() .. "\n\n" .. text)
			self:SetHeight(height + self.Description:GetHeight() + 4)
		end
	end)
end

local function SetFollowerIgnore(_, fid, val)
	MasterPlan:SetFollowerIgnored(fid, val)
	GarrisonMissionFrame.FollowerList.dirtyList = true
	GarrisonFollowerList_UpdateFollowers(GarrisonMissionFrame.FollowerList)
end
hooksecurefunc(GarrisonFollowerOptionDropDown, "initialize", function(self)
	local fi = self.followerID and C_Garrison.GetFollowerInfo(self.followerID)
	if fi and fi.isCollected and fi.status ~= GARRISON_FOLLOWER_INACTIVE then
		DropDownList1.numButtons = DropDownList1.numButtons - 1
		
		local info, ignored = UIDropDownMenu_CreateInfo(), T.config.ignore[fi.followerID]
		info.text, info.notCheckable = ignored and L"Unignore" or L"Ignore", true
		info.func, info.arg1, info.arg2 = SetFollowerIgnore, fi.followerID, not ignored
		UIDropDownMenu_AddButton(info)
		
		info.text, info.func = CANCEL
		UIDropDownMenu_AddButton(info)
	end
end)

do -- Follower headcounts
	local mf = GarrisonMissionFrame.MissionTab.MissionList.MaterialFrame
	local ff, fs = CreateFrame("Frame", nil, mf), mf:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
	local ni, nw, nx, nm = 0, 0, 0, 0
	ff:SetWidth(190) ff:SetPoint("TOPLEFT") ff:SetPoint("BOTTOMLEFT")
	fs:SetPoint("LEFT", 16, 0)
	ff:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
		GameTooltip:AddLine(GARRISON_FOLLOWERS_TITLE, 1,1,1)
		if ni > 0 then
			GameTooltip:AddLine("|cff40ff40" .. ni .. " " .. L"Idle")
		end
		if nx > 0 then
			GameTooltip:AddLine("|cffc864ff" .. nx .. " " .. L"Idle (max-level)")
		end
		if nw > 0 then
			GameTooltip:AddLine(nw .. " " .. GARRISON_FOLLOWER_WORKING)
		end
		if nm > 0 then
			GameTooltip:AddLine("|cff80dfff" .. nm .. " " .. GARRISON_FOLLOWER_ON_MISSION)
		end
		GameTooltip:Show()
	end)
	ff:SetScript("OnLeave", function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)
	for _, s in pairs({mf:GetRegions()}) do
		if s:IsObjectType("FontString") and s:GetText() == GARRISON_YOUR_MATERIAL then
			s:Hide()
		end
	end
	local function sync()
		ni, nw, nx, nm = 0, 0, 0, 0
		for k, v in pairs(G.GetFollowerInfo()) do
			if not v.isCollected or T.config.ignore[k] then
			elseif v.status == GARRISON_FOLLOWER_WORKING then
				nw = nw + 1
			elseif v.status == GARRISON_FOLLOWER_ON_MISSION then
				nm = nm + 1
			elseif (v.status or "") ~= "" then
			elseif v.level == 100 and v.quality == 4 then
				nx = nx + 1
			else
				ni = ni + 1
			end
		end
		local ico, spacer, t = "|TInterface\\FriendsFrame\\UI-Toast-FriendOnlineIcon:11:11:3:0:32:32:8:24:8:24:", "|TInterface\\Buttons\\UI-Quickslot2:9:9:0:0:64:64:31:32:31:32|t"
		if ni > 0 then t = ni .. ico .. "50:255:50|t" end
		if nx > 0 then t = (t and t .. spacer or "") .. nx .. ico .. "200:100:255|t" end
		if nw > 0 then t = (t and t .. spacer or "") .. nw .. ico .. "255:208:0|t" end
		if nm > 0 then t = (t and t .. spacer or "") .. nm .. ico .. "125:230:255|t" end
		fs:SetText(t or "")
	end
	
	hooksecurefunc("GarrisonMissionFrame_UpdateCurrency", sync)
	EV.RegisterEvent("GARRISON_MISSION_NPC_OPENED", sync)
	mf:HookScript("OnShow", sync)
end
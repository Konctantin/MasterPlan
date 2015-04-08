local _, T = ...
local EV, G = T.Evie, T.Garrison

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
	lab:SetPoint("LEFT", 15, 0) lab:SetText("Mission order:")
	sortIndicator.label = lab
	sortIndicator:SetNormalFontObject(GameFontHighlight)
	sortIndicator:SetHighlightFontObject(GameFontGreen)
	sortIndicator:SetText("!")
	local fs = sortIndicator:GetFontString()
	fs:ClearAllPoints() fs:SetPoint("RIGHT", -15, 0)
	sortIndicator:SetPoint("BOTTOMLEFT", GarrisonMissionFrameMissions, "TOPLEFT", 6, -1)
	sortIndicator:SetSize(250, 43)
	EV.RegisterEvent("MP_SETTINGS_CHANGED", function(ev, s)
		if s == nil or s == "availableMissionSort" then
			sortIndicator:SetText(MasterPlan:GetMissionOrder() == "threats" and "Mitigated threats" or "Mission level")
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
			GarrisonMissionFrame.MissionTab.MissionPage.CloseButton:Click()
		end
		GarrisonMissionFrame_SelectTab(1)
		GarrisonMissionList_UpdateMissions()
		GarrisonMissionFrameMissionsTab2:Click()
		PanelTemplates_SetTab(GarrisonMissionFrame, 3)
		sortIndicator:Hide()
		GarrisonMissionFrame_CheckCompleteMissions()
	end)
	tab.Text:SetText("Active Missions")
	GarrisonMissionFrameTab1:SetText("Available Missions")
	tab:SetPoint("LEFT", GarrisonMissionFrameTab1, "RIGHT", -5, 0)
	GarrisonMissionFrameTab2:SetPoint("LEFT", tab, "RIGHT", -5, 0)
	PanelTemplates_DeselectTab(tab)
	local function updateMissionCounts(useCachedData)
		if not useCachedData then
			C_Garrison.GetAvailableMissions(GarrisonMissionFrameMissions.availableMissions)
			C_Garrison.GetInProgressMissions(GarrisonMissionFrameMissions.inProgressMissions)
		end
		tab:SetFormattedText("Active Missions (%d)", #GarrisonMissionFrameMissions.inProgressMissions)
		GarrisonMissionFrameTab1:SetFormattedText("Available Missions (%d)", #GarrisonMissionFrameMissions.availableMissions)
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
	local used, finfo, cinfo = {}
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

	local origSort = Garrison_SortMissions
	function Garrison_SortMissions(...)
		if MasterPlan:GetMissionOrder() == "threats" then
			finfo, cinfo = G.GetFollowerInfo(), G.GetCounterInfo()
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
	   if followerCounters and followerTraits and GarrisonMissionFrame.MissionTab:IsVisible() then
			return missionFollowerSort(self.followersList, self.followers, followerCounters, followerTraits, GarrisonMissionFrame.MissionTab.MissionPage.missionInfo.level)
		end
		return oldSortFollowers(self)
	end
end

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
	for i=1, #buttons do
		local f, fi = buttons[i], fl[buttons[i].id]
		if f:IsShown() and fi and fi.missionTimeLeft then
			f.Status:SetFormattedText("%s (%s)", f.Status:GetText(), fi.missionTimeLeft)
		end
	end
end)

GarrisonMissionMechanicTooltip:HookScript("OnShow", function(self)
	local finfo, cinfo = G.GetFollowerInfo(), G.GetCounterInfo()
	local c = cinfo[T.Garrison.GetMechanicInfo(self.Icon:GetTexture():lower())]
	if c then
		local mi = GarrisonMissionFrame.MissionTab.MissionPage.missionInfo
		local t, mlvl = {}, GarrisonMissionMechanicTooltip.missionLevel or (mi and G.GetFMLevel(mi))
		T.Garrison.sortByFollowerLevels(c, finfo)
		for i=1,#c do
			t[#t+1] = T.Garrison.GetFollowerLevelDescription(c[i], mlvl, finfo[c[i]])
		end
		if #t > 0 then
			local height = self:GetHeight()-self.Description:GetHeight()
			self.Description:SetText(self.Description:GetText() .. NORMAL_FONT_COLOR_CODE .. "\n\nCountered by:\n" .. table.concat(t, "\n"))
			self:SetHeight(height + self.Description:GetHeight() + 4)
		end
	end
end)

local threatListMT = {} do
	local function HideTip(self)
		GarrisonMissionMechanicTooltip:Hide()
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
		self:GetParent():UnlockHighlight()
	end
	local function OnEnter(self)
		if self.info.isFollowers then
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
	local bf = GarrisonMissionFrameMissions.CompleteDialog.BorderFrame
	local bm = bf.Model
	bm:SetWidth(300)
	bm:SetPoint("BOTTOMLEFT", -80, 0)
	bm.Title:ClearAllPoints()
	bm.Title:SetPoint("TOPLEFT", bm:GetParent(), "TOPLEFT", 200, -10)
	bm.Title:SetPoint("TOPRIGHT", bm:GetParent(), "TOPRIGHT", -50, -10)
	bm.Title:SetText((bm.Title:GetText():gsub("%s+", " ")))
	bf.CompleteAll = CreateFrame("Button", nil, bf, "UIPanelButtonTemplate")
	bf.CompleteAll:SetWidth(200)
	bf.CompleteAll:SetText("Complete All")
	bf.CompleteAll:SetPoint("BOTTOM", 80, 20)
	bf.MissionList = bf:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	bf.MissionList:SetPoint("TOPLEFT", 240, -75)
	bf.MissionList:SetJustifyH("LEFT")
	bf.MissionListState = bf:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	bf.MissionListState:SetPoint("TOPLEFT", bf.MissionList, "TOPRIGHT", 10, 0)
	bf.MissionListState:SetPoint("TOPRIGHT", -60, -75)
	bf.MissionListState:SetJustifyH("RIGHT")
	bf.ViewButton:Hide()
	local close = CreateFrame("Button", nil, bf, "UIPanelCloseButton")
	close:SetSize(24,24) close:SetPoint("TOPRIGHT")
	close:SetScript("OnClick", function()
		GarrisonMissionFrameMissions.CompleteDialog:Hide()
		GarrisonMissionList_UpdateMissions()
	end)
	local lootContainer = CreateFrame("Frame", nil, GarrisonMissionFrameMissions.CompleteDialog.BorderFrame)
	lootContainer:SetSize(490, 205)
	lootContainer:SetPoint("TOPRIGHT", -40, -70)
	lootContainer:Hide()
	local function SetFollower(btn, info, award)
		GarrisonMissionFrame_SetFollowerPortrait(btn, info, false)
		if info.levelXP > info.xp then
			btn.xpProgressTex:SetWidth(46*info.xp/info.levelXP)
			btn.xpProgressTex2:SetWidth(46*math.min(info.xp, award)/info.levelXP)
			btn.xpProgressTex2:Show()
			btn.xpProgressTex:Show()
		else
			btn.xpProgressTex:Hide()
			btn.xpProgressTex2:Hide()
		end
		btn.info = info
		local ding = award and award > (info.xp or 0)
		btn.Level:SetFontObject(ding and GameFontGreenSmall or GameFontHighlightSmall)
		btn:Show()
	end
	lootContainer.followers = {} do
		local function createFollowerButton()
			local b = CreateFrame("Button", nil, lootContainer, "GarrisonFollowerPortraitTemplate")
			b.xpProgressTex = b:CreateTexture(nil, "ARTWORK", nil, 2)
			b.xpProgressTex:SetPoint("TOPLEFT", b.LevelBorder, "TOPLEFT", 6, -6)
			b.xpProgressTex:SetTexture("Interface\\Buttons\\GradBlue")
			b.xpProgressTex:SetAlpha(0.5)
			b.xpProgressTex:SetSize(30, 12)
			b.xpProgressTex2 = b:CreateTexture(nil, "ARTWORK", nil, 2)
			b.xpProgressTex2:SetPoint("RIGHT", b.xpProgressTex)
			b.xpProgressTex2:SetTexture("Interface\\Buttons\\GradBlue")
			b.xpProgressTex2:SetSize(30, 12)
			b:SetScript("OnEnter", GarrisonMissionPageFollowerFrame_OnEnter)
			b:SetScript("OnLeave", GarrisonMissionPageFollowerFrame_OnLeave)
			b:Hide()
			return b
		end
		setmetatable(lootContainer.followers, {__index=function(self, k)
			local b = createFollowerButton()
			if k % 9 == 1 then
				b:SetPoint("TOP", self[k-9], "BOTTOM", 0, -4)
			else
				b:SetPoint("LEFT", self[k-1], "RIGHT", 4, 0)
			end
			self[k] = b
			return b
		end})
		lootContainer.followers[1] = createFollowerButton()
		lootContainer.followers[1]:SetPoint("TOPLEFT")
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
			i.Quantity:SetPoint("BOTTOMRIGHT", -4, 4)
			i:SetScript("OnEnter", OnEnter)
			i:SetScript("OnLeave", OnLeave)
			self[k], i.SetIcon = i, SetIcon
			return i
		end})
		local _ = lootContainer.items[1]
	end
	
	local ownCompleteMissions
	local function UpdateCompleteButton(isBusy, isFinished)
		bf.CompleteAll:SetShown(not isBusy)
		bf.CompleteAll:SetText(isFinished and (lootContainer:IsShown() and "Done" or "View Rewards") or "Complete Missions")
		bf.CompleteAll.isFinished = isFinished
	end
	local function updateMissionStatusList(completeMissions)
		local mlist, mstat = "", ""
		for i=1,#completeMissions do
			local mi = completeMissions[i]
			mlist = mlist .. ("%s%s[%d]|r %s"):format(i > 1 and "\n" or "", "", mi.level, mi.name)
			mstat = mstat .. (i > 1 and "\n" or "") .. (mi.failed and "|cffff2020Failure|r" or mi.state >= 0 and "|cff20ff20Success|r" or (NORMAL_FONT_COLOR_CODE .. "Ready|r"))
		end
		GarrisonMissionFrameMissions.CompleteDialog.BorderFrame.MissionList:SetText(mlist)
		GarrisonMissionFrameMissions.CompleteDialog.BorderFrame.MissionListState:SetText(mstat)
		return mlist, mstat
	end
	function UpdateCompletedMissionList(reset)
		local self, mlist, mstat = GarrisonMissionFrame, "", ""
		self.MissionComplete.completeMissions = C_Garrison.GetCompleteMissions()
		if reset then
			ownCompleteMissions = self.MissionComplete.completeMissions
			lootContainer:Hide()
			UpdateCompleteButton(false, false)
		end
		updateMissionStatusList(ownCompleteMissions)
	end
	local function completionCallback(state, stack, rewards, followers)
		updateMissionStatusList(stack)
		UpdateCompleteButton(state == "STEP", state == "DONE")
		if state == "DONE" then
			MasterPlanArchive = {lastComplete={stack, rewards, followers}}
			local fi, fn = G.GetFollowerInfo(), 1
			for k,v in pairs(followers) do
				SetFollower(lootContainer.followers[fn], fi[k], v.xpAward)
				fn = fn + 1
			end
			for i=fn, #lootContainer.followers do
				lootContainer.followers[i]:Hide()
			end

			local ni = 1
			for k,v in pairs(rewards) do
				local quantity, icon, tooltipHeader, tooltipText, _ = v.quantity
				if v.itemID then
					icon = select(10, GetItemInfo(v.itemID)) or "Interface\\Icons\\Temp"
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
					ib.itemID, ib.currencyID, ib.tooltipHeader, ib.tooltipText = v.itemID, v.currencyID, tooltipHeader, tooltipText
					ni, fn = ni + 1, fn + 1
				end
			end
			for i=ni,#lootContainer.items do
				lootContainer.items[i]:Hide()
			end
		end
	end
	bf.CompleteAll:SetScript("OnClick", function(self)
		if #ownCompleteMissions == 0 or lootContainer:IsShown() then
			GarrisonMissionFrameMissions.CompleteDialog:Hide()
			GarrisonMissionList_UpdateMissions()
		elseif self.isFinished then
			bf.MissionListState:SetText("")
			bf.MissionList:SetText("")
			lootContainer:Show()
			self:SetText("Done")
		elseif IsAltKeyDown() then
			bf.ViewButton:Click()
		else
			G.CompleteMissions(ownCompleteMissions, completionCallback)
		end
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
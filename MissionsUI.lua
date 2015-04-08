local _, T = ...
if T.Mark ~= 16 then return end
local L, EV, G = T.L, T.Evie, T.Garrison

local RefreshActiveMissionsView, activeMissionsHandle

local function abridge(n)
	return (n >= 1000 and L"%.2gk" or "%d"):format(n >= 1000 and n/1000 or n)
end

local activeUI = CreateFrame("Frame", nil, GarrisonMissionFrameMissions)
activeUI:SetSize(880, 22)
activeUI:SetPoint("BOTTOMLEFT", GarrisonMissionFrameMissions, "TOPLEFT", 0, 4)
activeUI.CompleteAll = CreateFrame("Button", nil, activeUI, "UIPanelButtonTemplate") do
	local b = activeUI.CompleteAll
	b:SetSize(200, 26)
	b:SetPoint("BOTTOM", 0, 5)
	b:SetText(L"Complete All")
end
activeUI.batch = CreateFrame("CheckButton", nil, activeUI.CompleteAll, "InterfaceOptionsCheckButtonTemplate") do
	local b = activeUI.batch
	b:SetSize(22, 22)
	b:SetPoint("LEFT", activeUI, "LEFT", 12, 2)
	b.Text:SetText(L"Expedited mission completion")
	b.Text:SetFontObject(GameFontHighlightSmall)
	b:SetScript("OnClick", function(self)
		MasterPlan:SetBatchMissionCompletion(self:GetChecked())
	end)
	b:SetHitRectInsets(0, -b.Text:GetStringWidth()-6, 0,0)
	EV.RegisterEvent("MP_SETTINGS_CHANGED", function(ev, set)
		if set == "batchMissions" or set == nil then
			b:SetChecked(MasterPlan:GetBatchMissionCompletion())
		end
	end)
end
local SetCompletionRewards do
	local lootFrame = CreateFrame("Frame", nil, activeUI) do
		local lf = lootFrame
		activeUI.lootFrame = lf
		lf:SetSize(560, 380)
		lf:SetPoint("CENTER", GarrisonMissionFrameMissions, "CENTER")
		local t = lf:CreateTexture(nil, "BACKGROUND", nil, -1)
		t:SetAllPoints(GarrisonMissionFrameMissions)
		t:SetTexture(0,0,0)
		t:SetAlpha(0.35)
		local w1, h1 = lf:GetSize()
		local w2, h2 = GarrisonMissionFrameMissions:GetSize()
		lf:SetHitRectInsets((w1-w2)/2, (w1-w2)/2, (h1-h2)/2, (h1-h2)/2)
		lf:EnableMouse(true) lf:EnableMouseWheel(true)
		lf:SetFrameStrata("DIALOG")
		t = lf:CreateTexture(nil, "BACKGROUND")
		t:SetAtlas("Garr_InfoBox-BackgroundTile", true)
		t:SetHorizTile(true) t:SetVertTile(true)
		t:SetAllPoints()
		t = lf:CreateTexture(nil, "BORDER")
		t:SetAtlas("_Garr_InfoBoxBorder-Top", true)
		t:SetHorizTile(true) t:SetPoint("TOPLEFT") t:SetPoint("TOPRIGHT")
		t = lf:CreateTexture(nil, "BORDER")
		t:SetAtlas("_Garr_InfoBoxBorder-Top", true)
		t:SetHorizTile(true) t:SetPoint("BOTTOMLEFT") t:SetPoint("BOTTOMRIGHT")
		t:SetTexCoord(0, 1, 1, 0)
		t = lf:CreateTexture(nil, "BORDER")
		t:SetAtlas("!Garr_InfoBoxBorder-Left", true)
		t:SetVertTile(true) t:SetPoint("TOPLEFT") t:SetPoint("BOTTOMLEFT")
		t = lf:CreateTexture(nil, "BORDER")
		t:SetAtlas("!Garr_InfoBoxBorder-Left", true)
		t:SetVertTile(true) t:SetPoint("TOPRIGHT") t:SetPoint("BOTTOMRIGHT")
		t:SetTexCoord(1,0, 0,1)
		t = lf:CreateTexture(nil, "BORDER", nil, -1)
		t:SetAtlas("!Garr_InfoBox-Left", true)
		t:SetPoint("TOPLEFT", -7, 0)
		t:SetPoint("BOTTOMLEFT", -7, 0)
		t:SetVertTile(true)
		t = lf:CreateTexture(nil, "BORDER", nil, -1)
		t:SetAtlas("!Garr_InfoBox-Left", true)
		t:SetPoint("TOPRIGHT", 7, 0)
		t:SetPoint("BOTTOMRIGHT", 7, 0)
		t:SetVertTile(true)
		t:SetTexCoord(1,0, 0,1)
		t = lf:CreateTexture(nil, "BORDER", nil, -1)
		t:SetAtlas("_Garr_InfoBox-Top", true)
		t:SetPoint("TOPLEFT", 0, 7)
		t:SetPoint("TOPRIGHT", 0, 7)
		t:SetHorizTile(true)
		t = lf:CreateTexture(nil, "BORDER", nil, -1)
		t:SetAtlas("_Garr_InfoBox-Top", true)
		t:SetPoint("BOTTOMLEFT", 0, -7)
		t:SetPoint("BOTTOMRIGHT", 0, -7)
		t:SetHorizTile(true)
		t:SetTexCoord(0,1, 1,0)
		t = lf:CreateTexture(nil, "BORDER", nil, 1)
		t:SetAtlas("Garr_InfoBoxBorder-Corner", true)
		t:SetPoint("TOPLEFT")
		t = lf:CreateTexture(nil, "BORDER", nil, 1)
		t:SetAtlas("Garr_InfoBoxBorder-Corner", true)
		t:SetPoint("TOPRIGHT") t:SetTexCoord(1,0, 0,1)
		t = lf:CreateTexture(nil, "BORDER", nil, 1)
		t:SetAtlas("Garr_InfoBoxBorder-Corner", true)
		t:SetPoint("BOTTOMLEFT") t:SetTexCoord(0,1, 1,0)
		t = lf:CreateTexture(nil, "BORDER", nil, 1)
		t:SetAtlas("Garr_InfoBoxBorder-Corner", true)
		t:SetPoint("BOTTOMRIGHT") t:SetTexCoord(1,0, 1,0)
		t = lf:CreateFontString(nil, "ARTWORK", "QuestFont_Super_Huge")
		t:SetPoint("TOP", 0, -12)
		t:SetText((GARRISON_MISSION_REPORT:gsub("\n", " ")))
		t = lf:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
		t:SetPoint("TOP", 0, -40)
		t:SetText("30 Bear Cows Slain")
		lf.numMissions = t
		t = lf:CreateTexture(nil, "BORDER", nil, 1)
		t:SetAtlas("Garr_InfoBox-CornerShadow", true)
		t:SetPoint("BOTTOMRIGHT", lf, "TOPLEFT")
		t = lf:CreateTexture(nil, "BORDER", nil, 1)
		t:SetAtlas("Garr_InfoBox-CornerShadow", true)
		t:SetPoint("BOTTOMLEFT", lf, "TOPRIGHT")
		t:SetTexCoord(1,0, 0,1)
		t = lf:CreateTexture(nil, "BORDER", nil, 1)
		t:SetAtlas("Garr_InfoBox-CornerShadow", true)
		t:SetPoint("TOPRIGHT", lf, "BOTTOMLEFT")
		t:SetTexCoord(0,1, 1,0)
		t = lf:CreateTexture(nil, "BORDER", nil, 1)
		t:SetAtlas("Garr_InfoBox-CornerShadow", true)
		t:SetPoint("TOPLEFT", lf, "BOTTOMRIGHT")
		t:SetTexCoord(1,0, 1,0)
		t = CreateFrame("Button", nil, lootFrame, "UIPanelButtonTemplate")
		t:SetSize(200, 24) t:SetText(L"Done") t:SetPoint("BOTTOM", 0, 18)
		t:SetScript("OnClick", function()
			lootFrame:Hide()
			if T.UpdateMissionTabs then
				GarrisonMissionList_UpdateMissions()
				T.UpdateMissionTabs()
			end
			RefreshActiveMissionsView(true)
		end)
		lf.Dismiss = t
		t = lf:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		t:SetPoint("BOTTOM", lf.Dismiss, "TOP", 0, 6)
		t:SetText(("|cffff2020%s|r|n%s"):format(L"You have no free bag slots.", L"Additional mission loot may be delivered via mail."))
		lf.noBagSlots = t
		lf:Hide()
		lf:SetScript("OnShow", function(self)
			self.noBagSlots:Show()
			for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
				local freeSlots, bagFamily = GetContainerNumFreeSlots(i)
				if bagFamily == 0 and freeSlots > 0 then
					self.noBagSlots:Hide()
					break
				end
			end
			if self.onShowSound then
				PlaySound(self.onShowSound)
				self.onShowSound = nil
			end
		end)
	end
	
	local lootContainer = CreateFrame("Frame", nil, lootFrame)
	lootContainer:SetSize(490, 280)
	lootContainer:SetPoint("TOP", 0, -65)
	lootContainer:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	lootContainer:SetScript("OnEvent", function(self)
		for i=1,#self.items do
			local ii = self.items[i]
			if ii.itemID and ii:IsShown() then
				ii:SetIcon(select(10, GetItemInfo(ii.itemID)) or "Interface\\Icons\\Temp")
			end
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
			btn.info, btn.awardXP = info, award or 0
			if award and award > (info.xp or 0) or (oldQuality and oldQuality ~= info.quality) then
				lootFrame.onShowSound = "UI_Garrison_CommandTable_Follower_LevelUp"
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
		local function FollowerButton_OnEnter(self)
			local tip = GarrisonFollowerTooltip
			GarrisonMissionPageFollowerFrame_OnEnter(self)
			local data = tip.lastShownData
			if tip.XP:IsShown() and self.awardXP and self.awardXP > 0 then
				tip.XP:SetText(tip.XP:GetText() .. "|n|cff10ff10" .. (L"%s XP gained"):format(BreakUpLargeNumbers(self.awardXP)))
				if tip.XPGained and data then
					tip.XPGained:ClearAllPoints()
					tip.XPGained:SetPoint("TOPRIGHT", tip.XPBar)
					tip.XPGained:SetPoint("BOTTOMRIGHT", tip.XPBar)
					tip.XPGained:SetWidth(math.max(0.01, math.min(data.xp, self.awardXP)*tip.XPBarBackground:GetWidth()/data.levelxp))
					tip.XPGained:Show()
				end
			end
		end
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
			b:SetScript("OnEnter", FollowerButton_OnEnter)
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
		local perRow, baseY = 9, 0, 0
		if numTotal <= 9 then
			perRow, baseY = numTotal, -76
		elseif numTotal <= 18 then
			perRow, baseY = 6, numTotal <= 12 and -64 or -32
		elseif numTotal <= 32 then
			perRow, baseY = 8, numTotal <= 24 and -24 or 0
		end
		local baseX = (504 - perRow*56)/2
		for i=1,numTotal do
			self.followers[i]:SetPoint("TOPLEFT", baseX + ((i-1) % perRow) * 56, baseY - 64*floor((i-1)/perRow))
		end
		self.count = numTotal
	end
	function SetCompletionRewards(rewards, followers, numMissions)
		lootFrame.numMissions:SetFormattedText(GARRISON_NUM_COMPLETED_MISSIONS, numMissions or 1)
		lootFrame.onShowSound = rewards and next(rewards) and "UI_Garrison_CommandTable_ChestUnlock_Gold_Success" or "UI_Garrison_CommandTable_ChestUnlock"
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
				ib:Show()
				ni, fn = ni + 1, fn + 1
			end
		end
		for i=ni,#lootContainer.items do
			lootContainer.items[i]:Hide()
		end
		lootContainer:Layout(fn - 1)
		lootFrame:Show()
	end
end

local GetActiveMissions, StartCompleteAll, CompleteMission, ClearCompletionState do
	local completionMissions, expire, mark = {}, {}, {}

	local function cmp(a,b)
		local ac, bc = expire[a.missionID], expire[b.missionID]
		if not ac ~= not bc then
			return not ac
		end
		if ac == bc then
			ac, bc = strcmputf8i(a.name, b.name), 0
		end
		return ac < bc
	end
	function GetActiveMissions()
		local rt, rn, now = {}, 1, time()
		
		wipe(mark)
		for i=1,#completionMissions do
			rt[rn], rn, mark[completionMissions[i].missionID or 0] = completionMissions[i], rn + 1, 1
		end
		for j=1,2 do
			local t = C_Garrison[j == 1 and "GetCompleteMissions" or "GetInProgressMissions"]()
			for i=1,#t do
				local v = t[i]
				if not mark[v.missionID] then
					if j == 1 then
						v.timeLeftSeconds = 0
						completionMissions[#completionMissions+1] = v
					end
					if v.missionID and not v.successChance then
						local _, _, _, sc, partyBuffs, _, extraXP = C_Garrison.GetPartyMissionInfo(v.missionID)
						v.successChance, v.groupXPBuff, v.extraXP = sc, G.GetBuffsXPMultiplier(partyBuffs), extraXP
					end
					if v.timeLeft and not v.timeLeftSeconds then
						v.timeLeftSeconds = G.GetSecondsFromTimeString(v.timeLeft)
						v.readyTime = now + v.timeLeftSeconds
					end
					if v.timeLeftSeconds then
						v.readyTime = time() + v.timeLeftSeconds
					end
					rt[rn], rn, mark[v.missionID or 0] = v, rn + 1, 1
				end
			end
		end
		for i=1,rn-1 do
			local id, tl = rt[i].missionID, rt[i].timeLeftSeconds
			local diff = tl and expire[id] and (expire[id] - now - tl) or 1
			if (id and tl) and (diff > 0 or diff < -60) then
				expire[id] = now + tl
			end
		end
		table.sort(rt, cmp)
		table.sort(completionMissions, cmp)
		
		return rt
	end
	
	local function completeStep(state, stack, rew, fol)
		if (state == "DONE" or state == "ABORT") and activeUI.completionState == "RUNNING" then
			activeUI.completionState = state == "DONE" and "DONE" or nil
			if next(rew) or next(fol) then
				SetCompletionRewards(rew, fol, #stack)
			end
		end
		RefreshActiveMissionsView()
	end
	function StartCompleteAll()
		wipe(completionMissions)
		GetActiveMissions()
		if #completionMissions > 0 then
			local stack = {}
			for i=1,#completionMissions do
				stack[i] = completionMissions[i]
			end
			activeUI.completionState = "RUNNING"
			G.CompleteMissions(stack, completeStep)
			return true
		end
	end
	function CompleteMission(mi)
		GarrisonMissionFrame.MissionComplete:Show();
		GarrisonMissionFrame.MissionCompleteBackground:Show();
		GarrisonMissionFrame.MissionComplete.currentIndex = 1
		GarrisonMissionFrame.MissionComplete.completeMissions = {mi}
		GarrisonMissionComplete_Initialize(GarrisonMissionFrame.MissionComplete.completeMissions, 1)
		GarrisonMissionFrame.MissionComplete.NextMissionButton.returnToActiveList = true
	end
	function ClearCompletionState()
		wipe(completionMissions)
	end
end
activeUI.CompleteAll:SetScript("OnClick", function(self)
	PlaySound("UChatScrollButton")
	if IsAltKeyDown() == T.config.batchMissions then
		GarrisonMissionFrame.MissionComplete.completeMissions = C_Garrison.GetCompleteMissions()
		GarrisonMissionFrameMissions.CompleteDialog.BorderFrame.ViewButton:Click()
	else
		StartCompleteAll()
	end
end)

local core = {} do
	local int = {view={}}
	local sf, sc, bar = CreateFrame("ScrollFrame", nil, GarrisonMissionFrameMissions) do
		sf:SetSize(882, 541)
		sf:SetPoint("CENTER")
		bar = CreateFrame("Slider", nil, sf) do
			bar:SetWidth(19)
			bar:SetPoint("TOPRIGHT", 0, -6)
			bar:SetPoint("BOTTOMRIGHT", 0, 8)
			bar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
			bar:GetThumbTexture():SetSize(18, 24)
			bar:GetThumbTexture():SetTexCoord(0.20, 0.80, 0.125, 0.875)
			bar:SetMinMaxValues(0, 100)
			bar:SetValue(0)
			local bg = bar:CreateTexture("BACKGROUND")
			bg:SetPoint("TOPLEFT", 0, 16)
			bg:SetPoint("BOTTOMRIGHT", 0, -14)
			bg:SetTexture(0,0,0)
			bg:SetAlpha(0.85)
			local top = bar:CreateTexture("ARTWORK")
			top:SetSize(24, 48)
			top:SetPoint("TOPLEFT", -4, 17)
			top:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
			top:SetTexCoord(0, 0.45, 0, 0.20)
			local bot = bar:CreateTexture("ARTWORK")
			bot:SetSize(24, 64)
			bot:SetPoint("BOTTOMLEFT", -4, -15)
			bot:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
			bot:SetTexCoord(0.515625, 0.97, 0.1440625, 0.4140625)
			local mid = bar:CreateTexture("ARTWORK")
			mid:SetPoint("TOPLEFT", top, "BOTTOMLEFT")
			mid:SetPoint("BOTTOMRIGHT", bot, "TOPRIGHT")
			mid:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
			mid:SetTexCoord(0, 0.45, 0.1640625, 1)
			local function Move(self)
				bar:SetValue(bar:GetValue() - (2-self:GetID()) * int.props.entryHeight)
			end
			local up = CreateFrame("Button", nil, bar, "UIPanelScrollUpButtonTemplate", 1)
			up:SetPoint("BOTTOM", bar, "TOP", 0, -2)
			local down = CreateFrame("Button", nil, bar, "UIPanelScrollDownButtonTemplate", 3)
			down:SetPoint("TOP", bar, "BOTTOM", 0, 2)
			up:SetScript("OnClick", Move)
			down:SetScript("OnClick", Move)
			sf:SetScript("OnMouseWheel", function(self, direction)
				(direction == 1 and up or down):Click()
			end)
			bar:SetScript("OnValueChanged", function(self, v, _isUserInteraction)
				local _, x = self:GetMinMaxValues()
				int:Update(v, true)
				up:SetEnabled(v > 0)
				down:SetEnabled(v < x)
			end)
		end
		sc = CreateFrame("Frame", nil, sf) do
			sc:SetSize(880, 551)
			sf:SetScrollChild(sc)
		end
	end
	function int:Update(ofs)
		if not self.props then return end
		local entryHeight, bot, w = self.props.entryHeight, ofs + sf:GetHeight(), self.props.widgets
		local baseIndex = (ofs - ofs % entryHeight) / entryHeight
		local maxIndex = (bot + entryHeight - bot % entryHeight) / entryHeight

		local minIndex, maxIndex = max(1, baseIndex), min(#self.data, maxIndex)
		for k,v in pairs(self.view) do
			if k < minIndex or k > maxIndex then
				v:SetParent(nil)
				v:ClearAllPoints()
				v:Hide()
				w[#w + 1], self.view[k] = v
			end
		end
		for i=minIndex,maxIndex do
			local f = self.view[i]
			if not f then
				f, w[#w] = w[#w] or securecall(self.props.Spawn)
			end
			if f then
				securecall(self.props.Update, f, self.data[i])
				f:SetParent(sc)
				f:SetPoint("TOP", bar:IsShown() and -5 or 0, ofs - 5 - (i-1)*entryHeight)
				f:Show()
				self.view[i] = f
			end
		end
		
		if bar:GetValue() ~= ofs then
			bar:SetValue(ofs)
		end
	end

	function core:SetData(data, propsHandle)
		int.data, int.props = data, propsHandle
		local mv = max(0, 10+ propsHandle.entryHeight * #data - sf:GetHeight())
		bar:SetMinMaxValues(0, mv)
		bar:SetShown(mv > 0)
		bar:GetScript("OnValueChanged")(bar, int.props ~= propsHandle and 0 or bar:GetValue(), false)
	end
	function core:Refresh(handle)
		if int.props == handle then
			int:Update(bar:GetValue())
		end
	end
	function core:SetShown(isShown)
		sf:SetShown(isShown)
	end
	function core:IsShown()
		return sf:IsShown()
	end
	function core:IsOwned(propsHandle)
		return int.props == propsHandle
	end
	function core:CreateHandle(createFunc, setFunc, entryHeight)
		return {Spawn=createFunc, Update=setFunc, entryHeight=entryHeight, widgets={}}
	end
end
do -- activeMissionsHandle
	local data = {}
	local CreateRewards do
		local function Reward_OnEnter(self)
			if self.itemID then
				GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
				GameTooltip:SetItemByID(self.itemID)
				GameTooltip:Show()
			elseif self.tooltipTitle and self.tooltipText then
				GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
				GameTooltip:AddLine(self.tooltipTitle)
				GameTooltip:AddLine(self.tooltipText, 1,1,1,1)
				GameTooltip:Show()
			elseif self.currencyID then
				GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
				GameTooltip:SetCurrencyByID(self.currencyID)
				GameTooltip:Show()
			end
			if self:GetParent():IsEnabled() then
				self:GetParent():LockHighlight()
			end
		end
		local function Reward_OnLeave(self)
			if GameTooltip:IsOwned(self) then
				GameTooltip:Hide()
			end
			self:GetParent():UnlockHighlight()
		end
		local function Reward_OnClick(self)
			if IsModifiedClick("CHATLINK") then
				local qt, text, _ = self.quantity:GetText()
				if self.itemID then
					_, text = GetItemInfo(self.itemID)
				elseif self.currencyID and self.currencyID ~= 0 then
					text = GetCurrencyLink(self.currencyID)
				elseif self.tooltipTitle then
					text = self.tooltipTitle
				end
				if text and qt ~= "" and qt ~= "1" then
					text = qt .. " " .. text
				end
				if text then
					ChatEdit_InsertLink(text)
				end
			end
		end
		local function CreateReward(parent)
			local r = CreateFrame("Button", nil, parent)
			r:SetSize(32, 32)
			r:SetPoint("RIGHT", -12, 0)
			local t = r:CreateTexture(nil, "BACKGROUND")
			t:SetAtlas("GarrMission_RewardsShadow")
			t:SetPoint("CENTER")
			t:SetSize(36, 36)
			t = r:CreateTexture(nil, "ARTWORK")
			t:SetSize(32, 32)
			t:SetPoint("CENTER")
			t:SetTexture("Interface\\ICONS\\Temp")
			r.icon = t
			t = r:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
			t:SetPoint("BOTTOMRIGHT", -1, 1)
			r.quantity = t
			r:SetScript("OnEnter", Reward_OnEnter)
			r:SetScript("OnLeave", Reward_OnLeave)
			r:SetScript("OnHide", Reward_OnLeave)
			r:SetScript("OnClick", Reward_OnClick)
			return r
		end
		local rewardsMT = {__index=function(self, k)
			local l = self[k-1]
			local r = CreateReward(l:GetParent())
			r:SetPoint("RIGHT", l, "LEFT", -4, 0)
			self[k] = r
			return self[k]
		end}
		function CreateRewards(parent)
			return setmetatable({CreateReward(parent)}, rewardsMT)
		end
	end
	
	local function Follower_OnEnter(self)
		if self.followerID then
			if self:GetParent():IsEnabled() then
				self:GetParent():LockHighlight()
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
			G.ExtendFollowerTooltipMissionRewardXP(data[self:GetParent()], info)
		end
	end
	local function Follower_OnLeave(self)
		GarrisonFollowerTooltip:Hide()
		self:GetParent():UnlockHighlight()
	end
	local function ActiveMission_OnClick(self)
		local mi = data[self]
		if IsModifiedClick("CHATLINK") then
			local missionLink = C_Garrison.GetMissionLink(mi.missionID)
			if (missionLink) then
				ChatEdit_InsertLink(missionLink)
			end
		elseif mi.readyTime and mi.readyTime < time() and not (mi.succeeded or mi.failed) then
			CompleteMission(mi)
		end
	end
	local function CreateActiveMission()
		local b = CreateFrame("Button")
		b:SetSize(832, 44)
		local t = b:CreateTexture(nil, "BACKGROUND")
		t:SetAtlas("GarrMission_MissionParchment", true)
		t:SetPoint("TOPLEFT", 3, 0) t:SetPoint("BOTTOMRIGHT", -3, 0)
		t:SetVertTile(true) t:SetHorizTile(true)
		t = b:CreateTexture(nil, "BACKGROUND", nil, 1)
		t:SetAtlas("!GarrMission_Bg-Edge", true)
		t:SetVertTile(true)
		t:SetPoint("TOPLEFT", -10, 0)
		t:SetPoint("BOTTOMLEFT", -10, 0)
		t = b:CreateTexture(nil, "BACKGROUND", nil, 1)
		t:SetAtlas("!GarrMission_Bg-Edge", true)
		t:SetVertTile(true)
		t:SetPoint("TOPRIGHT", 10, 0)
		t:SetPoint("BOTTOMRIGHT", 10, 0)
		t:SetTexCoord(1,0, 0,1)
		t = b:CreateTexture(nil, "BACKGROUND", nil, 2)
		t:SetAtlas("_GarrMission_MissionListTopHighlight", true)
		t:SetHorizTile(true)
		t:SetPoint("TOPLEFT", 3, 0)
		t:SetPoint("TOPRIGHT", -3, 0)
		t = b:CreateTexture(nil, "BACKGROUND", nil, 2)
		t:SetAtlas("_GarrMission_Bg-BottomEdgeSmall", true)
		t:SetHorizTile(true)
		t:SetPoint("BOTTOMLEFT", 3, 0)
		t:SetPoint("BOTTOMRIGHT", -3, 0)
		t = b:CreateTexture(nil, "BACKGROUND", nil, 3)
		t:SetAtlas("Garr_MissionList-IconBG")
		t:SetPoint("TOPLEFT", 0, -1)
		t:SetPoint("BOTTOMLEFT", 0, 1)
		t:SetWidth(86)
		t:SetVertexColor(0,0,0,0.4)
		t = b:CreateTexture(nil, "BORDER")
		t:SetAtlas("_GarrMission_TopBorder", true)
		t:SetPoint("TOPLEFT", 20, 4)
		t:SetPoint("TOPRIGHT", -20, 4)
		t = b:CreateTexture(nil, "BORDER")
		t:SetAtlas("_GarrMission_TopBorder", true)
		t:SetPoint("BOTTOMLEFT", 20, -4)
		t:SetPoint("BOTTOMRIGHT", -20, -4)
		t:SetTexCoord(0,1, 1,0)
		t = b:CreateTexture(nil, "BORDER", nil, 1)
		t:SetAtlas("GarrMission_TopBorderCorner", true)
		t:SetPoint("TOPLEFT", -5, 4)
		t = b:CreateTexture(nil, "BORDER", nil, 1)
		t:SetAtlas("GarrMission_TopBorderCorner", true)
		t:SetPoint("TOPRIGHT", 4, 4)
		t:SetTexCoord(1,0, 0,1)
		t = b:CreateTexture(nil, "BORDER", nil, 1)
		t:SetAtlas("GarrMission_TopBorderCorner", true)
		t:SetPoint("BOTTOMLEFT", -5, -4)
		t:SetTexCoord(0,1, 1,0)
		t = b:CreateTexture(nil, "BORDER", nil, 1)
		t:SetAtlas("GarrMission_TopBorderCorner", true)
		t:SetPoint("BOTTOMRIGHT", 4, -4)
		t:SetTexCoord(1,0, 1,0)
		t = b:CreateTexture(nil, "HIGHLIGHT")
		t:SetAtlas("_GarrMission_TopBorder-Highlight", true)
		t:SetHorizTile(true)
		t:SetPoint("TOPLEFT", 21, 4)
		t:SetPoint("TOPRIGHT", -22, 4)
		t = b:CreateTexture(nil, "HIGHLIGHT")
		t:SetAtlas("_GarrMission_TopBorder-Highlight", true)
		t:SetHorizTile(true)
		t:SetPoint("BOTTOMLEFT", 21, -4)
		t:SetPoint("BOTTOMRIGHT", -22, -4)
		t:SetTexCoord(0,1, 1,0)
		t = b:CreateTexture(nil, "HIGHLIGHT", nil, 1)
		t:SetAtlas("GarrMission_TopBorderCorner-Highlight", true)
		t:SetPoint("TOPLEFT", -5, 4)
		t = b:CreateTexture(nil, "HIGHLIGHT", nil, 1)
		t:SetAtlas("GarrMission_TopBorderCorner-Highlight", true)
		t:SetPoint("TOPRIGHT", 4, 4)
		t:SetTexCoord(1,0, 0,1)
		t = b:CreateTexture(nil, "HIGHLIGHT", nil, 1)
		t:SetAtlas("GarrMission_TopBorderCorner-Highlight", true)
		t:SetPoint("BOTTOMLEFT", -5, -4)
		t:SetTexCoord(0,1, 1,0)
		t = b:CreateTexture(nil, "HIGHLIGHT", nil, 1)
		t:SetAtlas("GarrMission_TopBorderCorner-Highlight", true)
		t:SetPoint("BOTTOMRIGHT", 4, -4)
		t:SetTexCoord(1,0, 1,0)
		t = b:CreateTexture(nil, "HIGHLIGHT", nil, 1)
		t:SetAtlas("GarrMission_ListGlow-Highlight")
		t:SetPoint("TOPLEFT")
		t:SetPoint("TOPRIGHT")
		t:SetHeight(30)
		t = b:CreateTexture(nil, "ARTWORK")
		t:SetSize(30, 28) t:SetPoint("LEFT", 52, 0)
		b.mtype = t
		t = b:CreateFontString(nil, "ARTWORK", "Game30Font")
		t:SetPoint("CENTER", b, "LEFT", 32, 4)
		t:SetTextColor(0.84, 0.72, 0.57)
		b.level = t
		t = b:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		t:SetPoint("TOP", b, "LEFT", 32, -6)
		t:SetTextColor(0.84, 0.78, 0.72)
		b.chance = t
		t = b:CreateFontString(nil, "ARTWORK", "QuestFont_Super_Huge")
		t:SetPoint("LEFT", 92, 0)
		t:SetTextColor(1,1,1)
		t:SetShadowColor(0,0,0)
		t:SetShadowOffset(1,-1)
		b.title = t
		t = b:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		t:SetPoint("RIGHT", -110, 0)
		t:SetTextColor(0.84, 0.72, 0.57)
		b.status = t
		b.rewards, b.followers = CreateRewards(b), {}
		b.rewards[1]:SetPoint("RIGHT", -16, 1)
		for i=1,3 do
			local x = CreateFrame("Frame", nil, b, nil, i)
			x:SetSize(32, 32)	x:SetPoint("RIGHT", -265-36*i, 1)
			local v = x:CreateTexture(nil, "ARTWORK", nil, 1)
			v:SetPoint("TOPLEFT", 3, -3) v:SetPoint("BOTTOMRIGHT", -3, 3)
			b.followers[i], x.portrait = x, v
			v = x:CreateTexture(nil, "ARTWORK", nil, 2)
			v:SetAllPoints()
			v:SetAtlas("Garr_FollowerPortrait_Ring", true)
			v = x:CreateTexture(nil, "HIGHLIGHT")
			v:SetPoint("TOPLEFT", -2, 2) v:SetPoint("BOTTOMRIGHT", 1, -1)
			v:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
			v:SetBlendMode("ADD")
			x:SetScript("OnEnter", Follower_OnEnter)
			x:SetScript("OnLeave", Follower_OnLeave)
			x:SetScript("OnHide", Follower_OnLeave)
		end
		b:SetScript("OnClick", ActiveMission_OnClick)
	
		return b
	end
	local function TimerUpdate(self)
		local mi = data[self]
		if mi and mi.readyTime then
			self.status:SetText(G.GetTimeStringFromSeconds(mi.readyTime - time()))
		end
	end
	local function setData(self, d)
		data[self] = d
		self.level:SetText((d.isRare and "|cff0090ff" or "") .. (d.iLevel > 0 and d.iLevel or d.level))
		self.title:SetText(d.name)
		local tl = d.timeLeftSeconds or G.GetSecondsFromTimeString(d.timeLeft)
		self:SetScript("OnUpdate", tl > 0 and tl < 60 and TimerUpdate or nil)
		if tl > 0 then
			self.status:SetText(d.timeLeft)
		else
			local state = NORMAL_FONT_COLOR_CODE ..  L"Ready"
			if d.failed then
				state = "|cffff2020" .. L"Failed"
			elseif d.succeeded or d.state >= 0 then
				state = "|cff20ff20" .. L"Success"
			end
			self.status:SetText(state)
		end
		self.chance:SetText(d.successChance and (d.successChance .. "%") or "")
		local nr, nf, r = 1, 1
		if type(d.rewards) == "table" then
			for k,v in pairs(d.rewards) do
				local icon, quant = v.icon, v.quantity ~= 1 and v.quantity
				r, nr = self.rewards[nr], nr + 1
				r.itemID, r.tooltipTitle, r.tooltipText, r.currencyID = v.itemID, v.title, v.tooltip, v.currencyID
				if v.followerXP then
					quant = abridge(v.followerXP)
				elseif v.currencyID == 0 then
					quant = abridge(v.quantity/10000)
					r.tooltipText = GetMoneyString(v.quantity)
				elseif v.currencyID == GARRISON_CURRENCY then
					v.materialMultiplier = v.materialMultiplier or select(8, C_Garrison.GetPartyMissionInfo(d.missionID)) or 1
					quant = abridge(v.quantity * v.materialMultiplier)
				elseif v.itemID then
					local _, _, q, l, _, _, _, _, _, tex = GetItemInfo(v.itemID)
					if v.quantity == 1 and q and l and l > 500 then
						quant = ITEM_QUALITY_COLORS[q].hex .. l
					end
					if tex then
						icon = tex
					end
				end
				r.quantity:SetText(quant or "")
				r.icon:SetTexture(icon or "Interface/Icons/Temp")
				r:Show()
			end
		end
		self.mtype:SetAtlas(d.typeAtlas)
		if type(d.followers) == "table" then
			local fi, w
			for i=1,#d.followers do
				fi, w, nf = C_Garrison.GetFollowerInfo(d.followers[i]), self.followers[nf], nf + 1
				w.followerID = fi.followerID
				w.portrait:SetToFileData(fi.portraitIconID)
				w:Show()
			end
		end
		for i=nr, #self.rewards do
			self.rewards[i]:Hide()
		end
		for i=nf, #self.followers do
			self.followers[i]:Hide()
		end
	end
	activeMissionsHandle = core:CreateHandle(CreateActiveMission, setData, 48)
end
function RefreshActiveMissionsView(force)
	if core:IsShown() and (force or core:IsOwned(activeMissionsHandle)) then
		if force then ClearCompletionState() end
		local am = GetActiveMissions()
		local nextUpdate, hasComplete = 60, false
		for i=1,#am do
			local tl, m = am[i].timeLeftSeconds, am[i]
			if tl == 120 then
				nextUpdate = 1
			elseif tl == 0 and not (m.succeeded or m.failed) then
				hasComplete = true
			end
		end
		core:SetData(am, activeMissionsHandle)
		activeUI.CompleteAll:SetShown(not activeUI.lootFrame:IsShown() and (hasComplete and activeUI.completionState ~= "RUNNING"))
		activeUI.nextRefresh = nextUpdate
		if force then
			if #am == 0 then
				GarrisonMissionFrame_SelectTab(1)
			end
		end
	end
end
activeUI:SetScript("OnUpdate", function(self, elapsed)
	local nr = self.nextRefresh or 0
	if nr < elapsed then
		RefreshActiveMissionsView()
	else
		self.nextRefresh = nr - elapsed
	end
end)
EV.RegisterEvent("GET_ITEM_INFO_RECEIVED", function()
	if activeUI:IsVisible() then
		core:Refresh(activeMissionsHandle)
	end
end)

function GarrisonMissionFrame_CheckCompleteMissions(onShow)
	if not GarrisonMissionFrame.MissionComplete:IsShown() then
		GarrisonMissionFrame.MissionComplete.completeMissions = C_Garrison.GetCompleteMissions()
		if #GarrisonMissionFrame.MissionComplete.completeMissions > 0 and T.UpdateMissionTabs then
			T.UpdateMissionTabs()
		end
	end
	if onShow and not activeUI:IsVisible() and GarrisonMissionFrame:IsShown() and #C_Garrison.GetCompleteMissions() > 0 then
		GarrisonMissionFrame_SelectTab(1)
		PanelTemplates_SetTab(GarrisonMissionFrame, 3)
	end
end
do -- periodic comleted missions check
	local isTimerRunning = false
	local function timer()
		if GarrisonMissionFrame:IsShown() then
			local cm = GarrisonMissionFrame.MissionComplete.completeMissions
			if (cm and #cm or 0) == 0 then
				GarrisonMissionFrame_CheckCompleteMissions()
			end
			C_Timer.After(15, timer)
			isTimerRunning = true
		else
			isTimerRunning = false
		end
	end
	GarrisonMissionFrame:HookScript("OnShow", function()
		if not isTimerRunning then
			timer()
		end
	end)
end
do -- suppress completion toast while missions UI is visible
	local registered = false
	GarrisonMissionFrame:HookScript("OnShow", function(self)
		if AlertFrame:IsEventRegistered("GARRISON_MISSION_FINISHED") then
			registered = true
			AlertFrame:UnregisterEvent("GARRISON_MISSION_FINISHED")
		end
	end)
	GarrisonMissionFrame:HookScript("OnHide", function(self)
		if registered then
			AlertFrame:RegisterEvent("GARRISON_MISSION_FINISHED")
			registered = false
		end
	end)
end

T.InProgressUI = {SetShown=function(self, isShown)
	local wasShown = activeUI:IsShown()
	GarrisonMissionFrameMissionsListScrollFrame:SetShown(not isShown)
	core:SetShown(isShown)
	activeUI:SetShown(isShown)
	if isShown then
		RefreshActiveMissionsView(not wasShown)
	else
		if activeUI.completionState == "RUNNING" then
			G.AbortCompleteMissions()
		end
		activeUI.completionState = nil
	end
end}
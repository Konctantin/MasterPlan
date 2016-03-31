local _, T = ...
if T.Mark ~= 50 then return end
local G, L, EV = T.Garrison, T.L, T.Evie
local countFreeFollowers = G.countFreeFollowers

do -- Feed FrameXML updates to Evie
	local function FollowerList_OnShowFollower(self, id)
		local tab = self.followerTab
		tab.MPLastFollowerID = id
		EV("FXUI_GARRISON_FOLLOWER_LIST_SHOW_FOLLOWER", tab, id, false)
	end
	local function tabOnShow(self)
		if self.MPLastFollowerID then
			EV("FXUI_GARRISON_FOLLOWER_LIST_SHOW_FOLLOWER", self, self.MPLastFollowerID, true)
		end
	end
	hooksecurefunc(GarrisonMissionFrame.FollowerList, "ShowFollower", FollowerList_OnShowFollower)
	hooksecurefunc(GarrisonLandingPage.FollowerList, "ShowFollower", FollowerList_OnShowFollower)
	GarrisonLandingPage.FollowerTab:HookScript("OnShow", tabOnShow)
	GarrisonMissionFrame.FollowerTab:HookScript("OnShow", tabOnShow)
end

local function HideOwnedGameTooltip(self)
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

local mechanicsFrame = CreateFrame("Frame")
T.mechanicsFrame = mechanicsFrame
mechanicsFrame:SetSize(1,1) mechanicsFrame:Hide()
local floatingMechanics = CreateFrame("Frame", nil, mechanicsFrame)
floatingMechanics:EnableMouse(true)
local CreateMechanicButton, Mechanic_SetTrait do
	local function Mechanic_OnEnter(self)
		local ci = self.info
		GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT")
		if self.isTrait then
			G.SetTraitTooltip(GameTooltip, self.id, ci, not self.hideInactive)
		elseif self.isTraitGroup then
			floatingMechanics:SetOwner(self, ci)
			return
		elseif self.isDouble then
			G.SetDoubleCountersTooltip(GameTooltip, ci)
		else
			G.SetThreatTooltip(GameTooltip, self.id, ci, nil, true)
		end
		GameTooltip:Show()
		if GameTooltip:GetRight() > GarrisonMissionFrame:GetRight() then
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")
		end
	end
	local function Mechanic_OnClick(self)
		local nt = self.name or (self.info and self.info.name)
		local sb = GarrisonMissionFrameFollowers.SearchBox:IsVisible() and GarrisonMissionFrameFollowers.SearchBox or
		           GarrisonLandingPage.FollowerList.SearchBox:IsVisible() and GarrisonLandingPage.FollowerList.SearchBox

		if sb and nt then
			if IsAltKeyDown() and not self.isTrait then
				nt = "+" .. nt
			end
			if IsShiftKeyDown() then
				local ot = sb:GetText()
				if ot and ot ~= "" then
					nt = ot .. ";" .. nt
				end
			end
			sb:SetText(nt)
			sb.clearText = nt
		end
	end
	function CreateMechanicButton(parent)
		local f = CreateFrame("Button", nil, parent, "GarrisonAbilityCounterTemplate")
		f:SetNormalFontObject(GameFontHighlightOutline) f:SetText("0")
		f.Count = f:GetFontString()
		f.Count:ClearAllPoints() f.Count:SetPoint("BOTTOMRIGHT", 0, 2)
		f:SetFontString(f.Count)
		f:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
		f.Icon:SetAllPoints()
		f.Border:Hide()
		f:SetScript("OnClick", Mechanic_OnClick)
		f:SetScript("OnEnter", Mechanic_OnEnter)
		f:SetScript("OnLeave", HideOwnedGameTooltip)
		return f
	end
	function Mechanic_SetTrait(self, id, info)
		self.id, self.isTrait, self.info, self.name = id, true, info, C_Garrison.GetFollowerAbilityName(id)
		self.Icon:SetTexture(C_Garrison.GetFollowerAbilityIcon(id))
		local count = info and G.countFreeFollowers(info) or 0
		self.Count:SetText((count or 0) > 0 and count or "")
	end
	T.CreateMechanicButton, T.Mechanic_OnClick = CreateMechanicButton, Mechanic_OnClick
end

floatingMechanics:SetFrameStrata("DIALOG")
floatingMechanics:SetBackdrop({edgeFile="Interface/Tooltips/UI-Tooltip-Border", bgFile="Interface/DialogFrame/UI-DialogBox-Background-Dark", tile=true, edgeSize=16, tileSize=16, insets={left=4,right=4,bottom=4,top=4}})
floatingMechanics:SetBackdropBorderColor(1, 0.85, 0.6)
floatingMechanics.buttons = {}
function floatingMechanics:SetOwner(owner, info)
	self.owner, self.expire = owner
	self:SetPoint("TOPRIGHT", owner, "BOTTOMRIGHT", 16, -2)
	self:SetSize(10 + 27 * #info, 38)
	for i=1,#info do
		local ico, ci = self.buttons[i], info[i]
		if not ico then
			ico = CreateMechanicButton(self)
			ico:SetSize(24, 24)
			ico:SetPoint("LEFT", 27 * i - 21, 0)
			self.buttons[i] = ico
		end
		Mechanic_SetTrait(ico, ci.id, ci)
		ico:Show()
	end
	for i=#info+1, #self.buttons do
		self.buttons[i]:Hide()
	end
	self:Show()
end
floatingMechanics:SetScript("OnUpdate", function(self, elapsed)
	local isOver = self:IsMouseOver(0, -6, -10, 10) or (self.owner and self.owner:IsMouseOver(2,-8,-6,6))
	if isOver then
		self.expire = nil
	else
		self.expire = (self.expire or 0.35) - elapsed
		if self.expire < 0 then
			self:Hide()
			self.expire = nil
		end
	end
end)
floatingMechanics:Hide()
GameTooltip:HookScript("OnShow", function(self)
	local owner = self:GetOwner()
	if floatingMechanics:IsShown() and owner and (owner:IsForbidden() or owner:GetParent() ~= floatingMechanics) then
		floatingMechanics:Hide()
	end
end)

local icons = setmetatable({}, {__index=function(self, k)
	local f = CreateMechanicButton(mechanicsFrame)
	f:SetSize(24,24)
	f:SetPoint("LEFT", 27*k-20, 0)
	self[k] = f
	return f
end})
local traits, traitGroups = {221, 76, 77}, {
	{80, 236, 29, 79, 256, 314, icon="Interface\\Icons\\Trade_Archaeology_ChestOfTinyGlassAnimals"},
	{4,36,37,38,39,40,41,42,43, 7,8,9,44,45,46,48,49, icon="Interface\\Icons\\Ability_Hunter_MarkedForDeath"},
	{52,53,54,55,56,57,58,59,60,61,62,227,231, icon="Interface\\Icons\\Trade_Engineering"},
}
local function syncTotals()
	local finfo, cinfo, tinfo, i = G.GetFollowerInfo(), G.GetCounterInfo(), G.GetFollowerTraits(), 1
	for k=1,10 do
		local _, name, tex = G.GetMechanicInfo(k)
		if tex then
			local ico = icons[i]
			ico.Icon:SetTexture(tex)
			ico.Count:SetText(cinfo[k] and countFreeFollowers(cinfo[k], finfo) or "")
			ico:Show()
			ico.id, ico.name, ico.info, i, ico.isTrait = k, name, cinfo[k], i + 1
		end
	end
	for k=1,#traits do
		local ico, tid = icons[i], traits[k]
		Mechanic_SetTrait(ico, tid, tinfo[tid])
		i = i + 1
	end
	for k=1,#traitGroups do
		local ico, c, tg, m = icons[i], 0, traitGroups[k], {g=traitGroups[k]}
		for i=1,#tg do
			local tid = tg[i]
			local v = tinfo[tid] or {}
			m[#m+1], c, v.id, v.affine = v, c + countFreeFollowers(v, finfo), tid, v.affine or tg.affinities
		end
		ico.Icon:SetTexture(tg.icon or C_Garrison.GetFollowerAbilityIcon(tg[1]))
		ico.Count:SetText(c > 0 and c or "")
		ico.info, ico.isTraitGroup = m, true
		i = i + 1
	end

	local di, doubles, cc = G.GetDoubleCounters(), {}, 0
	for l=1,2 do
		for k,v in pairs(di) do
			if v.key == k and k > 0 and #v > 1 then
				if l == 1 then
					G.sortByFollowerLevels(v, finfo)
					if finfo[v[2]].status ~= GARRISON_FOLLOWER_INACTIVE then
						cc = cc + countFreeFollowers(v, finfo)
					end
				end
				for i=1,(finfo[v[2]].status == GARRISON_FOLLOWER_INACTIVE) == (l == 2) and #v or 0 do
					doubles[#doubles+1] = v[i]
				end
			end
		end
	end
	local ico = icons[i]
	ico.Icon:SetTexture("Interface\\Icons\\Inv_Misc_Book_11")
	ico.Count:SetText(cc and cc > 0 and cc or "")
	ico.info, ico.name, ico.isDouble = doubles, L"Duplicate counters", true
end
mechanicsFrame:SetScript("OnShow", syncTotals)
GarrisonMissionFrame.FollowerTab:HookScript("OnShow", function(self)
	mechanicsFrame:SetParent(self)
	mechanicsFrame:ClearAllPoints()
	mechanicsFrame:SetPoint("LEFT", self.NumFollowers, "RIGHT", 11, 0)
	mechanicsFrame:Show()
end)
GarrisonLandingPage.FollowerTab:HookScript("OnShow", function(self)
	mechanicsFrame:SetParent(self)
	mechanicsFrame:ClearAllPoints()
	mechanicsFrame:SetPoint("LEFT", GarrisonLandingPage.HeaderBar, "LEFT", 200, 0)
	mechanicsFrame:Show()
end)
hooksecurefunc(C_Garrison, "SetFollowerInactive", function()
	C_Timer.After(0.25, syncTotals)
	C_Timer.After(1, syncTotals)
end)
function EV:MP_RELEASE_CACHES()
	if not mechanicsFrame:IsVisible() then
		for i=1,#icons do
			icons[i].info = nil
		end
		for i=1,#floatingMechanics.buttons do
			floatingMechanics.buttons[i].info = nil
		end
	end
end

local UpgradesFrame = CreateFrame("FRAME")
UpgradesFrame:SetSize(237, 42)
UpgradesFrame:SetBackdrop({edgeFile="Interface/Tooltips/UI-Tooltip-Border", bgFile="Interface/DialogFrame/UI-DialogBox-Background-Dark", tile=true, edgeSize=16, tileSize=16, insets={left=4,right=4,bottom=4,top=4}})
UpgradesFrame:SetBackdropBorderColor(0.15, 1, 0.25)
UpgradesFrame:Hide()
UpgradesFrame:SetScript("OnHide", function(self)
	local so = self.owner
	self:Hide()
	self.owner, self.followerID = nil
	if so and so.Sync then
		so:Sync()
	end
end)
UpgradesFrame:SetScript("OnUpdate", function(self, elapsed)
	local isOver = self.owner:IsMouseOver(4,-4,-4,4) or self:IsMouseOver(4,-4,-4,4)
	if not isOver and (self.insetTop or 0) > 0 then
		isOver = self:IsMouseOver(self.insetTop+4,-4,-4,4)
	else
		self.insetTop = 0
	end
	
	if isOver then
		self.elapsed = 0
	else
		self.elapsed = self.elapsed + elapsed
		if self.elapsed > 0.5 then
			self:Hide()
		end
	end
end)
function EV:PLAYER_REGEN_DISABLED()
	UpgradesFrame:Hide()
	UpgradesFrame:SetParent(nil)
	UpgradesFrame:ClearAllPoints()
end
function EV:BAG_UPDATE_DELAYED()
	if UpgradesFrame:IsVisible() then
		UpgradesFrame:Update(true)
	end
end

local function UpgradeItem_SetItem(self, id)
	self.itemID = id
	local count, itemName, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemCount(id), GetItemInfo(id)
	if itemName then
		self.Icon:SetTexture(itemTexture)
		self.Name:SetText(itemName)
		self.Count:SetText(count > 1 and count or "")
		self.Name:SetTextColor(GetItemQualityColor(itemQuality))
		self.ItemLevel:SetFormattedText("")
	end
	self:SetAttribute("macrotext", SLASH_STOPSPELLTARGET1 .. "\n" .. SLASH_USE1 .. " item:" .. id)
	self:Show()
end
local function UpgradeItem_OnClick()
	C_Garrison.CastSpellOnFollower(UpgradesFrame.followerID)
end
local function CreateFollowerItemHighlight(b)
	local t1, t2, t3, t4 = b:CreateTexture(nil, "HIGHLIGHT"), b:CreateTexture(nil, "HIGHLIGHT"), b:CreateTexture(nil, "HIGHLIGHT"), b:CreateTexture(nil, "HIGHLIGHT")
	t1:SetTexture("Interface\\Buttons\\UI-SilverButtonLG-Left-Hi")
	t1:SetSize(32, 63)
	t1:SetPoint("TOPLEFT", 43, 2)
	t3:SetTexture("Interface\\Buttons\\UI-SilverButtonLG-Right-Hi")
	t3:SetSize(32, 63)
	t3:SetPoint("TOPRIGHT", 1, 2)
	t2:SetTexture("Interface\\Buttons\\UI-SilverButtonLG-Mid-Hi")
	t2:SetHeight(63)
	t2:SetPoint("LEFT", t1, "RIGHT")
	t2:SetPoint("RIGHT", t3, "LEFT")
	t4:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
	t4:SetBlendMode("ADD")
	t4:SetAllPoints(b.Icon)
	return {t1, t2, t3, t4}
end
local function UpgradeItem_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 0, -32)
	GameTooltip:SetItemByID(self.itemID)
	GameTooltip:Show()
end
local function UpgradeItem_OnEvent(self)
	if self:IsVisible() and self.itemID then
		UpgradeItem_SetItem(self, self.itemID)
	end
end
local upgradeItems = setmetatable({}, {__index=function(self, i)
	local b = CreateFrame("Button", nil, UpgradesFrame, "GarrisonFollowerItemButtonTemplate,SecureActionButtonTemplate")
	b.Count = b:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
	b.Count:SetPoint("BOTTOMRIGHT", b.Icon, "BOTTOMRIGHT", -1, 2)
	b:SetAttribute("type", "macro")
	b:SetPoint("BOTTOM", i > 1 and self[i-1] or UpgradesFrame, i > 1 and "TOP" or "BOTTOM", 0, i > 1 and 4 or 6)
	b:SetScript("OnEnter", UpgradeItem_OnEnter)
	b:SetScript("OnLeave", GameTooltip_Hide)
	b:SetScript("OnEvent", UpgradeItem_OnEvent)
	b:HookScript("OnClick", UpgradeItem_OnClick)
	CreateFollowerItemHighlight(b)
	b.Name:SetFontObject(GameFontNormal)
	b.Name:SetHeight(0)
	self[i] = b
	return b
end})
local function setUpgradeItems(i, a, ...)
	if a then
		UpgradeItem_SetItem(upgradeItems[i], a)
		return setUpgradeItems(i+1, ...)
	end
	return i-1
end
function UpgradesFrame:Update(liveUpdate)
	local c = setUpgradeItems(1, G.GetUpgradeItems(self.itemLevel, self.isWeapon))
	if c == 0 then
		return self:Hide()
	end
	for i=c+1,#upgradeItems do
		upgradeItems[i]:Hide()
	end
	local oh, nh = liveUpdate and self:GetHeight(), 8+46*c
	self:SetHeight(nh)
	self.insetTop = oh and max(0, oh-nh, self.insetTop or 0) or 0
end
function UpgradesFrame:DisplayFor(owner, itemLevel, isWeapon, followerID)
	if InCombatLockdown() then return end
	self:SetParent(owner)
	self.owner, self.itemLevel, self.isWeapon, self.followerID, self.insetTop = owner, itemLevel, isWeapon, followerID, 0
	self:SetPoint("BOTTOM", owner, "TOP", 0, 0)
	self:Show()
	UpgradesFrame:Update(false)
end
function UpgradesFrame:CheckUpdate(id, wil, ail)
	if self:IsShown() and self.followerID == id then
		self.itemLevel = self.isWeapon and wil or ail
		self:Update(true)
	end
end


hooksecurefunc("GarrisonFollowerPage_SetItem", function(self)
	local self = self:GetParent()
	self.ItemWeapon:Hide()
	self.ItemArmor:Hide()
	self.ItemAverageLevel:Hide()
end)
local CreateClassSpecButton, ClassSpecButton_Set do
	local function ClassSpecButton_OnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		if G.SetClassSpecTooltip(GameTooltip, self.follower) then
			GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")
			GameTooltip:Show()
		end
	end
	function CreateClassSpecButton(parent)
		local f = CreateFrame("Button", nil, parent)
		f:SetSize(38, 38)
		f.Icon = f:CreateTexture()
		f.Icon:SetAllPoints()
		f:SetScript("OnEnter", ClassSpecButton_OnEnter)
		f:SetScript("OnLeave", HideOwnedGameTooltip)
		return f
	end
	function ClassSpecButton_Set(self, info)
		self.Icon:SetToFileData(T.SpecIcons[info and info.classSpec])
		self.follower = info
	end
end
function EV:FXUI_GARRISON_FOLLOWER_LIST_SHOW_FOLLOWER(tab, followerID)
	local et, ab, at, ct, _hasMissions = T.EquivTrait,  tab.AbilitiesFrame.Abilities, G.GetFollowerRerollConstraints(followerID)
	for i=1, #ab do
		local button = ab[i]
		local abid, isFree = button.IconButton.abilityID
		if not (abid and abid > 0 and ct and at) then
			if abid and abid > 0 then
				button.Name:SetText(C_Garrison.GetFollowerAbilityName(abid))
			end
			button.IconButton.ValidSpellHighlight:SetVertexColor(1,1,1)
		else
			if C_Garrison.GetFollowerAbilityIsTrait(abid) then
				isFree = ct[et[abid] or abid]
			else
				isFree = at[C_Garrison.GetFollowerAbilityCounterMechanicInfo(abid)]
			end
			if not isFree then
				button.Name:SetText([[|TInterface\PetBattles\PetBattle-LockIcon:11:10:-2:1:32:32:4:28:2:30:255:120:100|t]]..C_Garrison.GetFollowerAbilityName(abid))
				button.IconButton.ValidSpellHighlight:SetVertexColor(1,0.8,0.8)
			elseif T.LockTraits[et[abid] or abid] then
				button.Name:SetText([[|TInterface\PetBattles\PetBattle-LockIcon:11:10:-2:1:32:32:4:28:2:30:220:220:160|t]]..C_Garrison.GetFollowerAbilityName(abid))
				button.IconButton.ValidSpellHighlight:SetVertexColor(1,1,1)
			else
				button.Name:SetText([[|TInterface\Buttons\UI-RefreshButton:10:10:-2:2:16:16:16:0:16:0:120:255:0|t]]..C_Garrison.GetFollowerAbilityName(abid))
				button.IconButton.ValidSpellHighlight:SetVertexColor(1,1,0)
			end
		end
	end
end
hooksecurefunc(GarrisonShipyardFrameFollowers, "UpdateValidSpellHighlight", function(self, followerID, followerInfo, _hideCounters)
	local idx, et, cc, ct = 1, T.EquivTrait, G.GetFollowerRerollConstraints(followerID)
	for i=1, #followerInfo.abilities do
		local ability = followerInfo.abilities[i]
		if not ability.isTrait then
			local highlight = self.followerTab.EquipmentFrame.Equipment[idx].ValidSpellHighlight
			if highlight:IsShown() then
				local cof = C_Garrison.GetFollowerAbilityCounterMechanicInfo(ability.id)
				if ct and (cof and cc[cof] or not cof and ct[et[ability.id] or ability.id]) then
					highlight:SetVertexColor(1,1,0)
				elseif ct then
					highlight:SetVertexColor(1,0.8,0.8)
				else
					highlight:SetVertexColor(1,1,1)
				end
			end
			idx = idx + 1
		end
	end
end)

local SpecAffinityFrame = CreateFrame("Frame") do
	SpecAffinityFrame:SetSize(80, 42)
	SpecAffinityFrame.ClassSpec = CreateClassSpecButton(SpecAffinityFrame) do
		local f = SpecAffinityFrame.ClassSpec
		f:SetSize(40, 40)
		f:SetPoint("RIGHT", 0, 0)
	end
	SpecAffinityFrame.Affinity = CreateMechanicButton(SpecAffinityFrame) do
		SpecAffinityFrame.Affinity:SetSize(40, 40)
		SpecAffinityFrame.Affinity:SetPoint("RIGHT", -44, 0)
		SpecAffinityFrame.Affinity.hideInactive = true
	end
	SpecAffinityFrame.Missions = CreateFrame("Button", nil, SpecAffinityFrame) do
		local f = SpecAffinityFrame.Missions
		f:SetSize(40, 40)
		f:SetPoint("RIGHT", SpecAffinityFrame, "LEFT", -4, 0)
		f:Hide()
		local function GetMoIRewardIcon(rid)
			if rid == 0 then
				return "|TInterface\\Icons\\INV_Misc_Coin_01:14:14:0:0:64:64:4:60:4:60|t"
			elseif rid < 2000 then
				return "|T" .. (select(3,GetCurrencyInfo(rid)) or "Interface/Icons/Temp") .. ":14:14:0:0:64:64:4:60:4:60|t"
			else
				return "|T" .. (GetItemIcon(rid) or "Interface/Icons/Temp") .. ":14:14:0:0:64:64:4:60:4:60|t"
			end
			return ""
		end
		f:SetScript("OnEnter", function(self)
			local fid = self.followerID
			local groups = G.GetBestGroupInfo(1, C_Garrison.GetFollowerStatus(fid) == GARRISON_FOLLOWER_INACTIVE, false)
			if not (groups and fid) then
				self:Hide()
				return
			end
			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")
			local used = false
			for i, mi, b in G.MoIMissions(1, groups) do
				local mid = mi[1]
				local idx = b and (b[1] == fid and 1 or b[2] == fid and 2 or b[3] == fid and 3)
				if idx and b.used and G.IsInterestedInMoI(mi) and b.used % (2^idx) >= 2^(idx-1) then
					if not used then
						GameTooltip:SetText(L"Missions of Interest")
						GameTooltip:AddLine((L"%s is required by the following Missions of Interest."):format(C_Garrison.GetFollowerName(fid)), 1,1,1, 1)
						GameTooltip:AddLine(" ")
						used = true
					end
					GameTooltip:AddDoubleLine(GetMoIRewardIcon(mi.s[4]) .. " " .. (C_Garrison.GetMissionName(mid) or mid or "?"), b[5] .. "%", 1,1,1)
				end
			end
			if used then
				local et, lt, hasUnboundTraits, cc, ct = T.EquivTrait, T.LockTraits, false, G.GetFollowerRerollConstraints(fid)
				GameTooltip:AddLine(" ")
				for i=1,3 do
					local a = C_Garrison.GetFollowerTraitAtIndex(fid, i)
					local m = et[a] or a
					if m and m > 0 and ct[m] and not lt[a] then
						if not hasUnboundTraits then
							GameTooltip:AddLine(L"You may replace these traits:")
						end
						GameTooltip:AddLine("|T" .. C_Garrison.GetFollowerAbilityIcon(a) .. ":0|t " .. C_Garrison.GetFollowerAbilityName(a), 1,1,1)
						hasUnboundTraits = true
					end
				end
				if not hasUnboundTraits then
					GameTooltip:AddLine(L"All current traits are required.")
				end
				local nc = 0
				for k in pairs(cc) do nc = nc + 1 end
				if nc == (C_Garrison.GetFollowerQuality(fid) > 3 and 2 or 1) then
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine(L"Abilities may be retrained.")
				end
			else
				GameTooltip:SetText(L"Redundant")
				GameTooltip:AddLine((L"%s is not required by any Missions of Interest."):format(C_Garrison.GetFollowerName(fid)), 1,1,1, 1)
			end
			GameTooltip:Show()
		end)
		f:SetScript("OnLeave", HideOwnedGameTooltip)
	end
	function SpecAffinityFrame:ShowFor(owner, fi)
		self:SetParent(owner)
		self:SetPoint("TOPRIGHT", -18 + (owner.MPSpecOffsetX or 0), -8 + (owner.MPSpecOffsetY or 0))
		local afid = T.Affinities[fi.garrFollowerID or fi.followerID] or 0
		if afid > 0 then
			Mechanic_SetTrait(self.Affinity, afid)
		end
		self.Affinity:SetShown(afid > 0)
		self:SetWidth(afid > 0 and 84 or 40)
		ClassSpecButton_Set(self.ClassSpec, fi)
		owner.XPText:SetPoint("TOPRIGHT", self, "TOPLEFT", -4, -4)
		if owner.Class then
			owner.Class:SetAlpha(0)
		end
		local best = fi.isCollected and fi.level == 100 and fi.quality >= 4 and G.GetBestGroupInfo(1, fi.status == GARRISON_FOLLOWER_INACTIVE, false)
		if best then
			local fid = fi.followerID
			local f, r = UnitFactionGroup("player") == "Horde" and "Interface/Icons/Achievement_pvp_h_" or "Interface/Icons/Achievement_pvp_a_", "01"
			for _, mi, b in G.MoIMissions(fi.followerTypeID, best) do
				local idx = b[1] == fid and 1 or b[2] == fid and 2 or b[3] == fid and 3
				if idx and b.used and G.IsInterestedInMoI(mi) and b.used % (2^idx) >= 2^(idx-1) then
					r="10"
					break
				end
			end
			self.Missions.followerID = fid
			self.Missions:SetNormalTexture(f .. r)
			self.Missions:Show()
		else
			self.Missions:Hide()
		end
	end
end
GarrisonMissionFrame.FollowerTab.AbilitiesFrame.Counters[1]:SetScript("OnEnter", GarrisonMissionMechanic_OnEnter)
GarrisonMissionFrame.FollowerTab.AbilitiesFrame.Counters[1]:SetScript("OnLeave", function()
	GarrisonMissionMechanicTooltip:Hide()
end)

local function ShowPotentialAbilityTooltip(owner, classSpec, dropCounter, altTitle)
	GameTooltip:SetOwner(owner, "ANCHOR_NONE")
	return G.SetClassSpecTooltip(GameTooltip, classSpec, altTitle, dropCounter)
end
local function RecruitAbility_OnEnter(self)
	if self.abilityID == -1 then
		local cs, other, p = self.classSpec, self.otherCounter, self:GetParent()
		if p and not cs then cs, other = p.classSpec, p.otherCounter end
		if cs and ShowPotentialAbilityTooltip(self, cs, other) then
			GameTooltip:SetPoint("TOPLEFT", self.Icon, "BOTTOMRIGHT")
			GameTooltip:Show()
		end
	elseif self.abilityID and self.abilityID > 0 then
		GarrisonFollowerAbilityTooltip:ClearAllPoints()
		GarrisonFollowerAbilityTooltip:SetPoint("TOPLEFT", self.Icon, "BOTTOMRIGHT")
		GarrisonFollowerAbilityTooltip_Show(self.abilityID)
	end
end
local function RecruitAbility_OnLeave(self)
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	else
		GarrisonFollowerAbilityTooltip:Hide()
	end
end
for i=1,3 do
	local f = GarrisonRecruitSelectFrame.FollowerSelection["Recruit" .. i]
	f.MPClass = CreateClassSpecButton(f)
	f.MPClass:SetSize(20, 20)
	f.MPClass:SetPoint("TOPRIGHT", -4, 4)
	f.Affinity = CreateMechanicButton(f)
	f.Affinity:SetPoint("TOPRIGHT", -28, 4)
end
hooksecurefunc("GarrisonRecruitSelectFrame_UpdateRecruits", function(waiting)
	if not waiting then
		local followers, rf, tinfo = C_Garrison.GetAvailableRecruits(), GarrisonRecruitSelectFrame.FollowerSelection, G.GetFollowerTraits()
		for i=1,3 do
			local f, ff = followers[i], rf["Recruit" .. i]
			local afid, ico = T.Affinities[f.followerID], ff.Affinity
			if afid and afid > 0 then
				Mechanic_SetTrait(ico, afid, tinfo[afid])
				ico:Show()
			else
				ico:Hide()
			end
			ClassSpecButton_Set(ff.MPClass, f)
		end
	end
end)
hooksecurefunc("GarrisonMissionFrame_SetFollowerPortrait", function(port, fi)
	if not (port == GarrisonMissionFrame.FollowerTab.PortraitFrame or port == GarrisonLandingPage.FollowerTab.PortraitFrame) then
		return
	end
	local p = port:GetParent()
	if fi and fi.classSpec and port == GarrisonMissionFrame.FollowerTab.PortraitFrame then
		local c, hadAbilities = T.SpecCounters[fi.classSpec], fi.abilities
		if c then
			fi.abilities = fi.abilities or C_Garrison.GetFollowerAbilities(fi.followerID)
			local na, oi = 0
			for i=1,#fi.abilities do
				local a = fi.abilities[i]
				if not a.isTrait then
					oi, na = oi or i, na + 1
				end
			end

			local other = oi and C_Garrison.GetFollowerAbilityCounterMechanicInfo(fi.abilities[oi].id)
			if p then
				p.classSpec, p.otherCounter = fi.classSpec, other
			end
			
			if na < 2 and not hadAbilities then
				local at = {name=L"Epic Ability", description=L"An additional random ability is unlocked when this follower reaches epic quality.", id=-1, spec=fi.classSpec, other=other, isTrait=false, icon="Interface\\Icons\\INV_Misc_QuestionMark", counters={}}
				for i=1,#c do
					if c[i] == other then
						other = nil
					elseif not at.counters[c[i]] then
						local _, name, icon, desc = G.GetMechanicInfo(c[i])
						at.counters[c[i]] = {icon=icon, name=name, description=desc, factor=300}
					end
				end
				table.insert(fi.abilities, at)
			end
		end
	end
	if p and p.Class and p:GetParent():IsVisible() then
		port.info = fi
		SpecAffinityFrame:ShowFor(p, fi)
	end
end)
local function Portrait_OnShow(self)
	if self:GetParent():IsVisible() and self.info and SpecAffinityFrame:GetParent() ~= self then
		SpecAffinityFrame:ShowFor(self:GetParent(), self.info)
	end
end
GarrisonMissionFrame.FollowerTab.MPSpecOffsetX, GarrisonMissionFrame.FollowerTab.MPSpecOffsetY = 5, -6
GarrisonLandingPage.FollowerTab.MPSpecOffsetX, GarrisonLandingPage.FollowerTab.MPSpecOffsetY = -2, -4
GarrisonMissionFrame.FollowerTab.PortraitFrame:HookScript("OnShow", Portrait_OnShow)
GarrisonLandingPage.FollowerTab.PortraitFrame:HookScript("OnShow", Portrait_OnShow)
local function FollowerPageAbility_OnEnter(self)
	local ppp = self:GetParent():GetParent():GetParent()
	self.classSpec, self.otherCounter = ppp.classSpec, ppp.otherCounter
	return RecruitAbility_OnEnter(self)
end
function EV:FXUI_GARRISON_FOLLOWER_LIST_SHOW_FOLLOWER(followerTab)
	local af = followerTab.AbilitiesFrame.Abilities
	for i=1,#af do
		af[i].IconButton:SetScript("OnEnter", FollowerPageAbility_OnEnter)
		af[i].IconButton:SetScript("OnLeave", RecruitAbility_OnLeave)
	end
end

GarrisonThreatCountersFrame:SetScript("OnShow", GarrisonThreatCountersFrame.Hide)

local function Recruiter_ShowTraitTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	G.SetTraitTooltip(GameTooltip, self.value)
	GameTooltip:Show()
end
local function Recruiter_ShowCounterTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	G.SetThreatTooltip(GameTooltip, self.value)
	GameTooltip:Show()
end
hooksecurefunc("GarrisonRecruiterFrame_Init", function(_, level)
	local lf, bn
	if level == 2 then
		lf, bn = DropDownList2, "DropDownList2Button"
	elseif level == 1 and #GarrisonRecruiterFrame.Pick.entries > 0 then
		lf, bn = DropDownList1, "DropDownList1Button"
	end
	for i=1,lf and lf.numButtons or 0 do
		local b = _G[bn .. i]
		local entry = b.arg1
		if type(entry) == "table" and entry.id then
			b.tooltipOnButton, b.tooltipTitle, b.tooltipText = level == 2 and Recruiter_ShowTraitTooltip or Recruiter_ShowCounterTooltip
		end
	end
end)

local GarrisonFollowerList_SortFollowers = GarrisonFollowerList_SortFollowers
local specialSearchQueries = {["duplicate counters"]="dup", [(L"Duplicate counters"):lower()]="dup", ["upgradable gear"]="up", [(L"Upgradable gear"):lower()]="up", ["redundant"]="red", [(L"Redundant"):lower()]="red"}
function _G.GarrisonFollowerList_SortFollowers(followerList)
	local searchString = followerList.SearchBox and followerList.SearchBox:GetText() or ""
	local ws = followerList.SearchBox and followerList.SearchBox.MPWarning
	if ws then
		ws:Hide()
	elseif followerList.SearchBox then
		ws = followerList.SearchBox:CreateFontString(nil, "OVERLAY", "GameFontRed")
		ws:SetWidth(250)
		ws:SetPoint("TOP", 0, -100)
		followerList.SearchBox.MPWarning = ws
	end
	
	if searchString:match("/") and searchString:match("[^%s/]") then
		local showUncollected, list, s = followerList.showUncollected, followerList.followersList, {}
		for qs in searchString:gmatch("[^/]+") do
			s[#s+1] = qs
		end
		wipe(list)
		for i=1, #followerList.followers do
			local fi = followerList.followers[i]
			if showUncollected or fi.isCollected then
				for j=1,#s do
					if C_Garrison.SearchForFollower(fi.followerID, s[j]) then
						list[#list+1] = i
						break
					end
				end
			end
		end
	elseif (searchString:match("[!;+]") and searchString:match("[^%s;+!]")) or specialSearchQueries[searchString:lower()] then
		local showUncollected, list, q, ns, s = followerList.showUncollected, followerList.followersList, {}, {}
		local filterADup, filterIDup, filterRed, dupSet, filterUp, upW, upA, redFollowers, badQuery
		
		for qs in searchString:gmatch("[^;]+") do
			local neg, pl, qs = qs:match("^%s*(!?)(%+?)%s*(.-)%s*$")
			local ql = qs:lower()
			local sq = specialSearchQueries[ql]
			if (qs or "") == "" then
			elseif sq == "dup" then
				if pl ~= "+" then
					filterADup, badQuery = neg == "!", badQuery or (filterADup == (neg ~= "!"))
				else
					filterIDup, badQuery = neg == "!", badQuery or (filterIDup == (neg ~= "!"))
				end
			elseif sq == "up" then
				filterUp, showUncollected, badQuery = neg == "", false, badQuery or (filterUp == (neg ~= ""))
			elseif sq == "red" then
				filterRed, showUncollected, badQuery = neg == "", false, badQuery or (filterRed == (neg ~= ""))
			elseif pl == "+" then
				s = s or {}
				s[#s+1] = ql:gsub("[-%%%[%]().+*?]", "%%%0")
				s[-#s], ns[-#s] = qs, neg == "!"
			else
				q[#q+1], ns[#q+1] = ql, neg == "!"
			end
		end
		local hasDupFilter = filterADup ~= nil or filterIDup ~= nil
		
		if badQuery then
			wipe(list)
		elseif hasDupFilter or filterUp ~= nil or filterRed ~= nil or #q > 1 or ns[1] or (s and #s > 0) then
			local nf, ni = #followerList.followers, 1
			wipe(list)
			for i=1,nf do
				local f = followerList.followers[i]
				local id, ok, spec = f.followerID, showUncollected or f.isCollected, T.SpecCounters[f.classSpec]
				for j=1,ok and #q or 0 do
					if (not C_Garrison.SearchForFollower(id, q[j])) ~= ns[j] then
						ok = false
						break
					end
				end
				if ok and (filterUp ~= nil) then
					if not upA then
						upW, upA = G.GetUpgradeRange()
					end
					if f.level < 100 then
						ok = false
					else
						local _weaponItemID, weaponItemLevel, _armorItemID, armorItemLevel = C_Garrison.GetFollowerItems(f.followerID)
						ok = (weaponItemLevel < upW or armorItemLevel < upA) == filterUp
					end
				end
				for i=1,s and ok and #s or 0 do
					local ok2, qm = false, s[i]
					for j=1,#spec do
						local _, n, _, d = G.GetMechanicInfo(spec[j] or 10)
						if n:lower():match(qm) or d:lower():match(qm) then
							ok2 = true
							break
						end
					end
					if (not (ok2 or C_Garrison.SearchForFollower(id, s[-i]))) ~= ns[-i] then
						ok = false
						break
					end
				end
				if ok and hasDupFilter then
					if not dupSet then
						dupSet = {}
						for j=(filterIDup ~= nil) and 1 or 2, (filterADup ~= nil) and 2 or 1 do
							for k,v in pairs(G.GetDoubleCounters(j > 1)) do
								if k > 0 and #v > 1 then
									for i=1,#v do
										dupSet[v[i]] = j
									end
								end
							end
						end
					end
					local ds = dupSet[id]
					ok = (filterIDup == nil or filterIDup == (ds == nil)) and
					     (filterADup == nil or filterADup == (ds ~= 2))
				end
				if ok and filterRed ~= nil then
					if redFollowers == nil then
						redFollowers = false
						local groups = G.GetBestGroupInfo(f.followerTypeID, false, false)
						if groups then
							redFollowers = {}
							for _, mi, b in G.MoIMissions(f.followerTypeID, groups) do
								if b and G.IsInterestedInMoI(mi) then
									local muf = b and b.used
									for j=1, muf and mi.s[2] or 0 do
										if muf % (2^j) >= 2^(j-1) then
											redFollowers[b[j]] = mi[1]
										end
									end
								end
							end
						else
							ws:Show()
							ws:SetText((L"Redundant followers not known.\nOpen the %s tab."):format("|cffffffff" .. L"Missions of Interest" .. "|r"))
						end
					end
					ok = redFollowers and f.status ~= GARRISON_FOLLOWER_INACTIVE and ((not redFollowers[id]) == filterRed) or false
				end
				if ok then
					list[ni], ni = i, ni + 1
				end
			end
		end
	end
	
	return GarrisonFollowerList_SortFollowers(followerList)
end
GarrisonMissionFrameFollowers.SearchBox:SetMaxLetters(0)
GarrisonLandingPage.FollowerList.SearchBox:SetMaxLetters(0)

do -- Weapon/Armor upgrades and rerolls
	GarrisonMissionFrame.FollowerTab.MPItemsOffsetY = 82
	GarrisonMissionFrame.FollowerTab.MPSideItemsOffsetY = -18
	GarrisonLandingPage.FollowerTab.MPItemsOffsetX = -4
	GarrisonLandingPage.FollowerTab.MPItemsOffsetY = 62
	GarrisonLandingPage.FollowerTab.MPSideItemsOffsetY = -8
	GarrisonLandingPage.FollowerTab.Model.UpgradeFrame:ClearAllPoints()
	
	local items, gear, reroll = CreateFrame("Frame", "MPFollowerItemContainer") do
		items:SetSize(1, 24)
		gear = CreateFrame("Frame", nil, items) do
			gear:SetPoint("TOP")
			gear:SetSize(218, 24)
			items.averageGearLevel = gear:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
			items.averageGearLevel:SetPoint("CENTER")
			local function OnClick(self)
				local isWeapon = self == items.weapon
				if UpgradesFrame:IsShown() and UpgradesFrame.owner == gear and UpgradesFrame.isWeapon == isWeapon then
					UpgradesFrame:Hide()
				else
					UpgradesFrame:DisplayFor(gear, self.itemLevel, isWeapon, items.followerID)
				end
			end
			local function OnEnter(self)
				GameTooltip:SetOwner(self, "ANCHOR_NONE")
				GameTooltip:SetPoint("TOP", gear, "BOTTOM")
				GameTooltip:SetText(GARRISON_FOLLOWER_ITEMS)
				GameTooltip:AddLine(GARRISON_FOLLOWER_ITEMS_TOOLTIP, 1,1,1, 1)
				if self.IsEnabled and self:IsEnabled() then
					GameTooltip:AddLine(L"Click to view upgrade options")
				end
				GameTooltip:Show()
			end
			gear:SetScript("OnEnter", OnEnter)
			gear:SetScript("OnLeave", HideOwnedGameTooltip)
			for i=1,2 do
				local b = CreateFrame("Button", nil, gear)
				b:SetSize(62, 24)
				b:SetNormalFontObject(GameFontHighlightMedium)
				b:SetDisabledFontObject(GameFontDisableMed3)
				b:SetNormalTexture("Interface/Icons/Temp")
				b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
				b:GetNormalTexture():ClearAllPoints()
				b:GetNormalTexture():SetSize(24,24)
				b:GetHighlightTexture():SetAllPoints(b:GetNormalTexture())
				b:SetText("!")
				b:GetFontString():ClearAllPoints()
				b:SetScript("OnClick", OnClick)
				b:SetScript("OnLeave", HideOwnedGameTooltip)
				b:SetScript("OnEnter", OnEnter)
				b:SetMotionScriptsWhileDisabled(true)
				b:SetPushedTextOffset(0, 2)
				items[i == 1 and "weapon" or "armor"] = b
			end
			items.weapon:SetPoint("RIGHT", gear, "CENTER", -47, 0)
			items.armor:SetPoint("LEFT", gear, "CENTER", 47, 0)
			items.weapon:GetNormalTexture():SetPoint("RIGHT")
			items.armor:GetNormalTexture():SetPoint("LEFT")
			items.weapon:GetFontString():SetPoint("RIGHT", -28, 0)
			items.armor:GetFontString():SetPoint("LEFT", 28, 0)
			function gear:Sync()
				local id = items.followerID
				local wid, wil, aid, ail = C_Garrison.GetFollowerItems(id)
				local avail = C_Garrison.GetFollowerStatus(id) ~= GARRISON_FOLLOWER_ON_MISSION
				local canWeapon, canArmor = avail and not not G.GetUpgradeItems(wil, true), avail and not not G.GetUpgradeItems(ail, false)
				items.weapon.itemLevel, items.armor.itemLevel = wil, ail
				items.weapon:SetNormalTexture(GetItemIcon(wid))
				items.armor:SetNormalTexture(GetItemIcon(aid))
				items.weapon:SetText(wil)
				items.armor:SetText(ail)
				items.weapon:SetEnabled(canWeapon)
				items.armor:SetEnabled(canArmor)
				items.averageGearLevel:SetFormattedText(GARRISON_FOLLOWER_ITEM_LEVEL, (wil+ail)/2)
				if UpgradesFrame.followerID == id then
					UpgradesFrame:CheckUpdate(id, wil, ail)
				elseif UpgradesFrame:IsShown() then
					UpgradesFrame:Hide()
				end
			end
		end
		reroll = CreateFrame("Frame", nil, items) do
			reroll:SetPoint("TOP", items, "BOTTOM", 0, -2)
			reroll:SetHeight(24)
			local function TargetFollower()
				if SpellCanTargetGarrisonFollower() then
					GarrisonFollower_DisplayUpgradeConfirmation(items.followerID)
				end
			end
			local buttons = {}
			for i in ("122274 122273 122272 118354 118475 118474 122275 122584 122580 122582 122583 128314"):gmatch("%d+") do
				local b = T.CreateLazyItemButton(reroll, tonumber(i))
				b:SetSize(24, 24)
				b.real:SetScript("PostClick", TargetFollower)
				buttons[#buttons+1] = b
			end
			function reroll:Sync()
				local x = 0
				for i=1,#buttons do
					local b = buttons[i]
					if GetItemCount(b.itemID) > 0 then
						b:SetPoint("LEFT", x, 0)
						b:Show()
						x = x + 28
					else
						b:Hide()
					end
				end
				self:SetWidth(x > 0 and x - 4 or 0)
			end
		end
	end
	local function updateTabView(_event, tab, id)
		if not tab:IsVisible() or not tab.MPItemsOffsetY then
			return
		elseif type(id) ~= "string" then
			items:Hide()
			return
		end
		items.followerID = id
		if C_Garrison.GetFollowerLevel(id) < 100 then
			gear:Hide()
			UpgradesFrame:Hide()
		else
			gear:Sync()
			gear:Show()
		end
		reroll:SetPoint("TOP", items, "BOTTOM", 0, tab.MPSideItemsOffsetY or -2)
		reroll:Sync()
		items:SetParent(tab)
		items:SetPoint("BOTTOM", tab, "BOTTOMLEFT", 156 + (tab.MPItemsOffsetX or 0), tab.MPItemsOffsetY)
		items:Show()
	end
	EV.FXUI_GARRISON_FOLLOWER_LIST_SHOW_FOLLOWER = updateTabView
end

do -- XP Projections for follower summaries
	local function updateBar(bar)
		local tab, baseBar, bonusBar = bar:GetParent(), bar.XPBaseReward, bar.XPBonusReward
		local fid = tab.followerID
		if fid and type(fid) == "string" and C_Garrison.GetFollowerStatus(fid) == GARRISON_FOLLOWER_ON_MISSION then
			for k,v in pairs(C_Garrison.GetInProgressMissions(C_Garrison.GetFollowerTypeByID(fid))) do
				local ft = v.followers
				if ft[1] == fid or ft[2] == fid or ft[3] == fid then
					local fi = G.GetFollowerInfo()[fid]
					local bmul, base, extraXP, bonus, mentor = G.ExtendMissionInfoWithXPRewardData(v)
					local base, bonus = G.GetFollowerXPGain(fi, G.GetFMLevel(v), extraXP + base, bonus * bmul, mentor)
					local toLevel, wmul = fi.levelXP - fi.xp, bar.length/fi.levelXP
					if v.state ~= -1 then
						base, bonus = bonus, 0
					elseif v.successChance == 100 then
						base, bonus = base + bonus, 0
					end
		
					local baseWidth = min(toLevel, base)*wmul
					local bonusWidth = min(toLevel-base, bonus)*wmul
					baseBar:SetPoint("LEFT", fi.xp * wmul, 0)
					bonusBar:SetPoint("LEFT", (fi.xp + base) * wmul, 0)
					baseBar:SetWidth(max(0.01, baseWidth))
					bonusBar:SetWidth(max(0.01, bonusWidth))
					baseBar:SetShown(baseWidth > 0)
					bonusBar:SetShown(bonusWidth > 0)
		
					if not tab.XPText then
					elseif base >= toLevel then
						tab.XPText:SetTextColor(0.6, 1, 0)
					elseif (base + bonus) >= toLevel then
						tab.XPText:SetTextColor(0, 0.75, 1)
					else
						tab.XPText:SetTextColor(1,1,1)
					end
					break
				end
			end
		else
			tab.XPText:SetTextColor(1,1,1)
			baseBar:Hide()
			bonusBar:Hide()
		end
	end
	for i=1,4 do
		local bar = i == 4 and GarrisonLandingPage.ShipFollowerTab.XPBar or (i == 1 and GarrisonMissionFrame or i == 2 and GarrisonLandingPage or GarrisonShipyardFrame).FollowerTab.XPBar
		local baseBar, curBar = bar:CreateTexture(nil, "BACKGROUND", nil, 1), bar:GetStatusBarTexture()
		baseBar:SetTexture(curBar:GetTexture())
		baseBar:SetHeight(curBar:GetHeight())
		baseBar:SetWidth(50)
		baseBar:SetVertexColor(0.6, 1, 0)
		local bonusBar = bar:CreateTexture(nil, "BACKGROUND", nil, 1)
		bonusBar:SetTexture(curBar:GetTexture())
		bonusBar:SetHeight(curBar:GetHeight())
		bonusBar:SetWidth(100)
		bonusBar:SetVertexColor(0, 0.75, 1)
		bar.XPBaseReward, bar.XPBonusReward = baseBar, bonusBar
		hooksecurefunc(bar, "SetValue", updateBar)
	end
end

do -- Ship equipment
	local EQUIPMENT_ARRAY = {}
	for i=1,2 do
		table.insert(EQUIPMENT_ARRAY, GarrisonShipyardFrame.FollowerTab.EquipmentFrame.Equipment[i])
		table.insert(EQUIPMENT_ARRAY, GarrisonLandingPage.ShipFollowerTab.EquipmentFrame.Equipment[i])
	end
	local function CP_PreClick(self)
		local ct, cid, clink = GetCursorInfo()
		if ct == "item" and cid and clink then
			local owner = self:GetParent()
			local followerID = owner:GetParent():GetParent().followerID
			if ItemCanTargetGarrisonFollowerAbility(followerID, owner.abilityID) then
				ClearCursor()
				self:SetAttribute("macrotext", SLASH_STOPSPELLTARGET1 .. "\n" .. SLASH_USE1 .. " item:" .. cid)
			end
		end
	end
	local function CP_PostClick(self)
		self:SetAttribute("macrotext", nil)
		self:GetParent():Click()
	end
	local function CP_Attach(self)
		self.proxy:SetParent(self)
		self.proxy:SetAllPoints()
		self.proxy:Show()
	end
	local function CP_OnEnter(self, ...)
		local p = self:GetParent()
		local h = p and p:GetScript("OnEnter")
		if h and p then h(p, ...) end
	end
	local function CP_OnLeave(self, ...)
		local p = self:GetParent()
		local h = p and p:GetScript("OnLeave")
		if h and p then h(p, ...) end
	end
	local function CP_Detach(self)
		if self:IsMouseOver() then
			securecall(CP_OnLeave, self)
		end
		self:SetParent(nil)
		self:ClearAllPoints()
		self:Hide()
	end
	for i=1,#EQUIPMENT_ARRAY do
		local pf, ef = CreateFrame("Button", nil, nil, "SecureActionButtonTemplate"), EQUIPMENT_ARRAY[i]
		pf:Hide()
		pf:SetScript("PreClick", CP_PreClick)
		pf:SetScript("PostClick", CP_PostClick)
		pf:SetScript("OnHide", CP_Detach)
		pf:SetScript("OnEnter", CP_OnEnter)
		pf:SetScript("OnLeave", CP_OnLeave)
		ef:HookScript("OnShow", CP_Attach)
		ef:SetScript("OnReceiveDrag", nil)
		pf:SetAttribute("type", "macro")
		ef.proxy = pf
	end
	function EV:PLAYER_REGEN_DISABLED()
		for i=1,#EQUIPMENT_ARRAY do
			EQUIPMENT_ARRAY[i].proxy:Hide()
		end
	end
	
	T.shipUpgradesFrame = CreateFrame("Frame", "MPShipRefitItems") do
		local reroll = T.shipUpgradesFrame
		reroll:SetPoint("TOPRIGHT", -14, -98)
		reroll:SetHeight(24)
		reroll:Hide()
		local buttons = {}
		for k,v in pairs(T.EquipmentTraitItems) do
			local b = T.CreateLazyItemButton(reroll, v)
			b:SetSize(24, 24)
			buttons[#buttons+1] = b
		end
		table.sort(buttons, function(a,b)
			return a.itemID < b.itemID
		end)
		function reroll:Sync()
			local x = 0
			for i=1,#buttons do
				local b = buttons[i]
				if GetItemCount(b.itemID) > 0 then
					b:SetPoint("LEFT", x, 0)
					b:Show()
					x = x + 28
				else
					b:Hide()
				end
			end
			self:SetWidth(x > 0 and x - 4 or 0)
		end
		function reroll:DisplayFor(owner, _mission, ...)
			self:SetParent(owner)
			self:ClearAllPoints()
			self:Show()
			self:Sync()
			self:SetPoint(...)
			self.owner = owner
		end
	end
	local fleetContainer = CreateFrame("Frame", "MPFleetRefitContainer", GarrisonShipyardFrame.FollowerTab) do
		fleetContainer:SetPoint("TOPRIGHT", -14, -98)
		fleetContainer:SetSize(1, 24)
		fleetContainer:SetScript("OnShow", function(self)
			T.shipUpgradesFrame:DisplayFor(self, nil, "RIGHT")
		end)
		hooksecurefunc(GarrisonShipyardFrame.FollowerList, "ShowFollower", function()
			if fleetContainer:IsVisible() then
				fleetContainer:GetScript("OnShow")(fleetContainer)
			end
		end)
	end
end
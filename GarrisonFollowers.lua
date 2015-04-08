local icons, _, T = {}, ...
local G, L = T.Garrison, T.L

local function countFreeFollowers(f, finfo)
	local ret = 0
	for i=1,#f do
		local st = finfo[f[i]].status
		if not (st == GARRISON_FOLLOWER_INACTIVE or st == GARRISON_FOLLOWER_WORKING) then
			ret = ret + 1
		end
	end
	return ret
end

local floatingMechanics = CreateFrame("Frame", nil, GarrisonMissionFrame.FollowerTab)
local CreateMechanicButton do
	local function Mechanic_OnEnter(self)
		local ci, fi = self.info, G.GetFollowerInfo()
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		local ico = "|T" .. self.Icon:GetTexture() .. ":0:0:0:0:64:64:4:60:4:60|t "
		if self.isTrait then
			GameTooltip:AddLine(ico .. C_Garrison.GetFollowerAbilityName(self.id))
			GameTooltip:AddLine(C_Garrison.GetFollowerAbilityDescription(self.id), 1,1,1, 1)
			if ci and #ci > 0 then
				GameTooltip:AddLine("|n" .. NORMAL_FONT_COLOR_CODE .. L"Followers with this trait:", 1,1,1)
				for i=1,#ci do
					GameTooltip:AddLine(G.GetFollowerLevelDescription(ci[i], nil, fi[ci[i]]), 1,1,1)
				end
			else
				GameTooltip:AddLine(L"You have no followers with this trait.", 1,0.50,0, 1)
			end
		elseif self.isTraitGroup then
			floatingMechanics:SetOwner(self, ci, fi)
			return
		else
			GameTooltip:AddLine(ico .. self.name)
			if ci and #ci > 0 then
				GameTooltip:AddLine(L"Countered by:", 1,1,1)
				G.sortByFollowerLevels(ci, fi)
				for i=1,#ci do
					GameTooltip:AddLine(G.GetFollowerLevelDescription(ci[i], nil, fi[ci[i]]), 1,1,1)
				end
			else
				GameTooltip:AddLine(L"You have no followers to counter this mechanic.", 1,0.50,0, 1)
			end
		end
		GameTooltip:Show()
	end
	local function Mechanic_OnLeave(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end
	function CreateMechanicButton(parent)
		local f = CreateFrame("Button", nil, parent, "GarrisonAbilityCounterTemplate")
		f:SetNormalFontObject(GameFontHighlightOutline) f:SetText("0")
		f.Count = f:GetFontString()
		f.Count:ClearAllPoints() f.Count:SetPoint("BOTTOMRIGHT", 0, 2)
		f:SetFontString(f.Count)
		f:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")

		f.Border:Hide()
		f:SetScript("OnClick", function(self)
			if self.name then
				GarrisonMissionFrameFollowers.SearchBox:SetText(self.name)
				GarrisonMissionFrameFollowers.SearchBox.clearText = self.name
			end
		end)
		f:SetScript("OnEnter", Mechanic_OnEnter)
		f:SetScript("OnLeave", Mechanic_OnLeave)
		return f
	end
end

floatingMechanics:SetFrameStrata("DIALOG")
floatingMechanics:SetBackdrop({edgeFile="Interface/Tooltips/UI-Tooltip-Border", bgFile="Interface/DialogFrame/UI-DialogBox-Background-Dark", tile=true, edgeSize=16, tileSize=16, insets={left=4,right=4,bottom=4,top=4}})
floatingMechanics:SetBackdropBorderColor(1, 0.85, 0.6)
floatingMechanics.buttons = {}
function floatingMechanics:SetOwner(owner, info)
	self.owner, self.expire = owner
	self:SetPoint("TOPRIGHT", owner, "BOTTOMRIGHT", 16, -2)
	self:SetSize(10 + 24 * #info, 34)
	for i=1,#info do
		local ico, ci = self.buttons[i], info[i]
		if not ico then
			ico = CreateMechanicButton(self)
			ico:SetPoint("LEFT", 24 * i - 18, 0)
			self.buttons[i] = ico
		end
		ico.Icon:SetTexture(C_Garrison.GetFollowerAbilityIcon(ci.id))
		ico.Count:SetText(#ci > 0 and #ci or "")
		ico.id, ico.name, ico.isTrait, ico.info = ci.id, C_Garrison.GetFollowerAbilityName(ci.id), true, ci
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
	if owner and owner:GetParent() ~= floatingMechanics then
		floatingMechanics:Hide()
	end
end)


GarrisonMissionFrame.FollowerTab.threatIcons = setmetatable(icons, {__index=function(self, k)
	local f = CreateMechanicButton(GarrisonMissionFrame.FollowerTab)
	f:SetPoint("LEFT", k == 1 and GarrisonMissionFrame.FollowerTab.NumFollowers or self[k-1], "RIGHT", k == 1 and 15 or 4, 0)
	self[k] = f
	return f
end})


local traits = {221, 76, 77, 79}
local traitGroups = {
	{80, 236, icon="Interface\\Icons\\XPBonus_Icon"},
	{63,64,65,66,67,68,69,70,71,72,73,74,75,78, icon="Interface\\Icons\\PetBattle_Health"},
	{4,36,37,38,39,40,41,42,43,244, icon="Interface\\Icons\\Ability_Hunter_MarkedForDeath"},
	{7,8,9,44,45,46,48,49, icon="Interface\\Icons\\Achievement_Zone_Stonetalon_01"},
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
		ico.Icon:SetTexture(C_Garrison.GetFollowerAbilityIcon(tid))
		ico.Count:SetText(tinfo[tid] and countFreeFollowers(tinfo[tid], finfo) or "")
		ico.id, ico.name, ico.isTrait, ico.info, i = traits[k], C_Garrison.GetFollowerAbilityName(tid), true, tinfo[tid], i + 1
	end
	for k=1,#traitGroups do
		local ico, c, tg, m = icons[i], 0, traitGroups[k], {g=traitGroups[k]}
		for i=1,#tg do
			local v = tinfo[tg[i]] or {}
			m[#m+1], c, v.id = v, c + countFreeFollowers(v, finfo), tg[i]
		end
		ico.Icon:SetTexture(tg.icon or C_Garrison.GetFollowerAbilityIcon(tg[1]))
		ico.Count:SetText(c > 0 and c or "")
		ico.info, ico.isTraitGroup = m, true
		i = i + 1
	end
end
GarrisonMissionFrame.FollowerTab:HookScript("OnShow", syncTotals)
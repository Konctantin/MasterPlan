local icons, _, T = {}, ...

local function Mechanic_OnEnter(self)
	local id, name = T.Garrison.GetMechanicInfo(self.id)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:AddLine(name)
	local ci, fi = T.Garrison.GetCounterInfo()[id], T.Garrison.GetFollowerInfo()
	if ci then
		GameTooltip:AddLine("Countered by:", 1,1,1)
		T.Garrison.sortByFollowerLevels(ci, fi)
		for i=1,#ci do
			local fid = ci[i]
			local q = C_Garrison.GetFollowerQuality(fid)
			local away = fi[fid].missionTimeLeft
			away = away and (GRAY_FONT_COLOR_CODE .. " (" .. away .. ")") or ""
			GameTooltip:AddLine(("%s[%d]|r %s%s|r%s"):format(ITEM_QUALITY_COLORS[q].hex, fi[fid].level, HIGHLIGHT_FONT_COLOR_CODE, fi[fid].name, away), 1,1,1)
		end
	else
		GameTooltip:AddLine("You have no followers to counter this mechanic.", 1,0.50,0)
	end
	GameTooltip:Show()
	
end
local function Mechanic_OnLeave(self)
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end
local function CreateMechanicFrame(parent)
	local f = CreateFrame("Button", nil, parent, "GarrisonAbilityCounterTemplate")
	f.Count = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightOutline")
	f.Count:SetPoint("BOTTOMRIGHT", 0, 2)
	f.Border:Hide()
	f:SetScript("OnEnter", Mechanic_OnEnter)
	f:SetScript("OnLeave", Mechanic_OnLeave)
	return f
end

local function syncTotals()
	local finfo, i, ico = T.Garrison.GetFollowerInfo(), 1
	for k, f in pairs(T.Garrison.GetCounterInfo()) do
		ico = icons[i] or CreateMechanicFrame(GarrisonMissionFrame.FollowerTab)
		ico:SetPoint("LEFT", icons[i-1] or GarrisonMissionFrame.FollowerTab.NumFollowers, "RIGHT", i == 1 and 15 or 4, 0)
		local _, title, tex = T.Garrison.GetMechanicInfo(k)
		ico.Icon:SetTexture(tex)
		ico.Count:SetText(#f)
		ico:Show()
		ico.id, icons[i], i = k, ico, i + 1
	end
	for i=i,#icons do
		icons[i]:Hide()
	end
end
GarrisonMissionFrame.FollowerTab:HookScript("OnShow", syncTotals)
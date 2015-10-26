select(2, ...).Mark = select(4,GetBuildInfo()) == 60200 and 50

do
	GarrisonFollowerList_Update = function () end
	GarrisonFollowerPage_ShowFollower = GarrisonFollowerList_Update
	local function OnUpdateData(self)
		return GarrisonFollowerList_Update(self:GetParent())
	end
	local function OnShowFollower(self, ...)
		return GarrisonFollowerPage_ShowFollower(self.followerTab, ...)
	end
	hooksecurefunc(GarrisonMissionFrame.FollowerList, "UpdateData", OnUpdateData)
	hooksecurefunc(GarrisonLandingPage.FollowerList, "UpdateData", OnUpdateData)
	hooksecurefunc(GarrisonMissionFrame.FollowerList, "ShowFollower", OnShowFollower)
	hooksecurefunc(GarrisonLandingPage.FollowerList, "ShowFollower", OnShowFollower)
end
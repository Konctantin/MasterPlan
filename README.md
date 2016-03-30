# MasterPlan
Master Plan modifies the Garrison Missions UI, making it easier to figure out what you want to do. It can both suggest and complete parties to maximize mission rewards; see below for details.

Bug reports and feature suggestions should be submitted using the [ticket tracker](http://wow.curseforge.com/addons/master-plan/tickets/?per-page=40). For some frequently-posted comments, see [the FAQ page](https://www.townlong-yak.com/master-plan/faq.html).

## Available Missions tab

* A more compact layout for the available missions list fits more missions on screen, and shows you the mission's threats, as well as some suggested groups and their expected results, allowing you to quickly select the party for the mission.
  * The suggested group buttons summarise total [expected](http://en.wikipedia.org/wiki/Expected_value) rewards for the group, factoring in trait bonuses, low-level follower efficiency, XP caps, and success chance.
* Missions can be sorted by a number of parameters, including success chance, follower XP gain, mission expiration time, duration, or level.
* The number of idle, idle (level 100 epic), working, and away-on-missions followers is displayed next to the garrison resources on this tab.

## Mission detail page

* The follower list is sorted to move followers with counters the mission's threats to the top, and double-clicking a follower's portrait allows you to add/remove that follower from the party. Followers away on missions display they remaining mission time directly in the list.
* Several suggested groups can be viewed and quickly selected by hovering over the LFG eye in the mission header. If you've already selected some followers, suggestions will also include ways to complete your party.
* Closing the mission page using the minimize button, or navigating away from the tab will save the current party as a tentative party.
  * If you return to the mission before logging out, the tentative party will be there waiting.
  * In other missions, tentative party members appear with a "In Tentative Party" status. You can still add them to another mission by right-clicking them and selecting "Add to party", which will dissolve the tentative party they were in.

## Missions of interest tab

* A list of certain high-reward missions, showing you the party that would achieve greatest success chance on that mission, ignoring follower item levels and levels.
* Includes a "Redundant Followers" list -- you may deactivate any one of these followers (for instance to make room for your fresh Inn recruit) without affecting the quality of groups suggested in the tab.
* Follower portraits of under-leveled or under-geared followers for the projected success rate are tinted red; hovering over their portraits will display the desired item level.
* You can click a follower's portrait to jump directly to that follower's details page, where you can upgrade their gear.

## Active Missions tab

* The Active Missions tab displays a list of all missions your followers are currently on, showing the followers on each mission, success probabilities, and the bonus rewards.
* When you click the "Complete All" button, Master Plan completes all current missions automatically.
  * Automatic completion will skip any missions where less than 80% of a currency reward can be collected due to a currency cap.
  * You can complete mission using the default UI by clicking individual missions, or right-clicking the "Complete All" button.
* For missions completed using Master Plan's expedited completion, a summary of follower XP, levels, and loot gained (including salvage) will be displayed at the end of the mission report.

## Followers tab

* A summary of all primary threats and follower traits is shown at the top of the Followers tab of the garrison Missions and Report windows.
  * You can shift-click an icon to add it to the current search; and alt-click a threat icon to search for followers that could have abilities to counter that threat.
* You can upgrade your followers' gear by clicking on the Weapon/Armor slots and selecting the desired upgrade item, without having to open your bags.
* Followers that are currently away on mission display the remaining mission time in their status.
* Followers can be ignored via their right-click menu. Ignored followers will not be sent on missions by Master Plan, and are sorted with, and appear similar to Working followers in follower lists.

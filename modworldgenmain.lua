-- Stop Maxwell from appearing at the start of a new game
local function StopMaxwell(level)
    if level then
        level.nomaxwell = true
    end
end

AddLevelPreInitAny(StopMaxwell)
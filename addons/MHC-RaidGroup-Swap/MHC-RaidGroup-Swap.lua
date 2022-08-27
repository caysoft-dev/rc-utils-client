VERSION = ''
REQUEST_COUNTER = 0
ADDON_CHANNEL_PREFIX = 'RGS'
FONT_NAME = "Fonts\\FRIZQT__.TTF"
ADDON_NAME = 'MHC-RaidGroup-Swap'
CLASS_COLORS = {
    ["DRUID"] = {["r"]=1.00, ["g"]=0.49, ["b"]=0.04},
    ["HUNTER"] = {["r"]=0.67, ["g"]=0.83, ["b"]=0.45},
    ["MAGE"] = {["r"]=0.41, ["g"]=0.80, ["b"]=0.94},
    ["PALADIN"] = {["r"]=0.96, ["g"]=0.55, ["b"]=0.73},
    ["PRIEST"] = {["r"]=1.00, ["g"]=1.00, ["b"]=1.00},
    ["ROGUE"] = {["r"]=1.00, ["g"]=0.96, ["b"]=0.41},
    ["SHAMAN"] = {["r"]=0.0, ["g"]=0.44, ["b"]=0.87},
    ["WARLOCK"] = {["r"]=0.58, ["g"]=0.51, ["b"]=0.79},
    ["WARRIOR"] = {["r"]=0.78, ["g"]=0.61, ["b"]=0.43},
}

lastUpdate = time()
isGroupsManager = false
raidGroup = {}
raidGroupMembers = {}
draggedSlot = nil
slotOffset = 1
groupColumns = 2
slotHeight = 20
defaultGroupsCount = 5

function RGS:LoadAddon()
    VERSION = GetAddOnMetadata(ADDON_NAME, 'Version')

    if (sessionVariables == nil) then
        print('sessionVariables == nil')
        sessionVariables = {
            slotOffset = 1,
            groupColumns = 2,
            slotHeight = 20,
            groupsCount = 5,
            groupsManager = nil,
            collapsed = false,
            visible = false
        }
    end

    RGS:InitRaidGroup(defaultGroupsCount)
    RGS:InitUI()
end

function RGS:InitUI()
    RGS_RaidFrame_Options:Hide()

    local btn = CreateFrame('BUTTON', nil, RGS_RaidFrame_Controller)
    btn:SetWidth(18)
    btn:SetHeight(18)
    btn:SetFrameStrata('LOW')
    btn:SetPoint('LEFT', 10, -1)

    local highlightTex = btn:CreateTexture(nil, "BACKGROUND")
    highlightTex:SetTexture(.3, .3, .3, .8)
    highlightTex:SetPoint("topleft", btn, "topleft", 0, 0)
    highlightTex:SetTexture('Interface\\AddOns\\MHC-RaidGroup-Swap\\assets\\toolbar_highlight')
    highlightTex:SetTexCoord(0, .12, 0, 1)
    highlightTex:SetAllPoints()

    btn:SetHighlightTexture(highlightTex)

    local normalTex = btn:CreateTexture(nil, "BACKGROUND")
    normalTex:SetTexture(.3, .3, .3, .8)
    normalTex:SetPoint("topleft", btn, "topleft", 0, 0)
    normalTex:SetTexture('Interface\\AddOns\\MHC-RaidGroup-Swap\\assets\\toolbar_normal')
    normalTex:SetTexCoord(0, .12, 0, 1)
    normalTex:SetAllPoints()

    btn:SetNormalTexture(normalTex)
    
    btn:SetScript('OnClick', function(self, arg1)
        RGS_RaidFrame_Options:Show()
    end)

    btn:Show()

    if (sessionVariables.visible) then
        RGS:ShowUI()
    else
        RGS:HideUI()
    end
end


function RGS:RefreshRaidGroup()
    self:ClearRaidGroup()
    self:PopulateRaidGroup()
end

function RGS:InitRaidGroup(subGroupsCount)
    for i=1, subGroupsCount do
        RGS_RaidFrame:AddGroup()
    end
end

function RGS:ClearRaidGroup()
    for i=1, table.maxn(raidGroup) do
        for s=1, 5 do 
            RGS_RaidFrame:AssignPlayerSlot(nil, raidGroup[i].slots[s])
        end
    end
end

function RGS:PopulateRaidGroup()
    local info = RGS:GetRaidInfo()
    for i=1, table.maxn(info) do
        self:AddPlayerToGroup(info[i])
    end
end

function RGS:AddPlayerToGroup(player, group)
    if (group == nil) then
        group = raidGroup[player.subgroup]
    elseif (not (group.index == player.subgroup)) then
        raidGroup[player.subgroup].slots[player.slotIndex].player = nil
        player.subgroup = group.index
    end

    if (group == nil) then return end

    local slots = group.slots
    for i=1, 5 do
        local slot = slots[i]
        if (slot.player == nil) then
            RGS_RaidFrame:AssignPlayerSlot(player, slot)
            return
        end
    end
end

function RGS:GetPlayerSlot(groupIndex, slotIndex)
    return self:GetSlot(groupIndex, slotIndex).player
end

function RGS:GetSlot(groupIndex, slotIndex)
    return raidGroup[groupIndex].slots[slotIndex]
end

function RGS:GetNumSubgroupMembers(subgroup)
    local counter = 0
    local memberCount = GetNumGroupMembers()
    for i=1, memberCount do
        local name, rank, playerGroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
        if (subgroup == playerGroup) then
            counter = counter + 1
        end
    end
    return counter
end

function RGS:GetRaidInfo()
    local roster = {}
    local memberCount = GetNumGroupMembers()
    for i=1, memberCount do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
        if (class) then 
            local player = {}
            player.index = i
            player.name = name
            player.rank = rank
            player.class = strupper(class)
            player.subgroup = subgroup
            table.insert(roster, player)
        end
    end
    return roster
end

function RGS:GetRaidMemberInfo(playerName)
    local roster = {}
    local memberCount = GetNumGroupMembers()
    for i=1, memberCount do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
        if (playerName == name) then
            local player = {}
            player.index = i
            player.name = name
            player.rank = rank
            player.class = strupper(class)
            player.subgroup = subgroup
            return player
        end
    end
    return nil
end

function RGS:GetRaidMemberInfoByIndex(index)
    local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(index)
    local player = {}
    player.index = i
    player.name = name
    player.rank = rank
    player.class = strupper(class)
    player.subgroup = subgroup
    return player
end

function RGS:GetRaidMemberInfoOrFail(name)
    local player = self:GetRaidMemberInfo(name)
    if (player == nil) then
        print(name.. ' not found in raid')
    end
    return player
end

function RGS:HandleRemoteCommand(type, sender, payload)
    if (type == 'swap') then

        print(payload.player1)
        print(payload.player2)

        local player1 = self:GetRaidMemberInfoOrFail(payload.player1)
        local player2 = self:GetRaidMemberInfoOrFail(payload.player2)
        print(player1)
        print(player2)
        local validNames = not (player1 == nil or player2 == nil)
        
        if (validNames) then
            print('swapping '.. player1.index .. ' <==> '.. player2.index)
            SwapRaidSubgroup(player1.index, player2.index)
            self:SendRaidWarning('{triangle} Swapping '.. payload.player1 ..' <==> '..payload.player2..' {triangle}')
        else
            self:SendRaidWarning('{cross} Cannot swap '.. payload.player1 ..' with '..payload.player2..' {cross}')
        end
    end

    if (type == 'set') then
        local p = self:GetRaidMemberInfoOrFail(payload.player)
        if (p == nil) then 
            self:SendRaidWarning('{cross} Cannot move '.. payload.player ..' into group '..payload.group..'! Player not in group. {cross}')
            return
        end

        local num = self:GetNumSubgroupMembers(payload.group)
        if (num < 5) then
            local player = self:GetRaidMemberInfo(payload.player)
            SetRaidSubgroup(player.index, payload.group)
            self:SendRaidWarning('{triangle} Moving '.. payload.player ..' into group '..payload.group..' {triangle}')
        else
            self:SendRaidWarning('{cross} Cannot move '.. payload.player ..' into group '..payload.group..'! Group is full. {cross}')
        end
    end
end

function RGS:SendRaidWarning(message)
    SendChatMessage(message , 'RAID'); 
end

function RGS:ShowUI()
    RGS_RaidFrame_Controller:Show()
    RGS_RaidFrame_Controller:UpdateWidth()

    RGS:PopulateRaidGroup()
    RGS_RaidFrame:UpdateWidth()
    RGS_RaidFrame:UpdateHeight()
    RGS_RaidFrame_Controller:Expand()
    sessionVariables.visible = true
end

function RGS:HideUI()
    RGS_RaidFrame_Controller:Hide()
    RGS_RaidFrame:Hide()
    sessionVariables.visible = false
end


function RGS_RaidFrame_Options:Init()
    self:SetWidth(100)
    self:SetHeight(100)
    self:SetPoint('CENTER')
    self:Show()
end

function RGS_RaidFrame_Controller:Expand()
    RGS_RaidFrame_Controller:Hide()
    RGS_RaidFrame_Controller_ExpandButton:Hide()
    RGS_RaidFrame_Controller_CollapseButton:Show()
    RGS_RaidFrame_Controller_CollapseButton:ClearAllPoints()
    RGS_RaidFrame_Controller_CollapseButton:SetPoint('RIGHT', RGS_RaidFrame_Controller_CloseButton, 'LEFT', 0, 0)
    RGS_RaidFrame_Controller:Show()
    RGS_RaidFrame:Show()
    RGS_RaidFrame:UpdateWidth()
    RGS_RaidFrame_Controller:UpdateWidth()
end

function RGS_RaidFrame_Controller:Collapse()
    RGS_RaidFrame:Hide()
    RGS_RaidFrame_Controller:Hide()
    RGS_RaidFrame_Controller_CollapseButton:Hide()
    RGS_RaidFrame_Controller_ExpandButton:Show()
    RGS_RaidFrame_Controller_ExpandButton:ClearAllPoints()
    RGS_RaidFrame_Controller_ExpandButton:SetPoint('RIGHT', RGS_RaidFrame_Controller_CloseButton, 'LEFT', 0, 0)
    RGS_RaidFrame_Controller:Show()
    RGS_RaidFrame_Controller:UpdateWidth()
end

function RGS_RaidFrame:UpdateWidth()
    local width = (groupColumns * (100+15)) + 15
    self:SetWidth(width)
end

function RGS_RaidFrame:UpdateHeight()
    local height = (math.ceil(defaultGroupsCount / groupColumns) * (slotHeight * 5 + 15))+30
    self:SetHeight(height)
end

function RGS_RaidFrame:DoGroupSwap(frame1, frame2)
    local slot1 = RGS:GetSlot(frame1.groupIndex, frame1.index)
    local slot2 = RGS:GetSlot(frame2.groupIndex, frame2.index)

    local player1 = slot1.player
    local player2 = slot2.player

    self:AssignPlayerSlot(player1, slot2)
    self:AssignPlayerSlot(player2, slot1)

    SwapGroupMembers(player1.index, player2.index)

    self:RenderGroups()
end

function SwapGroupMembers(index1, index2)
    if (InCombatLockdown()) then 
        RGS:RemoteSwap(index1, index2)
    else
        SwapRaidSubgroup(index1, index2)
    end
end

function SetGroup(index, subgroup)
    if (InCombatLockdown()) then 
        RGS:RemoteSet(index, subgroup)
    else
        SetRaidSubgroup(index, subgroup)
    end
end

function RGS_RaidFrame:AssignPlayerSlot(player, slot)
    if (player == nil) then
        slot.frame:SetBackdropColor(0.2, 0.2, 0.2, 0.5)
        slot.frame:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
        slot.label:SetText('')
        slot.player = nil
    else
        local color = CLASS_COLORS[player.class]
        slot.frame:SetBackdropColor(color['r'], color['g'], color['b'], 0.8)
        slot.frame:SetBackdropBorderColor(color['r'], color['g'], color['b'], 0.6)
        slot.label:SetText(player.name)
        slot.player = player
        slot.player.slotIndex = slot.index
    end
end


function RGS_RaidFrame:AddSlot(group)
    local slot = {}
    slot.index = #group.slots+1
    slot.name = 'Group'..group.index..'_Slot'..slot.index
    slot.frame = CreateFrame('FRAME', nil, group.frame, 'RGS_RaidFrame_Slot')
    slot.frame:SetParent(group.frame)
    slot.frame.index = slot.index
    slot.frame.groupIndex = group.index

    local relative = nil
    local offsetY = #group.slots * -slotHeight

    slot.frame:SetPoint('TOPLEFT', group.frame, 'TOPLEFT', 0, offsetY)
    slot.frame:SetPoint('RIGHT', group.frame, 'RIGHT')
    slot.frame:SetHeight(slotHeight)

    slot.label = slot.frame:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    slot.label:SetTextColor(1, 1, 1, 1)
    slot.label:SetShadowColor(0, 0, 0, 0)
    slot.label:SetPoint('CENTER')
    slot.label:SetFont(FONT_NAME, 8)
    slot.label:SetText('');
    slot.label:Show()

    slot.player = nil

    table.insert(group.slots, slot)

    return slot
end

function RGS_RaidFrame:AddGroup()
    local group = {}
    group.slots = {}
    group.index = #raidGroup + 1
    group.frame = CreateFrame('FRAME', nil, RGS_RaidFrame, 'RGS_RaidFrame_Group')
    group.frame:SetParent(RGS_RaidFrame)
    group.frame:SetHeight(5*slotHeight)

    if (#raidGroup == 0) then
        group.frame:SetPoint('TOPLEFT', 15, -30)
    elseif ((#raidGroup % groupColumns) == 0) then
        local ref = raidGroup[#raidGroup-groupColumns+1].frame
        group.frame:SetPoint('TOPLEFT', ref, 'BOTTOMLEFT', 0, -15)
    else
        local ref = raidGroup[#raidGroup].frame
        group.frame:SetPoint('TOPLEFT', ref, 'TOPRIGHT', 15, 0)
    end

    group.frame.index = group.index

    group.label = group.frame:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    group.label:SetTextColor(1, 1, 1, 1)
    group.label:SetShadowColor(0, 0, 0, 0)
    group.label:SetPoint('TOP', 0, 10)
    group.label:SetFont(FONT_NAME, 8)
    group.label:SetText('Group '..group.index);
    group.label:Show()

    self:AddSlot(group)
    self:AddSlot(group)
    self:AddSlot(group)
    self:AddSlot(group)
    self:AddSlot(group)

    table.insert(raidGroup, group)

    return group
end

function RGS_RaidFrame:RenderGroup(group)
    for i=1, 5 do 
        local slot = group.slots[i]
        local offsetY = (i-1) * -slotHeight
        slot.frame:SetPoint('TOPLEFT', group.frame, 'TOPLEFT', 0, offsetY)
        slot.frame:SetPoint('RIGHT', group.frame, 'RIGHT')
        slot.frame:SetHeight(slotHeight)
        RGS_RaidFrame:AssignPlayerSlot(slot.player, slot)
    end
end

function RGS_RaidFrame:RenderGroups()
    for i=1, table.maxn(raidGroup) do
        self:RenderGroup(raidGroup[i])
    end

    RGS_RaidFrame:UpdateWidth()
    RGS_RaidFrame:UpdateHeight()
end

function RGS_RaidFrame_Controller:UpdateWidth()
    local width = (groupColumns * (100+15)) + 15
    self:SetWidth(width)
end

function RGS:getLastUpdate()
    return lastUpdate;
end

function RGS:setLastUpdate(time)
    lastUpdate = time;
end

function RGS:OnUpdate(diff)

end

function RGS:OnEvent(event, ...)
    if (event == 'CHAT_MSG_ADDON') then
        self:OnMessageAddonEvent(...)
    elseif (event == 'CHAT_MSG_ADDON_LOGGED') then
        self:OnMessageAddonEvent(...)
    elseif (event == 'GROUP_ROSTER_UPDATE') then
        RGS:RefreshRaidGroup()
    elseif (event == 'CHAT_MSG_WHISPER') then
        RGS:OnWhisper(...)
    elseif (event == 'ADDON_LOADED') then
        local addon = ...;
        if (addon == ADDON_NAME) then
            self:LoadAddon()
        end
    end
end

function RGS:OnWhisper(message, sender, lang, status)
    if (message == '!rgs') then
        whisperHelp(sender)
    end
end

function RGS:SendCompressedAddonMessage(type, data, channel, target)
    if (channel == nil) then
        channel = 'RAID'
    end

    local payload = { type = type, data = data }
    local LibSerialize = LibStub('LibSerialize')
    local LibDeflate = LibStub('LibDeflate')

    serialized = LibSerialize:Serialize(payload)
    compressed = LibDeflate:CompressDeflate(serialized)
    encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
    C_ChatInfo.SendAddonMessage(ADDON_CHANNEL_PREFIX, encoded, channel, target)
end

function RGS:OnMessageAddonEvent(...)
    local prefix, payload, distribution, sender = ...;
    if (not (prefix == ADDON_CHANNEL_PREFIX)) then
        return
    end

    local LibSerialize = LibStub("LibSerialize")
    local LibDeflate = LibStub("LibDeflate")

    local decoded = LibDeflate:DecodeForWoWAddonChannel(payload)
    if not decoded then return end
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then return end
    local success, body = LibSerialize:Deserialize(decompressed)
    if not success then return end

    local name, realm = UnitName('player')
    local senderName = strsplit('-', sender)
    local type = body.type
    local s = split(sender, '-')
    local packageName = split(type, '_')

    if (packageName[1] == 'RC') then
        RGS:HandleRemoteCommand(packageName[2], s[1], body.data)
    end
end

function RGS:RemoteSwap(index1, index2)
    local data = { }
    data.player1 = RGS:GetRaidMemberInfoByIndex(index1).name
    data.player2 = RGS:GetRaidMemberInfoByIndex(index2).name

    if (RGS:SendRemoteCommand('swap', data)) then
        print('|cFFFFFF00swapping '..data.player1..' with '..data.player2)
    end
end

function RGS:RemoteSet(index, group)
    local data = { }
    data.player = select(1, GetRaidRosterInfo(index))
    data.group = group

    if (RGS:SendRemoteCommand('set', data)) then
        print('|cFFFFFF00moving '..data.player..' into group '..data.group)
    end
end

function RGS:OnCombatLogEvent(...)
    local timestamp, logType, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
end

function RGS:SendRemoteCommand(cmd, payload)
    if (sessionVariables.groupsManager == nil) then
        print('|cFFFF0000You must set a groups-manager before you can move group members while in combat!')
        return false
    end
    RGS:SendCompressedAddonMessage('RC_'..cmd, payload, 'WHISPER', sessionVariables.groupsManager)
    return true
end


function trim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function empty(s)
    return s == nil or s == ''
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function strpadright(s, l)
    local strLength = string.len(s)
    
    local diff = l-strLength
    if (diff <= 0) then
        return s
    end

    for i = 1, diff do
        s = s..' '
    end

    return s
end

function whisper(receiver, message) 
    SendChatMessage(message, 'WHISPER', 'Common', receiver);
end

function whisperHelp(receiver)
    whisper(receiver, 'Syntax: !rgs <command>')
    whisper(receiver, '!rgs swap <player1> <player2>')
    whisper(receiver, '!rgs set <player> <group>')
    whisper(receiver, '!rgs version')
end

function printHelp()
    print('Syntax: /rgs <command>')
    print('/rgs swap <player1> <player2>')
    print('/rgs set <player> <group>')
    print('/rgs setmanager <player>')
    print('/rgs version')
end

function command_swap(params) 
    local args = split(trim(params), ' ')

    if (empty(args[1]) or empty(args[2])) then
        printHelp()
        return
    end

    local data = { }
    data.player1 = trim(args[1])
    data.player2 = trim(args[2])

    if (RGS:SendRemoteCommand('swap', data)) then
        print('|cFFFFFF00swapping '..data.player1..' with '..data.player2)
    end
end

function command_set(params) 
    local args = split(trim(params), ' ')

    if (empty(args[1]) or empty(args[2])) then
        printHelp()
        return
    end

    local data = { }
    data.player = trim(args[1])
    data.group = trim(args[2])

    if (RGS:SendRemoteCommand('set', data)) then
        print('|cFFFFFF00moving '..data.player..' into group '..data.group)
    end
end

function command_setmanager(params) 
    local args = split(trim(params), ' ')

    if (empty(args[1])) then
        printHelp()
        return
    end

    local name = trim(args[1])
    local player = RGS:GetRaidMemberInfoOrFail(name)
    if (player == nil) then return end

    if (AssertPermission(name, 'a groups-manager must be assistant or raid-leader')) then
        sessionVariables.groupsManager = name
        print('|cFFFFFF00'..name..' promoted to groups-manager')
    end
end

function HasPermission(player)
    local p = split(player, '-')[1]

    if (UnitIsGroupLeader(p)) then 
        return true
    end

    if (UnitIsGroupAssistant(p)) then 
        return true
    end

    return false
end

function AssertPermission(player, message)
    if (HasPermission(player)) then
        return true
    end
    print('|cFFFF0000'..message)
    return false
end

SLASH_RGS1 = "/rgs"
function SlashCmdList.RGS(body)
    local command, params = body:match('^(%S*)%s*(.-)$')

    if (command == 'swap') then
        command_swap(params)
    elseif (command == 'set') then
        command_set(params)
    elseif (command == 'setmanager') then
        command_setmanager(params)
    elseif (command == 'show') then
        RGS:ShowUI()
    else
        printHelp()
    end
end
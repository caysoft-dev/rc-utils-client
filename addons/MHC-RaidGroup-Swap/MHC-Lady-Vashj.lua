VERSION = ''
REQUEST_COUNTER = 0
FONT_NAME = "Fonts\\FRIZQT__.TTF"
ADDON_CHANNEL_PREFIX = 'ESTL'
ADDON_NAME = 'MHC-Lady-Vashj'
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

CLASS_MAP = {
    [1]='WARRIOR',
    [2]='PALADIN',
    [3]='HUNTER',
    [4]='ROGUE',
    [5]='PRIEST',
    [7]='SHAMAN',
    [8]='MAGE',
    [9]='WARLOCK',
    [11]='DRUID',
    ['WARRIOR']=1,
    ['PALADIN']=2,
    ['HUNTER']=3,
    ['ROGUE']=4,
    ['PRIEST']=5,
    ['SHAMAN']=7,
    ['MAGE']=8,
    ['WARLOCK']=9,
    ['DRUID']=11,
}

lastUpdate = time();
requestQueue = {}
isGroupsManager = false

MHC_Strider_Nets_Scroll:SetBackdropColor(0,0,0,0);
MHC_Strider_Nets_Scroll:SetBackdropBorderColor(0,0,0,0);

function MHC:LoadAddon()
    VERSION = GetAddOnMetadata(ADDON_NAME, 'Version')

    if (sessionVariables == nil) then
        sessionVariables = {
            players = {},
            order = {},
            lastIndex = nil,
            currentIndex = nil,
            striderToolHidden = true,
            striderHUDHidden = true,
            testMode = false,
            editMode = false
        }
        MHC_Strider_Nets:Hide()
        MHC_HUD:Hide()
    else
        local playerList = {}
        for i, name in pairs(sessionVariables.order) do
            local player = sessionVariables.players[name];
            if (not (player == nil)) then
                table.insert(playerList, {name, player.class})
            end
        end

        sessionVariables.players = {}
        sessionVariables.order = {}
        sessionVariables.currentIndex = nil
        sessionVariables.lastIndex = nil

        if (sessionVariables.striderToolHidden == nil) then
            sessionVariables.striderToolHidden = true
        end

        if (sessionVariables.striderHUDHidden == nil) then
            sessionVariables.striderHUDHidden = true
        end

        MHC_Strider_Nets.groups = {}

        for i, player in pairs(playerList) do
            MHC:AddPlayer(MHC_Strider_Nets, player[1], player[2], true)
        end
    end

    if (sessionVariables.striderToolHidden) then
        MHC_Strider_Nets:Hide()
    else
        MHC_Strider_Nets:Show()
    end

    if (sessionVariables.striderHUDHidden) then
        MHC_HUD:Hide()
    else
        MHC_HUD:Show()
    end

    MHC_Lady_Vashj:Hide()

    self:ToggleTestMode(MHC_Strider_Nets_Buttons_TestButton, sessionVariables.testMode)
    MHC_Strider_Nets_Buttons_TestButton:Hide()
    self:SetEditMode(false)
end

function MHC:HasPermission(player)
    local p = split(player, '-')[1]

    if (UnitIsGroupLeader(p)) then 
        return true
    end

    if (UnitIsGroupAssistant(p)) then 
        return true
    end

    return false
end

function MHC_Strider_Nets:HideUI()
    MHC_Strider_Nets:Hide();
    sessionVariables.striderToolHidden = true;
end

function MHC_HUD:HideUI()
    MHC_HUD:Hide();
    sessionVariables.striderHUDHidden = true;
end

function MHC_Strider_Nets:ShowUI()
    MHC_Strider_Nets:Show();
    sessionVariables.striderToolHidden = false;
end

function MHC_HUD:ShowUI()
    MHC_HUD:Show();
    sessionVariables.striderHUDHidden = false;
end

function MHC:ToggleTestMode(button, mode)
    if (mode == nil) then
        mode = not sessionVariables.testMode
    end

    sessionVariables.testMode = mode;
    button.selected = sessionVariables.testMode;
    MHC_SetTextButtonBackdropColor(button)
end

function MHC:getLastUpdate()
    return lastUpdate;
end

function MHC:setLastUpdate(time)
    lastUpdate = time;
end

function MHC_SetTextButtonBackdropColor(btn, hovering)
    if btn.disabled then
        btn:SetBackdropColor(0.3, 0.3, 0.3, 0.1)
        btn:SetBackdropBorderColor(1, 1, 1, 0.08)

        if (not btn.label == nil) then
            btn.label:SetTextColor(0.8, 0.8, 0.8, 0.5)
        end
    elseif hovering then
        if btn.selected then
            btn:SetBackdropColor(0.4, 0.4, 0.4, 0.4)
            btn:SetBackdropBorderColor(1, 1, 1, 0.25)
            if (not btn.label == nil) then
                btn.label:SetTextColor(255/255, 238/255, 0/255, 1)
            end
        else
            btn:SetBackdropColor(0.3, 0.3, 0.3, 0.2)
            btn:SetBackdropBorderColor(1, 1, 1, 0.15)

            if (not btn.label == nil) then
                btn.label:SetTextColor(0.8, 0.8, 0.8, 1)
            end
        end
    else
        if btn.selected then
            btn:SetBackdropColor(0.4, 0.4, 0.4, 0.3)
            btn:SetBackdropBorderColor(1, 1, 1, 0.2)

            if (not btn.label == nil) then
                btn.label:SetTextColor(245/255, 233/255, 66/255, 1)
            end
        else
            btn:SetBackdropColor(0, 0, 0, 0.4)
            btn:SetBackdropBorderColor(1, 1, 1, 0.1)
            if (not btn.label == nil) then
                btn.label:SetTextColor(0.8, 0.8, 0.8, 1)
            end
        end
    end
end

function MHC:OnEvent(event, ...)
    if (event == 'COMBAT_LOG_EVENT_UNFILTERED') then
        self:OnCombatLogEvent(CombatLogGetCurrentEventInfo())
    elseif (event == 'CHAT_MSG_ADDON') then
        self:OnMessageAddonEvent(...)
    elseif (event == 'CHAT_MSG_ADDON_LOGGED') then
        self:OnMessageAddonEvent(...)
    elseif (event == 'ADDON_LOADED') then
        local addon = ...;
        if (addon == ADDON_NAME) then
            self:LoadAddon()
        end
    end
end

function MHC:Clear()
    for i, name in pairs(sessionVariables.order) do
        local player = sessionVariables.players[name];
        if (not (player == nil)) then
            player.row.frame:Hide()
            self:HideEditButtons(player.row)
        end
    end

    sessionVariables.order = {}
    sessionVariables.players = {}
    sessionVariables.lastIndex = nil
    sessionVariables.currentIndex = nil

    MHC_Strider_Nets.rows = {}
    MHC_Strider_Nets.groups = {}

    MHC_HUD_Current_Name_Text:SetText('-')
    MHC_HUD:SetBackdropColor(0, 0, 0, 0.6)
    MHC_HUD:SetBackdropBorderColor(0, 0, 0, 0.9)
end

function HandleSync(sender, players)
    MHC:Clear()
    
    for i, player in pairs(players) do
        MHC:AddPlayer(MHC_Strider_Nets, player[1], CLASS_MAP[player[2]])
    end

    MHC:ResetOrder()

    print('|cffFFFF00'..split(sender, '-')[1]..' has updated the Netherweave Net order.')
end

function MHC:OpenSyncDialog(sender, players)
    if (MHC:HasPermission(sender)) then
        HandleSync(sender, players)
        return
    end

    StaticPopupDialogs['OPEN_SYNC_DIALOG'] = {
        text = sender..' has sent a new list. Do you want to accept and override your current list?',
        button1 = 'Yes',
        button2 = 'No',
        OnAccept = function(dialog)
            dialog.callback(dialog.sender,dialog.players)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    local dialog = StaticPopup_Show('OPEN_SYNC_DIALOG')
    if (dialog) then
        dialog.callback = HandleSync
        dialog.sender = sender
        dialog.players = players
    end
end


function MHC:AlertDialog(message)
    StaticPopupDialogs['ALERT_DIALOG'] = {
        text = message,
        button1 = 'Okay',
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    local dialog = StaticPopup_Show('ALERT_DIALOG')
end

function MHC:OnCombatLogEvent(...)
    local timestamp, logType, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...

    if (sessionVariables.players[sourceName] == nil) then return end

    if (logType == 'SPELL_CAST_SUCCESS') then
        local spellId, spellName, spellSchool = select(12, ...)
        if (spellId == 31367) then
            self:TriggerCooldown(sourceName, timestamp)
        end
    end
end

function MHC:TriggerCooldown(sourceName, timestamp)
    sessionVariables.players[sourceName].lastCast = math.floor(timestamp);
    self:UpdatePlayerStateCooldown(sessionVariables.players[sourceName])

    if (sessionVariables.order[sessionVariables.currentIndex] == sourceName) then
        self:NextPlayer()
    end
end

function MHC:UpdateDeathState(player)
    if (UnitIsDeadOrGhost(player.name)) then
        local classColor = player.color
        player.state = 'dead'
        player.row.frame:SetBackdropColor(classColor['r'] *0.5, classColor['g'] *0.5, classColor['b'] *0.5, 0.8)
        player.row.icon:SetTexture('Interface\\RaidFrame\\Raid-Icon-Rez')
    else
        player.state = 'ready'
    end
end

function MHC:AnyAlive()
    for i, name in pairs(sessionVariables.order) do
        local player = sessionVariables.players[name];
        if (not (player == nil)) then
            if (not (UnitIsDeadOrGhost(name))) then
                return true
            end
        end
    end
    return false
end

function MHC:SetPlayerStateReady(player)
    player.state = 'ready'
    player.row.frame:SetBackdropColor(player.color['r'], player.color['g'], player.color['b'], 1)
    player.row.icon:SetTexture('Interface\\RaidFrame\\ReadyCheck-Ready')
    player.row.timer:SetText('')
end

function MHC:UpdatePlayerStateCooldown(player)
    if (player.state == 'dead') then
        return
    end

    local cooldown = (player.lastCast + 60) - time();
    if (cooldown <= 0) then
        self:SetPlayerStateReady(player)
        return
    end

    player.state = 'cooldown'
    player.row.frame:SetBackdropColor(player.color['r'], player.color['g'], player.color['b'], 0.5)
    player.row.icon:SetTexture('Interface\\RaidFrame\\ReadyCheck-NotReady')

    local cooldownValue = ('%is').format(cooldown)..'s'
    if (cooldown > 60) then
        cooldownValue = ('%is').format(math.ceil((cooldown-15) / 60))..'m'
    end

    player.row.timer:SetText(cooldownValue)
end

function MHC:OnUpdate(diff)
    self:CleanPacketRefs()

    for i, name in pairs(sessionVariables.order) do
        local player = sessionVariables.players[name];
        if (not (player == nil)) then
            self:UpdateDeathState(player)
            self:UpdatePlayerStateCooldown(player)
        end
    end

    local current = self:GetCurrentPlayer();
    if (current == nil) then
        return
    end

    if (not (self:AnyAlive())) then
        self:ResetOrder()
        return
    end

    if (current.state == 'dead') then 
        self:NextPlayer()
    end

    self:UpdateCurrentPlayer(current);
end

function MHC:ResetOrder()
    if (not (sessionVariables.currentIndex == nil)) then
        sessionVariables.currentIndex = 1;
    end
end


function MHC:GetCurrentPlayer()
    local name = sessionVariables.order[sessionVariables.currentIndex]
    return sessionVariables.players[name]
end

function MHC:NextPlayer()
    local nextIndex = sessionVariables.currentIndex + 1
    if (nextIndex > sessionVariables.lastIndex) then
        nextIndex = 1
    end

    local player = self:GetPlayerByIndex(nextIndex)
    if (player.state == 'cooldown' or player.state == 'dead') then
        nextIndex = self:FindNextPlayerIndex(sessionVariables.currentIndex)
    end

    sessionVariables.currentIndex = nextIndex;
end

function MHC:GetPlayerByIndex(index)
    local name = sessionVariables.order[index]
    return self:GetPlayerByName(name)
end

function MHC:GetPlayerByName(name)
    return sessionVariables.players[name]
end

function MHC:GetPlayerIndexByName(n)
    for i, name in pairs(sessionVariables.order) do
        if (name == n) then
            return i
        end
    end
    return nil
end

function MHC:FindNextPlayerIndex(startIndex)
    local nextIndex = startIndex + 1
    if (nextIndex > sessionVariables.lastIndex) then
        nextIndex = 1
    end

    for i=nextIndex, sessionVariables.lastIndex do
        local player = self:GetPlayerByIndex(i)
        if (player.state == 'ready') then
            return i
        end
    end

    for i=1, startIndex-1 do
        local player = self:GetPlayerByIndex(i)
        if (player.state == 'ready') then
            return i
        end
    end

    return nextIndex
end

function MHC:UpdateCurrentPlayer(player)
    if (player == nil) then
        return
    end

    local me = UnitName('player')
    if (me == player.name) then
        MHC_HUD:SetBackdropColor(0.1, 0.4, 0.1, 0.7)
        MHC_HUD:SetBackdropBorderColor(0.1, 0.6, 0.1, 1)
    else
        MHC_HUD:SetBackdropColor(0, 0, 0, 0.6)
        MHC_HUD:SetBackdropBorderColor(0, 0, 0, 0.9)
    end

    MHC_HUD_Current_Name_Text:SetText(player.name)
end

function MHC_Strider_Nets_Buttons_HUDButton:ToggleHUD()
    MHC_HUD:ClearAllPoints()
    MHC_HUD:SetPoint("CENTER", 0, 200)
    MHC_HUD:Show()
end

function MHC:AddGroup(container, index)
    local groupIndex = math.floor((index+1) / 5) + 1
    local rowName = 'groupRow_'..index
    local row = {}
    row.name = 'Group '..groupIndex
    if (groupIndex == 5) then
        row.name = 'Backup'
    end
    row.frameName = rowName
    row.frame = CreateFrame('FRAME', rowName, container.scrollContent, BackdropTemplateMixin and "BackdropTemplate")
    row.frame:SetHeight(20);
    row.frame:SetToplevel(true);

    if #container.rows == 0 then
        row.frame:SetPoint("TOPLEFT", container.scrollContent, 0, -2);
        row.frame:SetPoint("RIGHT", container.scroll);
    else
        row.frame:SetPoint("TOP", container.rows[#container.rows].frame, "BOTTOM", 0, -2);
        row.frame:SetPoint("RIGHT", container.scroll, "RIGHT", 0, 0);
        row.frame:SetPoint("LEFT", container.scrollContent, "LEFT", 0, 0);
    end
    row.frame:SetBackdrop({
        bgFile = "Interface/Buttons/WHITE8X8",
        edgeSize = 16,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    row.frame:SetAlpha(1)
    row.frame:SetBackdropColor(0.2, 0.2, 0.2, 1)
    row.frame:Show();

    row.label = row.frame:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    row.label:SetTextColor(1, 1, 1, 1)
    row.label:SetShadowColor(0, 0, 0, 0)
    row.label:SetPoint("LEFT", 25, 0)
    row.label:SetFont(FONT_NAME, 10)
    row.label:SetText(row.name);
    row.label:Show()

    table.insert(container.groups, row);
end

function MHC:IsGroupRowIndex(index)
    if (index > 25) then
        return false
    end

    if (index == 0) then
        return true
    end

    if (math.fmod(index, 5) == 0) then
        return true
    end

    return false
end

function MHC:AddPlayer(container, playerName, class, skipPlayerCheck)
    if (not skipPlayerCheck and (not UnitIsPlayer(playerName))) then
        print((UnitName(playerName) or playerName)..' is too far away or does not exist.')
        return
    end

    local name, realm = UnitName(playerName);
    if (class == nil) then
        local classLoc, className = UnitClass(name);
        class = className
    end

    if (name == nil) then
        name = playerName
    end

    if (not (sessionVariables.players[name] == nil) and not (sessionVariables.players[name].row == nil)) then
        print(name..' is already listed')
        return
    end
    local groupAdded = false
    local rowIdx = #container.rows;

    local classColor = CLASS_COLORS[class];
    local rowName = 'playerRow_'..name..'_'..class
    local row = {}
    row.name = name
    row.frameName = rowName
    row.frame = CreateFrame('FRAME', rowName, container.scrollContent, BackdropTemplateMixin and "BackdropTemplate")
    row.frame:SetHeight(20);
    row.frame:SetToplevel(true);

    container.scrollContent:SetPoint("RIGHT", container.scroll);

    if (groupAdded) then
        row.frame:SetPoint("TOP", container.groups[#container.groups].frame, "BOTTOM", 0, -2);
        row.frame:SetPoint("RIGHT", container.scroll, "RIGHT", 0, 0);
        row.frame:SetPoint("LEFT", container.scrollContent, "LEFT", 0, 0);
    elseif #container.rows == 0 then
        row.frame:SetPoint("TOPLEFT", container.scrollContent, 0, -2);
        row.frame:SetPoint("RIGHT", container.scroll);
    else
        row.frame:SetPoint("TOP", container.rows[#container.rows].frame, "BOTTOM", 0, -2);
        row.frame:SetPoint("RIGHT", container.scroll, "RIGHT", 0, 0);
        row.frame:SetPoint("LEFT", container.scrollContent, "LEFT", 0, 0);
    end
    row.frame:SetBackdrop({
        bgFile = "Interface/Buttons/WHITE8X8",
        edgeSize = 16,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    row.frame:SetAlpha(1)
    row.frame:SetBackdropColor(classColor['r'], classColor['g'], classColor['b'], 1)
    row.frame:Show();

    row.icon = row.frame:CreateTexture("PlayerStatusIcon")
    row.icon:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
    row.icon:SetWidth(12)
    row.icon:SetHeight(12)
    row.icon:SetPoint("LEFT", 5, 0)

    row.timer = row.frame:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    row.timer:SetTextColor(0.04, 0.04, 0.04, 1)
    row.timer:SetShadowColor(0, 0, 0, 0)
    row.timer:SetPoint("RIGHT", -10, 0)
    row.timer:SetFont(FONT_NAME, 10)
    row.timer:SetText('')

    row.label = row.frame:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    row.label:SetTextColor(0.04, 0.04, 0.04, 1)
    row.label:SetShadowColor(0, 0, 0, 0)
    row.label:SetPoint("LEFT", 25, 0)
    row.label:SetFont(FONT_NAME, 10)
    row.label:SetText(name);
    row.label:Show()

    self:CreateEditButtons(row)

    if (sessionVariables.players[name] == nil) then
        table.insert(sessionVariables.order, name);
        sessionVariables.players[name] = {
            index = table.maxn(sessionVariables.order),
            row = row,
            name = name,
            lastCast = 0,
            state = 'ready',
            class = class,
            color = classColor
        }
    end

    if (sessionVariables.players[name].row == nil) then
        sessionVariables.players[name].row = row
    end

    table.insert(container.rows, row);

    sessionVariables.lastIndex = table.maxn(sessionVariables.order)
    if (sessionVariables.lastIndex == 1) then
        sessionVariables.currentIndex = 1
    end

    row.index = sessionVariables.players[name].index

    self:UpdateAllEditButtonsVisibility()
end

function MHC:ClearRows()
    for i,name in pairs(sessionVariables.order) do
        sessionVariables.players[name].row.label:Hide()
        sessionVariables.players[name].row.timer:Hide()
        sessionVariables.players[name].row.label:Hide()
        sessionVariables.players[name].row.frame:Hide()
        sessionVariables.players[name].row.label = nil
        sessionVariables.players[name].row.timer = nil
        sessionVariables.players[name].row.label = nil
        sessionVariables.players[name].row.frame = nil
        sessionVariables.players[name].row = nil
    end
    MHC_Strider_Nets.rows = {}
    MHC_Strider_Nets.groups = {}
end

function MHC:RefreshRows()
    MHC:ClearRows();
    for i,name in pairs(sessionVariables.order) do
        MHC:AddPlayer(MHC_Strider_Nets, name, sessionVariables.players[name].class, true);
    end
    if (table.maxn(sessionVariables.order) > 0) then
        sessionVariables.currentIndex = 1;
    end
end

function MHC:SwapPlayers(index1, index2)
    local name1 = sessionVariables.order[index1]
    local name2 = sessionVariables.order[index2]

    sessionVariables.order[index1] = name2;
    sessionVariables.order[index2] = name1;

    sessionVariables.players[name1].index = index2;
    sessionVariables.players[name1].row.index = index2;

    sessionVariables.players[name2].index = index1;
    sessionVariables.players[name2].row.index = index1;
end

function MHC:RemovePlayer(name)
    local index = self:GetPlayerIndexByName(name)
    sessionVariables.players[name].row.label:Hide()
    sessionVariables.players[name].row.timer:Hide()
    sessionVariables.players[name].row.label:Hide()
    sessionVariables.players[name].row.frame:Hide()
    sessionVariables.players[name].row.label = nil
    sessionVariables.players[name].row.timer = nil
    sessionVariables.players[name].row.label = nil
    sessionVariables.players[name].row.frame = nil
    sessionVariables.players[name].row = nil
    sessionVariables.players[name] = nil
    table.remove(MHC_Strider_Nets.rows, index)
    table.remove(sessionVariables.order, index)
    self:RefreshRows()
end

function MHC:MoveUpPlayer(name)
    local index = self:GetPlayerIndexByName(name);
    local firstIndex = 1;
    if (index == firstIndex) then return false end

    local targetIndex = index - 1;
    self:SwapPlayers(index, targetIndex)
    self:RefreshRows()
    return true;
end

function MHC:MoveDownPlayer(name)
    local index = self:GetPlayerIndexByName(name);
    local lastIndex = table.maxn(sessionVariables.order)
    if (index == lastIndex) then return false end

    local targetIndex = index + 1;
    self:SwapPlayers(index, targetIndex)
    self:RefreshRows()
    return true;
end

function MHC:SetEditMode(active)
    sessionVariables.editMode = active
    MHC_Strider_Nets_Buttons_EditPlayerButton.selected = active;
    for i,name in pairs(sessionVariables.order) do
        self:UpdateEditButtonsVisibility(sessionVariables.players[name].row)
    end
end

function MHC:UpdateAllEditButtonsVisibility()
    for i=1, table.maxn(sessionVariables.order) do
        local name = sessionVariables.order[i]
        local row = sessionVariables.players[name].row
        if (row) then
            self:UpdateEditButtonsVisibility(row)
        end
    end
end

function MHC:UpdateEditButtonsVisibility(row)
    if (sessionVariables.editMode) then
        self:ShowEditButtons(row)
    else
        self:HideEditButtons(row)
    end
end

function MHC:ShowEditButtons(row)
    if (row.index > 1) then
        row.edit_buttons.move_up_button:SetButtonState('NORMAL', false)
        MHC:UpdateEditButtonTexture(row.edit_buttons.move_up_button, row.edit_buttons.move_up_button.normalTexture)
    else
        row.edit_buttons.move_up_button:SetButtonState('DISABLED', true)
        MHC:UpdateEditButtonTexture(row.edit_buttons.move_up_button, row.edit_buttons.move_up_button.disabledTexture)
    end

    if (row.index < table.maxn(sessionVariables.order)) then
        row.edit_buttons.move_down_button:SetButtonState('NORMAL', false)
        MHC:UpdateEditButtonTexture(row.edit_buttons.move_down_button, row.edit_buttons.move_down_button.normalTexture)
    else
        row.edit_buttons.move_down_button:SetButtonState('DISABLED', true)
        MHC:UpdateEditButtonTexture(row.edit_buttons.move_down_button, row.edit_buttons.move_down_button.disabledTexture)
    end

    row.edit_buttons.remove_button:Show()
    row.edit_buttons.move_up_button:Show()
    row.edit_buttons.move_down_button:Show()
end

function MHC:UpdateEditButtonTexture(button, texture)
    button:GetNormalTexture():ClearAllPoints()
    button:GetNormalTexture():SetTexture(texture)
    button:GetNormalTexture():SetAllPoints()
end

function MHC:HideEditButtons(row)
    row.edit_buttons.remove_button:Hide()
    row.edit_buttons.move_up_button:Hide()
    row.edit_buttons.move_down_button:Hide()
end

function MHC:CreateEditButtons(row)
    row.edit_buttons = {}

    row.edit_buttons.remove_button = self:CreateEditButton(row, 'Remove',
            'Interface\\Buttons\\CancelButton-Up',
            'Interface\\Buttons\\CancelButton-Highlight',
            'Interface\\Buttons\\CancelButton-Down'
    )
    row.edit_buttons.remove_button.row = row
    row.edit_buttons.remove_button:SetWidth(28)
    row.edit_buttons.remove_button:SetHeight(28)
    row.edit_buttons.remove_button:SetPoint('RIGHT', 0, 0)
    row.edit_buttons.remove_button:SetScript('OnClick', function(button)
        MHC:RemovePlayer(button.row.name)
        print(button.row.name..' removed')
    end)

    row.edit_buttons.move_down_button = self:CreateEditButton(row, 'MoveDown',
            'Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up',
            'Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Highlight',
            'Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down',
            'Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Disabled'
    )
    row.edit_buttons.move_down_button.row = row
    row.edit_buttons.move_down_button:SetWidth(28)
    row.edit_buttons.move_down_button:SetHeight(28)
    row.edit_buttons.move_down_button:SetPoint('RIGHT', row.edit_buttons.remove_button, 'LEFT', 0, 0)
    row.edit_buttons.move_down_button:SetScript('OnClick', function(button)
        MHC:MoveDownPlayer(button.row.name)
    end)

    row.edit_buttons.move_up_button = self:CreateEditButton(row, 'MoveUp',
            'Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up',
            'Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Highlight',
            'Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Down',
            'Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Disabled'
    )
    row.edit_buttons.move_up_button.row = row
    row.edit_buttons.move_up_button:SetWidth(28)
    row.edit_buttons.move_up_button:SetHeight(28)
    row.edit_buttons.move_up_button:SetPoint('RIGHT', row.edit_buttons.move_down_button, 'LEFT', 0, 0)
    row.edit_buttons.move_up_button:SetScript('OnClick', function(button)
        MHC:MoveUpPlayer(button.row.name)
    end)
end

function MHC:CreateEditButton(row, name, normalTexture, highlightTexture, pushedTexture, disabledTexture)
    local button = CreateFrame('Button', row.frameName..'_'..name, row.frame, 'BackdropTemplate')
    button:SetNormalFontObject('GameFontNormal')
    button:SetDisabledFontObject('GameFontNormal')
    button.normalTexture = normalTexture;
    button.disabledTexture = disabledTexture;

    local ntex = button:CreateTexture()
    ntex:SetTexture(normalTexture)
    ntex:SetAllPoints()
    button:SetNormalTexture(ntex)

    local htex = button:CreateTexture(highlightTexture)
    htex:SetTexture(highlightTexture)
    htex:SetAllPoints()
    button:SetHighlightTexture(htex)

    local ptex = button:CreateTexture()
    ptex:SetTexture(pushedTexture)
    ptex:SetAllPoints()
    button:SetPushedTexture(ptex)

    return button;
end

function MHC_Strider_Nets_Buttons_AddPlayerButton:AddPlayer()
    local container = MHC_Strider_Nets;
    local name, realm = UnitName('target')
    local classLoc, class = UnitClass('target');

    if (name == nil) then
        classLoc, class = UnitClass('player');
    end

    MHC:AddPlayer(container, name and 'target' or 'player', class)
end

function MHC_Strider_Nets_Buttons_AddPlayerButton:Clicked() end

function MHC_Strider_Nets_Buttons_ClearButton:Clicked()
    MHC:Clear();
end

function MHC_Strider_Nets_Buttons_ShareButton:Clicked()
    MHC:ShareAssignments()
end

function MHC_Strider_Nets_Buttons_EditPlayerButton:Clicked()
    MHC:SetEditMode(not sessionVariables.editMode)
end

function MHC:ShareAssignments()
    local data = {}

    for i, name in pairs(sessionVariables.order) do
        local player = self:GetPlayerByName(name)
        local classId = CLASS_MAP[player.class]
        table.insert(data, {name, classId})
    end

    self:SendCompressedAddonMessage('sync', data)
    self:AlertDialog('Your list has been shared with the other players of the raid.')
end

function MHC:GetNextRequestId()
    REQUEST_COUNTER = REQUEST_COUNTER + 1
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local length = 12
    local randomString = ''

    charTable = {}
    for c in chars:gmatch"." do
        table.insert(charTable, c)
    end

    for i = 1, length do
        randomString = randomString .. charTable[random(1, #charTable)]
    end

    return UnitGUID("player")..'-'..randomString..'-'..REQUEST_COUNTER
end


function MHC:SendCompressedAddonMessage(type, data, channel, target)
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

function MHC:FindPacketRef(id)
    for i,ref in pairs(requestQueue) do
        if (ref.id == id) then
            return ref
        end
    end
    return nil
end

function MHC:CleanPacketRefs(id)
    local now = time()
    for i,ref in pairs(requestQueue) do
        if ((ref.time+30) <= now) then
            requestQueue[i] = nil
        end
    end
end

function MHC:SendRequest(type, data)
    if (data == nil) then
        data = {}
    end

    data.ID = MHC:GetNextRequestId()

    local packetRef = {}
    packetRef.id = data.ID
    packetRef.time = time()

    table.insert(requestQueue, packetRef)

    MHC:SendCompressedAddonMessage('REQ_'..type, data)
end

function MHC:SendResponse(type, id, data)
    if (data == nil) then
        data = {}
    end

    data.ID = id
    MHC:SendCompressedAddonMessage('RES_'..type, data)
end

function MHC:OnMessageAddonEvent(...)
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

    if (type == 'sync') then
        if (senderName == name) then return end
        MHC:OpenSyncDialog(sender, body.data);
    else
        local s = split(sender, '-')
        local packageName = split(type, '_')
        if (packageName[1] == 'REQ') then
            MHC:HandleRequest(packageName[2], s[1], body.data)
        elseif (packageName[1] == 'RES') then
            MHC:HandleResponse(packageName[2], s[1], body.data)
        elseif (packageName[1] == 'RC') then
            MHC:HandleRemoteCommand(packageName[2], s[1], body.data)
        end
    end
end

function MHC:HandleRequest(type, sender, payload)
    if (type == 'raid-status') then
        self:HandleRequest_RaidStatus(sender, payload)
    elseif (type == 'vashj-reset-nets') then
        self:HandleRequest_VashjResetNets(sender, payload)
    end
end

function MHC:GetRaidInfo()
    local roster = {}
    local memberCount = GetNumGroupMembers()
    for i=1, memberCount do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
        local player = {}
        player.index = i
        player.name = name
        player.rank = rank
        player.subgroup = subgroup
        table.insert(roster, player)
    end
    return player
end

function MHC:GetRaidMemberInfo(playerName)
    local roster = {}
    local memberCount = GetNumGroupMembers()
    for i=1, memberCount do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
        if (playerName == name) then
            local player = {}
            player.index = i
            player.name = name
            player.rank = rank
            player.subgroup = subgroup
            return player
        end
    end
    return nil
end

function MHC:SwapRaidMembers(name1, name2)
    local player1 = self:GetRaidMemberInfo(name1)
    local player2 = self:GetRaidMemberInfo(name2)

    if (player1 == nil) then 
        print(name1.. ' not found in raid')
        return false
    end

    if (player2 == nil) then 
        print(name2.. ' not found in raid')
        return false
    end
    print('swapping '.. player1.index .. ' <==> '.. player2.index)
    SwapRaidSubgroup(player1.index, player2.index)
    return true
end


function MHC:HandleRemoteCommand(type, sender, payload)
    if (type == 'groups-setmanager') then
        local name, realm = UnitName('player')
        self:SendRaidWarning('{star} '.. sender ..' promoted '..name..' to GROUPS-MANAGER {star}')
        isGroupsManager = true
    end
    if (type == 'groups-swap') then
        if (isGroupsManager) then
            if (self:SwapRaidMembers(payload.player1, payload.player2)) then
                self:SendRaidWarning('{triangle} Swapping '.. payload.player1 ..' <==> '..payload.player2..' {triangle}')
            else
                self:SendRaidWarning('{cross} Can not swap '.. payload.player1 ..' with '..payload.player2..' {cross}')
            end
        end
    end
end

function MHC:SendRaidWarning(message)
    SendChatMessage(message , "RAID_WARNING"); 
end

function MHC:HandleResponse(type, sender, payload)
    local ref = self:FindPacketRef(payload.ID)
    if (ref == nil) then
        return 
    end

    if (type == 'raid-status') then
        self:HandleResponse_RaidStatus(sender, payload)
    end
end

function MHC:HandleResponse_RaidStatus(sender, payload)
    print('|cFFFFFF00Player: '..strpadright(sender, 15)..' Status: Online    Version: '..payload.version)
end

function MHC:HandleRequest_RaidStatus(sender, payload)
    local data = {}
    data.version = VERSION
    data.time = time()
    self:SendResponse('raid-status', payload.ID, data)
end

function MHC:HandleRequest_VashjResetNets(sender, payload)
    if (self:HasPermission(sender)) then
        self:ResetOrder()
    end
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

function printHelp()
    print('Syntax: /mhc <command>')
    print('/mhc raid status')
    print('/mhc groups setmanager <player>')
    print('/mhc vashj')
    print('/mhc vashj add <player> <nets|cores>')
    print('/mhc vashj reset nets')
    print('/mhc version')
end

function command_vashj(params) 
    if (empty(params)) then
        MHC_Lady_Vashj:Show()
        return
    end

    local args = split(trim(params), ' ')
    local subCmd = args[1]

    if (subCmd == 'add') then
        if (empty(args[2]) or empty(args[3])) then
            printHelp()
            return
        end

        local player = trim(args[2])
        local type = trim(args[3])

        if (type == 'nets') then
            MHC:AddPlayer(MHC_Strider_Nets, player, nil, false)
        end
    elseif (subCmd == 'reset') then
        if (empty(args[2])) then
            printHelp()
            return
        end

        local type = trim(args[2])
        if (type == 'nets') then
            if (not (MHC:HasPermission('player'))) then
                print('|cFFFF0000You must be raid-assistant or raid-leader to reset Netherweave Net order.')
                return
            end

            MHC:SendRequest('vashj-reset-nets')
            print('|cFFFFFF00Netherweave Net order has been reset.')
        end
    else
        printHelp()
    end
end

function command_version(params) 
    print(ADDON_NAME..' v'..VERSION)
end

function command_raid(params) 
    if (empty(params)) then
        MHC_Lady_Vashj:Show()
        return
    end

    local args = split(trim(params), ' ')
    local subCmd = args[1]

    if (subCmd == 'status') then
        MHC:SendRequest('raid-status')
    end
end

function command_groups(params) 
    local args = split(trim(params), ' ')
    local subCmd = args[1]

    if (subCmd == 'setmanager') then
        if (empty(args[2])) then
            printHelp()
            return
        end

        local player = trim(args[2])
        print('|cFFFFFF00Promoting '..player..' to GROUPS-MANAGER')
        MHC:SendCompressedAddonMessage('RC_groups-setmanager', nil, 'WHISPER', player)
        return
    end

    if (subCmd == 'swap') then
        if (empty(args[2]) or empty(args[3])) then
            printHelp()
            return
        end

        local data = { }
        data.player1 = trim(args[2])
        data.player2 = trim(args[3])

        print('|cFFFFFF00Swapping '..data.player1..' with '..data.player2)

        MHC:SendCompressedAddonMessage('RC_groups-swap', data)
        return
    end

    RGS_RaidFrame:Show()
end

function MHC:AssertPermission(player, message)
    if (self:HasPermission(player)) then
        return true
    end
    print('|cFFFF0000'..message)
    return false
end

SLASH_MHC1 = "/mhc"
function SlashCmdList.MHC(body)
    local command, params = body:match('^(%S*)%s*(.-)$')

    if (command == 'vashj') then
        command_vashj(params)
    elseif (command == 'version') then
        command_version(params)
    elseif (command == 'raid') then
        command_raid(params)
    elseif (command == 'groups') then
        command_groups(params)
    else
        printHelp()
    end
end

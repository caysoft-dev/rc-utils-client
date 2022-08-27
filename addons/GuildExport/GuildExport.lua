local LibParse = LibStub('LibParse')
local AceGUI = LibStub('AceGUI-3.0')
local LibBase64 = LibStub('LibBase64-1.0')

function createFrame(data)
    local frame = AceGUI:Create('Frame')
    frame:SetTitle('Guild Roster Export')
    frame:SetStatusText('This encoded data set contains general information about your guild roster.')
    frame:SetLayout('fill')

    local editBox = AceGUI:Create('MultiLineEditBox')
    editBox:SetText(data)
    editBox:DisableButton(true)
    editBox:SetFocus()
    editBox:HighlightText()
    frame:SetCallback('OnClose', function(widget) AceGUI:Release(widget) end)
    editBox:SetLabel('Copy (CTRL+C) and paste (CTRL+V) the data below on the website')
    frame:AddChild(editBox)

    _G['GuildExportFrame'] = frame.frame
    table.insert(UISpecialFrames, 'GuildExportFrame')
end

SLASH_GUILDEXPORT1 = '/guildexport'
function SlashCmdList.GUILDEXPORT(body)
    guildData = {}
    members = {}
    ranks = {}

    local numTotalMembers = GetNumGuildMembers();
    for i=1,numTotalMembers do
        name, rank, rankIndex, level, class, zone, note = GetGuildRosterInfo(i);

        member = {}
        member.name = name
        member.class = class
        member.level = level
        member.rankIndex = rankIndex
        member.rank = rank
        member.note = note
        table.insert(members, member)
    end

    local numTotalRanks = GuildControlGetNumRanks()
    for i=1,numTotalRanks do
        rankName = GuildControlGetRankName(i);

        rank = {}
        rank.index = i
        rank.name = rankName

        table.insert(ranks, rank)
    end

    guildData.members = members
    guildData.ranks = ranks

    json = LibParse:JSONEncode(guildData)
    base64 = LibBase64.Encode(json)
    createFrame(base64)
end

GuildDeposit = LibStub("AceAddon-3.0"):NewAddon("GuildDeposit")
local Timer = LibStub("AceTimer-3.0")
local _, L = ...
local GBSlots = 98

function GuildDeposit:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("GuildDepositDB", self.defaults, true)
    self.conf = self.db.profile
    self:SetupConfig()
    self:CreateProgressFrame()
    self:Events()
end

function GuildDeposit:OnGuildBankClose() self.ProgressFrame:Hide() end

function GuildDeposit:Events()
    self.GB_CLOSED = CreateFrame('Frame')
    self.GB_CLOSED:RegisterEvent('GUILDBANKFRAME_CLOSED')
    self.GB_CLOSED:SetScript("OnEvent", function() self.ProgressFrame:Hide() end)

    self.GB_OPEN = CreateFrame('Frame')
    self.GB_OPEN:RegisterEvent('GUILDBANKFRAME_OPENED')
    self.GB_OPEN:SetScript("OnEvent", function()
        if self.conf.autoDeposit then self:StartDeposit() end
    end)
end

-- add entry to map ass well as link and item name in a separate table
function GuildDeposit:AddMap(id, tab)
    local name, link = GetItemInfo(id)
    if name and link then
        print(link)
        table.insert(self.conf.itemInfo, id, {name = name, link = link})
    end
    table.insert(self.conf.map, id, tab)
end

-- add all items from specified bag to the mappings
-- TODO: ignore soulbound
function GuildDeposit:MapBag(bag, tab)
    local slots = GetContainerNumSlots(bag)
    for i = 1, slots, 1 do
        local id = GetContainerItemID(bag, i)
        if id then self:AddMap(id, tab) end
    end
    print("MapBag for bag " .. bag .. " to tab " .. tab .. " complete")
end

-- add all items from a specified guild bank tab to the mappings
function GuildDeposit:MapTab(tab)
    for i = 1, GBSlots, 1 do
        local link = GetGuildBankItemLink(tab, i)
        if link then
            local id = GetItemInfoInstant(link)
            self:AddMap(id, tab)
        end
    end
    print("MapTab for tab " .. tab .. " complete")
end

-- print any table
function GuildDeposit:PrintTable(table)
    for k, v in pairs(table) do print(k .. ": " .. v) end
end

-- print map
function GuildDeposit:PrintMap() self:PrintTable(self.conf.map) end

-- clear whole map
function GuildDeposit:ClearMap()
    self.conf.map = {}
    print("map cleared")
end

-- compose list of items that have to be deposited and where they can be placed
function GuildDeposit:ToDeposit()
    -- reset deposit list, just in case it wasn't emptied last time
    self.depositList = {}
    -- get guild bank free slots for each tab
    self:GBFreeSlots()
    -- scan through bags
    for b = 0, 4, 1 do
        -- bag size
        local slots = GetContainerNumSlots(b)
        for i = 1, slots do
            -- check id in map
            local id = GetContainerItemID(b, i)
            if id and self.conf.map[id] then
                local tab = self.conf.map[id]
                table.insert(self.depositList, {
                    id = id,
                    from_bag = b,
                    from_slot = i,
                    to_tab = tab,
                    to_slot = self:GetGuildHead(tab)
                })
            end
        end
    end
end

-- compose list of items to withdraw from tab
function GuildDeposit:ToWithdraw(tab)
    self.withdrawList = {}
    for i = 1, GBSlots, 1 do
        local link = GetGuildBankItemLink(tab, i)
        if link then
            table.insert(self.withdrawList, {tab = tab, slot = i})
        end
    end
end

-- scan through guild bank and get the free slots for each tab
function GuildDeposit:GBFreeSlots()
    -- reset table
    self.guildBankSlots = {}
    local tabs = GetNumGuildBankTabs()
    for t = 1, tabs, 1 do
        local tab_free = {}
        for i = 1, GBSlots, 1 do
            if not GetGuildBankItemLink(t, i) then
                table.insert(tab_free, i)
            end
        end
        -- store free slots in tab
        self.guildBankSlots[t] = tab_free
    end
end

-- store items
function GuildDeposit:DoMoves()
    GuildDeposit:ToDeposit()
    local interval = self.conf.interval
    Timer:ScheduleRepeatingTimer("MoveHead", interval)
end

-- remove and return head of the table of items to move
function GuildDeposit:GetHead()
    local item = table.remove(self.depositList, 1)
    if item then
        return item.id, item.from_bag, item.from_slot, item.to_tab, item.to_slot
    end
    return
end

-- remove and return first free slots in guild bank
function GuildDeposit:GetGuildHead(tab)
    local t = tonumber(tab)
    return table.remove(self.guildBankSlots[t], 1)
end

-- perform one move
function GuildDeposit:MoveHead()
    local _, from_bag, from_slot, to_tab, to_slot = self:GetHead()
    if from_bag and from_slot and to_tab and to_slot then
        PickupContainerItem(from_bag, from_slot)
        PickupGuildBankItem(to_tab, to_slot)
    else
        self:EndDeposit()
    end
end

-- stop storing process
function GuildDeposit:EndDeposit()
    Timer:CancelAllTimers()
    self.ProgressFrame:Hide()
    print(L["Deposit complete!"])
end

function GuildDeposit:WithdrawHead()
    local item = table.remove(self.withdrawList, 1)
    if item then
        AutoStoreGuildBankItem(item.tab, item.slot)
    else
        self:EndDeposit()
    end
end

function GuildDeposit:ProgressFrame_OnUpdate(elapsed)
    self.Info.timer = self.Info.timer - elapsed
    if (self.Info.timer > 0) then return end
    self.Info.timer = self.Info.interval
    if (self.Info.counter >= self.Info.max) then self.Info.counter = 0 end
    self.status:SetValue(self.Info.counter)
    self.Info.counter = self.Info.counter + 1
    self.status.text:SetText((self.Info.counter) .. " / " .. (self.Info.max))
    if self.Info.withdraw then
        GuildDeposit:WithdrawHead()
    else
        GuildDeposit:MoveHead()
    end
end

-- create progress bar frame
function GuildDeposit:CreateProgressFrame()
    self.ProgressFrame = CreateFrame("Frame", "GuildDepositProgressFrame",
                                     self.UIParent)
    self.ProgressFrame:Size(140, 40)
    self.ProgressFrame:Point("CENTER", self.UIParent)
    self.ProgressFrame:CreateBackdrop("Transparent")
    self.ProgressFrame:SetAlpha(self.conf.showStatus and 1 or 0)

    self.ProgressFrame.title = self.ProgressFrame:CreateFontString(nil,
                                                                   "OVERLAY")
    self.ProgressFrame.title:FontTemplate(nil, 10, "OUTLINE")
    self.ProgressFrame.title:Point("TOP", self.ProgressFrame, "TOP", 0, -2)
    self.ProgressFrame.title:SetText(L["Deposit Items"])

    self.ProgressFrame.status = CreateFrame("StatusBar",
                                            "GuildDepositProgressFrameStatus",
                                            self.ProgressFrame)
    self.ProgressFrame.status:Size(116, 18)
    self.ProgressFrame.status:Point("BOTTOM", self.ProgressFrame, "BOTTOM", 0, 4)
    self.ProgressFrame.status:SetStatusBarTexture("status.bmp")
    self.ProgressFrame.status:SetStatusBarColor(0, 1, 1)
    self.ProgressFrame.status:CreateBackdrop("Transparent")

    self.ProgressFrame.status.animation =
        self.ProgressFrame.status:CreateAnimationGroup()
    self.ProgressFrame.status.animation.progress =
        self.ProgressFrame.status.animation:CreateAnimation("Progress")
    self.ProgressFrame.status.animation.progress:SetSmoothing("OUT")
    self.ProgressFrame.status.animation.progress:SetDuration(.4)

    self.ProgressFrame.status.text = self.ProgressFrame.status:CreateFontString(
                                         nil, "OVERLAY")
    self.ProgressFrame.status.text:FontTemplate(nil, 9, "OUTLINE")
    self.ProgressFrame.status.text:Point("CENTER", self.ProgressFrame.status)
    self.ProgressFrame.status.text:SetText("0s")

    self.ProgressFrame.Info = {
        interval = 0,
        timer = 0,
        max = 0,
        counter = 0,
        whithdraw = false,
    }

    self.ProgressFrame:SetScript("OnUpdate", self.ProgressFrame_OnUpdate)

    self.ProgressFrame:Hide()
end

function GuildDeposit:StartDeposit()
    self:ToDeposit()
    self.ProgressFrame:SetAlpha(self.conf.showStatus and 1 or 0)
    self.ProgressFrame.Info.interval = self.conf.depositInterval
    self.ProgressFrame.Info.timer = 0
    self.ProgressFrame.Info.max = table.getn(self.depositList)
    self.ProgressFrame.Info.counter = 0
    self.ProgressFrame.Info.withdraw = false

    self.ProgressFrame.status:SetValue(0)
    self.ProgressFrame.status:SetMinMaxValues(0, self.ProgressFrame.Info.max)

    self.ProgressFrame:Show()
end

function GuildDeposit:StartWithdraw(tab)
    self:ToWithdraw(tab)
    self.ProgressFrame:SetAlpha(self.conf.showStatus and 1 or 0)
    self.ProgressFrame.Info.interval = self.conf.withdrawInterval
    self.ProgressFrame.Info.timer = 0
    self.ProgressFrame.Info.items = self.withdrawList
    self.ProgressFrame.Info.max = table.getn(self.withdrawList)
    self.ProgressFrame.Info.counter = 0
    self.ProgressFrame.Info.withdraw = true

    self.ProgressFrame.status:SetValue(0)
    self.ProgressFrame.status:SetMinMaxValues(0, self.ProgressFrame.Info.max)

    self.ProgressFrame:Show()
end

SLASH_TEST1 = "/test"
SlashCmdList["TEST"] = function(msg) GuildDeposit:StartDeposit() end

SLASH_GDDEPOSIT1 = "/gdeposit"
SLASH_GDDEPOSIT2 = "/gdep"
SlashCmdList["GDDEPOSIT"] = function(msg) GuildDeposit:StartDeposit() end

SLASH_GDGUILDDEPOSIT1 = "/guilddeposit"
SLASH_GDGUILDDEPOSIT2 = "/gd"
SlashCmdList["GDGUILDDEPOSIT"] = function(msg)
    InterfaceOptionsFrame_OpenToCategory("GuildDeposit")
end

SLASH_GDMAPBAG1 = "/gdbag"
SlashCmdList["GDMAPBAG"] = function(msg)
    local arg1, arg2 = strsplit(" ", msg)
    if arg1 and arg2 then
        GuildDeposit:MapBag(tonumber(arg1), tonumber(arg2))
    else
        print("Usage: /gbbag <bag_number> <tab_number>")
    end
end

SLASH_GDMAPTAB1 = "/gdtab"
SlashCmdList["GDMAPTAB"] = function(msg)
    local arg1 = strsplit(" ", msg)
    if arg1 and string.len(arg1) > 0 then
        GuildDeposit:MapTab(tonumber(arg1))
    elseif GetCurrentGuildBankTab() then
        local tab = GetCurrentGuildBankTab()
        if tab then
            GuildDeposit:MapTab(tab)
        else
            print("tab could not be found")
        end
    end
end

SLASH_GDWITHDRAW1 = "/gdwithdraw"
SlashCmdList["GDWITHDRAW"] = function(msg)
    local arg1 = strsplit(" ", msg)
    if arg1 and string.len(arg1) > 0 then
        GuildDeposit:StartWithdraw(tonumber(arg1))
    elseif GetCurrentGuildBankTab() then
        local tab = GetCurrentGuildBankTab()
        if tab then
            GuildDeposit:StartWithdraw(tab)
        else
            print("tab could not be found")
        end
    end
end

SLASH_GDMAPCLEAR1 = "/gdclear"
SlashCmdList["GDMAPCLEAR"] = function(msg) GuildDeposit:ClearMap() end

SLASH_GDMAPPRINT1 = "/gdprint"
SlashCmdList["GDMAPPRINT"] = function(msg) GuildDeposit:PrintMap() end

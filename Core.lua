
GuildDeposit = LibStub("AceAddon-3.0"):NewAddon("GuildDeposit", "AceTimer-3.0")
local _, L = ...
local GBSlots = 98
local bank_map = {[168649]=3, [152510]=1}

function GuildDeposit:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("GuildDepositDB", self.defaults, true)
    self.conf = self.db.profile
    self:SetupConfig()
    self:CreateProgressFrame()
    -- self.db.mappings =  {[168649]=3, [152510]=1}
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
        for i=1,slots do
            -- check id in map
            local id = GetContainerItemID(b,i)
            if id and bank_map[id] then
                local tab = bank_map[id]
                table.insert(self.depositList, {
                    id=id,
                    from_bag=b,
                    from_slot=i,
                    to_tab=tab,
                    to_slot=self:GetGuildHead(tab)
                })
            end
        end
    end
end

-- scan through guild bank and get the free slots for each tab
function GuildDeposit:GBFreeSlots()
    -- reset table
    self.guildBankSlots = {}
    local tabs = GetNumGuildBankTabs()
    for t = 0, (tabs-1), 1 do
        local tab_free = {}
        for i = 1, GBSlots, 1 do
            if not GetGuildBankItemLink(t,i) then
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
    self:ScheduleRepeatingTimer("MoveHead", interval)
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
    return table.remove(self.guildBankSlots[tab], 1)
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
    self:CancelAllTimers()
    self.ProgressFrame:Hide()
    print(L["Deposit complete!"])
end

function GuildDeposit:ProgressFrame_OnUpdate(elapsed)
    self.Info.timer = self.Info.timer - elapsed
    if (self.Info.timer > 0) then return end
    self.Info.timer = self.Info.interval
    if (self.Info.counter >= self.Info.max) then self.Info.counter = 0 end
    self.status:SetValue(self.Info.counter)
    self.Info.counter = self.Info.counter + 1
    self.status.text:SetText((self.Info.counter).." / "..(self.Info.max))
    GuildDeposit:MoveHead()
end

-- create progress bar frame
function GuildDeposit:CreateProgressFrame()
    self.ProgressFrame = CreateFrame("Frame", "GuildDepositProgressFrame", self.UIParent)
    self.ProgressFrame:Size(140,40)
	self.ProgressFrame:Point("CENTER", self.UIParent)
    self.ProgressFrame:CreateBackdrop("Transparent")
    self.ProgressFrame:SetAlpha(1)

    self.ProgressFrame.title = self.ProgressFrame:CreateFontString(nil, "OVERLAY")
    self.ProgressFrame.title:FontTemplate(nil, 12, "OUTLINE")
    self.ProgressFrame.title:Point("TOP", self.ProgressFrame, "TOP", 0, -2)
    self.ProgressFrame.title:SetText(L["Deposit Items"])

    self.ProgressFrame.status = CreateFrame("StatusBar", "GuildDepositProgressFrameStatus", self.ProgressFrame)
    self.ProgressFrame.status:Size(116, 18)
    self.ProgressFrame.status:Point("BOTTOM", self.ProgressFrame, "BOTTOM", 0, 4)
    self.ProgressFrame.status:SetStatusBarTexture("status.bmp")
    self.ProgressFrame.status:SetStatusBarColor(0,1,1)
    self.ProgressFrame.status:CreateBackdrop("Transparent")

    self.ProgressFrame.status.animation = self.ProgressFrame.status:CreateAnimationGroup()
    self.ProgressFrame.status.animation.progress = self.ProgressFrame.status.animation:CreateAnimation("Progress")
    self.ProgressFrame.status.animation.progress:SetSmoothing("OUT")
    self.ProgressFrame.status.animation.progress:SetDuration(.2)

    self.ProgressFrame.status.text = self.ProgressFrame.status:CreateFontString(nil, "OVERLAY")
    self.ProgressFrame.status.text:FontTemplate(nil, 12, "OUTLINE")
    self.ProgressFrame.status.text:Point("CENTER", self.ProgressFrame.status)
    self.ProgressFrame.status.text:SetText("0s")


    self.ProgressFrame.Info = {
        interval = 0,
        timer = 0,
        items = {},
        max = 0,
        counter = 0
    }

    self.ProgressFrame:SetScript("OnUpdate", self.ProgressFrame_OnUpdate)

    self.ProgressFrame:Hide()
end

function GuildDeposit:StartDeposit()
    self:ToDeposit()
    self.ProgressFrame.Info.interval = self.conf.interval
    self.ProgressFrame.Info.timer = 0
    self.ProgressFrame.Info.items = self.depositList
    self.ProgressFrame.Info.max = table.getn(self.depositList)
    self.ProgressFrame.Info.counter = 0

    self.ProgressFrame.status:SetValue(0)
    self.ProgressFrame.status:SetMinMaxValues(0, self.ProgressFrame.Info.max)

    self.ProgressFrame:Show()
end

SLASH_TEST1="/test"
SlashCmdList["TEST"]=function(msg)
    GuildDeposit:StartDeposit()
end

SLASH_DEPOSIT1="/deposit"
SLASH_DEPOSIT2="/dep"
SlashCmdList["DEPOSIT"]=function(msg)
    GuildDeposit:DoMoves()
end

SLASH_GUILDDEPOSIT1="/guilddeposit"
SLASH_GUILDDEPOSIT2="/gdep"
SLASH_GUILDDEPOSIT3="/gd"
SlashCmdList["GUILDDEPOSIT"] = function (msg)
    InterfaceOptionsFrame_OpenToCategory("GuildDeposit")
end
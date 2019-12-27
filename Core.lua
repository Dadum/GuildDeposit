
GuildDeposit = LibStub("AceAddon-3.0"):NewAddon("GuildDeposit", "AceTimer-3.0")
local GBSlots = 98
local curr_bag = 0
local bag_scan, bag_head, b_free = {}, {}, {}
local bank_map = {[168649]=3, [152510]=1}

function GuildDeposit:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("GuildDepositDB", defaults, true)

    if self.SetupConfig then
        self.SetupConfig()
    end
end

function GuildDeposit:ToDeposit()
    self:GBFreeSlots()
    bag_scan = {}
    for b = 0, 4, 1 do
        local slots = GetContainerNumSlots(b)
        for i=1,slots do
            local id = GetContainerItemID(b,i)
            if id and bank_map[id] then
                local tab = bank_map[id]
                table.insert(bag_scan, {
                    id=id, 
                    from_bag=b, 
                    from_slot=i, 
                    to_tab=tab, 
                    to_slot=self:GetGuildHead(tab)
                })
            end
        end
    end
    return 
end

function GuildDeposit:GBFreeSlots()
    b_free = {}
    local tabs = GetNumGuildBankTabs()
    for t = 0, (tabs-1), 1 do
        local tab_free = {}
        for i = 1, GBSlots, 1 do 
            if not GetGuildBankItemLink(t,i) then
                table.insert(tab_free, i)
            end
        end
        b_free[t] = tab_free
    end
    return
end

function GuildDeposit:DoMoves()
    GuildDeposit:ToDeposit()
    self:ScheduleRepeatingTimer("MoveHead", 0.5)
end

function GuildDeposit:GetHead()
    local item = table.remove(bag_scan, 1)
    if not item then return end
    return item.id, item.from_bag, item.from_slot, item.to_tab, item.to_slot
end

function GuildDeposit:GetGuildHead(tab)
    return table.remove(b_free[tab], 1)
end

function GuildDeposit:MoveHead()
    local _, from_bag, from_slot, to_tab, to_slot = self:GetHead()
    if from_bag and from_slot and to_tab and to_slot then
        PickupContainerItem(from_bag, from_slot)
        PickupGuildBankItem(to_tab, to_slot)
    else
        self:CancelAllTimers()
        print("Deposit complete")

    end
end


SLASH_TEST1="/test"
SlashCmdList["TEST"]=function(msg)
    GuildDeposit:DoMoves()
end

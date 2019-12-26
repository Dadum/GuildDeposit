
GuildDeposit = LibStub("AceAddon-3.0"):NewAddon("GuildDeposit", "AceTimer-3.0")
local GBSlots = 98
local curr_bag = 0
local bag_scan, bag_head, b_free = {}, {}, {}
local bank_map = {[168649]=3}

function GuildDeposit:ToDeposit()
    curr_bag = 0
    local dredged = 168649
    bag_scan = {}
    for b = 0, 4, 1 do
        local slots = GetContainerNumSlots(b)
        local t_bag = {}
        for i=1,slots do
            local id = GetContainerItemID(b,i)
            if id and id == dredged then
                table.insert(t_bag, {slot=i, id=id})
            end
        end
        bag_scan[b] = t_bag
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
    GuildDeposit:GBFreeSlots()
    self:ScheduleRepeatingTimer("MoveHead", 0.5)
end

function GuildDeposit:GetBagHead()
    local item = table.remove(bag_scan[curr_bag], 1)
    if not item then 
        -- bag_head = table.remove(bag_scan, 1)
        curr_bag = curr_bag + 1
        if curr_bag > 4 then
            return
        end
        return self:GetBagHead()
    end
    local slot = item.slot
    local id = item.id
    return slot, id
end

function GuildDeposit:GetGuildHead(tab)
    return table.remove(b_free[tab], 1)
end

function GuildDeposit:MoveHead()
    local item, id = self:GetBagHead()
    if item and id then
        local tab = bank_map[id]
        local slot = self:GetGuildHead(tab)
        PickupContainerItem(curr_bag,item)
        PickupGuildBankItem(tab,slot)
    else
        self:CancelAllTimers()
        print("Deposit complete")
    end
end


SLASH_TEST1="/test"
SlashCmdList["TEST"]=function(msg)
    GuildDeposit:DoMoves()
end

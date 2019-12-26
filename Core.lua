
GuildDeposit = LibStub("AceAddon-3.0"):NewAddon("GuildDeposit", "AceTimer-3.0")
local GBSlots = 98
local curr_bag = 0
local bag_scan, bag_head, b_free = {}, {}, {}

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
                table.insert(t_bag, i)
            end
        end
        bag_scan[b] = t_bag
    end
    return 
end

function GuildDeposit:GBFreeSlots()
    local free = {}
        for i = 1, GBSlots, 1 do 
            if not GetGuildBankItemLink(3,i) then
                table.insert(free, i)
            end
        end
    return free
end

function GuildDeposit:DoMoves()
    GuildDeposit:ToDeposit()
    b_free = GuildDeposit:GBFreeSlots()
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
    return item
end

function GuildDeposit:MoveHead()
    local item = self:GetBagHead()
    local slot = table.remove(b_free, 1)
    if item and slot then
        PickupContainerItem(curr_bag,item)
        PickupGuildBankItem(3,slot)
    else
        self:CancelAllTimers()
    end
end


SLASH_TEST1="/test"
SlashCmdList["TEST"]=function(msg)
    GuildDeposit:DoMoves()
end

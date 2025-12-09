UCore = UCore or {}
UCore.Players = UCore.Players or {}

UCore.Player = {}
UCore.Player.__index = UCore.Player

function UCore.Player.new(src, account, character)
    local self = setmetatable({}, UCore.Player)
    self.source = src
    self.accountId = account.id
    self.accountIdentifier = account.identifier
    self.accountGroup = account["group"] or "user"
    self.charId = character.id
    self.firstname = character.firstname
    self.lastname = character.lastname
    self.gender = character.gender
    self.money = character.money or 0
    self.bank = character.bank or 0
    self.pos_x = character.pos_x or 0.0
    self.pos_y = character.pos_y or 0.0
    self.pos_z = character.pos_z or 0.0
    self.heading = character.heading or 0.0
    UCore.Players[src] = self
    return self
end

function UCore.Player:GetSource()
    return self.source
end

function UCore.Player:GetAccountId()
    return self.accountId
end

function UCore.Player:GetIdentifier()
    return self.accountIdentifier
end

function UCore.Player:GetGroup()
    return self.accountGroup
end

function UCore.Player:GetCharId()
    return self.charId
end

function UCore.Player:GetName()
    return self.firstname .. " " .. self.lastname
end

function UCore.Player:GetMoney()
    return self.money
end

function UCore.Player:GetBank()
    return self.bank
end

function UCore.Player:GetPosition()
    return self.pos_x, self.pos_y, self.pos_z, self.heading
end

function UCore.Player:AddMoney(amount)
    self.money = self.money + amount
    DB.execute("UPDATE characters SET money = ? WHERE id = ?", { self.money, self.charId })
end

function UCore.Player:RemoveMoney(amount)
    self.money = self.money - amount
    DB.execute("UPDATE characters SET money = ? WHERE id = ?", { self.money, self.charId })
end

function UCore.Player:AddBank(amount)
    self.bank = self.bank + amount
    DB.execute("UPDATE characters SET bank = ? WHERE id = ?", { self.bank, self.charId })
end

function UCore.Player:RemoveBank(amount)
    self.bank = self.bank - amount
    DB.execute("UPDATE characters SET bank = ? WHERE id = ?", { self.bank, self.charId })
end

function UCore.GetPlayer(src)
    return UCore.Players[src]
end

function UCore.GetPlayerByIdentifier(identifier)
    for _, player in pairs(UCore.Players) do
        if player.accountIdentifier == identifier then
            return player
        end
    end
    return nil
end

function UCore.RemovePlayer(src)
    UCore.Players[src] = nil
end

function GetPlayer(src)
    return UCore.GetPlayer(src)
end

function GetPlayerByIdentifier(identifier)
    return UCore.GetPlayerByIdentifier(identifier)
end

function GetCharactersByAccountId(accountId, cb)
    DB.fetchAll("SELECT * FROM characters WHERE account_id = ?", { accountId }, function(result)
        cb(result)
    end)
end

function GetCharacterById(id, cb)
    DB.fetchAll("SELECT * FROM characters WHERE id = ? LIMIT 1", { id }, function(result)
        cb(result[1])
    end)
end

function CreateCharacter(accountId, firstname, lastname, gender, cb)
    DB.insert("INSERT INTO characters (account_id, firstname, lastname, gender, money, bank, pos_x, pos_y, pos_z, heading) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", {
        accountId,
        firstname,
        lastname,
        gender or 0,
        Config.StartMoney,
        Config.StartBank,
        Config.InitialSpawn.x,
        Config.InitialSpawn.y,
        Config.InitialSpawn.z,
        Config.InitialSpawn.heading
    }, function(id)
        if cb then
            cb(id)
        end
    end)
end

function DeleteCharacter(id, cb)
    DB.execute("DELETE FROM characters WHERE id = ?", { id }, function(affected)
        if cb then
            cb(affected)
        end
    end)
end

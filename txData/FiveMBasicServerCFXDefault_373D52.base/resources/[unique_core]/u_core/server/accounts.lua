function GetAccountByIdentifier(identifier, cb)
    DB.fetchAll("SELECT * FROM accounts WHERE identifier = ? LIMIT 1", { identifier }, function(result)
        cb(result[1])
    end)
end

function CreateAccount(identifier, name, cb)
    DB.insert("INSERT INTO accounts (identifier, name, is_whitelisted, `group`) VALUES (?, ?, ?, ?)", { identifier, name, 0, "user" }, function(id)
        if cb then
            cb(id)
        end
    end)
end

function SetAccountWhitelisted(id, state)
    local value = state and 1 or 0
    DB.execute("UPDATE accounts SET is_whitelisted = ? WHERE id = ?", { value, id })
end

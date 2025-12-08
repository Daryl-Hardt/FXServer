local function GetLicenseIdentifier(src)
    local identifiers = GetPlayerIdentifiers(src)
    for _, v in ipairs(identifiers) do
        if string.sub(v, 1, 7) == "license" then
            return v
        end
    end
    return nil
end

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    deferrals.defer()

    local src = source
    local identifier = GetLicenseIdentifier(src)

    if not identifier then
        deferrals.done(Config.KickMessageNoIdentifier)
        return
    end

    if not Config.EnableWhitelist then
        deferrals.done()
        return
    end

    deferrals.update("Überprüfe Whitelist...")

    exports['u_core']:GetAccountByIdentifier(identifier, function(account)
        if not account then
            exports['u_core']:CreateAccount(identifier, name, function()
                print("[u_login] Neuer Account: " .. identifier .. " (nicht gewhitelistet)")
                deferrals.done(Config.KickMessageNotWhitelisted)
            end)
            return
        end

        if account.is_whitelisted == true then
            print("[u_login] Whitelist OK für " .. identifier .. " (" .. name .. ")")
            deferrals.done()
        else
            print("[u_login] Whitelist blockiert " .. identifier .. " (" .. name .. ")")
            deferrals.done(Config.KickMessageNotWhitelisted)
        end
    end)
end)

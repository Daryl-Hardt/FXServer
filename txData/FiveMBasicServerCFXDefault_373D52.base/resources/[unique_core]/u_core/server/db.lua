DB = {}

function DB.fetchAll(query, params, cb)
    MySQL.query(query, params or {}, function(result)
        cb(result)
    end)
end

function DB.fetchScalar(query, params, cb)
    MySQL.scalar(query, params or {}, function(result)
        cb(result)
    end)
end

function DB.execute(query, params, cb)
    MySQL.update(query, params or {}, function(affected)
        if cb then
            cb(affected)
        end
    end)
end

function DB.insert(query, params, cb)
    MySQL.insert(query, params or {}, function(id)
        if cb then
            cb(id)
        end
    end)
end

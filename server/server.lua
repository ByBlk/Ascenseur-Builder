ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local ascenseurs = {}

function chargerAscenseurs()
    ascenseurs = {}
    MySQL.Async.fetchAll("SELECT * FROM ascenseurs", {}, function(results)
        for _, ascenseur in ipairs(results) do
            ascenseurs[ascenseur.id] = { id = ascenseur.id, name = ascenseur.name, etages = {} }
        end

        MySQL.Async.fetchAll("SELECT * FROM ascenseurs_etages", {}, function(etages)
            for _, etage in ipairs(etages) do
                if ascenseurs[etage.ascenseur_id] then
                    table.insert(ascenseurs[etage.ascenseur_id].etages, {
                        id = etage.id,
                        number = etage.etage_number,
                        coords = vector3(etage.pos_x, etage.pos_y, etage.pos_z)
                    })
                end
            end
            TriggerClientEvent("ascenseur:refresh", -1, ascenseurs)
        end)
    end)
end

MySQL.ready(function()
    chargerAscenseurs()
end)

function tableperm(table, element)
    for _, value in ipairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

RegisterServerEvent("ascenseur:checkPermission")
AddEventHandler("ascenseur:checkPermission", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local playerGroup = xPlayer.getGroup()
        if tableperm(Config.Perms, playerGroup) then
            TriggerClientEvent("ascenseur:openMenu", source)
        else
            TriggerClientEvent("esx:showNotification", source, "~r~Vous n'avez pas la permission d'ouvrir ce menu.")
        end
    end
end)

RegisterServerEvent("ascenseur:create")
AddEventHandler("ascenseur:create", function(name)
    MySQL.Async.insert("INSERT INTO ascenseurs (name) VALUES (@name)", {
        ["@name"] = name
    }, function(insertId)
        chargerAscenseurs()
    end)
end)

RegisterServerEvent("ascenseur:updateetage")
AddEventHandler("ascenseur:updateetage", function(ascenseurId, etageNumber, coords)
    MySQL.Async.fetchScalar("SELECT id FROM ascenseurs_etages WHERE ascenseur_id = @ascenseurId AND etage_number = @etageNumber", {
        ["@ascenseurId"] = ascenseurId,
        ["@etageNumber"] = etageNumber
    }, function(etageId)
        if etageId then
            MySQL.Async.execute("UPDATE ascenseurs_etages SET pos_x = @x, pos_y = @y, pos_z = @z WHERE id = @id", {
                ["@x"] = coords.x, ["@y"] = coords.y, ["@z"] = coords.z, ["@id"] = etageId
            })
        else
            MySQL.Async.insert("INSERT INTO ascenseurs_etages (ascenseur_id, etage_number, pos_x, pos_y, pos_z) VALUES (@ascenseurId, @etageNumber, @x, @y, @z)", {
                ["@ascenseurId"] = ascenseurId, ["@etageNumber"] = etageNumber, ["@x"] = coords.x, ["@y"] = coords.y, ["@z"] = coords.z
            })
        end
        chargerAscenseurs()
    end)
end)

RegisterServerEvent("ascenseur:deleteAscenseur")
AddEventHandler("ascenseur:deleteAscenseur", function(ascenseurId)
    MySQL.Async.execute("DELETE FROM ascenseurs_etages WHERE ascenseur_id = @ascenseurId", {
        ["@ascenseurId"] = ascenseurId
    }, function()
        MySQL.Async.execute("DELETE FROM ascenseurs WHERE id = @ascenseurId", {
            ["@ascenseurId"] = ascenseurId
        }, function()
            chargerAscenseurs()
        end)
    end)
end)

RegisterServerEvent("ascenseur:deleteEtage")
AddEventHandler("ascenseur:deleteEtage", function(ascenseurId, etageNumber)
    MySQL.Async.execute("DELETE FROM ascenseurs_etages WHERE ascenseur_id = @ascenseurId AND etage_number = @etageNumber", {
        ["@ascenseurId"] = ascenseurId, ["@etageNumber"] = etageNumber
    }, function()
        chargerAscenseurs()
    end)
end)

RegisterServerEvent("ascenseur:sync")
AddEventHandler("ascenseur:sync", function()
    TriggerClientEvent("ascenseur:refresh", source, ascenseurs)
end)

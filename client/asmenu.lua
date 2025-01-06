local ascenseurs = {}
local actuelAscenseur = nil
local activeMarkers = {}

RegisterNetEvent("ascenseur:refresh")
AddEventHandler("ascenseur:refresh", function(dataPartiel)
    ascenseurs = {}
    activeMarkers = {}
    for id, ascenseur in pairs(dataPartiel) do
        ascenseurs[id] = ascenseur
        for _, etage in ipairs(ascenseur.etages) do
            table.insert(activeMarkers, etage.coords)
        end
    end
end)

Citizen.CreateThread(function()
    TriggerServerEvent("ascenseur:sync")
end)

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local procheAscenseur = false

        for _, ascenseur in pairs(ascenseurs) do
            for _, etage in ipairs(ascenseur.etages) do
                local distance = #(playerCoords - etage.coords)

                if distance < Config.DistanceVu then
                    procheAscenseur = true
                    DrawMarker(Config.Marker, etage.coords.x, etage.coords.y, etage.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, Config.Couleurpoint[1], Config.Couleurpoint[2], Config.Couleurpoint[3], false, true, 2, false, nil, nil, false)
                end

                if distance < Config.DistanceAction then
                    procheAscenseur = true
                    actuelAscenseur = { id = ascenseur.id, name = ascenseur.name, etages = ascenseur.etages, currentFloor = etage.number }
                    ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour utiliser l'ascenseur.")
                    
                    if IsControlJustReleased(0, 38) then
                        ouvrirMenuAscenseur(actuelAscenseur)
                    end
                end
            end
        end

        Citizen.Wait(procheAscenseur and 0 or 500)
    end
end)

function ouvrirMenuAscenseur(ascenseur)
    RMenu.Add('ascenseur', 'teleport', RageUI.CreateMenu("Ascenseur", "Choisissez un étage"))
    RageUI.Visible(RMenu:Get('ascenseur', 'teleport'), true)

    Citizen.CreateThread(function()
        while RageUI.Visible(RMenu:Get('ascenseur', 'teleport')) do
            RageUI.IsVisible(RMenu:Get('ascenseur', 'teleport'), function()
                for _, etage in ipairs(ascenseur.etages) do
                    if etage.number ~= ascenseur.currentFloor then
                        RageUI.Button("Étage " .. etage.number, nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                teleporterVersEtage(etage.coords)
                                RageUI.CloseAll()
                            end
                        })
                    end
                end
            end)
            Citizen.Wait(0)
        end
    end)
end

function teleporterVersEtage(coords)
    local playerPed = PlayerPedId()
    DoScreenFadeOut(500)
    Citizen.Wait(500)
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z)
    Citizen.Wait(500)
    DoScreenFadeIn(500)
end

function ShowHelpNotification(text)
    AddTextEntry('AscenseurHelp', text)
    DisplayHelpTextThisFrame('AscenseurHelp', false)
end

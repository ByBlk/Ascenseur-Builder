local ascenseurs = {}
local activeMarkers = {}

RegisterNetEvent("ascenseur:refresh")
AddEventHandler("ascenseur:refresh", function(dataPartiel)
    for id, ascenseur in pairs(dataPartiel) do
        ascenseurs[id] = ascenseur
    end
end)

RegisterCommand("menuascenseur", function()
    TriggerServerEvent("ascenseur:checkPermission")
end, false)

RegisterNetEvent("ascenseur:openMenu")
AddEventHandler("ascenseur:openMenu", function()
    ouvrirMenuGestion()
end)

function ouvrirMenuGestion()
    local selectedAscenseur = nil
    local selectedEtage = nil

    RMenu.Add('ascenseur', 'main', RageUI.CreateMenu("", "Options"))
    RMenu.Add('ascenseur', 'modify', RageUI.CreateSubMenu(RMenu:Get('ascenseur', 'main'), "", "Modifier ou Supprimer"))
    RMenu.Add('ascenseur', 'etages', RageUI.CreateSubMenu(RMenu:Get('ascenseur', 'modify'), "", "Gérer les Étages"))
    RMenu.Add('ascenseur', 'etage_options', RageUI.CreateSubMenu(RMenu:Get('ascenseur', 'etages'), "", "Modifier ou Supprimer"))

    RageUI.Visible(RMenu:Get('ascenseur', 'main'), true)

    Citizen.CreateThread(function()
        while RageUI.Visible(RMenu:Get('ascenseur', 'main')) or RageUI.Visible(RMenu:Get('ascenseur', 'modify')) or RageUI.Visible(RMenu:Get('ascenseur', 'etages')) or RageUI.Visible(RMenu:Get('ascenseur', 'etage_options')) do
            for _, marker in ipairs(activeMarkers) do
                DrawMarker(Config.Marker, marker.x, marker.y, marker.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, Config.Couleurpoint[1], Config.Couleurpoint[2], Config.Couleurpoint[3], false, true, 2, false, nil, nil, false)
            end

            RageUI.IsVisible(RMenu:Get('ascenseur', 'main'), function()
                RageUI.Button("Créer un Ascenseur", nil, { RightLabel = "→" }, true, {
                    onSelected = function()
                        local name = KeyboardInput("Nom de l'ascenseur", "", 50)
                        if name and name ~= "" then
                            TriggerServerEvent("ascenseur:create", name)
                        end
                    end
                })

                RageUI.Button("Modifier un Ascenseur", nil, { RightLabel = "→" }, true, {
                    onSelected = function()
                        TriggerServerEvent("ascenseur:sync")
                        RageUI.Visible(RMenu:Get('ascenseur', 'modify'), true)
                    end
                })
            end)

            RageUI.IsVisible(RMenu:Get('ascenseur', 'modify'), function()
                for id, ascenseur in pairs(ascenseurs) do
                    RageUI.Button(ascenseur.name, nil, { RightLabel = "→" }, true, {
                        onSelected = function()
                            selectedAscenseur = ascenseur
                            activeMarkers = {}
                            for _, etage in ipairs(ascenseur.etages) do
                                table.insert(activeMarkers, etage.coords)
                            end
                            RageUI.Visible(RMenu:Get('ascenseur', 'etages'), true)
                        end
                    })

                    RageUI.Button("~r~Supprimer " .. ascenseur.name, nil, { RightLabel = "~r~Supprimer" }, true, {
                        onSelected = function()
                            TriggerServerEvent("ascenseur:deleteAscenseur", ascenseur.id)
                            ascenseurs[id] = nil
                            if ascenseur.etages then
                                for i = #ascenseur.etages, 1, -1 do
                                    table.remove(ascenseur.etages, i)
                                end
                            end
                        end
                    })
                end
            end)

            RageUI.IsVisible(RMenu:Get('ascenseur', 'etages'), function()
                if selectedAscenseur then
                    for index, etage in ipairs(selectedAscenseur.etages) do
                        RageUI.Button("Étage " .. etage.number, nil, { RightLabel = "→" }, true, {
                            onSelected = function()
                                selectedEtage = { index = index, data = etage }
                                RageUI.Visible(RMenu:Get('ascenseur', 'etage_options'), true)
                            end
                        })
                    end

                    RageUI.Button("Ajouter un Étage", nil, { RightLabel = "→" }, true, {
                        onSelected = function()
                            local playerCoords = GetEntityCoords(PlayerPedId())
                            local newEtageNumber = #selectedAscenseur.etages + 1
                            TriggerServerEvent("ascenseur:updateetage", selectedAscenseur.id, newEtageNumber, playerCoords)
                            table.insert(selectedAscenseur.etages, {
                                number = newEtageNumber,
                                coords = playerCoords
                            })
                        end
                    })
                end
            end)

            RageUI.IsVisible(RMenu:Get('ascenseur', 'etage_options'), function()
                if selectedEtage then
                    RageUI.Button("Modifier la Position", nil, { RightLabel = "→" }, true, {
                        onSelected = function()
                            local playerCoords = GetEntityCoords(PlayerPedId())
                            TriggerServerEvent("ascenseur:updateetage", selectedAscenseur.id, selectedEtage.data.number, playerCoords)
                            selectedEtage.data.coords = playerCoords 
                        end
                    })
            
                    RageUI.Button("Se téléporter à l'Étage", nil, { RightLabel = "→" }, true, {
                        onSelected = function()
                            tpetage(selectedEtage.data.coords)
                        end
                    })
            
                    RageUI.Button("Supprimer l'Étage", nil, { RightLabel = "→" }, true, {
                        onSelected = function()
                            TriggerServerEvent("ascenseur:deleteEtage", selectedAscenseur.id, selectedEtage.data.number)
                            table.remove(selectedAscenseur.etages, selectedEtage.index) 
                        end
                    })
                end
            end)

            Citizen.Wait(0)
        end
    end)
end

function tpetage(coords)
    local playerPed = PlayerPedId()
    DoScreenFadeOut(500)
    Citizen.Wait(500)
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z)
    Citizen.Wait(500)
    DoScreenFadeIn(500)
end

function KeyboardInput(textEntry, exampleText, maxStringLength)
    AddTextEntry('FMMC_KEY_TIP1', textEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", exampleText, "", "", "", maxStringLength)
    while UpdateOnscreenKeyboard() == 0 do
        Citizen.Wait(0)
    end
    if GetOnscreenKeyboardResult() then
        return GetOnscreenKeyboardResult()
    end
    return nil
end

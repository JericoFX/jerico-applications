local QBCore = exports["qb-core"]:GetCoreObject()
local Peds = {}
---Creo una metatabla para agarrar los datos dentro y poder manejarlos mas facil.
local Menus = setmetatable({}, {
    __call = function(self)
        return self
    end,
    ---Si el dato no existe lo crea
    __newindex = function(t, k, v)
        rawset(t, k, v)
    end,
    ---Si el dato existe entonces lo llama, en este caso abre el menu.
    __index = function(t, k)
        return lib.showContext(k)
    end
})

--- Crea el menu de formulario
---@param name string
local function createFormMenu(name)
    if not name then return Menus["welcome"] end
    local Info = QBCore.Functions.GetPlayerData()
    local input = lib.inputDialog(("Application %s"):format(name:upper()), {
        {
            type = 'input',
            label = "Name",
            placeholder = Info.charinfo.firstname,
            description = 'First Name',
            required = false,
            disabled = true
        },
        {
            type = 'input',
            label = 'Last Name',
            placeholder = Info.charinfo.lastname,
            description = 'Last Name',
            disabled = true
        },
        {
            type = 'input',
            label = 'Citizenid',
            placeholder = Info.citizenid,
            description = 'Citizenid',
            disabled = true
        },
        {
            type = 'textarea',
            label = 'Why would you like to be part?',
            required = true,
            autosize = true
        },
        {
            type = 'select',
            label = 'Have you ever worked on this before?',
            options = {
                {
                    label = "Yes",
                    value = "si",
                },
                {
                    label = "No",
                    value = "no"
                }
            },
            default = "si",
            required = true,
            autosize = true
        },
    })
    lib.notify({
        title = "POSTULATION",
        description = "Application Sent",
        type = 'success', --'inform' or 'error' or 'success'or 'warning'
        duration = 5000
    })
    if not input then return end
    TriggerServerEvent("fx-postu::server::SendDataToDiscord", input, name)
end

local function createMenus(name)
    local jerico = lib.callback.await("fx-postu::server::recibirDeselected", nil, name)
    Menus["welcome"] = lib.registerContext({
        id = "welcome",
        title = "APPLICATIONS MENU",
        options = {
            {
                title = name:upper(),
                disabled = jerico,
                description = jerico == false and "Create a form for the selected job" or
                    "New applications are disabled at this moment"
                ,
                onSelect = function()
                    createFormMenu(name)
                end
            }
        }
    })
    return Menus["welcome"]
end
---Crea en la Metatabla Menus para luego llamarlo mas facil.

local function CreatePeds()
    CreateThread(function()
        for k, v in pairs(Config.Places) do
            local el = Config.Places[k]
            lib.requestModel(el.model, 500)
            local Ped = CreatePed(1, GetHashKey(el.model), el.coord.x, el.coord.y, el.coord.z - 1, el.coord.w, false,
                false)
            while not DoesEntityExist(Ped) do Wait(0) end
            FreezeEntityPosition(Ped, true)
            SetPedRandomComponentVariation(Ped, 0)
            SetEntityInvincible(Ped, true)
            SetBlockingOfNonTemporaryEvents(Ped, true)
            exports.ox_target:addLocalEntity(Ped, {
                label = "Check Applications",
                name = k,
                distance = 2,
                data = { name = k },
                canInteract = function(entity, distance, coords, name, bone)
                    return true
                end,
                onSelect = function(data)
                    createMenus(data.data.name)
                end
            })
            Peds[#Peds + 1] = Ped
        end
    end)
end
CreateThread(function()
    Wait(100)
    CreatePeds()
end)

AddEventHandler("onResourceStart", function(res)
    if GetCurrentResourceName() ~= res then return end
    CreatePeds()
end)

AddEventHandler("onResourceStop", function(res)
    if GetCurrentResourceName() ~= res then return end
    if Peds then
        for _, v in ipairs(Peds) do
            if DoesEntityExist(v) then
                DeleteEntity(v)
            end
        end
    end
end)

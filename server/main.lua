local QBCore = exports["qb-core"]:GetCoreObject()
local Peds = {}

print([[
                ██████╗ ██╗   ██╗         ██╗███████╗██████╗ ██╗ ██████╗ ██████╗     ███████╗██╗  ██╗
                ██╔══██╗╚██╗ ██╔╝         ██║██╔════╝██╔══██╗██║██╔════╝██╔═══██╗    ██╔════╝╚██╗██╔╝
                ██████╔╝ ╚████╔╝          ██║█████╗  ██████╔╝██║██║     ██║   ██║    █████╗   ╚███╔╝
                ██╔══██╗  ╚██╔╝      ██   ██║██╔══╝  ██╔══██╗██║██║     ██║   ██║    ██╔══╝   ██╔██╗
                ██████╔╝   ██║       ╚█████╔╝███████╗██║  ██║██║╚██████╗╚██████╔╝    ██║     ██╔╝ ██╗
                ╚═════╝    ╚═╝        ╚════╝ ╚══════╝╚═╝  ╚═╝╚═╝ ╚═════╝ ╚═════╝     ╚═╝     ╚═╝  ╚═╝
              ]])
lib.callback.register("fx-postu::server::recibirDeselected", function(source, name)
    if not name then return false end
    local wachin = MySQL.scalar.await("SELECT valor FROM postu WHERE nombre = ?", { name })
    return wachin
end)

local function changeData(name, value)
    if not name then return end
    if not value then value = 0 end
    local variable = MySQL.query.await("UPDATE postu SET  valor = ? WHERE nombre = ?", { value, name })
end

MySQL.ready(function()
    local querys = [[
            CREATE TABLE IF NOT EXISTS postu (
                id INT NOT NULL AUTO_INCREMENT,
                nombre VARCHAR(50),
                valor TINYINT(1)
            );
        ]]

    MySQL.execute(querys, function(result)
        for k in pairs(Config.Places) do
            local query = string.format("SELECT COUNT(*) FROM postu WHERE nombre = '%s'", k)
            local variable = MySQL.single.await(query)
            if variable["COUNT(*)"] > 0 then
                print(string.format("The data '%s' exists in the database.", k))
            else
                Wait(100)
                print(string.format("The data '%s' does not exist in the database. CREATING", k))
                local vsariable = MySQL.insert.await(
                    "INSERT INTO postu (`nombre`,`valor`) VALUES (?,?) ", { tostring(k), 1 })
            end
        end
    end)
end)


lib.addCommand('application', {
    help = 'Allow or block the request for a form',
    params = {
        {
            name = 'job',
            type = 'string',
            help = 'Enter the job to change',
        },
        {
            name = 'valor',
            type = 'number',
            help = 'enter 0 to allow, 1 to disallow',
        },
    },
    restricted = SConfig.Group
}, function(source, args, raw)
    if not args then return end
    if args.valor == 0 then
        TriggerClientEvent('chat:addMessage', -1, {
            template = '<div style="font-weight:bold;font-size:1.5vh;color:' ..
                "#FF3E32" .. '; margin: 0.05vw;">' .. args.job:upper() ..
                ': <b style=color:#ffffff;font-weight:normal>{0}</div>',
            args = { "Open Applications" }
        })
    end
    changeData(args.job, args.valor)
end)

RegisterNetEvent("fx-postu::server::SendDataToDiscord", function(data, name)
    if not data or not name then return end
    local Player = QBCore.Functions.GetPlayer(source)
    local id = nil
    local identifiers = GetPlayerIdentifiers(source)
    for _, v in pairs(identifiers) do
        if string.find(v, 'discord') then
            id = v
            break
        end
    end
    data[1] = Player.PlayerData.charinfo.firstname
    data[2] = Player.PlayerData.charinfo.lastname
    data[3] = Player.PlayerData.citizenid

    local mensajeFormateado = string.format(
        "New Application Form %s**\n \nFirst name: %s \nLast name: %s \nCitizenID: %s \nDiscord: <@%s> \nReason: %s \nPrevious Experience: %s",
        name, data[1], data[2], data[3], string.sub(id, 9), data[4], data[5]
    )
    local webHook = SConfig.Webhook
    local embedData = {
        {
            ['title'] = ("APPLICATION %s"):format(name:upper()),
            ['color'] = 255,
            ['footer'] = {
                ['text'] = os.date('%c') .. " Creado por JericoFX",
            },
            ['description'] = mensajeFormateado,
            ['author'] = {
                ['name'] = 'FX POSTULACIONES',
                ['icon_url'] =
                'https://cdn.discordapp.com/avatars/284882049393754123/a74cbda062bc24dee25bbe305580e789.webp?size=128',
            },
        }
    }
    PerformHttpRequest(webHook, function() end, 'POST',
        json.encode({ username = 'FX', embeds = embedData }),
        { ['Content-Type'] = 'application/json' })
end)

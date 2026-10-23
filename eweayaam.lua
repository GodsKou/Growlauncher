pref = require("preferences")

pref:new("KouProjectConfig")
pref:load()

growz_enabled = pref:get("growz_enabled", false)
saveworldsaved = pref:get("save_world", "")
speed_growz = pref:get("speed_growz", 3)
antilag = pref:get("antilag", false)
fastdrop = pref:get("fastdrop", false)
fasttake = pref:get("fasttake", false)
noparticle = pref:get("noparticle", false)
blink_color = pref:get("blink_color", false)

-- Keep relog state between hook callbacks; do not reset it on every packet.
local relogWorld = nil
local relogPending = false

local checklist = {
    blinkMode = pref:get("checklist_blinkMode", false) == true
}

local blinkThreadRunning = false

local function applyChecklistBlink()
    -- Both the checklist option and the legacy blink_color option share one thread.
    blinking = (checklist.blinkMode == true) or (blink_color == true)

    if blinking and not blinkThreadRunning then
        blinkThreadRunning = true
        runThread(function()
            local ok, err = pcall(setblink)
            if not ok then
                log("`4[Blink] Thread error: " .. tostring(err))
            end
            blinkThreadRunning = false
        end)
    end
end

local function saveChecklist()
    local ok, err = pcall(function()
        pref:set("checklist_blinkMode", checklist.blinkMode)
        pref:save()
    end)

    if not ok then
        log("`4[Checklist] Gagal menyimpan: " .. tostring(err))
        return false
    end

    log("`2[Checklist] Konfigurasi berhasil disimpan.")
    return true
end

local function openChecklist()
    local dialog = [[
set_default_color|`o
add_label_with_icon|big|`wChecklist Settings|left|32|
add_spacer|small|
]]

    dialog = dialog
        .. "add_checkbox|blink_mode|`wBlink Mode|"
        .. (checklist.blinkMode and "1" or "0") .. "|\n"

    dialog = dialog .. [[
add_spacer|small|
end_dialog|checklist_dialog|Cancel|Save|
]]

    SendVariant({v1 = "OnDialogRequest", v2 = dialog})
end

local function parseChecklistFields(packet)
    local fields = {}
    for line in packet:gmatch("[^\r\n]+") do
        local key, value = line:match("^([^|]+)|([^|]*)$")
        if key then
            fields[key] = value
        end
    end
    return fields
end

local function processChecklistReturn(packet)
    local fields = parseChecklistFields(packet)

    -- Tombol Cancel tidak mengubah konfigurasi yang tersimpan.
    if fields.buttonClicked == "Cancel" then
        return true
    end

    -- Dialog ini hanya memiliki checkbox Blink Mode.
    if fields.blink_mode == nil then
        log("`4[Checklist] Data checkbox Blink Mode tidak ditemukan.")
        return true
    end

    checklist.blinkMode = fields.blink_mode == "1"

    if not saveChecklist() then
        return true
    end

    applyChecklistBlink()
    log("`2[Checklist] Blink Mode: " .. (checklist.blinkMode and "ON" or "OFF"))
    return true
end

modmeno = [[
{
    "sub_name": "MOD TOOLS",
    "icon": "Wrench",
    "description": "MODIFICATION CENTER",
    "menu": [
        {
            "type": "labelapp",
            "icon": "Search",
            "text": "SCANNER TOOLS",
            "description": "Scan floating items and blocks"
        },
        {
            "type": "button",
            "text": "Scan Floating Items",
            "alias": "cheat_growscan_open_floating"
        },
        {
            "type": "button",
            "text": "Scan Block",
            "alias": "cheat_growscan_open_block"
        },
        {
            "type": "labelapp",
            "icon": "Build",
            "text": "PLAYER MODIFICATIONS",
            "description": "Movement and player options"
        },
        {
            "text": "FindPath",
            "description": "Teleport to a target tile using FindPath",
            "type": "toggle",
            "default": false
        },
        {
            "text": "ModFly",
            "description": "Fly like creative mode",
            "type": "toggle",
            "default": false
        },
        {
            "text": "Growz V2",
            "description": "Adjust player movement speed",
            "type": "toggle",
            "default": ]] .. tostring(growz_enabled) .. [[,
            "expandable": true,
            "list_child": [
                {
                    "text": "Speed Growz",
                    "type": "slider",
                    "min": 0,
                    "max": 8,
                    "use_dot": true,
                    "step": 7,
                    "default": ]] .. tostring(speed_growz) .. [[,
                    "alias": "speed_growz"
                }
            ]
        },
        {
            "type": "labelapp",
            "icon": "Speed",
            "text": "PERFORMANCE",
            "description": "Rendering and item collection"
        },
        {
            "type": "toggle",
            "text": "Antilag",
            "description": "Skip render background",
            "default": ]] .. tostring(antilag) .. [[,
            "alias": "cheat_antilag",
            "autosave": true
        },
        {
            "type": "toggle",
            "text": "No Particle",
            "description": "Skip all render particles",
            "default": ]] .. tostring(noparticle) .. [[,
            "alias": "config_cheat_noparticle",
            "autosave": true
        },
        {
            "type": "toggle",
            "text": "Fast Drop",
            "description": "Enable fast drop mode",
            "default": ]] .. tostring(fastdrop) .. [[,
            "alias": "cheat_config_fastdrop_active",
            "autosave": true
        },
        {
            "type": "toggle",
            "text": "Fast Take",
            "description": "Instantly picks up items without delay",
            "default": ]] .. tostring(fasttake) .. [[
        }
    ]
}
]]

csnmeno = [[
{
    "sub_name": "CSN CENTER",
    "icon": "RemoveRedEye",
    "description": "GAME MODE CENTER",
    "menu": [
        {
            "type": "labelapp",
            "icon": "Tune",
            "text": "GAME CONFIGURATION",
            "description": "Select your preferred game mode"
        },
        {
            "type": "dropdown",
            "value": "[\"NUMBER ONLY\",\"FAST WHEEL\",\"REME\",\"LEME\",\"LEWA\"]",
            "default": 0,
            "alias": "game_mode",
            "text": "CSN MODE",
            "description": "Select game mode"
        },
        {
            "type": "labelapp",
            "icon": "LocationOn",
            "text": "WORLD SETTINGS",
            "description": "Configure your saved destination"
        },
        {
            "type": "input_string",
            "alias": "save_world",
            "text": "SAVE WORLD",
            "default": "]] .. saveworldsaved .. [[",
            "icon": "LocationOn",
            "label": "World Name",
            "placeholder": "EXIT"
        },
        {
            "type": "button",
            "text": "Warp To Save",
            "icon": "Bolt",
            "alias": "wptosave"
        },
        {
            "type": "labelapp",
            "icon": "Search",
            "text": "ITEM IDENTIFICATION",
            "description": "Find and select item IDs"
        },
        {
            "type": "item_picker",
            "text": "ID Finder",
            "item": "Blank",
            "default": "Blank",
            "alias": "selected_item"
        }
    ]
}
]]

bjmeno = [[
{
    "sub_name": "BJ CENTER",
    "icon": "RemoveRedEye",
    "description": "BJ ACTION CENTER",
    "menu": [
    {
            "type": "labelapp",
            "icon": "RemoveRedEye",
            "text": "BJ ACTION MENU",
            "description": "Quick access to item actions"
        },
                {
            "text": "Show Collected Gems",
            "type": "toggle",
            "icon": "Bolt",
            "alias": "show_collected_gems"
        },
        {
            "text": "Scan Gems Mode",
            "description": "Scan Gems",
            "type": "toggle",
            "default": false,
            "alias": "scan_gems"
        },
        {
            "text": "Scan Gems Repeat",
            "description": "Repeat Scan Gems",
            "type": "toggle",
            "default": false,
            "alias": "scan_gems_repeat"
        },
        {
            "text": "Take Gems",
            "type": "button",
            "icon": "Bolt",
            "alias": "takegems"
        },
        {
            "text": "Take Block",
            "type": "button",
            "icon": "Bolt",
            "alias": "takingblock"
        },
        {
            "text": "Check Gems",
            "type": "button",
            "icon": "Bolt",
            "alias": "checkgemss"
        },
        {
            "text": "Show Collected Gems",
            "type": "button",
            "icon": "Bolt",
            "alias": "checkcollectedgems"
        },
        {
            "text": "Scan Gems",
            "type": "button",
            "icon": "Bolt",
            "alias": "scan_gems1x"
        },
        {
            "type": "labelapp",
            "icon": "Bolt",
            "text": "BET MANAGEMENT",
            "description": "Bet and payout actions"
        },
        {
            "text": "BTK",
            "type": "button",
            "icon": "Bolt",
            "alias": "btkbutton"
        },
        {
            "text": "Take Bet",
            "type": "button",
            "icon": "Bolt",
            "alias": "takebet"
        },
        {
            "text": "Drop Tax",
            "type": "button",
            "icon": "Bolt",
            "alias": "droptax"
        },
        {
            "text": "Drop Payout",
            "type": "button",
            "icon": "Bolt",
            "alias": "droppayout"
        },
        {
            "type": "labelapp",
            "icon": "RemoveRedEye",
            "text": "PLAYER PAYOUTS",
            "description": "Select the target player"
        },
        {
            "text": "Drop To Player 1",
            "type": "button",
            "icon": "Bolt",
            "alias": "win1"
        },
        {
            "text": "Drop To Player 2",
            "type": "button",
            "icon": "Bolt",
            "alias": "win2"
        },
        {
            "text": "Drop To Player 3",
            "type": "button",
            "icon": "Bolt",
            "alias": "win3"
        },
        {
            "text": "Drop To Player 4",
            "type": "button",
            "icon": "Bolt",
            "alias": "win4"
        }
    ]
}
]]

require("IniEy")
addCategory("KOU PROJECT", "settings")
addIntoModule(modmeno, "KOU PROJECT")
addIntoModule(csnmeno, "KOU PROJECT")
addIntoModule(bjmeno, "KOU PROJECT")
sendNotification("KOU PROXY")

world_logs = {}
spin_logs = {}
max_logs_limit = 50

function add_log(table_ref, msg)
    local clean_msg = tostring(msg or ""):gsub("\n", " ")
    table.insert(table_ref, 1, clean_msg)
    if #table_ref > max_logs_limit then
        table.remove(table_ref)
    end
end

function show_logs_menu()
    local logs_menu = [[set_default_color|`o
add_label_with_icon|big|`bCCTV Logs System|left|32|
add_spacer|small|
add_textbox|`oSelect the database module you wish to inspect.|left|
add_spacer|small|
add_button|btn_world_logs|`wWorld Collect/Drop Logs|
add_button|btn_spin_logs|`wRoulette Spin Logs|
add_spacer|small|
add_quick_exit||
end_dialog|logs_menu_main|||
]]
    dialog(logs_menu)
end

spin_mode = "FAST WHEEL"
spintext = nil
uidplayer = nil

GTPS = true
systemlog = "`7[ `4KILLYOURIDOL `7]`o "
date = os.date("%d, %b, %Y")
tanggal = os.date("%d")
bulan = os.date("%B")
tahun = os.date("%Y")
hari = os.date("%A")
modfly = 0
tele = 0
checktile = false
conte = 0
count = 0
checkwl = growtopia.checkInventory(242)
checkdl = growtopia.checkInventory(1796)
checkbgl = growtopia.checkInventory(7188)
auto_bgl_mode = false
collectedgems = false
local localPlayerAtStart = (type(GetLocal) == "function" and GetLocal()) or nil
nick = (type(localPlayerAtStart) == "table" and localPlayerAtStart.name) or "Player"
cg = 0
auto_drop_count = 0
local player1x
local player1y
local player2x
local player2y
local player3x
local player3y
local player4x
local player4y
local takeleftx
local takelefty
local takerightx
local takerighty
local gemsleftx1
local gemslefty1
local gemsleftx2
local gemslefty2
local gemsleftx3
local gemslefty3
local gemsleftx4
local gemslefty4
local gemsleftx5
local gemslefty5
local gemsleftx6
local gemslefty6
local gemsleftx7
local gemslefty7
local gemsleftx8
local gemslefty8
local backposx
local backposy
local gemsrightx1
local gemsrighty1
local gemsrightx2
local gemsrighty2
local gemsrightx3
local gemsrighty3
local gemsrightx4
local gemsrighty4
local gemsrightx5
local gemsrighty5
local gemsrightx6
local gemsrighty6
local gemsrightx7
local gemsrighty7
local gemsrightx8
local gemsrighty8
Aount = betwl
data ={}
taxset = "5"
saved_tax = 0
local savedWeather = tonumber(pref:get("saved_weather", nil))
auto_accept_mode = false
auto_accept_hide_ticks = 0
punchgems = false
blinking = (checklist.blinkMode == true) or (blink_color == true)
kouproject = true
auto_me_mode = false
gemsrepeat = false
spam_tick = 0
visual_gems_mode = false
autocrime = false
previousCounterGems = getGems() or 0
collectedCounterGems = 0
lastGemGainTime = 0
show_gems_collected = false
Config = {
	gameMode = "number_only",
	autoConvert = true,
    autoConvertStep = 1,
    autoConvertX = 57,
    autoConvertY = 41,
    blink = false
	}

function notify(msg)
    if growtopia and growtopia.notify then
        growtopia.notify(msg)
    end
    log(msg)
end

function message(hax)
SendPacket(2,"action|input\ntext|(troll) "..hax.."")
return true
end

function kou(var)
var = {}
var.v1 = "OnAddNotification"
var.v3 = "`4KOU PROJECT"
var.v4 = "audio/gauntlet_spawn.wav"
SendVariant(var)
return true
end

function wear(id)
    local pkt = {}
    pkt.type = 10
    pkt.value = id
    SendPacketRaw(false, pkt)
end

function dialog(tkss)
va = {}
va.v1 = "OnDialogRequest"
va.v2 = tkss
SendVariant(va)
end

function log(str)
LogToConsole(systemlog .. str)
end

function ontalk(str)
    local me = (type(GetLocal) == "function" and GetLocal()) or nil
    if type(me) ~= "table" then return end

    local variant = {
        v1 = "OnTalkBubble",
        v2 = me.netID or me.netid,
        v3 = tostring(str or "")
    }
    if variant.v2 then
        SendVariant(variant)
    end
end

function ontext(str)
o = {}
o.v1 = "OnTextOverlay"
o.v2 = str
SendVariant(o)
end

function notify(str)
    if growtopia and type(growtopia.notify) == "function" then
        growtopia.notify(tostring(str or ""))
    else
        log(tostring(str or ""))
    end
end

function greenbox(x, y)
    SendPacketRaw(true, {
        type = 38,
        netid = tonumber(string.format("%02d%02d", y, x))
    })
end

function path(x, y, is_left)
    local f_state = 32
    local x_off = 8
    if is_left then
        f_state = 16
        x_off = -8
    end
    SendPacketRaw(false, {type = 0, x = x*32 + x_off, y = y*32, state = f_state})
end

function inv(id)
    for _, item in pairs(GetInventory()) do
        local i_id = item.id or item.itemid
        local i_amt = item.amount or item.count or 0
        if (tonumber(i_id) == tonumber(id)) then
            return tonumber(i_amt)
        end
    end
    return 0
end

function checkitm(id)
    local inv = GetInventory()
    if type(inv) ~= "table" then return 0 end
    for _, v in pairs(inv) do
        if v.id == id then
            return v.amount
        end
    end
    return 0
end

function repeatgems()
while gemsrepeat do
ScanGemsParticle()
Sleep(2000)
end
end

function setblink()
    local colors = {
        3370516479,
        3033464831,
        2864971775,
        2527912447,
        2190853119,
        2022356223,
        1685231359,
        1348237567,
        1348237567,
        1685231359,
        2022356223,
        2190853119,
        2527912447,
        2864971775,
        3033464831,
        3370516479
    }

    while blinking do
        local worldName = (type(GetWorldName) == "function" and GetWorldName()) or ""

        -- Do not send gameplay packets while connecting, disconnected, or outside a world.
        if worldName ~= "" and worldName ~= "EXIT" then
            for _, color in ipairs(colors) do
                if not blinking then break end

                local currentWorld = (type(GetWorldName) == "function" and GetWorldName()) or ""
                if currentWorld == "" or currentWorld == "EXIT" then
                    break
                end

                SendPacket(2, "action|setSkin\ncolor|" .. tostring(color))
                Sleep(150)
            end
        else
            Sleep(1000)
        end
    end
end

if checklist.blinkMode or blink_color then
    applyChecklistBlink()
end

function toggleAutoConvert()
    Config.autoConvert = not Config.autoConvert
    if Config.autoConvert then
        Config.autoConvertStep = 1
        log("`9Auto Convert : `2ON")
        ontext("`9Auto Convert : `2ON")
    else
        log("`9Auto Convert : `4OFF")
        ontext("`9Auto Convert : `4OFF")
    end
end

function dropItem(itemID, count)
    SendPacket(2, "action|drop\n|itemID|" .. itemID)
    SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. itemID .. "\ncount|" .. count)
end
function dropgtps(id, count)
SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|"..id.."|\nitem_count|"..count)
end

function rdrop(id, amount)
    SendPacket(2, "action|drop\n|itemID|"..id)
    SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|"..id.."|\ncount|"..amount)
end

function autodrop(id, amount)
    local left = amount
    while left > 200 do
        auto_drop_count = auto_drop_count + 1
        rdrop(id, 200)
        left = left - 200
    end
    if left > 0 then
        auto_drop_count = auto_drop_count + 1
        rdrop(id, left)
    end
end

function pos(px,py)
local hasil
if not px and not py then
hasil = "`bTap Me``"
else
hasil = "`b[`2X: `5"..px.."`w,`2Y: `5"..py.."`b]"
end
return hasil
end

tile = {
pos1 = {
{x = gemsrightx1, y = gemsrighty1}, {x = gemsrightx2, y = gemsrighty2}, {x = gemsrightx3, y = gemsrighty3}, {x = gemsrightx4, y = gemsrighty4}, {x = gemsrightx5, y = gemsrighty5}, {x = gemsrightx6, y = gemsrighty6}, {x = gemsrightx7, y = gemsrighty7}, {x = gemsrightx8, y = gemsrighty8}
},
pos2 = {
{x = gemsleftx1, y = gemslefty1}, {x = gemsleftx2, y = gemslefty2}, {x = gemsleftx3, y = gemslefty3}, {x = gemsleftx4, y = gemslefty4}, {x = gemsleftx5, y = gemslefty5}, {x = gemsleftx6, y = gemslefty6}, {x = gemsleftx7, y = gemslefty7}, {x = gemsleftx8, y = gemslefty8}
}
}

function takegems()
tile = (tile);
Count = 0;
data = {};
do
local objects = (type(GetObjectList) == "function" and GetObjectList()) or (type(getObjectList) == "function" and getObjectList()) or {}
for _, obj in pairs(objects) do
for _, tiles in pairs(tile.pos1) do
if obj.itemid == 112 and (obj.posX)//32 == tiles.x and (obj.posY)//32 == tiles.y then
Count = Count + obj.amount;
pkt = {}
pkt.type = 11
pkt.value = obj.id
pkt.x = obj.posX
pkt.y = obj.posY
SendPacketRaw(false, pkt)
end end end
table.insert(data, Count)
Count = 0;
local objects = (type(GetObjectList) == "function" and GetObjectList()) or (type(getObjectList) == "function" and getObjectList()) or {}
for _, obj in pairs(objects) do
for _, tiles in pairs(tile.pos2) do
if obj.itemid == 112 and (obj.posX)//32 == tiles.x and (obj.posY)//32 == tiles.y then
Count = Count + obj.amount;
pkt = {}
pkt.type = 11
pkt.value = obj.id
pkt.x = obj.posX
pkt.y = obj.posY
SendPacketRaw(false, pkt)
end end end
table.insert(data, Count)
Count = 0;
if data[2] > data[1] then
SendPacket(2, "action|input\n|text|`0[ Player1 ] :`2 "..data[2].." `bVs `0[ Player2 ] :`2 "..data[1].."");
ontalk("`9Pos Left `2WIN!")
log("`9Pos Left `2WIN!")
cg2 = data[2]
elseif data[1] == data[2] then
SendPacket(2, "action|input\n|text|`0[ Player1 ] `w: "..data[2].." `0[ `bTie `0] `0[ Player2 ] `w: "..data[1].. "");
log("`9Nothing Winner `4TIE!")
ontalk("`9Nothing Winner `4TIE!")
elseif data[2] < data[1] then
SendPacket(2, "action|input\n|text|`0[ Player1 ] :`2 "..data[2].." `bVs `0[ Player2 ] :`2 "..data[1].. "");
ontalk("`9Pos Right `2WIN!")
log("`9Pos Right `2WIN!")
cg1 = data[1]
end
data = {};
end;
end

function takeblock()
    tile = tile

    local TAKE_TOLERANCE = 10

    local function isObjectInTile(obj, tiles)
        if not obj or not tiles then
            return false
        end

        local objX = tonumber(obj.posX)
        local objY = tonumber(obj.posY)

        if (not objX or not objY) and obj.pos then
            objX = tonumber(obj.pos.x)
            objY = tonumber(obj.pos.y)
        end

        if not objX or not objY then
            return false
        end

        local tileX = tonumber(tiles.x)
        local tileY = tonumber(tiles.y)

        if not tileX or not tileY then
            return false
        end

        local minX = (tileX * 32) - TAKE_TOLERANCE
        local maxX = ((tileX + 1) * 32) + TAKE_TOLERANCE
        local minY = (tileY * 32) - TAKE_TOLERANCE
        local maxY = ((tileY + 1) * 32) + TAKE_TOLERANCE

        return objX >= minX
           and objX <= maxX
           and objY >= minY
           and objY <= maxY
    end

    local objects = GetObjectList() or {}

    for _, obj in pairs(objects) do
        for _, tiles in pairs(tile.pos1 or {}) do
            if isObjectInTile(obj, tiles) then
                local objX = tonumber(obj.posX)
                local objY = tonumber(obj.posY)

                if (not objX or not objY) and obj.pos then
                    objX = tonumber(obj.pos.x)
                    objY = tonumber(obj.pos.y)
                end

                if objX and objY and obj.id then
                    local pkt = {}
                    pkt.type = 11
                    pkt.value = obj.id
                    pkt.x = objX
                    pkt.y = objY

                    SendPacketRaw(false, pkt)
                end

                break
            end
        end
    end

    for _, obj in pairs(objects) do
        for _, tiles in pairs(tile.pos2 or {}) do
            if isObjectInTile(obj, tiles) then
                local objX = tonumber(obj.posX)
                local objY = tonumber(obj.posY)

                if (not objX or not objY) and obj.pos then
                    objX = tonumber(obj.pos.x)
                    objY = tonumber(obj.pos.y)
                end

                if objX and objY and obj.id then
                    local pkt = {}
                    pkt.type = 11
                    pkt.value = obj.id
                    pkt.x = objX
                    pkt.y = objY

                    SendPacketRaw(false, pkt)
                end

                break
            end
        end
    end

    return false
end

function checkgems()
    tile = tile

    local data = {0, 0}
    local objects = GetObjectList() or {}

    local GEM_TOLERANCE = 10

    local function isGemInTile(obj, tiles)
        if not obj or obj.itemid ~= 112 then
            return false
        end

        local x = tonumber(obj.posX) or 0
        local y = tonumber(obj.posY) or 0
        local tx = tonumber(tiles.x)
        local ty = tonumber(tiles.y)

        if not tx or not ty then
            return false
        end

        local left   = tx * 32 - GEM_TOLERANCE
        local right  = (tx + 1) * 32 + GEM_TOLERANCE
        local top    = ty * 32 - GEM_TOLERANCE
        local bottom = (ty + 1) * 32 + GEM_TOLERANCE

        return x >= left and x <= right and
               y >= top and y <= bottom
    end

    local counted1 = {}
    local counted2 = {}

    for _, obj in pairs(objects) do
        if obj.itemid == 112 then
            local amount = tonumber(obj.amount) or 0
            local id = obj.id

            if amount > 0 then
                for _, tiles in pairs(tile.pos1 or {}) do
                    if isGemInTile(obj, tiles) then
                        if id == nil or not counted1[id] then
                            data[1] = data[1] + amount
                            if id ~= nil then
                                counted1[id] = true
                            end
                        end
                        break
                    end
                end

                for _, tiles in pairs(tile.pos2 or {}) do
                    if isGemInTile(obj, tiles) then
                        if id == nil or not counted2[id] then
                            data[2] = data[2] + amount
                            if id ~= nil then
                                counted2[id] = true
                            end
                        end
                        break
                    end
                end
            end
        end
    end

    local p1 = data[2]
    local p2 = data[1]

    if p1 > 21 and p2 > 21 then

        if p1 < p2 then
      SendPacket(2,
                "action|input\n|text|" ..
                "`0[ Player1 ] : `2" .. p1 ..
                " `bVs `0[ Player2 ] : `4" .. p2
            )

            ontalk("`9Pos LEFT `2WIN! `wLowest > 21")
            log("`9Pos LEFT `2WIN! `wLowest > 21")

            cg1 = p1

        elseif p2 < p1 then
            SendPacket(2,
                "action|input\n|text|" ..
                "`0[ Player1 ] : `4" .. p1 ..
                " `bVs `0[ Player2 ] : `2" .. p2
            )

            ontalk("`9Pos RIGHT `2WIN! `wLowest > 21")
            log("`9Pos RIGHT `2WIN! `wLowest > 21")

            cg2 = p2

        else
            SendPacket(2,
                "action|input\n|text|" ..
                "`0[ Player1 ] : `w" .. p1 ..
                " [ `bTIE `0] `0[ Player2 ] : `w" .. p2
            )

            ontalk("`9Nothing Winner `4TIE!")
            log("`9Nothing Winner `4TIE!")
        end

    elseif p1 > 21 then
        SendPacket(2,
            "action|input\n|text|" ..
            "`0[ Player1 ] : `4" .. p1 ..
            " `bVs `0[ Player2 ] : `2" .. p2
        )

        ontalk("`9Pos Left `4LOSE! `wPlayer1 > 21")
        log("`9Pos Left `4LOSE! `wPlayer1 > 21")

        cg2 = p2

    elseif p2 > 21 then
        SendPacket(2,
            "action|input\n|text|" ..
            "`0[ Player1 ] : `2" .. p1 ..
            " `bVs `0[ Player2 ] : `4" .. p2
        )

        ontalk("`9Pos Right `4LOSE! `wPlayer2 > 21")
        log("`9Pos Right `4LOSE! `wPlayer2 > 21")

        cg1 = p1

    elseif p1 > p2 then
        SendPacket(2,
            "action|input\n|text|" ..
            "`0[ Player1 ] : `2" .. p1 ..
            " `bVs `0[ Player2 ] : `4" .. p2
        )

        ontalk("`9Pos LEFT `2WIN!")
        log("`9Pos LEFT `2WIN!")

        cg1 = p1

    elseif p2 > p1 then
        SendPacket(2,
            "action|input\n|text|" ..
            "`0[ Player1 ] : `4" .. p1 ..
            " `bVs `0[ Player2 ] : `2" .. p2
        )

        ontalk("`9Pos RIGHT `2WIN!")
        log("`9Pos RIGHT `2WIN!")

        cg2 = p2

    else
        SendPacket(2,
            "action|input\n|text|" ..
            "`0[ Player1 ] : `w" .. p1 ..
            " [ `bTIE `0] `0[ Player2 ] : `w" .. p2
        )

        ontalk("`9Nothing Winner `4TIE!")
        log("`9Nothing Winner `4TIE!")
    end

    return false
end

function execute_payout(mode)
    if not Aount or Aount == 0 then
        ontext("`4Warning: Bet value is 0.")
        return
    end

    local jl = math.floor(taxset / 100 * Aount * 2)
    local jumlah = math.floor(Aount * 2 - jl)
    local earnedwls = Aount * 2 - jumlah

    SendVariant({
        v1 = "OnTalkBubble",
        v2 = GetLocal().netID,
        v3 = "`0You Got : `9+" .. earnedwls .. " `9WL.",
        v5 = 1
    })

    if mode == 1 then
        if player1x ~= nil and player1y ~= nil then
            local face_left = false

            if player2x ~= nil and player1x < player2x then
                face_left = true
            end

            greenbox(player1x, player1y)
            path(player1x, player1y, face_left)
        end

    elseif mode == 2 then
        if player2x ~= nil and player2y ~= nil then
            local face_left = false

            if player1x ~= nil and player2x < player1x then
                face_left = true
            end

            greenbox(player2x, player2y)
            path(player2x, player2y, face_left)
        end

    elseif mode == 3 then
        if player3x ~= nil and player3y ~= nil then
            local face_left = false

            if player4x ~= nil and player3x < player4x then
                face_left = true
            end

            greenbox(player3x, player3y)
            path(player3x, player3y, face_left)
        end

    elseif mode == 4 then
        if player4x ~= nil and player4y ~= nil then
            local face_left = false

            if player3x ~= nil and player4x < player3x then
                face_left = true
            end

            greenbox(player4x, player4y)
            path(player4x, player4y, face_left)
        end

    elseif mode == 5 then
        local local_player = GetLocal()

        if local_player then
            greenbox(
                math.floor(local_player.posX / 32),
                math.floor(local_player.posY / 32)
            )
        end
    end

    local drop_bgl = math.floor(jumlah / 10000)
    local rem = jumlah % 10000

    local bgl_inventory = inv(7188)

    if bgl_inventory < drop_bgl then
        rem = rem + ((drop_bgl - bgl_inventory) * 10000)
        drop_bgl = bgl_inventory
    end

    local drop_dl = math.floor(rem / 100)
    local drop_wl = rem % 100

    if inv(242) < drop_wl then
        if inv(1796) > drop_dl then
            wear(1796)
        elseif inv(7188) > drop_bgl then
            wear(7188)
            wear(1796)
        end
    end

    if inv(1796) < drop_dl and inv(7188) > drop_bgl then
        wear(7188)
    end

    if drop_bgl > 0 then
        autodrop(7188, drop_bgl)
    end

    if drop_dl > 0 then
        autodrop(1796, drop_dl)
    end

    if drop_wl > 0 then
        autodrop(242, drop_wl)
    end

    Aount = 0
end

function execute_arroz(mode, count)
    count = tonumber(count) or 0

    if count <= 0 then
        ontext("`4Warning: Count is 0.")
        return
    end

    local targetX, targetY
    local face_left = false

    if mode == 1 then
        targetX, targetY = player1x, player1y

        if player1x < player2x then
            face_left = true
        end

    elseif mode == 2 then
        targetX, targetY = player2x, player2y

        if player2x < player1x then
            face_left = true
        end

    elseif mode == 3 then
        targetX, targetY = player3x, player3y

        if player3x < player4x then
            face_left = true
        end

    elseif mode == 4 then
        targetX, targetY = player4x, player4y

        if player4x < player3x then
            face_left = true
        end

    else
        ontext("`4Warning: Invalid mode.")
        return
    end

    if targetX == nil or targetY == nil then
        ontext("`4Warning: Player position is not set.")
        return
    end

    greenbox(targetX, targetY)
    path(targetX, targetY, face_left)

    autodrop(4604, count)

    ontext("`2Dropped `9" .. count .. " `0Arroz")
    log("`2Dropped `9" .. count .. " `0Arroz")
end

function btk()
setupbtk =  [[
set_bg_color|2, 0, 1, 100|
add_label_with_icon|big|`2Configuration BTK|left|11550|
add_spacer|small|
add_text_input|taxkuy|`wInput Tax Amount|]] ..taxset.. [[|12|
add_textbox|`0Current Tax: `b[`2]]..taxset..[[%`b]|
add_spacer|small|
add_label_with_icon|small|`bPosition Gems Left:|left|340|
add_button|gemsleft1|`0Player1 1: ]]..pos(gemsleftx1,gemslefty1)..[[|noflags|0|
add_button|gemsleft2|`0Player1 2: ]]..pos(gemsleftx2,gemslefty2)..[[|noflags|0|
add_button|gemsleft3|`0Player1 3: ]]..pos(gemsleftx3,gemslefty3)..[[|noflags|0|
add_button|gemsleft4|`0Player1 4: ]]..pos(gemsleftx4,gemslefty4)..[[|noflags|0|
add_button|gemsleft5|`0Player1 5: ]]..pos(gemsleftx5,gemslefty5)..[[|noflags|0|
add_spacer|small|
add_label_with_icon|small|`5Position Gems Right:|left|340|
add_button|gemsright1|`0Player2 1: ]]..pos(gemsrightx1,gemsrighty1)..[[|noflags|0|
add_button|gemsright2|`0Player2 2: ]]..pos(gemsrightx2,gemsrighty2)..[[|noflags|0|
add_button|gemsright3|`0Player2 3: ]]..pos(gemsrightx3,gemsrighty3)..[[|noflags|0|
add_button|gemsright4|`0Player2 4: ]]..pos(gemsrightx4,gemsrighty4)..[[|noflags|0|
add_button|gemsright5|`0Player2 5: ]]..pos(gemsrightx5,gemsrighty5)..[[|noflags|0|
add_spacer|small|
add_label_with_icon|small|`bPosition Display:|left|12854|
add_button|posplayer1|`0Pos Display Player 1: ]]..pos(player1x,player1y)..[[|noflags|0|
add_button|posplayer2|`0Pos Display Player 2 : ]]..pos(player2x,player2y)..[[|noflags|0|
add_button|posplayer3|`0Pos Display Player 3: ]]..pos(player3x,player3y)..[[|noflags|0|
add_button|posplayer4|`0Pos Display Player 4 : ]]..pos(player4x,player4y)..[[|noflags|0|
add_spacer|small|
add_smalltext|`bSupport Transmatter Field``|
add_spacer|small|
add_quick_exit||
end_dialog|setupcoy|Cancel|Apply|
]]
dialog(setupbtk)
return true
end

function take()
    local total_pos1, total_pos2 = 0, 0
    local total_pos3, total_pos4 = 0, 0

    local player_positions = {
        {x = player1x, y = player1y},
        {x = player2x, y = player2y},
        {x = player3x, y = player3y},
        {x = player4x, y = player4y}
    }

    local active_players = {}

    for i, pos in ipairs(player_positions) do
        if type(pos.x) == "number" and type(pos.y) == "number" then
            active_players[#active_players + 1] = i
        end
    end

    if #active_players < 2 then
        ontext("`4At least 2 player positions must be configured!")
        return true
    end

    local totals = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0
    }

    local objects = GetObjectList()

    if objects then
        for _, obj in pairs(objects) do
            local bx = math.floor(obj.posX / 32)
            local by = math.floor(obj.posY / 32)

            local amt = obj.amount or obj.count or 1
            local lock_val = 0

            if obj.itemid == 242 then
                lock_val = amt
            elseif obj.itemid == 1796 then
                lock_val = amt * 100
            elseif obj.itemid == 7188 then
                lock_val = amt * 10000
            end

            if lock_val > 0 then
                for _, i in ipairs(active_players) do
                    local pos = player_positions[i]

                    local dist = math.max(
                        math.abs(bx - pos.x),
                        math.abs(by - pos.y)
                    )

                    if dist <= 1 then
                        totals[i] = totals[i] + lock_val
                        break
                    end
                end
            end
        end
    end

    total_pos1 = totals[1]
    total_pos2 = totals[2]
    total_pos3 = totals[3]
    total_pos4 = totals[4]

    local any_locks = false

    for _, i in ipairs(active_players) do
        if totals[i] > 0 then
            any_locks = true
            break
        end
    end

    if not any_locks then
        ontext("`4No locks found on configured positions!")
        return true
    end

    local reference_total = totals[active_players[1]]

    for _, i in ipairs(active_players) do
        if totals[i] ~= reference_total then
            ontext(
                "`4Bet Mismatched!\n" ..
                "`w[ Player1 ] : `9" .. total_pos1 ..
                "\n`w[ Player2 ] : `9" .. total_pos2 ..
                "\n`w[ Player3 ] : `9" .. total_pos3 ..
                "\n`w[ Player4 ] : `9" .. total_pos4
            )
            return true
        end
    end

    local total_picked = 0

    if objects then
        for _, obj in pairs(objects) do
            local bx = math.floor(obj.posX / 32)
            local by = math.floor(obj.posY / 32)

            local amt = obj.amount or obj.count or 1
            local lock_val = 0

            if obj.itemid == 242 then
                lock_val = amt
            elseif obj.itemid == 1796 then
                lock_val = amt * 100
            elseif obj.itemid == 7188 then
                lock_val = amt * 10000
            end

            if lock_val > 0 then
                for _, i in ipairs(active_players) do
                    local pos = player_positions[i]

                    local dist = math.max(
                        math.abs(bx - pos.x),
                        math.abs(by - pos.y)
                    )

                    if dist <= 1 then
                        total_picked = total_picked + lock_val

                        wear(242)

                        SendPacketRaw(false, {
                            px = bx,
                            py = by,
                            type = 11,
                            value = obj.id,
                            x = obj.posX,
                            y = obj.posY
                        })

                        break
                    end
                end
            end
        end
    end

    if total_picked > 0 then
        Aount = math.floor(total_picked / 2)

        local tax_deduction = math.floor(
            taxset / 100 * total_picked
        )

        saved_tax = tax_deduction

        local payout_after_tax = total_picked - tax_deduction

        local result =
            "[ Player1 ] : `9" .. total_pos1 .. " WL\n" ..
            "[ Player2 ] : `9" .. total_pos2 .. " WL\n" ..
            "[ Player3 ] : `9" .. total_pos3 .. " WL\n" ..
            "[ Player4 ] : `9" .. total_pos4 .. " WL\n" ..
            "[ TAX ] : `9" .. taxset .. " WL\n" ..
            "[ Total ] : `9" .. total_picked .. " WL\n" ..
            "[ PAYOUT ] : `9" .. payout_after_tax .. " WL\n" ..
            "[ `4TAXED`0 ] : `9" .. tax_deduction .. " WL"

        ontext(result)
        log(result)
    end

    return true
end

    function droptax()
            if saved_tax <= 0 then ontext("`4No tax saved."); return true end
        local target = saved_tax
        local b_drop = math.floor(target / 10000)
        local rem = target % 10000

        if inv(7188) < b_drop then rem = rem + ((b_drop - inv(7188)) * 10000); b_drop = inv(7188) end
        local d_drop = math.floor(rem / 100)
        local w_drop = rem % 100

        if inv(242) < w_drop then if inv(1796) > d_drop then wear(1796) elseif inv(7188) > b_drop then wear(7188); wear(1796) end end
        if inv(1796) < d_drop and inv(7188) > b_drop then wear(7188) end

        if b_drop > 0 then autodrop(7188, b_drop) end
        if d_drop > 0 then autodrop(1796, d_drop) end
        if w_drop > 0 then autodrop(242, w_drop) end

        ontext("`0[ Dropped Tax ] : " .. b_drop .. " `eBGL  `0" .. d_drop .. " `1DL  `0" .. w_drop .. " `9WL")
        log("`0[ Dropped Tax ] : " .. b_drop .. " `eBGL  `0" .. d_drop .. " `1DL  `0" .. w_drop .. " `9WL")
        saved_tax = 0
        return true
    end

kou_floating_objects = {}
kou_floating_search = ""

function kouFloatingScan()
    kou_floating_objects = {}

    local objects = getObjectList()
    if not objects then return end

    for _, obj in pairs(objects) do
        if obj then
            local itemid = tonumber(obj.itemid) or 0
            local amount = tonumber(obj.amount) or 1
            local object_id = tonumber(obj.id) or 0

            if itemid > 0 then
                local px = 0
                local py = 0

                if obj.pos then
                    px = tonumber(obj.pos.x) or 0
                    py = tonumber(obj.pos.y) or 0
                end

                local tile_x = math.floor(px / 32)
                local tile_y = math.floor(py / 32)
                local item_info = getItemInfoByID(itemid)
                local item_name = "Unknown Item"

                if item_info and item_info.name then
                    item_name = tostring(item_info.name)
                end

                table.insert(kou_floating_objects, {
                    id = object_id,
                    itemid = itemid,
                    amount = amount,
                    x = tile_x,
                    y = tile_y,
                    name = item_name
                })
            end
        end
    end

    table.sort(kou_floating_objects, function(a, b)
        if a.y == b.y then
            if a.x == b.x then
                return a.id < b.id
            end
            return a.x < b.x
        end
        return a.y < b.y
    end)
end

function kouFloatingMatch(obj)
    if kou_floating_search == "" then
        return true
    end

    local item_name = tostring(obj.name or ""):lower()
    local keyword = tostring(kou_floating_search or ""):lower()

    return item_name:find(keyword, 1, true) ~= nil
end

function kouFloatingDialog()
    kouFloatingScan()

    local lines = {}
    local shown = 0

    table.insert(lines, "set_default_color|`o")
    table.insert(lines, "add_label_with_icon|big|`9Floating Items|left|32|")
    table.insert(lines, "add_smalltext|`7Total Floating Items: `2" .. tostring(#kou_floating_objects) .. "|left|")
    table.insert(lines, "add_spacer|small|")
    table.insert(lines, "add_text_input|kou_float_search|`wSearch Item Name|" .. kou_floating_search .. "|30|")
    table.insert(lines, "add_button|kou_float_search_btn|`2Search|noflags|")
    table.insert(lines, "add_button|kou_float_clear_btn|`4Clear Search|noflags|")
    table.insert(lines, "add_spacer|small|")

    for i, obj in ipairs(kou_floating_objects) do
        if kouFloatingMatch(obj) then
            shown = shown + 1

            local text = "`2" .. obj.name .. " `7x" .. tostring(obj.amount) .. " `o[" .. tostring(obj.x) .. "," .. tostring(obj.y) .. "]"
            table.insert(lines, "add_button_with_icon|kou_float_" .. tostring(i) .. "|" .. text .. "|static|" .. tostring(obj.itemid) .. "|")
        end
    end

    if shown == 0 then
        table.insert(lines, "add_smalltext|`4No floating item found.|left|")
    end

    table.insert(lines, "add_spacer|small|")
    table.insert(lines, "add_smalltext|`7Showing: `2" .. tostring(shown) .. " `7items|left|")
    table.insert(lines, "add_button_with_icon||END_LIST|noflags|0||")
    table.insert(lines, "text_scaling_string|SubsToIptxtxD|")
    table.insert(lines, "add_button|kou_float_refresh|`9Refresh Scan|noflags|")
    table.insert(lines, "end_dialog|kou_floating_dialog|Close||")

    dialog(table.concat(lines, "\n"))
end

function kouFloatingTeleport(index)
    index = tonumber(index)
    if not index then return end

    local obj = kou_floating_objects[index]
    if not obj then return end

    FindPath(obj.x, obj.y)
end

local function getTotalGemsAtTile(x_tile, y_tile)
    local total_amount = 0

    if type(getObjectList()) == "table" then
        for _, obj in pairs(getObjectList()) do
            if obj.itemid == 112 then
                local tx = math.floor((obj.posX + 8) / 32)
                local ty = math.floor((obj.posY + 8) / 32)

                if tx == x_tile and ty == y_tile then
                    total_amount = total_amount + (obj.amount or 1)
                end
            end
        end
    end

    return total_amount
end

local function spawnGemsParticle(x_tile, y_tile, amount)
    local px = (x_tile * 32) + 16
    local py = (y_tile * 32) + 16

    if amount and amount > 0 then
        if type(sendPacketRaw) == "function" then
            sendPacketRaw(true, {
                type = 17,
                x = px,
                y = py,
                xspeed = 0,
                yspeed = 181,
                padding5 = math.floor(amount)
            })
        end
    end
end

local function triggerParticleAt(tx, ty, delay)
    runThread(function()
        sleep(delay or 100)
        local total = getTotalGemsAtTile(tx, ty)
        if total > 0 then
            spawnGemsParticle(tx, ty, total)
            Sleep(800)
            spawnGemsParticle(tx, ty, total)
            Sleep(800)
            spawnGemsParticle(tx, ty, total)
        end
    end)
end

function showchatgems()
    runThread(function()
    Sleep(1000)
SendPacket(2,"action|input\n|text|Collected `#+"..cg.." `7Gems")
log("`9Gems `7Lu `#"..cg.."`7 y")
cg = 0
return false
    end)
end

local function triggerParticleAt1(tx, ty, delay)
    runThread(function()
        sleep(delay or 100)
        local total = getTotalGemsAtTile(tx, ty)
        if total > 0 then
            spawnGemsParticle(tx, ty, total)
        end
    end)
end

function ScanGemsParticle()
    for _, obj in pairs(getObjectList() or {}) do
        if obj.itemid == 112 then
            local x = math.floor((obj.pos.x + 8 or 0) / 32)
            local y = math.floor((obj.pos.y + 8 or 0) / 32)

            triggerParticleAt(x, y, 100)
        end
    end
end

    local function formatGemNumber(number)
        local formatted = tostring(math.floor(number))
        local result

        repeat
            formatted, result = formatted:gsub(
                "^(-?%d+)(%d%d%d)", "%1,%2"
            )
        until result == 0

        return formatted
    end

    local function sendGemCounterChat(message)
        SendPacket(2, "action|input\n|text|" .. message)
    end

runThread(function()
    while true do
        if show_gems_collected then
            local currentCounterGems = getGems() or 0
            local currentGemTime = os.clock() * 1000

            if currentCounterGems > previousCounterGems then
                collectedCounterGems = collectedCounterGems
                    + currentCounterGems - previousCounterGems

                lastGemGainTime = currentGemTime
            end

            previousCounterGems = currentCounterGems

            if collectedCounterGems > 0
                and currentGemTime - lastGemGainTime >= 500 then

                sendGemCounterChat(
                    "`wCollected `#+" ..
                    formatGemNumber(collectedCounterGems) ..
                    " `wGems."
                )

                collectedCounterGems = 0
                lastGemGainTime = 0

                Sleep(1000)
            end
        else
            previousCounterGems = getGems() or 0
            collectedCounterGems = 0
            lastGemGainTime = 0
        end

        Sleep(100)
    end
end)

local function getCleanName(rawName)
    if rawName == nil then return "Player" end
    local clean = tostring(rawName)
    -- Hilangkan akhiran angka spin, baik memakai kode warna maupun tidak.
    clean = clean:gsub("%s*`7%[%s*`?.?%d+`?%s*%]$", "")
    clean = clean:gsub("%s*%[%s*`?.?%d+`?%s*%]$", "")
    clean = clean:gsub("%s*%[%d+%]%s*$", "")
    return clean:match("^%s*(.-)%s*$") or tostring(rawName)
end

-- Nama dinormalisasi agar cache tetap cocok meskipun kode warna/nama tampilan berubah.
local function normalizeSpinName(rawName)
    local name = getCleanName(rawName)
    name = name:gsub("`.", "")
    return name:lower():match("^%s*(.-)%s*$") or name:lower()
end

-- Cache tetap hidup ketika world berganti; tidak mengembalikan nama ke nama asli.
local spinNameOriginals = {}
local spinNumbersByName = {}

local function getPlayerName(netid)
    if getPlayerList then
        local ok, list = pcall(getPlayerList)
        if ok and type(list) == "table" then
            for _, p in pairs(list) do
                if tonumber(p.netid or p.netID) == tonumber(netid) then
                    return getCleanName(p.name)
                end
            end
        end
    end
    if getLocal then
        local ok, me = pcall(getLocal)
        if ok and type(me) == "table" and tonumber(me.netid or me.netID) == tonumber(netid) then
            return getCleanName(me.name)
        end
    end
    return nil
end


local function calculate(expression)
    if not expression or expression == "" then
        return nil
    end

    expression = expression:gsub("%s+", "")

    if expression:find("[^%d%.%+%-%*/%(%)%%%^]") then
        return nil
    end

    for number in expression:gmatch("[%d%.]+") do
        local _, count = number:gsub("%.", "")
        if count > 1 then
            return nil
        end
    end

    local fn, err = load("return " .. expression)
    if not fn then
        return nil
    end

    local success, result = pcall(fn)

    if success and type(result) == "number"
        and result == result
        and result ~= math.huge
        and result ~= -math.huge then
        return result
    end

    return nil
end

local startupPlayer = (type(GetLocal) == "function" and GetLocal()) or nil
local startupName = (type(startupPlayer) == "table" and startupPlayer.name) or "Player"
log("`9Hello, " .. tostring(startupName) .. " Welcome Back")
Sleep(500)
log("`bKamu Bermain Di `0Hari`9 "..hari.." `0Tanggal`c "..tanggal.." `0Bulan`c "..bulan.." `0 Tahun`9 "..tahun.."")
log("`#Ketik /proxy untuk melihat command.")

function hook(type, str, packet)

str = tostring(str or "")

local input = str:lower():gsub("^.*|", ""):gsub("^%s+", ""):gsub("%s+$", "")

local function cmd(command)
    local expected = command:lower()
    if input == expected then
        return true
    end
    return input:sub(1, #expected + 1) == expected .. " "
end

if cmd("/option") then
    openChecklist()
    return true
end

if str:find("action|dialog_return", 1, true)
    and str:find("dialog_name|checklist_dialog", 1, true) then
    return processChecklistReturn(str)
end

if cmd("/proxy") or input == "cmd" then
local currentPlayer = (type(GetLocal) == "function" and GetLocal()) or nil
local currentName = (type(currentPlayer) == "table" and currentPlayer.name) or "Player"
gazette = [[add_label_with_icon|big|`9PROXY Commands    ````       |left|32|
add_spacer|small|
add_smalltext|`9Welcome, to the `5#1 Best OPEN SOURCE Proxy `9script.|left|
add_smalltext|`9What will you do today?, ]]..tostring(currentName)..[[|left|
add_spacer|small|
add_label_with_icon|small|`5Information:|left|3524|
add_spacer|small|
add_textbox|`9/proxy `2- Show proxy command|left|
add_spacer|small|
add_label_with_icon|small|`5Lock Command:|left|1422|
add_spacer|small|
add_textbox|`9/daw `2- Drop All Locks|left|
add_textbox|`9/cd `1[AMOUNT] `2- Custom Drop Lock|left|
add_textbox|`9/dw `1[AMOUNT] `2- Drop WL only|left|
add_textbox|`9/dd `1[AMOUNT] `2- Drop DL only|left|
add_textbox|`9/db `1[AMOUNT] `2- Drop BGL only|left|
add_textbox|`9/bal `2- Show WL Balance|left|
add_textbox|`9/cv `2- Fast convert bgl|left|
add_spacer|small|
add_label_with_icon|small|`5World Command:|left|242|
add_spacer|small|
add_textbox|`9/relog `2- Rejoin world|left|
add_textbox|`9/res `2- Fast respawn|left|
add_textbox|`9/tp [X] [Y] `2- Teleport on path|left|
add_textbox|`9/checktile `2- Fast respawn|left|
add_spacer|small|
add_label_with_icon|small|`5CSN Helper Command:|left|758|
add_spacer|small|
add_textbox|`9/setup `2- Show setup for BJ|left|
add_textbox|`9/bet [ AMOUNT ] `2- Set Manual Bet|left|
add_textbox|`9/tp `2- Take lock in pos|left|
add_textbox|`9/dt `2- Drop Tax|left|
add_textbox|`9/w1 `1[AMOUNT] `2- Drop lock to POS1|left|
add_textbox|`9/w2 `1[AMOUNT] `2- Drop lock to POS2|left|
add_textbox|`9/split `1[AMOUNT] `2- Split|left|
add_textbox|`9/gd `2- Drop payout to current posssition|left|
add_textbox|`9/zzz `2- Show gems collected|left|
add_spacer|small|
add_label_with_icon|small|`5More Command:|left|2376|
add_spacer|small|
add_textbox|`9/arroz [ AMOUNT ] `2- Drop Arroz (`1only show u`2)|left|
add_textbox|`9/relog `2- Fast Relog game|left|
add_spacer|small|
add_quick_exit||
end_dialog|gazz|Cancel|Okay|
]]
dialog(gazette)
return true
end

function weather()
weatherid = [[
set_default_color|`o
add_quick_exit|
add_label_with_icon|big|`b[KillYourIdol] `wWeather Visual|left|934|
add_smalltext|`wSelect weather yang ingin digunakan|
add_spacer|small|
add_button_with_icon|weather_1|`b1 `wBeach Blast|staticBlueFrame|934|
add_button_with_icon|weather_2|`b2 `wNight|staticBlueFrame|934|
add_button_with_icon|weather_3|`b3 `wArid|staticBlueFrame|934|
add_button_with_icon|weather_4|`b4 `wSunny|staticBlueFrame|934|
add_button_with_icon|weather_5|`b5 `wRainy|staticBlueFrame|934|
add_button_with_icon|weather_6|`b6 `wHarvest Moon|staticBlueFrame|934|
add_button_with_icon|weather_7|`b7 `wMars|staticBlueFrame|934|
add_button_with_icon|weather_8|`b8 `wSpooky|staticBlueFrame|934|
add_button_with_icon||END_LIST|noflags|0||
text_scaling_string|SubsToIptxtxD|
add_button_with_icon|weather_9|`b9 `wGrowganoth|staticBlueFrame|934|
add_button_with_icon|weather_10|`b10 `wNothingness|staticBlueFrame|934|
add_button_with_icon|weather_11|`b11 `wSnowy|staticBlueFrame|934|
add_button_with_icon|weather_12|`b12 `wAnggry Growch|staticBlueFrame|934|
add_button_with_icon|weather_13|`b13 `wHappy Growch|staticBlueFrame|934|
add_button_with_icon|weather_14|`b14 `wUndersea|staticBlueFrame|934|
add_button_with_icon|weather_15|`b15 `wWarp Speed|staticBlueFrame|934|
add_button_with_icon|weather_16|`b16 `wNight Of The Comet|staticBlueFrame|934|
add_button_with_icon||END_LIST|noflags|0||
text_scaling_string|SubsToIptxtxD|
add_button_with_icon|weather_17|`b17 `wComet|staticBlueFrame|934|
add_button_with_icon|weather_18|`b18 `wPARTY!|staticBlueFrame|934|
add_button_with_icon|weather_19|`b19 `wPineapple|staticBlueFrame|934|
add_button_with_icon|weather_20|`b20 `wSnowy Night|staticBlueFrame|934|
add_button_with_icon|weather_21|`b21 `wSpring|staticBlueFrame|934|
add_button_with_icon|weather_22|`b22 `wHowl|staticBlueFrame|934|
add_button_with_icon|weather_23|`b23 `wSunny|staticBlueFrame|934|
add_button_with_icon|weather_24|`b24 `wHeatwave [ Purple ]|staticBlueFrame|934|
add_button_with_icon||END_LIST|noflags|0||
text_scaling_string|SubsToIptxtxD|
add_button_with_icon|weather_25|`b25 `wHeatwave [ Red ]|staticBlueFrame|934|
add_button_with_icon|weather_26|`b26 `wHeatwave [ Green ]|staticBlueFrame|934|
add_button_with_icon|weather_27|`b27 `wHeatwave [ Blue ]|staticBlueFrame|934|
add_button_with_icon|weather_28|`b28 `wHeatwave [ Orange ]|staticBlueFrame|934|
add_button_with_icon|weather_29|`b29 `wStuff|staticBlueFrame|934|
add_button_with_icon|weather_30|`b30 `wPagoda|staticBlueFrame|934|
add_button_with_icon|weather_31|`b31 `wApocalypse|staticBlueFrame|934|
add_button_with_icon|weather_32|`b32 `wJungle|staticBlueFrame|934|
add_button_with_icon||END_LIST|noflags|0||
text_scaling_string|SubsToIptxtxD|
add_button_with_icon|weather_33|`b33 `wBaloon|staticBlueFrame|934|
add_button_with_icon|weather_34|`b34 `wBackground|staticBlueFrame|934|
add_button_with_icon|weather_35|`b35 `wAutumn|staticBlueFrame|934|
add_button_with_icon|weather_36|`b36 `wValentine's|staticBlueFrame|934|
add_button_with_icon|weather_37|`b37 `wSt.Paddy's|staticBlueFrame|934|
add_button_with_icon|weather_38|`b38 `wEpoch [ Ice ]|staticBlueFrame|934|
add_button_with_icon|weather_39|`b39 `wEpoch [ Volcano ]|staticBlueFrame|934|
add_button_with_icon|weather_40|`b40 `wEpoch [ Land ]|staticBlueFrame|934|
add_button_with_icon||END_LIST|noflags|0||
text_scaling_string|SubsToIptxtxD|
add_spacer|small|
add_button|weather_close|`4Close|
end_dialog|weather_visual|||
]]
dialog(weatherid)
return true
end

if str:find("action|friends\ndelay") or str:find("buttonClicked|bk0") or str == ("action|dialog_return\ndialog_name|socialportal\n") then
mmenu = [[
set_default_color|`o
set_bg_color|2, 0, 1, 100|
set_border_color|255, 255, 255, 200|
add_quick_exit|

add_label_with_icon|big|`wKillYourIdoll `9Proxy Menu|left|758|
add_spacer|small|

add_textbox|`9General Tools|left|
text_scaling_string|SubsToIptxtxD|
add_button_with_icon|fcbgl|`wFast Change BGL|staticPurpleFrame|7188|
add_button_with_icon|setupbtkk|`6BTK Setup|staticPurpleFrame|340|
add_button_with_icon|weatherr|`wWeather|staticPurpleFrame|934|
add_button_with_icon|scan_floating|`3Scan Floating|staticPurpleFrame|6016|
add_button_with_icon|auto_crime|`4Auto Crime|staticPurpleFrame|2380|
add_button_with_icon|friends|`eSocial|staticPurpleFrame|9474|
add_spacer|small|
add_button_with_icon||END_LIST|noflags|0||
add_textbox|`9Gems Tools|left|
text_scaling_string|SubsToIptxtxD|
add_button_with_icon|open_logs|`9Logs|staticPurpleFrame|10668|
add_spacer|small|
add_button_with_icon||END_LIST|noflags|0||
end_dialog|k||Back|
]]
dialog(mmenu)
return true
end

    if cmd("/logs") or str:find("buttonClicked|open_logs") then
        show_logs_menu()
        return true
    end

local spin_search = ""

local function show_spin_logs(query)
    spin_search = query or ""

    local d = "set_default_color|`o\n"
    d = d .. "add_label_with_icon|big|`bRoulette Logs|left|32|\n"
    d = d .. "add_text_input|spin_search|Search Logs:|" .. spin_search .. "|30|\n"
    d = d .. "add_button|btn_search_spin|Search|\n"
    d = d .. "add_spacer|small|\n"

    local found = false

    for _, v in ipairs(spin_logs) do
        local log = tostring(v)

        if spin_search == ""
            or log:lower():find(spin_search:lower(), 1, true) then

            log = log:gsub("^(%S+)", "`2%1`o", 1)

            d = d .. "add_textbox|" .. log .. "|left|\n"
            found = true
        end
    end

    if not found then
        d = d .. "add_textbox|`4No logs found.|left|\n"
    end

    d = d .. "add_spacer|small|\n"
    d = d .. "add_button|back_to_logs|`wBack to Menu|\n"
    d = d .. "end_dialog|logs_view|Close||\n"

    dialog(d)
end

if str:find("dialog_name|logs_menu_main", 1, true) then

    if str:find("buttonClicked|btn_world_logs", 1, true) then
        local d = "set_default_color|`o\n"
        d = d .. "add_label_with_icon|big|`bWorld Logs|left|3826|\n"
        d = d .. "add_spacer|small|\n"

        for _, v in ipairs(world_logs) do
            d = d .. "add_textbox|" .. tostring(v) .. "|left|\n"
        end

        d = d .. "add_spacer|small|\n"
        d = d .. "add_button|back_to_logs|`wBack to Menu|\n"
        d = d .. "end_dialog|logs_view|Close||\n"

        dialog(d)
        return true

    elseif str:find("buttonClicked|btn_spin_logs", 1, true) then
        show_spin_logs("")
        return true
    end
end

if str:find("action|dialog_return", 1, true)
    and str:find("dialog_name|logs_view", 1, true) then

    local button = str:match("buttonClicked|([^\r\n]*)")

    if button == "btn_search_spin" then
        local query = str:match("\nspin_search|([^\r\n]*)") or ""
        show_spin_logs(query)
        return true

    elseif button == "back_to_logs" then
        show_spin_logs("")
        return true
    end
end

    if str:find("dialog_name|logs_view") and str:find("buttonClicked|back_to_logs") then
        show_logs_menu()
        return true
    end

if cmd("/relog") then
    local wname = GetWorldName()

    if wname and wname ~= "" and wname ~= "EXIT" then
        relogWorld = wname
        relogPending = true
        SendPacket(3, "action|quit_to_exit")
    else
        ontext("`4You are not currently in a world.")
    end

    return true
end

if relogPending and str:find("action|quit_to_exit", 1, true) then
        return false
    end

if str:find("buttonClicked|btkbutton") then
btk()
return true
end

    if str:find("buttonClicked|Save", 1, true) then

        blink_color = getCheckbox(
            str,
            "blink_color",
            blink_color
        )

        pref:set("blink_color", blink_color)
        pref:save()
        applyChecklistBlink()

        log("`2Checklist Saved")

        return true
    end

if str:find("buttonClicked|friends") then
SendPacket(2,"action|friends\ndelay|0\n")
return true
end

if str:find("buttonClicked|weatherr") or cmd("/weatherid") then
weather()
return true
end

if str:find("buttonClicked|visual_gems_mode") then
visual_gems_mode = not visual_gems_mode
ontext("`9Visual Gems Mode : " .. (visual_gems_mode and "`2ON" or "`4OFF"))
return true
end

local weatherChoice = str:match("buttonClicked|weather_(%d+)")

if weatherChoice then
    weatherChoice = tonumber(weatherChoice)
    if weatherChoice >= 1 and weatherChoice <= 40 then
        savedWeather = weatherChoice
        pref:set("saved_weather", savedWeather)
        pref:save()
        growtopia.setWeather(savedWeather)
        return true
    end
end

if str:find("buttonClicked|mod_menu") or cmd("/modmenu") then
checklist()
return true
end

if str:find("buttonClicked|scan_floating") or cmd("/scan") then
    kou_floating_search = ""
    kouFloatingDialog()
    return true
end

if str:find("dialog_name|kou_floating_dialog") then
    if str:find("buttonClicked|kou_float_search_btn") then
        kou_floating_search = str:match("kou_float_search|([^\n]*)") or ""
        kouFloatingDialog()
        return true
    end

    if str:find("buttonClicked|kou_float_clear_btn") then
        kou_floating_search = ""
        kouFloatingDialog()
        return true
    end

    if str:find("buttonClicked|kou_float_refresh") then
        kouFloatingDialog()
        return true
    end

    local index = str:match("buttonClicked|kou_float_(%d+)")
    if index then
        kouFloatingTeleport(index)
        return true
    end
end

if str:find("buttonClicked|posplayer1") then
player1loc = true
log("`9Please Punch Display")
ontext("`9Please Punch Display")
return true
elseif str:find("buttonClicked|posplayer2") then
player2loc = true
log("`9Please Punch Display")
ontext("`9Please Punch Display")
return true
end
if str:find("buttonClicked|posplayer3") then
player3loc = true
log("`9Please Punch Display")
ontext("`9Please Punch Display")
return true
elseif str:find("buttonClicked|posplayer4") then
player4loc = true
log("`9Please Punch Display")
ontext("`9Please Punch Display")
return true
end

if str:find("buttonClicked|gemsright1") then
gemsright1 = true
log("`9Please Punch Chand")
ontext("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsright2") then
gemsright2 = true
log("`9Please Punch Chand")
ontext("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsright3") then
gemsright3 = true
log("`9Please Punch Chand")
ontext("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsright4") then
gemsright4 = true
log("`9Please Punch Chand")
ontext("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsright5") then
gemsright5 = true
log("`9Please Punch Chand")
ontext("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsright6") then
gemsright6 = true
log("`9Please Punch Chand")
ontext("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsright7") then
gemsright7 = true
log("`9Please Punch Chand")
ontext("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsright8") then
gemsright8 = true
log("`9Please Punch Chand")
ontext("`9Please Punch Chand")
return true
end

if str:find("buttonClicked|gemsleft1") then
gemsleft1 = true
log("`9Please Punch Chand")
ontext("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsleft2") then
gemsleft2 = true
log("`9Please Punch Chand")
ontext("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsleft3") then
gemsleft3 = true
log("`9Please Punch Chand")
ontext("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsleft4") then
gemsleft4 = true
log("`9Please Punch Chand")
ontext("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsleft5") then
gemsleft5 = true
log("`9Please Punch Chand")
ontext("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsleft6") then
gemsleft6 = true
log("`9Please Punch Chand")
ontext("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsleft7") then
gemsleft7 = true
log("`9Please Punch Chand")
ontext("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsleft8") then
gemsleft8 = true
log("`9Please Punch Chand")
ontext("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|backpos") then
backpos = true
log("`9Punch Position Back")
ontext("`9Punch Position Back")
return true
end

if cmd("/checktile") then
checktile = not checktile
ontext("`2Checktile: " .. (checktile and "`2ON" or "`4OFF"))
log("`2Checktile: " .. (checktile and "`2ON" or "`4OFF"))
return true
end

if cmd("/tg") or str:find("buttonClicked|ck") then
takegems()
return true
end

if str:find("buttonClicked|fcbgl") then
toggleAutoConvert()
return true
end


if str:find("buttonClicked|auto_crime") then
autocrime = not autocrime
ontext("`2Auto Crime: " .. (autocrime and "`2ON" or "`4OFF"))
return true
end

     if string.match(input, "/arroz (%d+)") then
jumlah = string.match(input, "/arroz (%d+)")
dropItem(4604,jumlah)
ontalk("`2Succesfully Drop `0"..jumlah.." `9Arroz!")
log("`2Succesfully Drop `0"..jumlah.." `9Arroz!")
return true
end

local amount = input:match("^/arroz%d+ (%d+)$")
if amount then
    if input:match("^/arroz1 ") then
        execute_arroz(1, tonumber(amount))
    elseif input:match("^/arroz2 ") then
        execute_arroz(2, tonumber(amount))
    elseif input:match("^/arroz3 ") then
        execute_arroz(3, tonumber(amount))
    elseif input:match("^/arroz4 ") then
        execute_arroz(4, tonumber(amount))
    end
    return true
end

     if string.match(input, "/dd (%d+)") then
local amount = string.match(input, "/dd (%d+)")
local cur_dl, cur_bgl = inv(1796), inv(7188)
local b_drop = math.floor(amount / 100)
local d_drop = amount % 100
if cur_bgl < b_drop then
local diff = b_drop - cur_bgl
b_drop = cur_bgl
d_drop = d_drop + (diff * 100)
end
local max_dl_100s = math.floor(cur_dl / 100)
local replace_bgl = math.min(max_dl_100s, b_drop)
b_drop = b_drop - replace_bgl
d_drop = d_drop + (replace_bgl * 100)
if cur_dl < d_drop then wear(7188) end
if b_drop > 0 then autodrop(7188, b_drop) end
if d_drop > 0 then autodrop(1796, d_drop) end
ontext("`2Dropped: `9" .. b_drop .. " BGL  `9" .. d_drop .. " DL  `90 WL")
ontalk("`2Dropped: `9" .. b_drop .. " BGL  `9" .. d_drop .. " DL  `90 WL")
log("`2Dropped: `9" .. b_drop .. " BGL  `9" .. d_drop .. " DL  `90 WL")
return true
end

if string.match(input, "^/db (%d+)$") then
    local jumlah = tonumber(string.match(input, "^/db (%d+)$"))
    if jumlah > 0 then
        dropItem(7188, jumlah)
        ontalk("`2Successfully Dropped `0" .. jumlah .. " `eBlue Gem Locks!")
        log("`2Successfully Dropped `0" .. jumlah .. " `eBlue Gem Locks!")
    end
    return true
end

if string.match(input, "/cd (%d+)") then
local target = string.match(input, "/cd (%d+)")
local b_drop = math.floor(target / 10000)
local rem = target % 10000
if inv(7188) < b_drop then
rem = rem + ((b_drop - inv(7188)) * 10000)
b_drop = inv(7188)
end
local d_drop = math.floor(rem / 100)
local w_drop = rem % 100
if inv(242) < w_drop then
if inv(1796) > d_drop then wear(1796)
elseif inv(7188) > b_drop then wear(7188); wear(1796) end
end
if inv(1796) < d_drop and inv(7188) > b_drop then wear(7188) end
if b_drop > 0 then autodrop(7188, b_drop) end
if d_drop > 0 then autodrop(1796, d_drop) end
if w_drop > 0 then autodrop(242, w_drop) end
    local result =
        "`2Dropped: `9" .. b_drop ..
        " BGL  `9" .. d_drop ..
        " DL  `9"..w_drop..
        " WL"
    ontext(result)
    log(result)
    ontalk(result)
return true
end

if cmd("/bal") then
local hailto = inv(242) + (inv(1796) * 100) + (inv(7188) * 10000)
log("`2Balance: `9"..hailto.."`2 WL (`9"..inv(7188).." `2BGL, `9"..inv(1796).." `2DL, `9"..inv(242).." `2WL).")
return true
end

if cmd("/daw") then
        local wl, dl, bgl = inv(242), inv(1796), inv(7188)
        if wl > 0 then autodrop(242, wl) end
        if dl > 0 then autodrop(1796, dl) end
        if bgl > 0 then autodrop(7188, bgl) end
return true
end

    if cmd("/cv") then
        toggleAutoConvert()
        return true
    end
        if cmd("/gemsrepeat") or str:find("buttonClicked|gems_repeat") then
        gemsrepeat = not gemsrepeat
        ontext("`2Gems Repeat : " .. (gemsrepeat and "`2ON" or "`4OFF"))
        runThread(function()
repeatgems()
end)
        return true
    end

    if auto_bgl_mode then
    toggleAutoConvert()
    end

if cmd("/res") then
growtopia.notify("`2Respawn Succesful.")
log("`2Respawn Succesful.")
SendPacket(2,"action|respawn")
return true
end

    if cmd("/reme") then
        Config.gameMode = "reme"
        log("Mode: REME")
        notify("Mode: REME")
        return true
    end
    if cmd("/leme") then
        Config.gameMode = "leme"
        log("Mode: LEME")
        notify("Mode: LEME")
        return true
    end
    if cmd("/lewa") then
        Config.gameMode = "lewa"
        log("Mode: lewa")
        notify("Mode: LEWA")
        return true
    end

     if cmd("/zzz") then
SendPacket(2,"action|input\n|text|Collected `2+"..cg.." Gems")
log("`9Gems `7Lu `#"..cg.."`7 y")
cg = 0
return false
end

     if cmd("/tb") then
     log("Block has been Taked")
     takeblock()
     return true
     end

if string.match(input, "/tp (%d+) (%d+)") then
local x = string.match(input, "/tp (%d+)")
local y = string.match(input, "/tp "..x.." (%d+)")
FindPath(x, y)
ontalk("`2Succesfully teleport to Pos `0"..x.." "..y.."!")
log("`2Succesfully teleport to Pos `0"..x.." "..y.."!")
return true
end

if cmd("/setup") or str:find("buttonClicked|setupbtkk")then
btk()
kou()
log("`2Opening setup BTK")
return true
end

    if str:find([[
action|dialog_return
dialog_name|setupcoy
taxkuy|(%d+%.?%d*)]]) then
taxset = str:match("taxkuy|(%d+%.?%d*)")
ontalk("`4Tax Set To : `9"..taxset.."")
log("`4Tax Set To : `9"..taxset.."")
return true
  end

if str:find("/settax (%d+%.?%d*)") then
    taxset = tonumber(str:match("/settax (%d+%.?%d*)"))

    if taxset and taxset >= 0 and taxset <= 100 then
        ontext("`2Tax set to: `w" .. taxset .. "%")
    else
        ontext("`4Tax must be between 0 and 100.")
    end

    return true
end

    if cmd("/acc") then
        auto_accept_mode = not auto_accept_mode
        ontalk("`2Auto Accept Access Mode: " .. (auto_accept_mode and "`2ON" or "`4OFF"))
        return true
    end

  if cmd("/gems") then
  punchgems = not punchgems
  ontext("`2PunchGems: " .. (punchgems and "`2ON" or "`4OFF"))
  log("`2PunchGems: " .. (punchgems and "`2ON" or "`4OFF"))
  return true
  end

if cmd("/pos1") then
player1x = math.floor(GetLocal().posX / 32)
player1y = math.floor(GetLocal().posY / 32)
ontext("Pos player 1 Saved")
greenbox(player1x, player1y)
return true
end
if cmd("/pos2") then
player2x = math.floor(GetLocal().posX / 32)
player2y = math.floor(GetLocal().posY / 32)
ontext("Pos player 2 Saved")
greenbox(player2x, player2y)
return true
end
if cmd("/pos3") then
player3x = math.floor(GetLocal().posX / 32)
player3y = math.floor(GetLocal().posY / 32)
ontext("Pos player 3 Saved")
greenbox(player3x, player3y)
return true
end
if cmd("/pos4") then
player4x = math.floor(GetLocal().posX / 32)
player4y = math.floor(GetLocal().posY / 32)
ontext("Pos player 4 Saved")
greenbox(player4x, player4y)
return true
end

if cmd("/remove1") then
player1x = nil
player1y = nil
ontext("Pos player 1 Removed")
return true
end
if cmd("/remove2") then
player2x = nil
player2y = nil
ontext("Pos player 2 Removed")
return true
end
if cmd("/remove3") then
player3x = nil
player3y = nil
ontext("Pos player 3 Removed")
return true
end
if cmd("/remove4") then
player4x = nil
player4y = nil
ontext("Pos player 4 Removed")
return true
end

if string.match(input, "^/weather (%d+)$") then
    local id = tonumber(string.match(input, "^/weather (%d+)$"))
    if id and id >= 1 and id <= 40 then
        savedWeather = id
        pref:set("saved_weather", savedWeather)
        pref:save()
        growtopia.setWeather(savedWeather)
        log("Weather changed to ID: " .. id)
    else
        log("`4Weather ID harus antara 1 sampai 40.")
    end
    return true
end

if cmd("/blink") then
    checklist.blinkMode = not checklist.blinkMode
    pref:set("checklist_blinkMode", checklist.blinkMode)
    pref:save()
    applyChecklistBlink()
    ontext("`2Blinking Skin: " .. (blinking and "`2ON" or "`4OFF"))
    log("`2Blinking Skin: " .. (blinking and "`2ON" or "`4OFF"))
    return true
end
    if string.match(input, "/bet (%d+)") then
        Aount = tonumber(match)
        local total_picked = Aount * 2
        local tax_deduction = math.floor(stax / 100 * total_picked)
        saved_tax = tax_deduction
        local payout_after_tax = total_picked - tax_deduction
        ontext("`w[ BET1 ] : `9" .. Aount .. " WL\n`w[ BET2 ] : `9" .. Aount .. " WL\n`w[ TOTAL ] : `9" .. total_picked .. " WL\n`w [ PAYOUT ] : `9" .. payout_after_tax .. " WL\n`4 [ TAX ] : `9" .. tax_deduction .. " WL")
        log("`w[ BET1 ] : `9" .. Aount .. " WL\n`w[ BET2 ] : `9" .. Aount .. " WL\n`w[ TOTAL ] : `9" .. total_picked .. " WL\n`w [ PAYOUT ] : `9" .. payout_after_tax .. " WL\n`4 [ TAX ] : `9" .. tax_deduction .. " WL")
        return true
    end

    if str:find("/calc ", 1, true) then
    local expression = str:match("/calc%s+(.+)")

    if expression then
        local result = calculate(expression)

        if result ~= nil then
            ontext(
                "`w" ..
                expression ..
                " `2= `w" ..
                tostring(result)
            )
            ontalk(
                "`w" ..
                expression ..
                " `2= `w" ..
                tostring(result)
            )
            log(
                "`2Calculator: `w" ..
                expression ..
                " `2= `w" ..
                tostring(result)
            )
        else
            ontext("`4Invalid calculation!")
        end
    else
        ontext("`4Usage: /calc 4*5")
    end

    return true
end

if cmd("/tp") then
take()
return true
end

if cmd("/dt") then
droptax()
return true
end

if cmd("/radar") then
showRadar()
return true
end

    if cmd("/w1") then execute_payout(1); return true end
    if cmd("/w2") then execute_payout(2); return true end
    if cmd("/w3") then execute_payout(3); return true end
    if cmd("/w4") then execute_payout(4); return true end
    if cmd("/gd") then execute_payout(5); return true end

    if cmd("/autome") then
        auto_me_mode = not auto_me_mode
        ontext("`2Auto /me Mode: " .. (auto_me_mode and "`2ON" or "`4OFF"))
        return true
    end

if string.match(input, "/drop (%d+) (%d+)") then
local id = string.match(input, "/drop (%d+)")
local amount = string.match(input, "/drop "..id.." (%d+)")
    if id and amount then
        posX, posY = getLocal().posX + 32, getLocal().posY
    sendPacketRaw(true, {
            type = 14,
            value = tonumber(id),
            netid = -1,
            secnetid = 1,
            padding4 = tonumber(amount),
            x = posX,
            y = posY
        })

end
        return true
    end

    if auto_me_mode and str:find("action|input\n|text|") then
        local chat_msg = str:match("text|(.*)")
        if chat_msg and chat_msg:sub(1,1) ~= "/" then
            SendPacket(2, "action|input\n|text|/me " .. chat_msg)
            return true
        end
    end

if string.match(input, "^/split%s+(%d+)$") then
    local pct = tonumber(string.match(input, "^/split%s+(%d+)$"))
    pct = math.max(0, math.min(100, pct))

    local wl = inv(242) or 0
    local dl = inv(1796) or 0
    local bgl = inv(7188) or 0

    local total_wl = wl + (dl * 100) + (bgl * 10000)
    local target = math.floor(total_wl * pct / 100)

    if target <= 0 then
        ontext("`4Nothing to drop.")
        return true
    end

    local b_drop = math.min(math.floor(target / 10000), bgl)
    local rem = target - (b_drop * 10000)

    local d_drop = math.min(math.floor(rem / 100), dl)
    rem = rem - (d_drop * 100)

    local w_drop = math.min(rem, wl)

    local actual = (b_drop * 10000) + (d_drop * 100) + w_drop

    if actual <= 0 then
        ontext("`4Tidak ada item yang dapat di-drop.")
        return true
    end

    if b_drop > 0 then
        autodrop(7188, b_drop)
    end

    if d_drop > 0 then
        autodrop(1796, d_drop)
    end

    if w_drop > 0 then
        autodrop(242, w_drop)
    end

    ontext(
        "`2Dropped: "
        .. "`9" .. b_drop .. " BGL  "
        .. "`9" .. d_drop .. " DL  "
        .. "`9" .. w_drop .. " WL"
    )

    return true
end

return false
end

function var(var)
    if type(var) ~= "table" then
        return false
    end
    var.v1 = tostring(var.v1 or "")

if Config and Config.autoConvert then
    local payload = type(var.v2) == "string" and var.v2 or ""

    if payload:find("Wow, that's fast delivery.", 1, true) then
        Config.autoConvertStep = 1
        return true
    end

    if var.v1 == "OnDialogRequest"
    and payload:find("Telephone", 1, true) then

        local x = payload:match("tilex|(%d+)")
        local y = payload:match("tiley|(%d+)")

        if x then Config.autoConvertX = tonumber(x) end
        if y then Config.autoConvertY = tonumber(y) end

        local tx = tonumber(Config.autoConvertX)
        local ty = tonumber(Config.autoConvertY)

        if not tx or not ty then
            return true
        end

        if Config.autoConvertStep == 1 then
            SendPacket(2,
                "action|dialog_return\n" ..
                "dialog_name|phonecall\n" ..
                "tilex|" .. tx .. "\n" ..
                "tiley|" .. ty .. "\n" ..
                "num|53785\n" ..
                "buttonClicked|chc5"
            )

            Config.autoConvertStep = 2

        elseif Config.autoConvertStep == 2 then
            SendPacket(2,
                "action|dialog_return\n" ..
                "dialog_name|phonecall\n" ..
                "tilex|" .. tx .. "\n" ..
                "tiley|" .. ty .. "\n" ..
                "num|-34\n" ..
                "buttonClicked|chc0"
            )

            Config.autoConvertStep = 1
        end

        return true
    end
end

    if var.v1 == "OnDialogRequest" and type(var.v2) == "string" then
        local d = var.v2
        if d:find("drop", 1, true) and (d:find("242", 1, true) or d:find("1796", 1, true) or d:find("7188", 1, true) or d:find("4604", 1, true)) then
            return true
        end
    end

    if var.v1 == "OnConsoleMessage" then
        local msg = tostring(var.v2 or "")
        if msg:match("Collected `w(%d+) World Lock``") then
            wear(242)
            return true
        end
    end

   if var.v1 == "OnConsoleMessage" and tostring(var.v2 or ""):find("list of valid", 1, true) then
log("`4Gada Command Begitu Njing")
return true
end

   if var.v1 == "OnConsoleMessage" and tostring(var.v2 or ""):find("World Locked", 1, true) then
log("\n`#Balance\n`9World Locks : `2"..inv(242).."\n`1Diamond Locks : `2"..inv(1796).."\n`eBlue Gem Locks : `2"..inv(7188).."\n`9Gems : `2"..getGems().."`0")
return true
end

   if var.v1 == "OnConsoleMessage" and tostring(var.v2 or ""):find("powerhelp", 1, true) then
log("`4/proxy For menu")
return true
end

   if var.v1 == "OnConsoleMessage" and tostring(var.v2 or ""):find("World Locked", 1, true) then
log("\n`#Balance\n`9World Locks : `2"..inv(242).."\n`1Diamond Locks : `2"..inv(1796).."\n`eBlue Gem Locks : `2"..inv(7188).."\n`9Gems : `2"..getGems().."`0")
return true
end

   if var.v1 == "OnConsoleMessage" and tostring(var.v2 or ""):find("Where would", 1, true) then
log("\n`#Balance\n`9World Locks : `2"..inv(242).."\n`1Diamond Locks : `2"..inv(1796).."\n`eBlue Gem Locks : `2"..inv(7188).."\n`9Gems : `2"..getGems().."`0")
return true
end

if var.v1 == "OnTalkBubble" and var.v3 then
    local msg = tostring(var.v3)

    if msg:find("spun the wheel and got", 1, true) then
        uidplayer = tonumber(var.v2)
        spintext = msg

        local clean = msg:gsub("`.", "")
        local num = tonumber(clean:match("got.-(%d+)"))
        local isFakeSpin = msg:find("OID:", 1, true) ~= nil
            or (msg:find("<", 1, true) ~= nil and msg:find(">", 1, true) ~= nil)

        if isFakeSpin then
            -- Tandai fake spin seperti fitur message.lua.
            local fakeChat = msg:match("player_chat=(.+)") or msg
            var.v3 = "`7[`4FAKE``] " .. fakeChat
        elseif num then
            spinNumberColor = msg:match("got.-(`.)%d+") or "`b"

            -- Tambahkan angka spin di samping nama player untuk semua mode.
            local playerName = spinNameOriginals[uidplayer] or getPlayerName(uidplayer)
            if playerName and playerName ~= "" then
                -- Simpan nama dasar dan pertahankan saat keluar/masuk world.
                if spinNameOriginals[uidplayer] == nil then
                    spinNameOriginals[uidplayer] = playerName:gsub("%s+`7%[.*%]$", "")
                end
                playerName = spinNameOriginals[uidplayer]
                -- Simpan hasil spin terakhir berdasarkan nama dasar, bukan hanya NetID.
                -- NetID dapat berubah ketika keluar lalu masuk world lain.
                spinNumbersByName[normalizeSpinName(playerName)] = {
                    baseName = playerName,
                    number = tostring(num),
                    color = spinNumberColor
                }
                local nameWithSpin = playerName .. " `#[ " .. spinNumberColor .. tostring(num) .. "`# ]"
                SendVariant({
                    v1 = "OnNameChanged",
                    v2 = nameWithSpin,
                    netID = uidplayer
                }, uidplayer)
            end

            -- Pertahankan tampilan Number Only dan Fast Wheel.
            if Config.gameMode == "number_only" or Config.gameMode == "number" then
                var.v3 = "`w[ `2REAL`w ] " .. spinNumberColor .. tostring(num)
            else
                var.v3 = "`7[ `2REAL`` ] " .. msg
            end
        end
        return true
    end
end

if var.v1 == "OnConsoleMessage" and var.v2 then
    local console_msg = tostring(var.v2)
    local isFakeSpin = console_msg:find("OID:", 1, true) ~= nil
        or (console_msg:find("<", 1, true) ~= nil and console_msg:find(">", 1, true) ~= nil)

    if console_msg:find("spun the wheel and got", 1, true) then

        local text_to_check = spintext or console_msg
        local clean_text = text_to_check:gsub("`.", "")
        local num = tonumber(clean_text:match("got.-(%d+)"))
        local number_color = spinNumberColor or text_to_check:match("got.-(`.)%d+") or "`w"

        if not num then
            spintext = nil
            spinNumberColor = nil
            uidplayer = nil
            return false
        end

        local localPlayer = (type(GetLocal) == "function" and GetLocal()) or nil
        local target_uid = uidplayer
            or (type(localPlayer) == "table" and tonumber(localPlayer.netid))
            or (type(localPlayer) == "table" and tonumber(localPlayer.netID))
            or -1

        local timestamp = os.date("%H:%M:%S")

        if Config.gameMode == "number_only" then
            if isFakeSpin then
                if target_uid ~= -1 then
                    SendVariant({
                        v1 = "OnTalkBubble",
                        v2 = target_uid,
                        v3 = "`w[ `4FAKE`w ] " .. number_color .. tostring(num),
                        v4 = 0,
                        v5 = 0
                    })
                end

                SendVariant({
                    v1 = "OnConsoleMessage",
                    v2 = "`w[ `4FAKE`w ] " .. number_color .. tostring(num)
                })
            else
                if target_uid ~= -1 then
                    SendVariant({
                        v1 = "OnTalkBubble",
                        v2 = target_uid,
                        v3 = "`w[ `^REAL`w ] " .. number_color .. tostring(num),
                        v4 = 0,
                        v5 = 0
                    })
                end

                SendVariant({
                    v1 = "OnConsoleMessage",
                    v2 = "`w[ `^REAL`w ] " .. number_color .. tostring(num)
                })
            end

            add_log(
                spin_logs,
                "`8[" .. timestamp .. "] `p◆ `w" .. clean_text .. " `8» `w"
            )

            spintext = nil
            spinNumberColor = nil
            uidplayer = nil
            return true
        end

                if Config.gameMode == "number" then
            if isFakeSpin then
                if target_uid ~= -1 then
                    SendVariant({
                        v1 = "OnTalkBubble",
                        v2 = target_uid,
                        v3 = "`w[ `4FAKE`w ] `w" .. (spintext or console_msg),
                        v4 = 0,
                        v5 = 0
                    })
                end

                SendVariant({
                    v1 = "OnConsoleMessage",
                    v2 = "`w[ `4FAKE`w ] `w" .. console_msg
                })
            else
                if target_uid ~= -1 then
                    SendVariant({
                        v1 = "OnTalkBubble",
                        v2 = target_uid,
                        v3 = "`w[ `^REAL`w ] `w" .. (spintext or console_msg),
                        v4 = 0,
                        v5 = 0
                    })
                end

                SendVariant({
                    v1 = "OnConsoleMessage",
                    v2 = "`w[ `^REAL`w ] `w" .. console_msg
                })
            end

            add_log(
                spin_logs,
                "`8[" .. timestamp .. "] `p◆ `w" .. clean_text .. " `8» `w"
            )

            spintext = nil
            uidplayer = nil
            return true
        end

        local logic = ""
        local point

        if Config.gameMode == "reme" then
            point = (math.floor(num / 10) + (num % 10)) % 10

            if point == 0 then
                logic = " `w[ `^REME : `b" .. point .. " `2X3!`w ]"
            elseif point == 1 then
                logic = " `w[ `^REME : `b" .. point .. " `4AUTO LOSE`w ]"
            else
                logic = " `w[ `^REME : `b" .. point .. "`w ]"
            end

        elseif Config.gameMode == "leme" then
            point = (math.floor(num / 10) + (num % 10)) % 10

            if point == 1 then
                logic = " `w[ `^LEME : `b" .. point .. " `2X3!`w ]"
            elseif point == 0 then
                logic = " `w[ `^LEME : `b" .. point .. " `2X4!`w ]"
            elseif point == 9 then
                logic = " `w[ `^LEME : `b" .. point .. " `4AUTO LOSE`w ]"
            else
                logic = " `w[ `^LEME : `b" .. point .. "`w ]"
            end

        elseif Config.gameMode == "lewa" then
            point = num % 10

            if num == 0 then
                point = 1
            end

            if point == 0 then
                logic = " `w[ `^LEWA : `b" .. point .. " `2X7!`w ]"
            elseif point == 9 then
                logic = " `w[ `^LEWA : `b" .. point .. " `2X3!`w ]"
            elseif point == 1 or point == 2 or point == 3 then
                logic = " `w[ `^LEWA : `b" .. point .. " `4AUTO LOSE`w ]"
            else
                logic = " `w[ `^LEWA : `b" .. point .. "`w ]"
            end
        end

        if isFakeSpin then
            if target_uid ~= -1 then
                SendVariant({
                    v1 = "OnTalkBubble",
                    v2 = target_uid,
                    v3 = "`w[ `4FAKE`w ] `w" .. (spintext or console_msg) .. logic,
                    v4 = 0,
                    v5 = 0
                })
            end

            SendVariant({
                v1 = "OnConsoleMessage",
                v2 = "`w[ `4FAKE`w ] `w" .. console_msg .. logic
            })
        else
            if target_uid ~= -1 then
                SendVariant({
                    v1 = "OnTalkBubble",
                    v2 = target_uid,
                    v3 = "`w[ `^REAL`w ] `w" .. (spintext or console_msg) .. logic,
                    v4 = 0,
                    v5 = 0
                })
            end

            SendVariant({
                v1 = "OnConsoleMessage",
                v2 = "`w[ `^REAL`w ] `w" .. console_msg .. logic
            })
        end

        add_log(
            spin_logs,
            "`8[" .. timestamp .. "] `w" .. clean_text .. " `b» `w" .. logic
        )

        spintext = nil
        uidplayer = nil
        return true
    end

    LogToConsole("" .. systemlog .. " " .. console_msg)
    return true
end

    if autocrime then
local crimeItemNames = {
    [2292] = "Superpower - Heat Vision",
    [2294] = "Superpower - Incinerate",
    [2296] = "Superpower - Flame On!",
    [2298] = "Superpower - Liquify",
    [2300] = "Superpower - Overheat",
    [2308] = "Superpower - Ice Shards",
    [2310] = "Superpower - Frost Breath",
    [2312] = "Superpower - Ice Barrier",
    [2314] = "Superpower - Puddle",
    [2316] = "Superpower - Frozen Mirror",
    [2320] = "Superpower - Super Strength",
    [2322] = "Superpower - Super Speed",
    [2324] = "Superpower - Enrage",
    [2326] = "Superpower - Crush",
    [2328] = "Superpower - Regeneration",
    [2332] = "Superpower - Shocking Fist",
    [2334] = "Superpower - Thunderstorm",
    [2336] = "Superpower - Overcharge",
    [2338] = "Superpower - Megawatt Pulse"
}

local function logCrimeItem(itemID)
    local itemName = crimeItemNames[tonumber(itemID)] or "Unknown Item"
    ontext("`2[Crime] `wMenggunakan: `9" .. itemName)
end

if var.v1:find("OnDialogRequest") then
    if var.v2:find("Devil Ham``%'s `2Crush`` card `4melted") then
        liq = "yes"
    end

    if var.v2:find("Ms%. Terry") and var.v2:find("Ban Hammer") then
        ban = "yes"
    end

    if var.v2:find("|Battle%!|") then
        x = var.v2:match("tilex|(%d+)")
        y = var.v2:match("tiley|(%d+)")

        log("`0 Crime :" .. (var.v2:match("add_textbox|(.*)`` is") or "Unknown"))

        if var.v2:find("Crime in Progress") then
            c1 = 2298
            c2 = 2308
            c3 = 2320
            c4 = 2324
            c5 = 2332
        end

        if var.v2:find("Jimmy Snow") then
            use1, use2, use3 = c5, c4, c3

        elseif var.v2:find("Big Bertha") then
            use1, use2, use3 = c1, c4, c3

        elseif var.v2:find("Shockinator") then
            use1, use2, use3 = c4, c3, c1

        elseif var.v2:find("The Firebug") then
            use1, use2, use3 = c2, c1, c5

        elseif var.v2:find("Generic Thug") or var.v2:find("Kat 5") then
            use1, use2, use3 = c4, c3, c2

        elseif var.v2:find("Professor Pummel") then
            c1, c2, c3, c4, c5 = 2296, 2298, 2300, 2320, 2324
            use1, use2, use3 = c3, c2, c1

        elseif var.v2:find("Z%. Everett Koop") then
            c1, c2, c3, c4, c5 = 2296, 2298, 2300, 2320, 2324
            use1, use2, use3 = c3, c1, c2

        elseif var.v2:find("Dr%. Destructo") then
            c1, c2, c3, c4, c5 = 2298, 2308, 2310, 2314, 2316
            step = "0"
            use1, use2, use3 = c1, c3, c5

        elseif var.v2:find("Dragon Hand") or var.v2:find("Almighty Seth") then
            c1, c2, c3, c4, c5 = 2308, 2312, 2314, 2326, 2328
            use1, use2, use3 = c5, c4, 6969

        elseif var.v2:find("Devil Ham") then
            c1, c2, c3, c4, c5 = 2298, 2332, 2334, 2336, 2338
            use1, use2, use3, use4, use5 = c1, c4, c5, c3, c2
            liq = "no"
            step = "1"

        elseif var.v2:find("Ms%. Terry") then
            c1, c2, c3, c4, c5 = 2294, 2316, 2322, 2328, 2338
            use1, use2, use3, use4, use5 = c1, c2, c3, c4, c5
            ban = "no"
        end

        SendPacket(
            2,
            "action|dialog_return\ndialog_name|crime_edit\ntilex|" ..
                x .. "|\ntiley|" .. y ..
                "|\nstate|0||\nbuttonClicked|button_ok\n\nc" ..
                c1 .. "|1\nc" .. c2 .. "|1\nc" .. c3 ..
                "|1\nc" .. c4 .. "|1\nc" .. c5 .. "|1\n"
        )

    elseif var.v2:find("Fighting Crime") and var.v2:find("Devil Ham") then
        if liq == "no" then
            if var.v2:find("c" .. use1) then
                use = use1
            else
                use = "passturn"
            end

        elseif var.v2:find("c" .. use2) and step == "0" then
            step = "1"
            use = use2

        elseif var.v2:find("c" .. use3) then
            use = use3

        elseif var.v2:find("c" .. use4) then
            use = use4

        elseif var.v2:find("c" .. use5) then
            use = use5

        else
            use = "passturn"
        end

        if tonumber(use) then
            logCrimeItem(use)
        end

        SendPacket(
            2,
            "action|dialog_return\ndialog_name|crime_edit\ntilex|" ..
                x .. "|\ntiley|" .. y ..
                "|\nstate|1||\nbuttonClicked|c" .. use
        )

    elseif var.v2:find("Fighting Crime") and var.v2:find("Ms%. Terry") then
        if var.v2:find("is going to play `%d") then
            local enemyMove = var.v2:match("is going to play `(%d)")

            if enemyMove == "2" then
                use = use1
            elseif enemyMove == "4" then
                use = use2
            elseif enemyMove == "9" then
                use = use4
            elseif enemyMove == "1" then
                use = use5
            end

        elseif var.v2:find("c" .. use3) then
            use = use3
        elseif var.v2:find("c" .. use5) and ban == "yes" then
            use = use5
        elseif var.v2:find("c" .. use1) then
            use = use1
        elseif var.v2:find("c" .. use4) then
            use = use4
        elseif var.v2:find("c" .. use5) then
            use = use5
        elseif var.v2:find("c" .. use2) then
            use = use2
        else
            use = "passturn"
        end

        use = use or "passturn"

        if tonumber(use) then
            logCrimeItem(use)
        end

        SendPacket(
            2,
            "action|dialog_return\ndialog_name|crime_edit\ntilex|" ..
                x .. "|\ntiley|" .. y ..
                "|\nstate|1||\nbuttonClicked|c" .. use
        )

    elseif var.v2:find("Fighting Crime") and var.v2:find("Dr%. Destructo") then
        if var.v2:find("c" .. use1) and step == "0" then
            use = use1
            step = "1"
        elseif var.v2:find("c" .. use2) then
            use = use2
        elseif var.v2:find("c" .. use3) then
            use = use3
        else
            use = "passturn"
        end

        if tonumber(use) then
            logCrimeItem(use)
        end

        SendPacket(
            2,
            "action|dialog_return\ndialog_name|crime_edit\ntilex|" ..
                x .. "|\ntiley|" .. y ..
                "|\nstate|1||\nbuttonClicked|c" .. use
        )

    elseif var.v2:find("Fighting Crime") then
        if var.v2:find("c" .. use1) then
            use = use1
        elseif var.v2:find("c" .. use2) then
            use = use2
        elseif var.v2:find("c" .. use3) then
            use = use3
        else
            use = "passturn"
        end

        if tonumber(use) then
            logCrimeItem(use)
        end

        SendPacket(
            2,
            "action|dialog_return\ndialog_name|crime_edit\ntilex|" ..
                x .. "|\ntiley|" .. y ..
                "|\nstate|1||\nbuttonClicked|c" .. use
        )
    end

    return true
end
    end


    if relogPending and (var.v1 == "OnConsoleMessage" or var.v1 == "OnSpawn") then
        local world = (type(GetWorldName) == "function" and GetWorldName()) or ""

        if not world or world == "" or world == "EXIT" then
            if type(relogWorld) == "string" and relogWorld ~= "" then
                SendPacket(3, "action|join_request\nname|" .. relogWorld .. "\ninvitedWorld|0")
            end
            relogPending = false
        end
    end

    return false
end

function raw(a)

if type(a) ~= "table" then
    return false
end

if a.type == 11 then
local objects = (type(GetObjectList) == "function" and GetObjectList()) or (type(getObjectList) == "function" and getObjectList()) or {}
for _, obj in pairs(objects) do
if obj.id == a.value then
if obj.itemid == 112 then
cg = cg + (tonumber(obj.amount) or 0)
end
break
end
end
end
if a.type == 3 then
cg = 0
end

if visual_gems_mode then
    if type(a) == "table" then
        if a.type == 0 then
            local tx = a.px or (a.x and math.floor(a.x / 32))
            local ty = a.py or (a.y and math.floor(a.y / 32))

            if tx and ty then
                triggerParticleAt1(tx, ty, 80)
            end
        end
    end
    end

if takerighton == true then
if a.type == 3 and a.value == 18 then
takerightx = a.px
takerighty = a.py
greenbox(takerightx, takerighty)
takerighton = false
btk()
log("`9Pos Take Right: `2DONE")
ontalk("`9Pos Take Right: `2DONE")
end end
if takelefton == true then
if a.type == 3 and a.value == 18 then
takeleftx = a.px
takelefty = a.py
greenbox(takeleftx, takelefty)
takelefton = false
btk()
log("`9Pos Take Left: `2DONE")
ontalk("`9Pos Take Left: `2DONE")
end end

if player1loc == true then
if a.type == 3 and a.value == 18 then
player1x = a.px
player1y = a.py
greenbox(player1x, player1y)
player1loc = false
btk()
log("`9Pos Player 1: `2DONE")
ontalk("`9Pos Player 1: `2DONE")
end end
if player2loc == true then
if a.type == 3 and a.value == 18 then
player2x = a.px
player2y = a.py
greenbox(player2x, player2y)
player2loc = false
btk()
log("`9Pos Player 2: `2DONE")
ontalk("`9Pos Player 2: `2DONE")
end end
if player3loc == true then
if a.type == 3 and a.value == 18 then
player3x = a.px
player3y = a.py
greenbox(player3x, player3y)
player3loc = false
btk()
log("`9Pos Player 3: `2DONE")
ontalk("`9Pos Player 3: `2DONE")
end end
if player4loc == true then
if a.type == 3 and a.value == 18 then
player4x = a.px
player4y = a.py
greenbox(player4x, player4y)
player4loc = false
btk()
log("`9Pos Player 4: `2DONE")
ontalk("`9Pos Player 4: `2DONE")
end end

if gemsright1 == true then
if a.type == 3 and a.value == 18 then
gemsrightx1 = a.px
gemsrighty1 = a.py
greenbox(gemsrightx1, gemsrighty1)
gemsright1 = false
tile = {
pos1 = {
{x = gemsrightx1, y = gemsrighty1}, {x = gemsrightx2, y = gemsrighty2}, {x = gemsrightx3, y = gemsrighty3}
},
pos2 = {
{x = gemsleftx1, y = gemslefty1}, {x = gemsleftx2, y = gemslefty2}, {x = gemsleftx3, y = gemslefty3}
}
}
btk()
log("`9Pos Gems Right 1: `2DONE")
ontalk("`9Pos Gems Right 1: `2DONE")
end end
if gemsright2 == true then
if a.type == 3 and a.value == 18 then
gemsrightx2 = a.px
gemsrighty2 = a.py
greenbox(gemsrightx2, gemsrighty2)
gemsright2 = false
tile = {
pos1 = {
{x = gemsrightx1, y = gemsrighty1}, {x = gemsrightx2, y = gemsrighty2}, {x = gemsrightx3, y = gemsrighty3}
},
pos2 = {
{x = gemsleftx1, y = gemslefty1}, {x = gemsleftx2, y = gemslefty2}, {x = gemsleftx3, y = gemslefty3}
}
}
btk()
log("`9Pos Gems Right 2: `2DONE")
ontalk("`9Pos Gems Right 2: `2DONE")
end end
if gemsright3 == true then
if a.type == 3 and a.value == 18 then
gemsrightx3 = a.px
gemsrighty3 = a.py
greenbox(gemsrightx3, gemsrighty3)
gemsright3 = false
tile = {
pos1 = {
{x = gemsrightx1, y = gemsrighty1}, {x = gemsrightx2, y = gemsrighty2}, {x = gemsrightx3, y = gemsrighty3}
},
pos2 = {
{x = gemsleftx1, y = gemslefty1}, {x = gemsleftx2, y = gemslefty2}, {x = gemsleftx3, y = gemslefty3}
}
}
btk()
log("`9Pos Gems Right 3: `2DONE")
ontalk("`9Pos Gems Right 3: `2DONE")
end end
if gemsright4 == true then
if a.type == 3 and a.value == 18 then
gemsrightx4 = a.px
gemsrighty4 = a.py
greenbox(gemsrightx4, gemsrighty4)
gemsright4 = false
tile = {
pos1 = {
{x = gemsrightx1, y = gemsrighty1}, {x = gemsrightx2, y = gemsrighty2}, {x = gemsrightx3, y = gemsrighty3}, {x = gemsrightx4, y = gemsrighty4}, {x = gemsrightx5, y = gemsrighty5}
},
pos2 = {
{x = gemsleftx1, y = gemslefty1}, {x = gemsleftx2, y = gemslefty2}, {x = gemsleftx3, y = gemslefty3}, {x = gemsleftx4, y = gemslefty4}, {x = gemsleftx5, y = gemslefty5}
}
}
btk()
log("`9Pos Gems Right 4: `2DONE")
ontalk("`9Pos Gems Right 4: `2DONE")
end end
if gemsright5 == true then
if a.type == 3 and a.value == 18 then
gemsrightx5 = a.px
gemsrighty5 = a.py
greenbox(gemsrightx5, gemsrighty5)
gemsright5 = false
tile = {
pos1 = {
{x = gemsrightx1, y = gemsrighty1}, {x = gemsrightx2, y = gemsrighty2}, {x = gemsrightx3, y = gemsrighty3}, {x = gemsrightx4, y = gemsrighty4}, {x = gemsrightx5, y = gemsrighty5}
},
pos2 = {
{x = gemsleftx1, y = gemslefty1}, {x = gemsleftx2, y = gemslefty2}, {x = gemsleftx3, y = gemslefty3}, {x = gemsleftx4, y = gemslefty4}, {x = gemsleftx5, y = gemslefty5}
}
}
btk()
log("`9Pos Gems Right 5: `2DONE")
ontalk("`9Pos Gems Right 5: `2DONE")
end end
if gemsright6 == true then
if a.type == 3 and a.value == 18 then
gemsrightx6 = a.px
gemsrighty6 = a.py
greenbox(gemsrightx6, gemsrighty6)
gemsright6 = false
tile = {
pos1 = {
{x = gemsrightx1, y = gemsrighty1}, {x = gemsrightx2, y = gemsrighty2}, {x = gemsrightx3, y = gemsrighty3}, {x = gemsrightx4, y = gemsrighty4}, {x = gemsrightx5, y = gemsrighty5}, {x = gemsrightx6, y = gemsrighty6}, {x = gemsrightx7, y = gemsrighty7}, {x = gemsrightx8, y = gemsrighty8}
},
pos2 = {
{x = gemsleftx1, y = gemslefty1}, {x = gemsleftx2, y = gemslefty2}, {x = gemsleftx3, y = gemslefty3}, {x = gemsleftx4, y = gemslefty4}, {x = gemsleftx5, y = gemslefty5}, {x = gemsleftx6, y = gemslefty6}, {x = gemsleftx7, y = gemslefty7}, {x = gemsleftx8, y = gemslefty8}
}
}
btk()
log("`9Pos Gems Right 6: `2DONE")
ontalk("`9Pos Gems Right 6: `2DONE")
end end
if gemsright7 == true then
if a.type == 3 and a.value == 18 then
gemsrightx7 = a.px
gemsrighty7 = a.py
greenbox(gemsrightx7, gemsrighty7)
gemsright7 = false
tile = {
pos1 = {
{x = gemsrightx1, y = gemsrighty1}, {x = gemsrightx2, y = gemsrighty2}, {x = gemsrightx3, y = gemsrighty3}, {x = gemsrightx4, y = gemsrighty4}, {x = gemsrightx5, y = gemsrighty5}, {x = gemsrightx6, y = gemsrighty6}, {x = gemsrightx7, y = gemsrighty7}, {x = gemsrightx8, y = gemsrighty8}
},
pos2 = {
{x = gemsleftx1, y = gemslefty1}, {x = gemsleftx2, y = gemslefty2}, {x = gemsleftx3, y = gemslefty3}, {x = gemsleftx4, y = gemslefty4}, {x = gemsleftx5, y = gemslefty5}, {x = gemsleftx6, y = gemslefty6}, {x = gemsleftx7, y = gemslefty7}, {x = gemsleftx8, y = gemslefty8}
}
}
btk()
log("`9Pos Gems Right 7: `2DONE")
ontalk("`9Pos Gems Right 7: `2DONE")
end end
if gemsright8 == true then
if a.type == 3 and a.value == 18 then
gemsrightx8 = a.px
gemsrighty8 = a.py
greenbox(gemsrightx8, gemsrighty8)
gemsright8 = false
tile = {
pos1 = {
{x = gemsrightx1, y = gemsrighty1}, {x = gemsrightx2, y = gemsrighty2}, {x = gemsrightx3, y = gemsrighty3}, {x = gemsrightx4, y = gemsrighty4}, {x = gemsrightx5, y = gemsrighty5}, {x = gemsrightx6, y = gemsrighty6}, {x = gemsrightx7, y = gemsrighty7}, {x = gemsrightx8, y = gemsrighty8}
},
pos2 = {
{x = gemsleftx1, y = gemslefty1}, {x = gemsleftx2, y = gemslefty2}, {x = gemsleftx3, y = gemslefty3}, {x = gemsleftx4, y = gemslefty4}, {x = gemsleftx5, y = gemslefty5}, {x = gemsleftx6, y = gemslefty6}, {x = gemsleftx7, y = gemslefty7}, {x = gemsleftx8, y = gemslefty8}
}
}
btk()
log("`9Pos Gems Right 8: `2DONE")
ontalk("`9Pos Gems Right 8: `2DONE")
end end
if gemsleft1 == true then
if a.type == 3 and a.value == 18 then
gemsleftx1 = a.px
gemslefty1 = a.py
greenbox(gemsleftx1, gemslefty1)
gemsleft1 = false
tile = {
pos1 = {
{x = gemsrightx1, y = gemsrighty1}, {x = gemsrightx2, y = gemsrighty2}, {x = gemsrightx3, y = gemsrighty3}, {x = gemsrightx4, y = gemsrighty4}, {x = gemsrightx5, y = gemsrighty5}
},
pos2 = {
{x = gemsleftx1, y = gemslefty1}, {x = gemsleftx2, y = gemslefty2}, {x = gemsleftx3, y = gemslefty3}, {x = gemsleftx4, y = gemslefty4}, {x = gemsleftx5, y = gemslefty5}
}
}
btk()
log("`9Pos Gems Left 1: `2DONE")
ontalk("`9Pos Gems Left 1: `2DONE")
end end
if gemsleft2 == true then
if a.type == 3 and a.value == 18 then
gemsleftx2 = a.px
gemslefty2 = a.py
greenbox(gemsleftx2, gemslefty2)
gemsleft2 = false
tile = {
pos1 = {
{x = gemsrightx1, y = gemsrighty1}, {x = gemsrightx2, y = gemsrighty2}, {x = gemsrightx3, y = gemsrighty3}, {x = gemsrightx4, y = gemsrighty4}, {x = gemsrightx5, y = gemsrighty5}
},
pos2 = {
{x = gemsleftx1, y = gemslefty1}, {x = gemsleftx2, y = gemslefty2}, {x = gemsleftx3, y = gemslefty3}, {x = gemsleftx4, y = gemslefty4}, {x = gemsleftx5, y = gemslefty5}
}
}
btk()
log("`9Pos Gems Left 2: `2DONE")
ontalk("`9Pos Gems Left 2: `2DONE")
end end
if gemsleft3 == true then
if a.type == 3 and a.value == 18 then
gemsleftx3 = a.px
gemslefty3 = a.py
greenbox(gemsleftx3, gemslefty3)
gemsleft3 = false
tile = {
pos1 = {
{x = gemsrightx1, y = gemsrighty1}, {x = gemsrightx2, y = gemsrighty2}, {x = gemsrightx3, y = gemsrighty3}, {x = gemsrightx4, y = gemsrighty4}, {x = gemsrightx5, y = gemsrighty5}
},
pos2 = {
{x = gemsleftx1, y = gemslefty1}, {x = gemsleftx2, y = gemslefty2}, {x = gemsleftx3, y = gemslefty3}, {x = gemsleftx4, y = gemslefty4}, {x = gemsleftx5, y = gemslefty5}
}
}
btk()
log("`9Pos Gems Left 3: `2DONE")
ontalk("`9Pos Gems Left 3: `2DONE")
end end
if gemsleft4 == true then
if a.type == 3 and a.value == 18 then
gemsleftx4 = a.px
gemslefty4 = a.py
greenbox(gemsleftx4, gemslefty4)
gemsleft4 = false
tile = {
pos1 = {
{x = gemsrightx1, y = gemsrighty1}, {x = gemsrightx2, y = gemsrighty2}, {x = gemsrightx3, y = gemsrighty3}, {x = gemsrightx4, y = gemsrighty4}, {x = gemsrightx5, y = gemsrighty5}
},
pos2 = {
{x = gemsleftx1, y = gemslefty1}, {x = gemsleftx2, y = gemslefty2}, {x = gemsleftx3, y = gemslefty3}, {x = gemsleftx4, y = gemslefty4}, {x = gemsleftx5, y = gemslefty5}
}
}
btk()
log("`9Pos Gems Left 4: `2DONE")
ontalk("`9Pos Gems Left 4: `2DONE")
end end
if gemsleft5 == true then
if a.type == 3 and a.value == 18 then
gemsleftx5 = a.px
gemslefty5 = a.py
greenbox(gemsleftx5, gemslefty5)
gemsleft5 = false
tile = {
pos1 = {
{x = gemsrightx1, y = gemsrighty1}, {x = gemsrightx2, y = gemsrighty2}, {x = gemsrightx3, y = gemsrighty3}, {x = gemsrightx4, y = gemsrighty4}, {x = gemsrightx5, y = gemsrighty5}
},
pos2 = {
{x = gemsleftx1, y = gemslefty1}, {x = gemsleftx2, y = gemslefty2}, {x = gemsleftx3, y = gemslefty3}, {x = gemsleftx4, y = gemslefty4}, {x = gemsleftx5, y = gemslefty5}
}
}
btk()
log("`9Pos Gems Left 5: `2DONE")
ontalk("`9Pos Gems Left 5: `2DONE")
end end
if gemsleft6 == true then
if a.type == 3 and a.value == 18 then
gemsleftx6 = a.px
gemslefty6 = a.py
greenbox(gemsleftx6, gemslefty6)
gemsleft6 = false
tile = {
pos1 = {
{x = gemsrightx1, y = gemsrighty1}, {x = gemsrightx2, y = gemsrighty2}, {x = gemsrightx3, y = gemsrighty3}, {x = gemsrightx4, y = gemsrighty4}, {x = gemsrightx5, y = gemsrighty5}, {x = gemsrightx6, y = gemsrighty6}, {x = gemsrightx7, y = gemsrighty7}, {x = gemsrightx8, y = gemsrighty8}
},
pos2 = {
{x = gemsleftx1, y = gemslefty1}, {x = gemsleftx2, y = gemslefty2}, {x = gemsleftx3, y = gemslefty3}, {x = gemsleftx4, y = gemslefty4}, {x = gemsleftx5, y = gemslefty5}, {x = gemsleftx6, y = gemslefty6}, {x = gemsleftx7, y = gemslefty7}, {x = gemsleftx8, y = gemslefty8}
}
}
btk()
log("`9Pos Gems Left 6: `2DONE")
ontalk("`9Pos Gems Left 6: `2DONE")
end end
if gemsleft7 == true then
if a.type == 3 and a.value == 18 then
gemsleftx7 = a.px
gemslefty7 = a.py
greenbox(gemsleftx7, gemslefty7)
gemsleft7 = false
tile = {
pos1 = {
{x = gemsrightx1, y = gemsrighty1}, {x = gemsrightx2, y = gemsrighty2}, {x = gemsrightx3, y = gemsrighty3}, {x = gemsrightx4, y = gemsrighty4}, {x = gemsrightx5, y = gemsrighty5}, {x = gemsrightx6, y = gemsrighty6}, {x = gemsrightx7, y = gemsrighty7}, {x = gemsrightx8, y = gemsrighty8}
},
pos2 = {
{x = gemsleftx1, y = gemslefty1}, {x = gemsleftx2, y = gemslefty2}, {x = gemsleftx3, y = gemslefty3}, {x = gemsleftx4, y = gemslefty4}, {x = gemsleftx5, y = gemslefty5}, {x = gemsleftx6, y = gemslefty6}, {x = gemsleftx7, y = gemslefty7}, {x = gemsleftx8, y = gemslefty8}
}
}
btk()
log("`9Pos Gems Left 7: `2DONE")
ontalk("`9Pos Gems Left 7: `2DONE")
end end
if gemsleft8 == true then
if a.type == 3 and a.value == 18 then
gemsleftx8 = a.px
gemslefty8 = a.py
greenbox(gemsleftx8, gemslefty8)
gemsleft8 = false
tile = {
pos1 = {
{x = gemsrightx1, y = gemsrighty1}, {x = gemsrightx2, y = gemsrighty2}, {x = gemsrightx3, y = gemsrighty3}, {x = gemsrightx4, y = gemsrighty4}, {x = gemsrightx5, y = gemsrighty5}, {x = gemsrightx6, y = gemsrighty6}, {x = gemsrightx7, y = gemsrighty7}, {x = gemsrightx8, y = gemsrighty8}
},
pos2 = {
{x = gemsleftx1, y = gemslefty1}, {x = gemsleftx2, y = gemslefty2}, {x = gemsleftx3, y = gemslefty3}, {x = gemsleftx4, y = gemslefty4}, {x = gemsleftx5, y = gemslefty5}, {x = gemsleftx6, y = gemslefty6}, {x = gemsleftx7, y = gemslefty7}, {x = gemsleftx8, y = gemslefty8}
}
}
btk()
log("`9Pos Gems Left 8: `2DONE")
ontalk("`9Pos Gems Left 8: `2DONE")
end end
if backpos == true then
if a.type == 3 and a.value == 18 then
backposx = a.px
backposy = a.py
greenbox(backposx, backposy)
backpos = false
btk()
log("`9Back Position `2DONE")
ontalk("`9Back Position `2DONE")
end end

if checktile then
if a.type == 3 then
ontext("`#X : `3"..a.px.." `6Y : `9"..a.py)
log("`#X : `3"..a.px.." `6Y : `9"..a.py)
end
end

return false
end

function OnGamePacket(game)
if visual_gems_mode then
    if type(game) == "table" then
        if game.type == 14 and game.value == 112 then
            local tx = math.floor((game.x or 0) / 32)
            local ty = math.floor((game.y or 0) / 32)
            triggerParticleAt(tx, ty, 150)
        end
    end
    end
    return false
    end

function OnValue(type, name, value)
if name == "checkcollectedgems" then
SendPacket(2,"action|input\n|text|Collected `#+"..cg.." `7Gems")
log("`9Gems `7Lu `#"..cg.."`7 y")
cg = 0
return false
end

if name == "btkbutton" then
btk()
kou()
end

if name == "takebet" then
take()
end

if name == "droptax" then
droptax()
end

if name == "win1" then
execute_payout(1)
return true
end

if name == "win2" then
execute_payout(2)
return true
end
if name == "win3" then
execute_payout(3)
return true
end
if name == "win4" then
execute_payout(4)
return true
end

if name == "droppayout" then
execute_payout(5)
return true
end

if name == "takegems" then
takegems()
ontext("Gems has been taked")
end

if name == "takingblock" then
takeblock()
log("Block has been Taked")
ontext("Block has been taked")
end

if name == "checkgemss" then
checkgems()
ontext("Gems checking is launching")
end

if name == "game_mode" then
if value == 0 then
Config.gameMode = "number_only"
spin_mode = "NUMBERONLY"
    elseif value == 1 then
        Config.gameMode = "number"
        spin_mode = "FAST WHEEL"
    elseif value == 2 then
        Config.gameMode = "reme"
        spin_mode = "REME"
    elseif value == 3 then
        Config.gameMode = "leme"
        spin_mode = "LEME"
    elseif value == 4 then
        Config.gameMode = "lewa"
        spin_mode = "LEWA"
    end

    pref:set("game_mode", value)
    pref:save()
    log("Game Mode: " .. tostring(spin_mode))
end

        if name == "save_world" then
        saveworldsaved = tostring(value)
pref:set("save_world", saveworldsaved)
pref:save()
    end

    if name == "wptosave" then
growtopia.warpTo(""..saveworldsaved.."")
    end

    if name == "Growz V2" then
    growz_enabled = value
        pref:set("growz_enabled", growz_enabled)
        pref:save()
    end
        if name == "speed_growz" then
        speed_growz = value
        pref:set("speed_growz", value)
        pref:save()
    end

    if name == "cheat_antilag" then
    antilag = value

    pref:set("antilag", value)
        pref:save()
        end

            if name == "Fast Take" then
    fasttake = value

    pref:set("fasttake", value)
        pref:save()
        end

        if name == "config_cheat_noparticle" then
        noparticle = value
        pref:set("noparticle", value)
        pref:save()
        end

        if name == "cheat_config_fastdrop_active" then
        fastdrop = value
        pref:set("fastdrop", value)
        pref:save()
        end

    if name == "selected_item" then
        local selectedItemID = findItemID(value)

        if selectedItemID then
            log("`2[ID FINDER] Item ditemukan")
            log("`wName: `9" .. tostring(value))
            log("`wID: `9" .. tostring(selectedItemID))

            ontext("ID: " .. tostring(selectedItemID))
            ontalk("`2Item ditemukan")
            ontalk("`wName: `9" .. tostring(value))
            ontalk("`wID: `9" .. tostring(selectedItemID))

            if growtopia.checkInventory(selectedItemID) then
                log("`2Status: Item ada di inventory")
            else
                log("`4Status: Item tidak ada di inventory")
            end
        else
            log("`4[ID FINDER] ID item tidak ditemukan")
            log("`wName: `9" .. tostring(value))

            ontext("ID item tidak ditemukan")
            ontalk("`4ID item tidak ditemukan")
        end

        return true
    end

        if name == "scan_gems1x" then
        ScanGemsParticle()
end

    if name == "scan_gems_repeat" then
        -- Samakan toggle UI dengan fungsi Gems Repeat pada dialog.
        local enabled = value == true or value == 1 or value == "true"
        gemsrepeat = enabled

        ontext("`2Gems Repeat : " .. (gemsrepeat and "`2ON" or "`4OFF"))

        if gemsrepeat then
            runThread(function()
                repeatgems()
            end)
        end

        return true
    end
    
if name == "scan_gems" then
        local enabled = value == true
            or value == 1
            or value == "1"
            or value == "true"

        visual_gems_mode = enabled

        if visual_gems_mode then
            runThread(function()
                if visual_gems_mode then
                    ScanGemsParticle()
                end
            end)
        end

        ontext("`9Visual Gems Mode : " ..
            (visual_gems_mode and "`2ON" or "`4OFF"))

        return true
    end

    if name == "show_gems_collected" then
        local enabled = value == true
            or value == 1
            or value == "1"
            or value == "true"

        show_gems_collected = enabled

        ontext("`9Show Gems Collected : " ..
            (show_gems_collected and "`2ON" or "`4OFF"))

        return true
    end

return false
end

-- Pasang kembali angka spin setelah masuk/pindah world.
-- Cache tidak dihapus saat keluar world; nama akan diperbarui saat player list tersedia.
runThread(function()
    local lastWorld = ""
    while true do
        Sleep(1000)
        local worldName = ""
        if type(GetWorldName) == "function" then
            local ok, result = pcall(GetWorldName)
            if ok and type(result) == "string" then worldName = result end
        elseif type(getWorld) == "function" then
            local ok, result = pcall(getWorld)
            if ok and type(result) == "table" then worldName = tostring(result.name or "") end
        end

        if worldName ~= "" and worldName ~= "EXIT" then
            if type(getPlayerList) == "function" then
                local ok, players = pcall(getPlayerList)
                if ok and type(players) == "table" then
                    for _, player in pairs(players) do
                        local netid = tonumber(player.netid or player.netID)
                        local rawPlayerName = tostring(player.name or "")
                        local baseName = getCleanName(rawPlayerName)
                        local saved = spinNumbersByName[normalizeSpinName(baseName)]
                        if netid and saved and saved.number then
                            local desiredName = (saved.baseName or baseName) .. " `7[" .. (saved.color or "`b") .. saved.number .. "`7]"
                            local hasSavedNumber = rawPlayerName:match("%[.*" .. tostring(saved.number) .. "`7%]%s*$") ~= nil
                            if not hasSavedNumber then
                                pcall(function()
                                    SendVariant({
                                        v1 = "OnNameChanged",
                                        v2 = desiredName,
                                        netID = netid
                                    }, netid)
                                end)
                            end
                        end
                    end
                end
            end
        end
        lastWorld = worldName
    end
end)

local hookApi = addHook or AddHook
if type(hookApi) == "function" then
    hookApi(hook, "onSendPacket")
    hookApi(var, "onVariant")
    hookApi(raw, "onSendPacketRaw")
    hookApi(OnValue, "onValue")
    hookApi(OnGamePacket, "onGamePacket")

    local applyApi = applyHook or ApplyHook
    if type(applyApi) == "function" then
        applyApi()
    end
else
    log("`4[Kou Project] Hook API addHook tidak tersedia.")
end

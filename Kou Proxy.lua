


var = {} 
var.v1 = "OnAddNotification"
var.v2 = "interface/large/kouproxy.rttex"
var.v3 = "`4KOU PROJECT"
var.v4 = "audio/gauntlet_spawn.wav"
SendVariant(var)

modmeno = [[

{"sub_name" : "MOD MENU",
"icon" : "Wrench",
"description" : "Mod Menu from PowerKuy",
"menu" : [
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
     "text": "FindPath",
     "description": "Teleport to target block, use the findpath item and click target tile. You will be automatically teleported.",
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
     "description": "Give more speed to your player",
     "type": "toggle",
     "default": false,
     "expandable": true,
     "list_child": [
         {
            "text": "Speed Growz",
            "type": "slider",
            "min": 0,
            "max": 8,
            "use_dot": true,
            "step":  7,
            "default": 3,
            "alias": "speed_growz"
}
]
},
{
     "type": "toggle",
     "text": "Antilag",
     "default": false,
     "alias": "cheat_antilag",
     "description": "Skip render background",
     "autosave": true
},
{
     "type": "toggle",
     "text": "No Particle",
     "default": true,
     "alias": "config_cheat_noparticle",
     "description": "Skip all render particles",
     "autosave": true
},
{
     "type": "toggle",
     "text": "Fast Drop",
     "alias": "cheat_config_fastdrop_active",
     "default": false
}




]
}

]]

csnmeno = [[

{"sub_name" : "CSN MENU",
"icon" : "Wrench",
"description" : "CSN PROXY",
"menu" : [
{
     "text": "Show collected gems",
     "description": "Show collected gems on talk bubble",
     "type": "toggle",
     "default": false,
     "alias": "collectgemss"
},
{
     "type": "toggle",
     "text": "Fast Wheel",
     "default": false,
     "alias": "cheat_config_fastwheel"
},
{
    "text": "BTK",
    "type": "button",
    "alias": "btkbutton"
},
{
    "text": "Take Bet",
    "type": "button",
    "alias": "takebet"
},
{
    "text": "Take Gems",
    "type": "button",
    "alias": "takegems"
},
{
    "text": "Check Gems",
    "type": "button",
    "alias": "checkgemss"
},
{
     "text": "Show collected gems",
     "type": "button",
     "default": false,
     "alias": "checkcollectedgems"
},
{
    "text": "REME MODE",
    "type": "toggle",
    "alias": "rememode"
},
{
    "text": "QQ MODE",
    "type": "toggle",
    "alias": "qqmode"
},
{
    "text": "LEME MODE",
    "type": "toggle",
    "alias": "lememode"
}


]
}

]]



addCategory("MOD MENU", "Wrench")
addIntoModule(modmeno, "MOD MENU")
addCategory("CSN MENU", "Wrench")
addIntoModule(csnmeno, "CSN MENU")
sendNotification("KOU PROXY")






-- Logging limits and database
world_logs = {}
spin_logs = {}
max_logs_limit = 30

spin_mode = "REME" 

GTPS = true
systemlog = "`7[ `4Kou Proxy `7]`o "
date = os.date("%d, %b, %Y")
tanggal = os.date("%d")
bulan = os.date("%B")
tahun = os.date("%Y")
hari = os.date("%A")
historywl = "`7[`b" .. os.date("%X") .. "`7]`w You've Collected `60 WL"
historywls = "`7[`b" .. os.date("%X") .. "`7]`w You've Dropped `60 WL"
historydl = "`7[`b" .. os.date("%X") .. "`7]`w You've Collected `10 DL"
historydls = "`7[`b" .. os.date("%X") .. "`7]`w You've Dropped `10 DL"
historybgl = "`7[`b" .. os.date("%X") .. "`7]`w You've Collected `c0 BGL"
historybgls = "`7[`b" .. os.date("%X") .. "`7]`w You've Dropped `c0 BGL"
modfly = 0 
tele = 0
conte = 0
checkwl = growtopia.checkInventory(242)
checkdl = growtopia.checkInventory(1796)
checkbgl = growtopia.checkInventory(7188)
fcbgls = false
collectedgems = false
nick = GetLocal().name
cg = 0
local player1x
local player1y
local player2x
local player2y
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
data ={}
taxset = "5"
weatherid = "0"
auto_accept_mode = false
auto_accept_hide_ticks = 0

Config = {
	gameMode = "reme",
	autoConvert = false,
    autoConvertStep = 1,
    autoConvertX = 57,
    autoConvertY = 41
	}

function notify(msg)
    if growtopia and growtopia.notify then
        growtopia.notify(msg)
    end
    log(msg)
end


-- Append logs
function add_log(table_ref, msg)
    local clean_msg = msg:gsub("\n", " ")
    table.insert(table_ref, 1, clean_msg)
    if #table_ref > max_logs_limit then
        table.remove(table_ref)
    end
end

-- Strip name tags
function clean_tags(name)
    if not name then return "" end
    local s = name
    s = s:gsub("`4%[%d+%]%s*", "")
    s = s:gsub("`7%[`eSpin: `b%d+`7%]%s*", "")
    s = s:gsub("`7%[`b%d+`7%]%s*", "")
    s = s:match("^%s*(.-)%s*$") or s
    return s
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
s = {}
s.v1 = "OnTalkBubble"
s.v2 = GetLocal().netID
s.v3 = str
SendVariant(s)
end 

function ontext(str)
o = {}
o.v1 = "OnTextOverlay"
o.v2 = str
SendVariant(o)
end

function notify(str)
growtopia.notify(str)
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
if (item.id == id) then
return item.amount
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

function toggleAutoConvert()
    Config.autoConvert = not Config.autoConvert
    if Config.autoConvert then
        Config.autoConvertStep = 1
        log("Auto Convert: ON")
        notify("Auto Convert ON")
    else
        log("Auto Convert: OFF")
        notify("Auto Convert OFF")
    end
end

function handleAutoConvert(var)
    if not Config.autoConvert then return false end
    if var.v1 == "OnDialogRequest" then
        if type(var.v2) == "string" and var.v2:find("Telephone") then
            Config.autoConvertX = var.v2:match("tilex|(%d+)") or Config.autoConvertX
            Config.autoConvertY = var.v2:match("tiley|(%d+)") or Config.autoConvertY
            
            if Config.autoConvertStep == 1 then
                SendPacket(2, "action|dialog_return\ndialog_name|phonecall\ntilex|" .. Config.autoConvertX .. "\ntiley|" .. Config.autoConvertY .. "\nnum|53785\nbuttonClicked|chc5")
                log("Convert Pos: " .. Config.autoConvertX .. "," .. Config.autoConvertY)
                Config.autoConvertStep = 2
            else
                SendPacket(2, "action|dialog_return\ndialog_name|phonecall\ntilex|" .. Config.autoConvertX .. "\ntiley|" .. Config.autoConvertY .. "\nnum|-34\nbuttonClicked|chc0")
                log("Convert Step 2")
                Config.autoConvertStep = 3
            end
            return true
        end
        if type(var.v2) == "string" and var.v2:find("Wow, that's fast delivery.") then
            log("Conversion complete!")
            Config.autoConvertStep = 1
            return true
        end
    end
    return false
end

function calcReme(num)
    local n = tonumber(num)
    if not n then return 0 end
    local a = math.floor(n / 10)
    local b = n % 10
    local r = a + b
    if r > 10 then r = r % 10 elseif r == 10 then r = 0 end
    return r
end

function calcLastDigit(num)
    local n = tonumber(num)
    if not n then return 0 end
    return n % 10
end

function dropItem(itemID, count)
    SendPacket(2, "action|drop\n|itemID|" .. itemID)
    SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. itemID .. "\ncount|" .. count)
end
function dropgtps(id, count)
SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|"..id.."|\nitem_count|"..count)
end

-- Batch drop bypass
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

function dropWL(amount)
    if checkitm(242) < amount then
        log("Not enough WL! Have: " .. checkitm(242))
        return
    end
    dropItem(242, amount)
    log("Dropped " .. amount .. " WL")
    notify("Dropped " .. amount .. " WL")
end

function dropDL(amount)
    if checkitm(1796) < amount then
        log("Not enough DL! Have: " .. checkitm(1796))
        return
    end
    dropItem(1796, amount)
    log("Dropped " .. amount .. " DL")
    notify("Dropped " .. amount .. " DL")
end

function dropBGL(amount)
    if checkitm(7188) < amount then
        log("Not enough BGL! Have: " .. checkitm(7188))
        return
    end
    dropItem(7188, amount)
    log("Dropped " .. amount .. " BGL")
    notify("Dropped " .. amount .. " BGL")
end

function cdl()
pkt = {}
pkt.value = 242
pkt.type = 10
SendPacketRaw(false, pkt)
end
function cwl()
pkt = {}
pkt.value = 1796
pkt.type = 10
SendPacketRaw(false, pkt)
end
function cbgl()
pkt = {}
 pkt.value = 7188
pkt.type = 10
SendPacketRaw(false, pkt)
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

function Data()
Amount = 0
for _, list in pairs(data) do
Name = ""
if list.id == 11550 then
Name = "`bBlack Gem Lock"
Amount = Amount + list.count * 1000000
elseif list.id == 7188 then
Name = "`eBlue Gem Lock"
Amount = Amount + list.count * 10000
elseif list.id == 1796 then
Name = "`1Diamond Lock"
Amount = Amount + list.count * 100
elseif list.id == 242 then
Name = "`9World Lock"
Amount = Amount + list.count
end end
data = {}
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
for _, obj in pairs(GetObjectList()) do
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
for _, obj in pairs(GetObjectList()) do
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

function checkgems()
tile = (tile);
Count = 0;
data = {};
do
for _, obj in pairs(GetObjectList()) do
for _, tiles in pairs(tile.pos1) do
if obj.itemid == 112 and (obj.posX)//32 == tiles.x and (obj.posY)//32 == tiles.y then
Count = Count + obj.amount;
end end end
table.insert(data, Count)
Count = 0;
for _, obj in pairs(GetObjectList()) do
for _, tiles in pairs(tile.pos2) do
if obj.itemid == 112 and (obj.posX)//32 == tiles.x and (obj.posY)//32 == tiles.y then
Count = Count + obj.amount;
SendPacketRaw(false, pkt)
end end end
table.insert(data, Count)
Count = 0;
if data[2] > data[1] then
SendPacket(2, "action|input\n|text|`0[ Player1 ] :`2 "..data[2].." `bVs `0[ Player2 ] :`2"..data[1].."");
ontalk("`9Pos Left `2WIN!")
log("`9Pos Left `2WIN!")
cg2 = data[2]
elseif data[1] == data[2] then
SendPacket(2, "action|input\n|text|`0[ Player1 ] : `w"..data[2].." `0[ `bTie `0] `0[ Player2 ] `w: "..data[1].. "");
log("`9Nothing Winner `4TIE!")
ontalk("`9Nothing Winner `4TIE!")
elseif data[2] < data[1] then
SendPacket(2, "action|input\n|text|`0[ Player1 ] : `2"..data[2].." `bVs `0[ Player2 ] : `2"..data[1].. "");
ontalk("`9Pos Right `2WIN!")
log("`9Pos Right `2WIN!")
cg1 = data[1]
end
data = {};
end;
return false
end

-- Render CCTV menu
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

function btk()
setupbtk =  [[
add_label_with_icon|big|`2Configuration BTK|left|11550|
add_spacer|small|
add_text_input|taxkuy|`wInput Tax Amount|]] ..taxset.. [[|12|
add_textbox|`0Current Tax: `b[`2]]..taxset..[[%`b]|
add_spacer|small|
add_label_with_icon|small|`bPosition Gems Left:|left|340|
add_button|gemsleft1|`0Left 1: ]]..pos(gemsleftx1,gemslefty1)..[[|noflags|0|
add_button|gemsleft2|`0Left 2: ]]..pos(gemsleftx2,gemslefty2)..[[|noflags|0|
add_button|gemsleft3|`0Left 3: ]]..pos(gemsleftx3,gemslefty3)..[[|noflags|0|
add_button|gemsleft4|`0Left 4: ]]..pos(gemsleftx4,gemslefty4)..[[|noflags|0|
add_button|gemsleft5|`0Left 5: ]]..pos(gemsleftx5,gemslefty5)..[[|noflags|0|
add_button|gemsleft6|`0Left 6: ]]..pos(gemsleftx6,gemslefty6)..[[|noflags|0|
add_button|gemsleft7|`0Left 7: ]]..pos(gemsleftx7,gemslefty7)..[[|noflags|0|
add_spacer|small|
add_label_with_icon|small|`5Position Gems Right:|left|340|
add_button|gemsright1|`0Right 1: ]]..pos(gemsrightx1,gemsrighty1)..[[|noflags|0|
add_button|gemsright2|`0Right 2: ]]..pos(gemsrightx2,gemsrighty2)..[[|noflags|0|
add_button|gemsright3|`0Right 3: ]]..pos(gemsrightx3,gemsrighty3)..[[|noflags|0|
add_button|gemsright4|`0Right 4: ]]..pos(gemsrightx4,gemsrighty4)..[[|noflags|0|
add_button|gemsright5|`0Right 5: ]]..pos(gemsrightx5,gemsrighty5)..[[|noflags|0|
add_button|gemsright6|`0Right 6: ]]..pos(gemsrightx6,gemsrighty6)..[[|noflags|0|
add_button|gemsright7|`0Right 7: ]]..pos(gemsrightx7,gemsrighty7)..[[|noflags|0|
add_button|gemsright8|`0Right 8: ]]..pos(gemsrightx8,gemsrighty8)..[[|noflags|0|
add_spacer|small|
add_label_with_icon|small|`bPosition Back:|left|12854|
add_button|backpos|`0Pos Back: ]]..pos(backposx,backposy)..[[|noflags|0|
add_button|posplayer1|`0Pos Player 1: ]]..pos(player1x,player1y)..[[|noflags|0|
add_button|posplayer2|`0Pos Player 2 : ]]..pos(player2x,player2y)..[[|noflags|0|
add_spacer|small|
add_label_with_icon|small|`bPosition Display For Take Bet:|left|1422|
add_button|takeleft|`0Left: ]]..pos(takeleftx,takelefty)..[[|noflags|0|
add_button|takeright|`0Right: ]]..pos(takerightx,takerighty)..[[|noflags|0|
add_smalltext|`bSupport Transmatter Field``|
add_spacer|small|
add_quick_exit||
end_dialog|setupcoy|Cancel|Apply|
]]
dialog(setupbtk)
return true
end 

function take()
tiles = {
{takeleftx,takelefty},
{takerightx,takerighty}
}
for _, obj in pairs(GetObjectList()) do
for _, tiles in pairs(tiles) do
if (obj.posX)//32 == tiles[1] and (obj.posY)//32 == tiles[2] then
local pkt = {}
pkt.type = 11
pkt.value = obj.id
pkt.x = obj.posX
pkt.y = obj.posY
SendPacketRaw(false,pkt)
table.insert(data, {id=obj.itemid, count=obj.amount})
end 
end 
end
Data()
end
function Data()
Amount = 0
for _, list in pairs(data) do
Name = ""
if list.id == 11550 then
Name = "`bBlack Gem Lock"
Amount = Amount + list.count * 1000000
elseif list.id == 7188 then
Name = "`eBlue Gem Lock"
Amount = Amount + list.count * 10000
elseif list.id == 1796 then
Name = "`1Diamond Lock"
Amount = Amount + list.count * 100
elseif list.id == 242 then
Name = "`9World Lock"
Amount = Amount + list.count
end end
data = {}
end

function checkBetLeft(x,y)
for _, obj in pairs(GetObjectList()) do
if (obj.posX)//32 == x and (obj.posY)//32 == y then
if obj.itemid == 242 then
return obj.amount
end
if obj.itemid == 1796 then
return obj.amount * 100
end
if obj.itemid == 7188 then
return obj.amount * 10000
end
if obj.itemid == 11550 then
return obj.amount * 1000000
end
end end end

function checkBetRight(x,y)
for _, obj in pairs(GetObjectList()) do
if (obj.posX)//32 == x and (obj.posY)//32 == y then
if obj.itemid == 242 then
return obj.amount
end
if obj.itemid == 1796 then
return obj.amount * 100
end
if obj.itemid == 7188 then
return obj.amount * 10000
end
if obj.itemid == 11550 then
return obj.amount * 1000000
end
end end end

function clock(id,id2,amount)
for _, inv in pairs(GetInventory()) do
if inv.id == id then
if inv.amount < amount then
jk = {}
jk.x = 0
jk.y = 0
jk.type = 10
jk.value = id2
jk.px = 0
jk.py = 0
jk.state = 0
jk.netid = 0
SendPacketRaw(false, jk)
end
end
end
end

function skip(x, y)
if math.abs(GetLocal().posX // 32 - x) > 11 or math.abs(GetLocal().posY // 32 - y) > 10 then
return nil
end
if getTiles(x, y).collidable then
return nil
end
local Z = 0
if not getTiles(x + 1, y).collidable then
Z = 1
elseif not getTiles(x - 1, y).collidable then
Z = -1
else
return nil
end
SendPacketRaw(false, { type = 0, x = (x + Z -1) * 32, y = y * 32, state = (Z == 1 and 48 or 32) })
end

function skip2(x, y)
if math.abs(GetLocal().posX // 32 - x) > 11 or math.abs(GetLocal().posY // 32 - y) > 10 then
return nil
end
if getTiles(x, y).collidable then
return nil
end
local Z = 0
if not getTiles(x + 1, y).collidable then
Z = 1
elseif not getTiles(x - 1, y).collidable then
Z = -1
else
return nil
end
SendPacketRaw(false, { type = 0, x = (x + Z +1) * 32, y = y * 32, state = (Z == 1 and 48 or 32) })
end

function Drop(x, y, id, count)
_ENV["jumlah"] = count
if math.abs(GetLocal().posX // 32 - x) > 8 or math.abs(GetLocal().posY // 32 - y) > 8 then
oto("Tile Position `4Max")
return nil
end
if GetTiles(x, y).collidable then
oto("Position `4Blocked")
log("make sure u break any block in position save")
return nil
end
local Z = 0
if not GetTiles(x + 1, y).collidable then
Z = 1
elseif not GetTiles(x - 1, y).collidable then
Z = -1
else
oto("Position `4Blocked")
return nil
end
SendPacketRaw(false, { type = 0, x = (x + Z) * 32, y = y * 32, state = (Z == 1 and 48 or 32) })
    SendPacket(2, "action|drop\n|itemID|" .. id)
    Sleep(80)
    SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. id .. "\ncount|" .. count)
end



log("`9Hello , " .. GetLocal().name .. " Welcome Back")
Sleep(500)
log("`bKamu Bermain Di `0Hari`9 "..hari.." `0Tanggal`c "..tanggal.." `0Bulan`c "..bulan.." `0 Tahun`9 "..tahun.."")
log("`#Ketik /proxy untuk melihat command.")



function hook(type, str, packet)

if str:find("/proxy") or str:find("buttonClicked|cmd") then
gazette = [[add_label_with_icon|big|`9PROXY Commands    ````       |left|32|
add_spacer|small|
add_smalltext|`9Welcome, to the `5#1 Best OPEN SOURCE Proxy `9script.|left|
add_smalltext|`9What will you do today?, ]]..GetLocal().name..[[|left|
add_spacer|small|
add_label_with_icon|small|`5Information:|left|3524|
add_spacer|small|
add_textbox|`9/proxy `2- Show proxy command|left|
add_textbox|`9/pstats `2- Show proxy stats|left|
add_spacer|small|
add_label_with_icon|small|`5Lock Command:|left|1422|
add_spacer|small|
add_textbox|`9/daw `2- Drop All Locks|left|
add_textbox|`9/cd `1[AMOUNT] `2- Custom Drop Lock|left|
add_textbox|`9/dw `1[AMOUNT] `2- Drop WL only|left|
add_textbox|`9/dd `1[AMOUNT] `2- Drop DL only|left|
add_textbox|`9/db `1[AMOUNT] `2- Drop BGL only|left|
add_textbox|`9/bal `2- Show WL Balance|left|
add_textbox|`9/rafter `1[1-9] `2- Reset gems counter|left|
add_spacer|small|
add_label_with_icon|small|`5World Command:|left|242|
add_spacer|small|
add_textbox|`9/rejoin `2- Rejoin world|left|
add_textbox|`9/save `1[TEXT] `2- Save world to save wl|left|
add_textbox|`9/gsave `2- Go to save world|left|
add_textbox|`9/res `2- Fast respawn|left|
add_spacer|small|
add_label_with_icon|small|`5CSN Helper Command:|left|758|
add_spacer|small|
add_textbox|`9/setup `2- Show setup for BJ|left|
add_textbox|`9/win1 `1[AMOUNT] `2- Drop lock to POS1|left|
add_textbox|`9/win2 `1[AMOUNT] `2- Drop lock to POS2|left|
add_textbox|`9/gems `2- Show gems collected|left|
add_textbox|`9/auto `2- Auto take when /w1, /w2|left|
add_textbox|`9/tax `1[AMOUNT] `2- Set tax, don't add "%"|left|
add_textbox|`9/bet `1[AMOUNT] `2- Set Bet WL, DL, BGL|left|
add_textbox|`9/take `2- Take WL, DL, BGL|left|
add_textbox|`9/w1 `2- Drop WL to winner (Room 1)|left|
add_textbox|`9/w2 `2 Drop WL to winner (Room 2)|left|
add_spacer|small|
add_label_with_icon|small|`5More Command:|left|2376|
add_spacer|small|
add_textbox|`9/psc `2- Security Camera (`1only show u`2)|left|
add_textbox|`9/drop `1[ITEMID] [AMOUNT] `2- Drop item with command|left|
add_textbox|`9/name `1[TEXT] `2- Visual Name|left|
add_textbox|`9/relog `2- Fast Relog game|left|
add_textbox|`9/skin `1[SKIN ID] `2- Change Skin Colour (gtps)|left|
add_textbox|`9/fd `2- Fast Drop Toggle|left|
add_spacer|small|
add_quick_exit||
end_dialog|gazz|Cancel|Okay|
]]

dialog(gazette)
return true
end

if str:find("action|friends\ndelay") or str:find("buttonClicked|bk0") or str == ("action|dialog_return\ndialog_name|socialportal\n") then
mmenu = [[
set_default_color|`o
add_quick_exit|
add_label_with_icon|big|`wProxy Menu       ````     |left|758|
add_spacer|small|
add_textbox|`9World Locks : `2]]..inv(242)..[[|
add_textbox|`1Diamond Locks : `2]]..inv(1796)..[[|
add_textbox|`eBlue Gem Locks : `2]]..inv(7188)..[[|
add_textbox|`9Gems : `2]]..getGems()..[[|
add_spacer|small|
text_scaling_string|SubsToIptxtxD|
add_button_with_icon|modmnu|`wMod Menu|staticYellowFrame|5956|
add_button_with_icon|mfly|`wMod Fly|staticYellowFrame|362|
add_button_with_icon|fcbgl|`6Fast Change Bgl|staticPurpleFrame|7188|
add_button_with_icon|friends|`wSocial|staticYellowFrame|9474|
add_button_with_icon||END_LIST|noflags|0||
add_button_with_icon|setupbtkk|`wBTK Setup|staticYellowFrame|6016|
add_button_with_icon||END_LIST|noflags|0||
add_spacer|small|
end_dialog|k||Back|
]]
dialog(mmenu)
return true
end

    -- CCTV menu interaction
    if str:find("dialog_name|logs_menu_main") then
        if str:find("buttonClicked|btn_world_logs") then
            local str = "set_default_color|`o\nadd_label_with_icon|big|`bWorld Logs|left|3826|\nadd_spacer|small|\n"
            for _, v in ipairs(world_logs) do str = str .. "add_smalltext|"..v.."|left|\n" end
            str = str .. "add_spacer|small|\nadd_button|back_to_logs|`wBack to Menu|\nend_dialog|logs_view|Close||\n"
            dialog(str)
            return true
        elseif str:find("buttonClicked|btn_spin_logs") then
            local str = "set_default_color|`o\nadd_label_with_icon|big|`bRoulette Logs|left|32|\nadd_spacer|small|\n"
            for _, v in ipairs(spin_logs) do str = str .. "add_smalltext|"..v.."|left|\n" end
            str = str .. "add_spacer|small|\nadd_button|back_to_logs|`wBack to Menu|\nend_dialog|logs_view|Close||\n"
            dialog(str)
            return true
        end
    end
    
    -- CCTV back button
    if str:find("dialog_name|logs_view") and str:find("buttonClicked|back_to_logs") then
        show_logs_menu()
        return true
    end
    
        -- Show logs
    if str:find("/logs") then
        show_logs_menu()
        return true
    end

if str:find("/menu") or str:find("buttonClicked|modmnu") then
modmenu = [[
set_default_color|`o
add_quick_exit|
add_label_with_icon|big|`wProxy Menu       ````     |left|758|
add_spacer|small|
text_scaling_string|SubsToIptxtxD|
add_checkbox|modfly|`bMod Fly|]]..modfly..[[|
add_checkbox|modtele|`wTeleport|]]..tele..[[|
add_spacer|small|
end_dialog|meno||Okay|
]]
dialog(modmenu)
return true
end

if str:find("buttonClicked|btkbutton") then
btk()
return true
end

if str:find("buttonClicked|friends") then
SendPacket(2,"action|dialog_return\ndialog_name|social\nbuttonClicked|back")
return true
end

if str:find("action|dialog_return\ndialog_name|meno\nmodfly|1") then
if modfly == 0 then
modfly = 1
EditToggle("ModFly", true)
log("`2Enabling `9Fly Mod")
return true
end
end
if str:find("action|dialog_return\ndialog_name|meno\nmodfly|0") then
if modfly == 1 then
modfly = 0
EditToggle("ModFly", false)
log("`4Disabling `9Fly Mod")
return true
end
end

if str:find("buttonClicked|takeright") then
takerighton = true
log("`9Please Punch Display")
ontalk("`9Please Punch Display")
return true
elseif str:find("buttonClicked|takeleft") then
takelefton = true
log("`9Please Punch Display")
ontalk("`9Please Punch Display")
return true
end

if str:find("buttonClicked|takeright") then
takerighton = true
log("`9Please Punch Display")
ontalk("`9Please Punch Display")
return true
elseif str:find("buttonClicked|takeleft") then
takelefton = true
log("`9Please Punch Display")
ontalk("`9Please Punch Display")
return true
end

if str:find("buttonClicked|posplayer1") then
player1loc = true
log("`9Please Punch Chair")
ontalk("`9Please Punch Chair")
return true
elseif str:find("buttonClicked|posplayer2") then
player2loc = true
log("`9Please Punch Chair")
ontalk("`9Please Punch Chair")
return true
end

if str:find("buttonClicked|gemsright1") then
gemsright1 = true
log("`9Please Punch Chand")
ontalk("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsright2") then
gemsright2 = true
log("`9Please Punch Chand")
ontalk("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsright3") then
gemsright3 = true
log("`9Please Punch Chand")
ontalk("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsright4") then
gemsright4 = true
log("`9Please Punch Chand")
ontalk("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsright5") then
gemsright5 = true
log("`9Please Punch Chand")
ontalk("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsright6") then
gemsright6 = true
log("`9Please Punch Chand")
ontalk("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsright7") then
gemsright7 = true
log("`9Please Punch Chand")
ontalk("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsright8") then
gemsright8 = true
log("`9Please Punch Chand")
ontalk("`9Please Punch Chand")
return true
end

if str:find("buttonClicked|gemsleft1") then
gemsleft1 = true
log("`9Please Punch Chand")
ontalk("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsleft2") then
gemsleft2 = true
log("`9Please Punch Chand")
ontalk("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsleft3") then
gemsleft3 = true
log("`9Please Punch Chand")
ontalk("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsleft4") then
gemsleft4 = true
log("`9Please Punch Chand")
ontalk("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsleft5") then
gemsleft5 = true
log("`9Please Punch Chand")
ontalk("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsleft6") then
gemsleft6 = true
log("`9Please Punch Chand")
ontalk("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsleft7") then
gemsleft7 = true
log("`9Please Punch Chand")
ontalk("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|gemsleft8") then
gemsleft8 = true
log("`9Please Punch Chand")
ontalk("`9Please Punch Chand")
return true
elseif str:find("buttonClicked|backpos") then
backpos = true
log("`9Punch Position Back")
ontalk("`9Punch Position Back")
return true
end



if str:find("/checktile") then
if checktile == false then
checktile = true
ontalk("Check tile : `2Enable")
log("Check tile : `2Enable")
return true
else
checktile = false
ontalk("Check tile : `4Disable")
log("Check tile : `4Disable")
return true
end
end

if str:find("action|dialog_return\ndialog_name|meno\nmodfly|"..modfly.."\nmodtele|1") then
if tele == 0 then
tele = 1
EditToggle("FindPath", true)
log("`2Enabling `9Teleport Mod")
return true
end
end
if str:find("action|dialog_return\ndialog_name|meno\nmodfly|"..modfly.."\nmodtele|0") then
if tele == 1 then
tele = 0
EditToggle("FindPath", false)
log("`4Disabling `9Teleport Mod")
return true
end
end

if str:find("/tg") or str:find("buttonClicked|ck") then
takegems()
return true
end

     if str:find("buttonClicked|fcbgl") then
     if fcbgls == false then
cbgl = true
growtopia.notify("`7Fast Change Bgl `2Enable")
log("`2Enabling `9Fast Change `eBGL")
else
fcbgls = false
growtopia.notify("Fast Change Bgl `4Disable")
log("`4Disabling `9Fast Change `eBGL")
return true
end
end

     if str:find("/arroz (%d+)") then
jumlah = str:match("/arroz (%d+)")
dropItem(4604,jumlah)
ontalk("`2Succesfully Drop `0"..jumlah.." `9Arroz!")
log("`2Succesfully Drop `0"..jumlah.." `9Arroz!")
return true
end

     if str:find("/dw (%d+)") then
jumlah = str:match("/dw (%d+)")
dropItem(242,jumlah)
ontalk("`2Succesfully Drop `0"..jumlah.." `9World Locks!")
log("`2Succesfully Drop `0"..jumlah.." `9World Locks!")
return true
end

     if str:find("/dd (%d+)") then
jumlah = str:match("/dd (%d+)")
dropItem(1796,jumlah)
ontalk("`2Succesfully Drop `0"..jumlah.." `1Diamond Locks!")
log("`2Succesfully Drop `0"..jumlah.." `1Diamond Locks!")
return true
end

     if str:find("/db (%d+)") then
jumlah = str:match("/db (%d+)")
dropItem(7188,jumlah)
ontalk("`2Succesfully Drop `0"..jumlah.." `eBlue Gem Locks!")
log("`2Succesfully Drop `0"..jumlah.." `eBlue Gem Locks!")
return true
end

if str:find("/cd (%d+)") then
Amount = str:match("/cd (%d+)")
bgl = math.floor(Amount/10000)
Amount = Amount - bgl*10000 
dl = math.floor(Amount/100)
wl = Amount % 100
CDMode = true
hasil = (bgl ~= 0 and bgl.."`eBlue Gem Lock`0 " or "").." "..(dl ~= 0 and dl.."`1Diamond Lock`0 " or "").." "..(wl ~= 0 and wl.."`9World Lock`0 " or "")
return true
end

if str:find("/cdg (%d+)") then
Amount = str:match("/cdg (%d+)")
bgl =math.floor(Amount/10000)
Amount = Amount - bgl*10000 
dl = math.floor(Amount/100)
wl = Amount % 100
CDModeGTPS = true
hasil = (bgl ~= 0 and bgl.."`eBlue Gem Lock`0 " or "").." "..(dl ~= 0 and dl.."`1Diamond Lock`0 " or "").." "..(wl ~= 0 and wl.."`9World Lock`0 " or "")
return true
end

if str:find("/daw") then
bgl = inv(7188)
dl = inv(1796)
wl = inv(242)
dawMode = true
return true
end

if str:find("/cv") then
toggleAutoConvert()
return true
end

if str:find("/fly") or str:find("buttonClicked|mfly") then
if hiber == false then
hiber = true
EditToggle("ModFly", true)
notify("`2Mod Fly Enabled")
log("`2Enabling `9Fly Mod")
else
hiber = false
EditToggle("ModFly", false)
growtopia.notify("`4Mod Fly Disabled")
log("`4Disabling `9Fly Mod")
end
return true
end

if str:find("/tele") or str:find("buttonClicked|tele") then
if tele == false then
tele = true
EditToggle("FindPath", true)
growtopia.notify("`2Teleport Enabled")
log("`2Enabling `9Teleport")
else
tele = false
EditToggle("FindPath", false)
growtopia.notify("`4Teleport Disabled")
log("`4Disabling `9Teleport")
end
return true
end

if str:find("/relog") then
SendPacket(3,"action|quit")
growtopia.notify("`2Relog successfully.")
log("`2Relog successfully.")
return true
end

if str:find("/res") then
growtopia.notify("`2Respawn Succesful.")
log("`2Respawn Succesful.")
SendPacket(2,"action|respawn")
return true
end

    if str:find("/reme") then
        Config.gameMode = "reme"
        log("Mode: REME")
        notify("Mode: REME")
        return true
    end
    if str:find("/qeme") then
        Config.gameMode = "qq"
        log("Mode: Qeme")
        notify("Mode: Qeme")
        return true
    end
    if str:find("/csn") then
        Config.gameMode = "csn"
        log("Mode: CSN (Higher Wins)")
        notify("Mode: CSN")
        return true
    end

    
     if str:find("/gems") then
     if collectedgems == false then
     collectedgems = true
     log("Show collected gems On")
     else
     collectedgems = false
     log("Show collected gems Off")
     end
     return true
     end

     if str:find("/zzz") then
SendPacket(2,"action|input\n|text|Collected `2+"..cg.." Gems")
log("`9Gems `7Lu `#"..cg.."`7 y")
cg = 0
return true
end

     if str:find("/weather (%d+)") then
idweather = str:match("/weather (%d+)")
growtopia.setWeather("..idweather..")
log("`9Wheater set to "..idweather.."")
return true
end

if str:find("/tp (%d+) (%d+)") then
local x = str:match("/tp (%d+)")
local y = str:match("/tp "..x.." (%d+)")
FindPath(x, y)
ontalk("`2Succesfully teleport to Pos `0"..x.." "..y.."!")
log("`2Succesfully teleport to Pos `0"..x.." "..y.."!")
return true
end

if str:find("/setup") or str:find("buttonClicked|setupbtkk")then
btk()
kou()
log("`2Opening setup BTK")
return true
end

if str:find("/take") or str:find("buttonClicked|takebet") then
take()
tax = math.floor(Amount * taxset / 100)
jatuh = Amount - tax
bet = math.floor(Amount / 2)
log("\n`2Player1 : `0"..bet.." \n`2Player2 : `0"..bet.." \n`2Drop : `0"..jatuh.."")
SendPacket(2,"action|input\n|text|`w[ `2Player1 : `0"..bet.."`w ] `9Vs `w[ `2Player2 : `0"..bet.."`w ] [ `2Drop : `0"..jatuh.."`w ]")
return true
end

    if str:find([[
action|dialog_return
dialog_name|setupcoy
taxkuy|(%d+)]]) then
taxset = str:match("taxkuy|(%d+)")
ontalk("`4Tax Set To : `9"..taxset.."")
log("`4Tax Set To : `9"..taxset.."")
return true
  end
  
  if str:find("/win1 (%d+)") then
  FindPath(player1x,player1y)
  Sleep(2000)
Amount = str:match("/win1 (%d+)")
bgl =math.floor(Amount/10000)
Amount = Amount - bgl*10000 
dl = math.floor(Amount/100)
wl = Amount % 100
CDMode = true
hasil = (bgl ~= 0 and bgl.."`eBlue Gem Lock`0 " or "").." "..(dl ~= 0 and dl.."`1Diamond Lock`0 " or "").." "..(wl ~= 0 and wl.."`9World Lock`0 " or "")
Sleep(2000)
FindPath(backposx,backposy)
return true
end

  if str:find("/win2 (%d+)") then
  FindPath(player2x,player2y)
  Sleep(2000)
Amount = str:match("/win2 (%d+)")
bgl =math.floor(Amount/10000)
Amount = Amount - bgl*10000 
dl = math.floor(Amount/100)
wl = Amount % 100
CDMode = true
hasil = (bgl ~= 0 and bgl.."`eBlue Gem Lock`0 " or "").." "..(dl ~= 0 and dl.."`1Diamond Lock`0 " or "").." "..(wl ~= 0 and wl.."`9World Lock`0 " or "")
Sleep(2000)
FindPath(backposx,backposy)
return true
end

if str:find("/w1") then
bgl =math.floor(jatuh/10000)
jatuh = jatuh - bgl*10000 
dl = math.floor(jatuh/100)
wl = jatuh % 100
skip(player1x, player1y)
DropMode = true
hasil = (bgl ~= 0 and bgl.."Blue Gem Lock" or "").." "..(dl ~= 0 and dl.."Diamond Lock" or "").." "..(wl ~= 0 and wl.."World Lock" or "")
return true
end

if str:find("/w2") then
bgl =math.floor(jatuh/10000)
drop = jatuh - bgl*10000 
dl = math.floor(jatuh/100)
wl = jatuh % 100
skip2(player2x, player2y)
DropMode = true
hasil = (bgl ~= 0 and bgl.."Blue Gem Lock" or "").." "..(dl ~= 0 and dl.."Diamond Lock" or "").." "..(wl ~= 0 and wl.."World Lock" or "")
return true
end


  if str:find("/wing1 (%d+)") then
  FindPath(player1x,player1y)
  Sleep(300)
Amount = str:match("/wing1 (%d+)")
bgl =math.floor(Amount/10000)
Amount = Amount - bgl*10000 
dl = math.floor(Amount/100)
wl = Amount % 100
CDModeGTPS = true
hasil = (bgl ~= 0 and bgl.."`eBlue Gem Lock`0 " or "").." "..(dl ~= 0 and dl.."`1Diamond Lock`0 " or "").." "..(wl ~= 0 and wl.."`9World Lock`0 " or "")
return true
end

  if str:find("/wing2 (%d+)") then
  FindPath(player2x,player2y)
  Sleep(300)
Amount = str:match("/wing2 (%d+)")
bgl =math.floor(Amount/10000)
Amount = Amount - bgl*10000 
dl = math.floor(Amount/100)
wl = Amount % 100
CDModeGTPS = true
hasil = (bgl ~= 0 and bgl.."`eBlue Gem Lock`0 " or "").." "..(dl ~= 0 and dl.."`1Diamond Lock`0 " or "").." "..(wl ~= 0 and wl.."`9World Lock`0 " or "")
return true
end

if str:find("/gems") then
if collectedgems == false then
collectedgems = true
else
collectedgems = false
return true
end
end

    if str:find("/acc") then
        auto_accept_mode = not auto_accept_mode
        ontalk("`2Auto Accept Access Mode: " .. (auto_accept_mode and "`2ON" or "`4OFF"))
        return true
    end



return false
end

function var(var)

    -- Suppress drop dialogs
    if var.v1 == "OnDialogRequest" and type(var.v2) == "string" then
        local d = var.v2
        if d:find("drop", 1, true) and (d:find("242", 1, true) or d:find("1796", 1, true) or d:find("7188", 1, true)) then
            return true
        end
    end

    -- Auto-wear WL
    if var.v1 == "OnConsoleMessage" then
        local msg = tostring(var.v2 or "")
        if msg:match("Collected `w(%d+) World Lock``") then
            wear(242)
            return true
        end
    end

    if auto_accept_hide_ticks > 0 and var.v1:find("OnDialogRequest") then
        if var.v2:find("acceptlock") or var.v2:find("acceptaccess") then
            return true 
        end
    end

    if auto_accept_mode and var.v1:find("OnConsoleMessage") and var.v2:find("wants to add you to a") then
        local my_netid = tonumber(GetLocal().netid) or tonumber(GetLocal().netID) or 0
        SendPacket(2, "action|wrench\n|netid|" .. my_netid)
        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. my_netid .. "|\nbuttonClicked|acceptlock")
        SendPacket(2, "action|dialog_return\ndialog_name|acceptaccess")
        auto_accept_hide_ticks = 20
        ontalk("`2ACCESS GRANTED")
    end

   if var.v1 == "OnConsoleMessage" and var.v2:find("list of valid") then
log("`4Gada Command Begitu Njing")
return true 
end

   if var.v1 == "OnConsoleMessage" and var.v2:find("World Locked") then
log("\n`#Balance\n`9World Locks : `2"..inv(242).."\n`1Diamond Locks : `2"..inv(1796).."\n`eBlue Gem Locks : `2"..inv(7188).."\n`9Gems : `2"..getGems().."`0")
return true 
end

   if var.v1 == "OnConsoleMessage" and var.v2:find("powerhelp") then
log("`4/proxy For menu")
return true 
end

   if var.v1 == "OnConsoleMessage" and var.v2:find("World Locked") then
log("\n`#Balance\n`9World Locks : `2"..inv(242).."\n`1Diamond Locks : `2"..inv(1796).."\n`eBlue Gem Locks : `2"..inv(7188).."\n`9Gems : `2"..getGems().."`0")
return true 
end

   if var.v1 == "OnConsoleMessage" and var.v2:find("Where would") then
log("\n`#Balance\n`9World Locks : `2"..inv(242).."\n`1Diamond Locks : `2"..inv(1796).."\n`eBlue Gem Locks : `2"..inv(7188).."\n`9Gems : `2"..getGems().."`0")
return true 
end

if var.v1:find("OnConsoleMessage") then
LogToConsole(""..systemlog.." ".. var.v2)
return true
end

   if var.v1 == "OnTalkBubble" and var.v3 then
        local msg = tostring(var.v3)
        if msg:find("spun the wheel and got", 1, true) then
            local num = msg:match("`4(%d+)``!") or msg:match("`b(%d+)``!") or msg:match("`2(%d+)``!")
            if num then
                local result, label
                if Config.gameMode == "reme" then
                    result = calcReme(num)
                    label = "REME"
                elseif Config.gameMode == "qq" then
                    result = calcLastDigit(num)
                    label = "QEME"
                else
                    result = num
                    label = "CSN"
                end
                SendVariant({
                    v1 = "OnTalkBubble",
                    v2 = var.v2,
                    v3 = "`w[`2" .. label .. "`w] " .. msg .. " `2[`#" .. label .. ":`w" .. result .. "`2]"
                })
                return true
            end
        end
    end
return false
end

function raw(a)

if a.type == 11 then
for _, obj in pairs(GetObjectList()) do
if obj.id == a.value then
if obj.itemid == 112 then
cg = cg + obj.amount
end
end
end

end
if a.type == 3 then
cg = 0
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
return false
end

function OnValue(type, name, value)
if name == "checkcollectedgems" then 
SendPacket(2,"action|input\n|text|Collected `#+"..cg.." `7Gems")
log("`9Gems `7Lu `#"..cg.."`7 y")
cg = 0
return false
end

if name == "rememode" then 
Config.gameMode = "reme"
end

if name == "qqmode" then 
Config.gameMode = "qq"
end

if name == "lememode" then 
Config.gameMode = "leme"
end

if name == "btkbutton" then 
btk()
kou()
end

if name == "takebet" then 
take()
tax = math.floor(Amount * taxset / 100)
jatuh = Amount - tax
bet = math.floor(Amount / 2)
log("\n`2Player1 : `0"..bet.."\n`2Player2 : `0"..bet.."\n`2Drop : `0"..jatuh.."")
SendPacket(2,"action|input\n|text|`w[ `2Player1 : `0"..bet.." `w ] `4Vs `w[ `2Player2 : `0"..bet.." `w] [ `2Drop : `0"..jatuh.."`w ]")
end


if name == "takegems" then 
takegems()
end

if name == "checkgemss" then 
checkgems()
end

return false
end


AddHook(hook, "OnSendPacket")
AddHook(var,"OnVariant")
AddHook(raw,"OnSendPacketRaw")
addHook(OnValue, "OnValue")
applyHook()


while true do
Sleep(500)
if DropMode then
Sleep(200)
if bgl > 0 then
DropItem(7188, bgl)
Sleep(500)
end
if dl > 0 then
DropItem(1796, dl)
Sleep(500)
end
if wl > 0 then
DropItem(242, wl)
Sleep(500)
end
jatuh = nil
DropMode = false
log("`9Tax reset")
end

if CDMode then
Sleep(200)
if bgl > 0 then
dropItem(7188, bgl)
ontalk("`2Succesfully Drop `0"..bgl.." `eBlue Gem Locks!")
log("`2Succesfully Drop `0"..bgl.." `eBlue Gem Locks!")
Sleep(500)
end
if dl > 0 then
dropItem(1796, dl)
ontalk("`2Succesfully Drop `0"..dl.." `1Diamond Locks!")
log("`2Succesfully Drop `0"..dl.." `1Diamond Locks!")
Sleep(500)
end
if wl > 0 then
dropItem(242, wl)
log("`2Succesfully Drop `0"..wl.." `9World Locks!")
ontalk("`2Succesfully Drop `0"..wl.." `9World Locks!")
Sleep(500)
end
Amount = nil
CDMode = false
end

if CDModeGTPS then
Sleep(200)
if bgl > 0 then
dropgtps(7188, bgl)
ontalk("`2Succesfully Drop `0"..bgl.." `eBlue Gem Locks!")
log("`2Succesfully Drop `0"..bgl.." `eBlue Gem Locks!")
Sleep(500)
end
if dl > 0 then
dropgtps(1796, dl)
ontalk("`2Succesfully Drop `0"..dl.." `1Diamond Locks!")
log("`2Succesfully Drop `0"..dl.." `1Diamond Locks!")
Sleep(500)
end
if wl > 0 then
dropgtps(242, wl)
log("`2Succesfully Drop `0"..wl.." `9World Locks!")
ontalk("`2Succesfully Drop `0"..wl.." `9World Locks!")
Sleep(500)
end
Amount = nil
CDModeGTPS = false
end

if dawMode then
if bgl > 0 then
DropItem(7188, bgl)
Sleep(200)
end
if dl > 0 then
DropItem(1796, dl)
Sleep(200)
end
if wl > 0 then
DropItem(242, wl)
Sleep(200)
end
end
dawMode = false
bgl = nil
dl = nil
wl = nil
end

local function getCleanName(rawName)
    if not rawName then return "Player" end
    local clean = rawName:gsub("%s*`7%[`.%d+`7%]", "")
    clean = clean:gsub("%s*%[`.%d+%]", "")
    clean = clean:gsub("%s*%[%d+%]%s*$", "")
    return clean:match("^%s*(.-)%s*$") or rawName
end

local function getPlayerName(netid)
    if getPlayerList then
        local ok, list = pcall(getPlayerList)
        if ok and type(list) == "table" then
            for _, p in pairs(list) do
                if (p.netid or p.netID) == netid then
                    return getCleanName(p.name)
                end
            end
        end
    end
    if getLocal then
        local ok, me = pcall(getLocal)
        if ok and type(me) == "table" and (me.netid or me.netID) == netid then
            return getCleanName(me.name)
        end
    end
    return "Player"
end

local function onVariant(var)
    if var and var.v1 == "OnTalkBubble" then
        local netid = var.v2
        local text = type(var.v3) == "string" and var.v3 or ""

        if text:find("spun the wheel") then
            if text:find("OID:") then
                local fakeChat = text:match("player_chat=(.+)") or text
                local finalMsg = "`7[`4FAKE``] " .. fakeChat
                sendVariant({ v1 = "OnTalkBubble", v2 = netid, v3 = finalMsg, v4 = 0 }, nil, -1)
                return true
            else
                local spinColor, resultNum = text:match("and got (`.)(%d+)")
                if not resultNum then
                    resultNum = text:match("and got (%d+)")
                    spinColor = "`b"
                end

                if resultNum then
                    local finalMsg = "`7[`2REAL``] " .. text
                    sendVariant({ v1 = "OnTalkBubble", v2 = netid, v3 = finalMsg, v4 = 0 }, nil, -1)
                    local pName = getPlayerName(netid)
                    local nameWithSpin = pName .. " `7[" .. spinColor .. resultNum .. "`7]"
                    sendVariant({ v1 = "OnNameChanged", v2 = nameWithSpin, netID = -1 })
                    return true
                end
            end
        end
    end
    return false
end

addHook(onVariant, "onVariant")
if applyHook then
    applyHook()
end
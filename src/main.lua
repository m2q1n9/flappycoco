-- main.lua, created by mzq. -*- mode: lua -*-

function cclog(...)
    if not Config.debug then
        return
    end

    local log = string.format(...)
    local func = debug.getinfo(2)
    print(string.format("%s:%d %s", func.source, func.currentline, log))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("LUA ERROR: %s%s", tostring(msg), debug.traceback())
    return msg
end

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    math.randomseed(os.time())

    ccDirector = cc.Director:getInstance()
    ccFileUtils = cc.FileUtils:getInstance()
    ccUserDefault = cc.UserDefault:getInstance()

    ccFileUtils:addSearchPath("src")
    ccFileUtils:addSearchPath("res")

    local serpent = require("serpent")
    dump, dump1 = serpent.block, serpent.line

    require("module")

    cclog("Config = %s", dump(Config))

    ccDirector:setDepthTest(true)
    ccDirector:setDisplayStats(Config.displayStats)
    ccDirector:getOpenGLView():setDesignResolutionSize(
        Config.width, Config.height, cc.ResolutionPolicy.NO_BORDER)

    local size = ccDirector:getVisibleSize()
    local origin = ccDirector:getVisibleOrigin()
    visibleRect = cc.rect(origin.x, origin.y, size.width, size.height)
    visibleRect.xmid = cc.rectGetMidX(visibleRect)
    visibleRect.ymid = cc.rectGetMidY(visibleRect)
    visibleRect.xmax = cc.rectGetMaxX(visibleRect)
    visibleRect.ymax = cc.rectGetMaxY(visibleRect)
    cclog("visibleRect = %s", dump1(visibleRect))

    local scene = SceneLoading.new()
    if ccDirector:getRunningScene() then
        ccDirector:replaceScene(scene)
    else
        ccDirector:runWithScene(scene)
    end
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end

-- SceneLoading.lua, created by mzq. -*- mode: lua -*-

SceneLoading = class("SceneLoading", function()
    return cc.Scene:create()
end)

function SceneLoading:ctor()
    local label = cc.Label:createWithTTF("FlappyCoco", "04b08.TTF", 42)
    label:setColor(cc.c3b(0, 0xff, 0))
    label:setPosition(visibleRect.xmid, visibleRect.ymid+24)
    self:addChild(label)

    label = cc.Label:createWithTTF("FlappyBird x Cocos2dx", "04b08.TTF", 16)
    label:setColor(cc.c3b(0xff, 0, 0xff))
    label:setPosition(visibleRect.xmid, visibleRect.ymid-16)
    self:addChild(label)

    local function onNodeEvent(event)
        if event == "enter" then
            performWithDelay(self, self.load, 1)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function SceneLoading:load()
    cclog("SceneLoading:load()")

    atlas = ccDirector:getTextureCache():addImage("atlas.png")
    atlas:setAntiAliasTexParameters()

    scene = SceneGame.new()
    ccDirector:replaceScene(cc.TransitionFade:create(1, scene))

    cclog("Happy Hacking")
end

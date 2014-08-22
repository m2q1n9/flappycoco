-- LayerGameBack.lua, created by mzq. -*- mode: lua -*-

LayerGameBack = class("LayerGameBack", function()
    return cc.Layer:create()
end)

function LayerGameBack:ctor()
    local bg = Atlas.createSprite(Atlas.bg)
    bg:setPosition(visibleRect.xmid, visibleRect.ymid)
    self:addChild(bg)
end

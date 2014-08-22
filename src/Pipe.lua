-- Pipe.lua, created by mzq. -*- mode: lua -*-

Pipe = class("Pipe", function()
    return cc.Node:create()
end)

function Pipe:ctor()
    self.pass = false

    local upPipe = Atlas.createSprite(Atlas.pipe[1])
    local downPipe = Atlas.createSprite(Atlas.pipe[2])

    local upPipeBox = cc.PhysicsBody:createBox(upPipe:getContentSize())
    local downPipeBox = cc.PhysicsBody:createBox(downPipe:getContentSize())

    upPipeBox:setDynamic(false)
    downPipeBox:setDynamic(false)

    upPipeBox:setContactTestBitmask(1)
    downPipeBox:setContactTestBitmask(1)

    upPipe:setPhysicsBody(upPipeBox)
    downPipe:setPhysicsBody(downPipeBox)

    self:addChild(upPipe)
    self:addChild(downPipe)

    local size = upPipe:getContentSize()
    self.w, self.h, self.h1 = size.width, size.height/2, 0

    upPipe:setPosition(-self.w/2, -self.h+50)
    downPipe:setPosition(-self.w/2, self.h+Config.pipeDistance+50)
end

-- Ghost.lua, created by mzq. -*- mode: lua -*-

Ghost = class("Ghost", function()
    return cc.Sprite:create()
end)

function Ghost:ctor()
    self:runAction(cc.RepeatForever:create(cc.Animate:create(Atlas.createAnimation(Atlas.ghost))))

    local upAction = cc.MoveBy:create(1, cc.p(0, 100))
    local downAction = upAction:reverse()
    self.readyAction = cc.RepeatForever:create(cc.Sequence:create(upAction, downAction))
    self:runAction(self.readyAction)

    local body = cc.PhysicsBody:createCircle(Config.ghostRadius)
    body:setDynamic(false)
    body:setContactTestBitmask(1)
    self:setPhysicsBody(body)

    self.w, self.h, self.h1 = 50, 250, 150
end

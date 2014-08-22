-- Bird.lua, created by mzq. -*- mode: lua -*-

Bird = class("Bird", function()
    return cc.Sprite:create()
end)

function Bird:ctor(type)
    self.type = type
    self.Vy = Config.birdWingVy[type]
    cclog("bird type = %d, Vy = %d", self.type, self.Vy)

    local frames = Atlas.bird[type]
    icon = frames[1]
    self:runAction(cc.RepeatForever:create(cc.Animate:create(Atlas.createAnimation(frames))))

    local upAction = cc.MoveBy:create(0.4, cc.p(0, 8))
    local downAction = upAction:reverse()
    self.readyAction = cc.RepeatForever:create(cc.Sequence:create(upAction, downAction))
    self:runAction(self.readyAction)

    local body = cc.PhysicsBody:createCircle(Config.birdRadius)
    body:setDynamic(false)
    body:setRotationEnable(false)
    body:setContactTestBitmask(1)
    self:setPhysicsBody(body)
end

function Bird:play()
    cclog("Bird:play()")
    self:stopAction(self.readyAction)
    self:getPhysicsBody():setDynamic(true)
end

function Bird:wing()
    cclog("Bird:wing()")
    Audio.play(Audio.wing)
    self:getPhysicsBody():setVelocity(cc.p(0, self.Vy))
end

function Bird:die()
    cclog("Bird:die()")
    Audio.play(Audio.die)
    self:stopAllActions()
    self:setRotation(90)
end

function Bird:update()
    local Vy = self:getPhysicsBody():getVelocity().y
    self:setRotation(cc.clampf(-Vy*0.2-60, -30, 90))
end

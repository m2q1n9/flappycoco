-- SceneGame.lua, created by mzq. -*- mode: lua -*-

SceneGame = class("SceneGame", function()
    return cc.Scene:createWithPhysics()
end)

function SceneGame:ctor()
    self:getPhysicsWorld():setGravity(cc.p(0, Config.gravity))
    if Config.debugPhysics then
        self:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    end

    Audio.init()
    Atlas.init()

    self.layer = {}
    self.layer.game = LayerGame.new()
    self.layer.back = LayerGameBack.new()
    self.layer.info = LayerGameInfo.new()

    self:addChild(self.layer.back)
    self:addChild(self.layer.game)
    self:addChild(self.layer.info)
end

-- LayerGame.lua, created by mzq. -*- mode: lua -*-

local State =
    {
        READY = 0,
        PLAY  = 1,
        OVER  = 2,
    }

LayerGame = class("LayerGame", function()
    return cc.Layer:create()
end)

function LayerGame:ctor()
    Game = {}
    Game.topscore = ccUserDefault:getIntegerForKey("topscore")

    local function onNodeEvent(event)
        if event == "enter" then
            self:init()
            self:ready()
        elseif event == "exit" then
            self:unscheduleUpdate()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function LayerGame:init()
    self:addEdgeBox()
    self:addPipe()
    self:addGround()
    self:addMenu()
    self:addListener()
end

function LayerGame:addEdgeBox()
    local edgeBox = cc.Sprite:create()
    edgeBox:setPosition(visibleRect.xmid, visibleRect.ymid+Config.groundHeight/2)

    local size = cc.size(visibleRect.width, visibleRect.height-Config.groundHeight)
    local body = cc.PhysicsBody:createEdgeBox(size)
    body:setContactTestBitmask(1)
    edgeBox:setPhysicsBody(body)

    self:addChild(edgeBox)
    self.edgeBox = edgeBox
end

function LayerGame:addMenu()
    local play = Atlas.createSprite(Atlas.play)
    local playItem = cc.MenuItemSprite:create(play, play)
    playItem:setPosition(visibleRect.xmid, visibleRect.ymid)

    local select = Atlas.createSprite(Atlas.select)
    local selectItem = cc.MenuItemSprite:create(select, select)
    selectItem:setPosition(visibleRect.x+200, visibleRect.ymid+20)

    local menu = cc.Menu:create(playItem, selectItem)
    menu:setPosition(0, 0)
    self:addChild(menu)
    self.menu = {playItem = playItem, selectItem = selectItem}

    local function onTapPlay()
        self:ready()
    end
    playItem:registerScriptTapHandler(onTapPlay)

    local function onTapSelect()
        self:newBird((self.bird.type < 3) and (self.bird.type+1) or 1)
    end
    selectItem:registerScriptTapHandler(onTapSelect)
end

function LayerGame:addListener()
    local function onScheduleUpdate()
        self:update()
    end
    self:scheduleUpdateWithPriorityLua(onScheduleUpdate, 0)

    local function onTouchBegan(touch, event)
        self:touch()
    end
    local touchListener = cc.EventListenerTouchOneByOne:create()
    touchListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    ccDirector:getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, self)

    local function onContactBegin(contact)
        self:contact()
    end
    local contactListener = cc.EventListenerPhysicsContact:create()
    contactListener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    ccDirector:getEventDispatcher():addEventListenerWithSceneGraphPriority(contactListener, self)
end

function LayerGame:addGround()
    local ground1 = Atlas.createSprite(Atlas.ground)
    local ground2 = Atlas.createSprite(Atlas.ground)

    ground1:setAnchorPoint(0, 1)
    ground2:setAnchorPoint(0, 1)

    ground1:setPosition(0, visibleRect.y+Config.groundHeight)
    ground2:setPosition(0, visibleRect.y+Config.groundHeight)

    self:addChild(ground1)
    self:addChild(ground2)

    self.ground = {ground1, ground2}
end

function LayerGame:scrollGround()
    local ground1 = self.ground[1]
    local ground2 = self.ground[2]

    if ground2:getPositionX() == 0 then
        ground1:setPositionX(0)
    end

    local x1 = ground1:getPositionX()-Config.scroll
    local x2 = x1+ground1:getContentSize().width-36

    ground1:setPositionX(x1)
    ground2:setPositionX(x2)
end

function LayerGame:scrollPipe()
    for i, pipe in ipairs(self.pipe:getChildren()) do
        local x = pipe:getPositionX()
        if x >= -pipe.w then
            pipe:setPositionX(x-Config.scroll)
        else
            x = visibleRect.xmax
            pipe:setPosition(x, math.random(pipe.h1, pipe.h))
            pipe.pass = false
        end
    end
end

function LayerGame:removePipe()
    self.pipe:removeAllChildrenWithCleanup(true)
end

function LayerGame:addPipe()
    local pipe = cc.Sprite:create()
    pipe:setPosition(0, visibleRect.y+Config.groundHeight)

    self:addChild(pipe)
    self.pipe = pipe
end

function LayerGame:newPipe()
    local x = visibleRect.xmax
    for i = 1, Config.pipeCount do
        local pipe = Pipe.new()
        x = x + Config.pipeInterval
        pipe:setPosition(x, math.random(pipe.h1, pipe.h))
        self.pipe:addChild(pipe)
    end

    local ghost = Ghost.new()
    ghost:setPosition(x+150, math.random(ghost.h1, ghost.h))
    self.pipe:addChild(ghost)
end

function LayerGame:addBird(x, y, type)
    if self.bird then
        self:removeChild(self.bird)
    end

    self.bird = Bird.new(type)
    self.bird:setPosition(x, y)
    self:addChild(self.bird)
end

function LayerGame:newBird(type)
    Audio.play(Audio.swoosh)
    local x = self.menu.selectItem:getPositionX()+4
    local y = self.menu.selectItem:getPositionY()
    self:addBird(x, y, type or math.random(3))
end

function LayerGame:ready()
    cclog("LayerGame:ready()")
    Game.state = State.READY
    Game.lives = Config.birdLives
    Game.score = 0
    self:removePipe()
    self:newBird()
    self.menu.selectItem:setVisible(true)
    self.menu.playItem:setVisible(false)
    scene.layer.info:ready()
end

function LayerGame:play()
    cclog("LayerGame:play()")
    Game.state = State.PLAY
    self:newPipe()
    self.menu.selectItem:setVisible(false)
    scene.layer.info:play()
end

function LayerGame:over()
    cclog("LayerGame:over()")
    Game.state = State.OVER
    if Game.topscore < Game.score then
        Game.topscore = Game.score
        ccUserDefault:setIntegerForKey("topscore", Game.topscore)
    end
    self.menu.playItem:setVisible(true)
    scene.layer.info:over()
end

function LayerGame:touch()
    cclog("LayerGame:touch()")
    if Game.state == State.READY then
        self.bird:play()
        self:play()
    elseif Game.state == State.PLAY then
        self.bird:wing()
    end
end

function LayerGame:contact()
    cclog("LayerGame:contact()")
    if Game.state == State.PLAY then
        Audio.play(Audio.hit)
        self.bird:die()
        Game.lives = Game.lives-1
        scene.layer.info:updateLives()
        if Game.lives == 0 then
            self:over()
        end
    end
end

function LayerGame:point()
    cclog("LayerGame:point()")
    Audio.play(Audio.point)
    Game.score = Game.score+1
    scene.layer.info:updateScore()
end

function LayerGame:checkPoint()
    for i, pipe in ipairs(self.pipe:getChildren()) do
        if not pipe.pass then
            local pipeX = pipe:getPositionX()
            local birdX = self.bird:getPositionX()
            if pipeX+pipe.w < birdX then
                pipe.pass = true
                self:point()
            end
        end
    end
end

function LayerGame:update()
    if Game.state == State.PLAY then
        self.bird:update()
    elseif Game.state == State.OVER then
        return
    end

    self:scrollGround()
    self:scrollPipe()
    self:checkPoint()
end

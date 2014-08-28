FLAPPYCOCO 游戏制作小结
=======================

## 开发环境
* SDK：`Cocos2d-x 3.2 Final`
* IDE：`Cocos Code IDE`
* 语言：`Lua`
* 代码：https://github.com/m2q1n9/flappycoco

## 代码结构
```
[^_^mzq] ~/github $ ls -1 flappycoco/src/
Atlas.lua -- 纹理
Audio.lua -- 音频
Bird.lua -- 小鸟
Config.lua -- 配置
Ghost.lua -- 幽灵
LayerGame.lua -- 游戏层
LayerGameBack.lua -- 背景层
LayerGameInfo.lua -- 信息层
Number.lua -- 数字
Pipe.lua -- 水管
SceneGame.lua -- 游戏场景
SceneLoading.lua -- 加载场景
main.lua -- 入口
module.lua -- 模块
serpent.lua -- dump lua table
```

总代码行数：`819`
```
[^_^mzq] ~/github $ find flappycoco/src/ -type f ! -name "serpent.lua" | xargs wc -l
   24 flappycoco/src/SceneGame.lua
   29 flappycoco/src/Number.lua
   14 flappycoco/src/module.lua
   21 flappycoco/src/Ghost.lua
  267 flappycoco/src/LayerGame.lua
   36 flappycoco/src/SceneLoading.lua
  101 flappycoco/src/Atlas.lua
   11 flappycoco/src/LayerGameBack.lua
  119 flappycoco/src/LayerGameInfo.lua
   50 flappycoco/src/Bird.lua
   29 flappycoco/src/Audio.lua
   19 flappycoco/src/Config.lua
   33 flappycoco/src/Pipe.lua
   66 flappycoco/src/main.lua
  819 total
```

## 多分辨率适配方案选择
采用`NO_BORDER`方案
* 游戏画面等高宽比缩放
* 屏幕上下或左右无黑边
* 会导致上下或左右部分背景不可见
* 基于`VisibleSize`和`VisibleOrigin`做场景布局

初始化可视矩形方便使用：
```lua
local size = ccDirector:getVisibleSize()
local origin = ccDirector:getVisibleOrigin()
visibleRect = cc.rect(origin.x, origin.y, size.width, size.height)
visibleRect.xmid = cc.rectGetMidX(visibleRect)
visibleRect.ymid = cc.rectGetMidY(visibleRect)
visibleRect.xmax = cc.rectGetMaxX(visibleRect)
visibleRect.ymax = cc.rectGetMaxY(visibleRect)
cclog("visibleRect = %s", dump1(visibleRect))
```

## 纹理配置文件解析
纹理图片和配置文件从最新版的`Flappy Birds Family`拆包获得
<br/>
纹理配置文件`atlas_text.txt`结构：`name, width, height, x, y, w, h`
<br/>
这边用一行Lua正则表达式实现解析：
<br/>
`([%w_]+)%s+(%d+)%s+(%d+)%s+([%d%.]+)%s+([%d%.]+)%s+([%d%.]+)%s+([%d%.]+)`

```lua
local t = {}
local s = ccFileUtils:getStringFromFile("atlas_text.txt")
local p = "([%w_]+)%s+(%d+)%s+(%d+)%s+([%d%.]+)%s+([%d%.]+)%s+([%d%.]+)%s+([%d%.]+)"
local size = atlas:getContentSize()
for name, width, height, x, y, w, h in s:gmatch(p) do
    t[name] = cc.rect(x*size.width, y*size.height, w*size.width, h*size.height)
    cclog("%s = %s", name, dump1(t[name]))
end
```

创建`Sprite`：
```lua
function Atlas.createSprite(rect)
    return cc.Sprite:createWithTexture(atlas, rect)
end
```

创建`Animation`：
```lua
function Atlas.createAnimation(rects)
    local frames = {}
    for i, rect in ipairs(rects) do
        table.insert(frames, cc.SpriteFrame:createWithTexture(atlas, rect))
    end
    return cc.Animation:createWithSpriteFrames(frames, 0.1)
end
```

## 场景结构
* 加载场景 (显示游戏logo，后台初始化主游戏场景，加载所有资源，完后切换到游戏场景)
* 游戏场景
  * 背景层 (显示游戏背景)
  * 游戏层 (处理核心游戏逻辑，显示小鸟/水管/幽灵/陆地等)
  * 信息层 (实时显示游戏各种状态信息)

## 单位重用
* 小鸟 x1
* 水管 x3
* 幽灵 x1
* 陆地 x2

## 水管和幽灵随机生成
```lua
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
```

## 构造物理世界
**游戏中碰撞检测和小鸟运动均使用物理引擎实现：**
<br/>
小鸟和物理世界中的任意物体发生碰撞均会导致死亡
<br/>
游戏进行中小鸟会受到重力影响而加速往下降
<br/>
触摸屏幕时对小鸟施加一个向上的初速度，获得瞬间向上跳跃的效果
<br/>
小鸟头部也会随着Y轴速度的变化而转动相应角度，使得运动更加逼真

**初始化物理世界：**
```lua
SceneGame = class("SceneGame", function()
    return cc.Scene:createWithPhysics()
end)
function SceneGame:ctor()
    self:getPhysicsWorld():setGravity(cc.p(0, Config.gravity))
    if Config.debugPhysics then
        self:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    end
```

**创建物体并附加到相应单位：**

`edgeBox`：
```lua
local size = cc.size(visibleRect.width, visibleRect.height-Config.groundHeight)
local body = cc.PhysicsBody:createEdgeBox(size)
body:setContactTestBitmask(1)
edgeBox:setPhysicsBody(body)
```

`Bird`：
```lua
local body = cc.PhysicsBody:createCircle(Config.birdRadius)
body:setDynamic(false)
body:setRotationEnable(false)
body:setContactTestBitmask(1)
self:setPhysicsBody(body)
```

`Pipe`：
```lua
local upPipeBox = cc.PhysicsBody:createBox(upPipe:getContentSize())
local downPipeBox = cc.PhysicsBody:createBox(downPipe:getContentSize())
upPipeBox:setDynamic(false)
downPipeBox:setDynamic(false)
upPipeBox:setContactTestBitmask(1)
downPipeBox:setContactTestBitmask(1)
upPipe:setPhysicsBody(upPipeBox)
downPipe:setPhysicsBody(downPipeBox)
```

`Ghost`：
```lua
local body = cc.PhysicsBody:createCircle(Config.ghostRadius)
body:setDynamic(false)
body:setContactTestBitmask(1)
self:setPhysicsBody(body)
```

`setDynamic`控制物体是否受重力影响
<br/>
`setContactTestBitmask`设置接触测试位掩码

## 调度器和事件处理

调度器：
```lua
local function onScheduleUpdate()
    self:update()
end
self:scheduleUpdateWithPriorityLua(onScheduleUpdate, 0)
```

触摸事件：
```lua
local function onTouchBegan(touch, event)
    self:touch()
end
local touchListener = cc.EventListenerTouchOneByOne:create()
touchListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
ccDirector:getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, self)
```

碰撞事件：
```lua
local function onContactBegin(contact)
    self:contact()
end
local contactListener = cc.EventListenerPhysicsContact:create()
contactListener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
ccDirector:getEventDispatcher():addEventListenerWithSceneGraphPriority(contactListener, self)
```

## 状态切换
`READY => PLAY => OVER => READY => ...`

## 音频播放
```lua
AudioEngine.preloadEffect(name)
AudioEngine.playEffect(name)
```

## 数据保存读取
```lua
ccUserDefault:setIntegerForKey("topscore", Game.topscore)
Game.topscore = ccUserDefault:getIntegerForKey("topscore")
```

:shipit:

-- Atlas.lua, created by mzq. -*- mode: lua -*-

Atlas = Atlas or {}

function Atlas.createSprite(rect)
    return cc.Sprite:createWithTexture(atlas, rect)
end

function Atlas.createAnimation(rects)
    local frames = {}
    for i, rect in ipairs(rects) do
        table.insert(frames, cc.SpriteFrame:createWithTexture(atlas, rect))
    end
    return cc.Animation:createWithSpriteFrames(frames, 0.1)
end

function Atlas.init()
    local t = {}
    local s = ccFileUtils:getStringFromFile("atlas_text.txt")
    local p = "([%w_]+)%s+(%d+)%s+(%d+)%s+([%d%.]+)%s+([%d%.]+)%s+([%d%.]+)%s+([%d%.]+)"

    local size = atlas:getContentSize()
    for name, width, height, x, y, w, h in s:gmatch(p) do
        t[name] = cc.rect(x*size.width, y*size.height, w*size.width, h*size.height)
        cclog("%s = %s", name, dump1(t[name]))
    end

    local date = os.date("*t", os.time())
    cclog("date = %s", dump1(date))

    local hour = date.hour
    Atlas.bg = (hour >= 6 and hour < 18) and t.bg or t.bg_night

    Atlas.ground = t.ground

    Atlas.play = t.play
    Atlas.select = t.button_enable

    Atlas.tutorial = t.tutorial
    Atlas.ready = t.ready
    Atlas.gameover = t.gameover

    Atlas.pipe =
        {
            t.pipe_up,
            t.pipe_down,
        }

    Atlas.ghost =
        {
            t.ghost_0,
            t.ghost_1,
        }

    Atlas.bird =
        {
            {
                t.bird0_0,
                t.bird0_1,
                t.bird0_2,
            },
            {
                t.bird1_0,
                t.bird1_1,
                t.bird1_2,
            },
            {
                t.bird2_0,
                t.bird2_1,
                t.bird2_2,
            },
        }

    Atlas.number =
        {
            {
                t.font_048,
                t.font_049,
                t.font_050,
                t.font_051,
                t.font_052,
                t.font_053,
                t.font_054,
                t.font_055,
                t.font_056,
                t.font_057,
            },
            {
                t.number_score_00,
                t.number_score_01,
                t.number_score_02,
                t.number_score_03,
                t.number_score_04,
                t.number_score_05,
                t.number_score_06,
                t.number_score_07,
                t.number_score_08,
                t.number_score_09,
            },
        }
end

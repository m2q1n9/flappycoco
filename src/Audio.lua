-- Audio.lua, created by mzq. -*- mode: lua -*-

require "AudioEngine"

Audio = Audio or {
    die = "sfx_die.ogg",
    hit = "sfx_hit.ogg",
    wing = "sfx_wing.ogg",
    point = "sfx_point.ogg",
    swoosh = "sfx_swooshing.ogg",
}

function Audio.init()
    Audio.load(Audio.die)
    Audio.load(Audio.hit)
    Audio.load(Audio.wing)
    Audio.load(Audio.point)
    Audio.load(Audio.swoosh)
end

function Audio.load(name)
    cclog("Audio.load %s", name)
    AudioEngine.preloadEffect(name)
end

function Audio.play(name)
    cclog("Audio.play %s", name)
    AudioEngine.playEffect(name)
end

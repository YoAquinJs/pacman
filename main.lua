_G.engine = require("love")

require("gamecontrol")
require("utils")

_G.assetsdata = [[assets/sounds/die.mp3~die
assets/sounds/eatdot.mp3~eatdot
assets/sounds/eaten.mp3~eaten
assets/sounds/eatfruit.mp3~eatfruit
assets/sounds/eatghost.mp3~eatghost
assets/sounds/frigthtened.mp3~frigthtened
assets/sounds/frigthtenedstart.mp3~frigthtenedstart
assets/sounds/highscore.mp3~highscore
assets/sounds/siren.mp3~siren
assets/sounds/start.mp3~start
assets/sprites/title.png~title
assets/sprites/blinky/d1.png~blinky/d1
assets/sprites/blinky/d2.png~blinky/d2
assets/sprites/blinky/l1.png~blinky/l1
assets/sprites/blinky/l2.png~blinky/l2
assets/sprites/blinky/r1.png~blinky/r1
assets/sprites/blinky/r2.png~blinky/r2
assets/sprites/blinky/u1.png~blinky/u1
assets/sprites/blinky/u2.png~blinky/u2
assets/sprites/clyde/d1.png~clyde/d1
assets/sprites/clyde/d2.png~clyde/d2
assets/sprites/clyde/l1.png~clyde/l1
assets/sprites/clyde/l2.png~clyde/l2
assets/sprites/clyde/r1.png~clyde/r1
assets/sprites/clyde/r2.png~clyde/r2
assets/sprites/clyde/u1.png~clyde/u1
assets/sprites/clyde/u2.png~clyde/u2
assets/sprites/font/0.png~font/0
assets/sprites/font/1.png~font/1
assets/sprites/font/2.png~font/2
assets/sprites/font/3.png~font/3
assets/sprites/font/4.png~font/4
assets/sprites/font/5.png~font/5
assets/sprites/font/6.png~font/6
assets/sprites/font/7.png~font/7
assets/sprites/font/8.png~font/8
assets/sprites/font/9.png~font/9
assets/sprites/font/a.png~font/a
assets/sprites/font/b.png~font/b
assets/sprites/font/c.png~font/c
assets/sprites/font/d.png~font/d
assets/sprites/font/e.png~font/e
assets/sprites/font/f.png~font/f
assets/sprites/font/g.png~font/g
assets/sprites/font/h.png~font/h
assets/sprites/font/i.png~font/i
assets/sprites/font/j.png~font/j
assets/sprites/font/k.png~font/k
assets/sprites/font/l.png~font/l
assets/sprites/font/m.png~font/m
assets/sprites/font/n.png~font/n
assets/sprites/font/o.png~font/o
assets/sprites/font/p.png~font/p
assets/sprites/font/q.png~font/q
assets/sprites/font/r.png~font/r
assets/sprites/font/s.png~font/s
assets/sprites/font/slash.png~font/slash
assets/sprites/font/t.png~font/t
assets/sprites/font/u.png~font/u
assets/sprites/font/v.png~font/v
assets/sprites/font/w.png~font/w
assets/sprites/font/x.png~font/x
assets/sprites/font/y.png~font/y
assets/sprites/font/z.png~font/z
assets/sprites/ghosts/ed.png~ghosts/ed
assets/sprites/ghosts/el.png~ghosts/el
assets/sprites/ghosts/er.png~ghosts/er
assets/sprites/ghosts/eu.png~ghosts/eu
assets/sprites/ghosts/fB1.png~ghosts/fB1
assets/sprites/ghosts/fB2.png~ghosts/fB2
assets/sprites/ghosts/fW1.png~ghosts/fW1
assets/sprites/ghosts/fW2.png~ghosts/fW2
assets/sprites/inky/d1.png~inky/d1
assets/sprites/inky/d2.png~inky/d2
assets/sprites/inky/l1.png~inky/l1
assets/sprites/inky/l2.png~inky/l2
assets/sprites/inky/r1.png~inky/r1
assets/sprites/inky/r2.png~inky/r2
assets/sprites/inky/u1.png~inky/u1
assets/sprites/inky/u2.png~inky/u2
assets/sprites/maze/maze.png~maze/maze
assets/sprites/maze/winmaze.png~maze/winmaze
assets/sprites/pacman/d1.png~pacman/d1
assets/sprites/pacman/d2.png~pacman/d2
assets/sprites/pacman/dh1.png~pacman/dh1
assets/sprites/pacman/dh10.png~pacman/dh10
assets/sprites/pacman/dh11.png~pacman/dh11
assets/sprites/pacman/dh2.png~pacman/dh2
assets/sprites/pacman/dh3.png~pacman/dh3
assets/sprites/pacman/dh4.png~pacman/dh4
assets/sprites/pacman/dh5.png~pacman/dh5
assets/sprites/pacman/dh6.png~pacman/dh6
assets/sprites/pacman/dh7.png~pacman/dh7
assets/sprites/pacman/dh8.png~pacman/dh8
assets/sprites/pacman/dh9.png~pacman/dh9
assets/sprites/pacman/fill.png~pacman/fill
assets/sprites/pacman/l1.png~pacman/l1
assets/sprites/pacman/l2.png~pacman/l2
assets/sprites/pacman/r1.png~pacman/r1
assets/sprites/pacman/r2.png~pacman/r2
assets/sprites/pacman/u1.png~pacman/u1
assets/sprites/pacman/u2.png~pacman/u2
assets/sprites/pinky/d1.png~pinky/d1
assets/sprites/pinky/d2.png~pinky/d2
assets/sprites/pinky/l1.png~pinky/l1
assets/sprites/pinky/l2.png~pinky/l2
assets/sprites/pinky/r1.png~pinky/r1
assets/sprites/pinky/r2.png~pinky/r2
assets/sprites/pinky/u1.png~pinky/u1
assets/sprites/pinky/u2.png~pinky/u2
assets/sprites/popupfont/0.png~popupfont/0
assets/sprites/popupfont/1.png~popupfont/1
assets/sprites/popupfont/2.png~popupfont/2
assets/sprites/popupfont/3.png~popupfont/3
assets/sprites/popupfont/4.png~popupfont/4
assets/sprites/popupfont/5.png~popupfont/5
assets/sprites/popupfont/6.png~popupfont/6
assets/sprites/popupfont/7.png~popupfont/7
assets/sprites/popupfont/8.png~popupfont/8
assets/sprites/props/apple.png~props/apple
assets/sprites/props/bell.png~props/bell
assets/sprites/props/cherry.png~props/cherry
assets/sprites/props/dot.png~props/dot
assets/sprites/props/galaxian.png~props/galaxian
assets/sprites/props/key.png~props/key
assets/sprites/props/melon.png~props/melon
assets/sprites/props/orange.png~props/orange
assets/sprites/props/pill.png~props/pill
assets/sprites/props/strawberry.png~props/strawberry]]
_G.gamedata = [[startLifes:3
propMaxTime:10
maxVelocity:8
eatenVelocity:14
maxHighscores:5
screenSize:25
defaultNametag:AAAAA
pacmanStartDirection:-1,0
blinkyStartDirection:-1,0
props:100,300,500,700,1000,2000,3000,5000]]
_G.leveldata = [[1,0.80,0.71,0.75,0.40, 20,0.80,10,0.85,0.90,0.79,0.50,6
2,0.90,0.79,0.85,0.45, 30,0.90,15,0.95,0.95,0.83,0.55,5
3,0.90,0.79,0.85,0.45, 40,0.90,20,0.95,0.95,0.83,0.55,4
3,0.90,0.79,0.85,0.45, 40,0.90,20,0.95,0.95,0.83,0.55,3
4,1.00,0.87,0.95,0.50, 40,1.00,20,1.05,1.00,0.87,0.60,2
4,1.00,0.87,0.95,0.50, 50,1.00,25,1.05,1.00,0.87,0.60,5
5,1.00,0.87,0.95,0.50, 50,1.00,25,1.05,1.00,0.87,0.60,2
5,1.00,0.87,0.95,0.50, 50,1.00,25,1.05,1.00,0.87,0.60,2
6,1.00,0.87,0.95,0.50, 60,1.00,30,1.05,1.00,0.87,0.60,1
6,1.00,0.87,0.95,0.50, 60,1.00,30,1.05,1.00,0.87,0.60,5
7,1.00,0.87,0.95,0.50, 60,1.00,30,1.05,1.00,0.87,0.60,2
7,1.00,0.87,0.95,0.50, 80,1.00,40,1.05,1.00,0.87,0.60,1
8,1.00,0.87,0.95,0.50, 80,1.00,40,1.05,1.00,0.87,0.60,1
8,1.00,0.87,0.95,0.50, 80,1.00,40,1.05,1.00,0.87,0.60,3
8,1.00,0.87,0.95,0.50,100,1.00,50,1.05,1.00,0.87,0.60,1
8,1.00,0.87,0.95,0.50,100,1.00,50,1.05,1.00,0.87,0.60,1
8,1.00,0.87,0.95,0.50,100,1.00,50,1.05,null,null,null,0
8,1.00,0.87,0.95,0.50,100,1.00,50,1.05,1.00,0.87,0.60,1
8,1.00,0.87,0.95,0.50,120,1.00,60,1.05,null,null,null,0
8,1.00,0.87,0.95,0.50,120,1.00,60,1.05,null,null,null,0
8,0.90,0.79,0.95,0.50,120,1.00,60,1.05,null,null,null,0

 1,7,20,7,20,5,20,5,1
 4,7,20,7,20,5, 1
-1,5,20,5,20,5, 1]]
_G.mapdata = [[0000p0000000000000000000000b0000
00000%00000#00000000000000000000
000000000^000000000000$000000000
00000000000000000000000000000000
00111111111111111111111111111100
00133333333333311333333333333100
00131111311111311311111311113100
00141111311111311311111311114100
00131111311111311311111311113100
00133333333333333333333333333100
00131111311311111111311311113100
00131111311311111111311311113100
00133333311333311333311333333100
00111111311111611611111311111100
00000001311111611611111310000000
00000001311*666B6666611310000000
00000001311611122111611310000000
00111111311610000001611311111100
05-----636661I0P0C0166636-----50
00111111311610000001611311111100
00000001311611111111611310000000
000000013116666)6666611310000000
00000001311611111111611310000000
00111111311611111111611311111100
00133333333333311333333333333100
00131111311111311311111311113100
00131111311111311311111311113100
001433113333333M3333333311334100
00111311311311111111311311311100
00111311311311111111311311311100
00133333311333311333311333333100
00131111111111311311111111113100
00131111111111311311111111113100
00133333333333333333333333333100
00111111111111111111111111111100
00c00000000000000000000000000i00
00000!0(0000000000000000000@0000]]

function engine.load()
    _G.GameControl = GameControl.LoadGameControl() --Tile size determinating screen and elements sizes
    GameControl.currentLevelInfo.level = -1
    _G.Utils = Utils
    Utils:start()

    engine.graphics.setBackgroundColor(0,0,0) --window Background Color
    engine.window.setMode(#GameControl.grid.TILES*GameControl.grid.tilePX - (GameControl.grid.tilePX*4),
    #GameControl.grid.TILES[1]*GameControl.grid.tilePX - GameControl.grid.tilePX, {display = 2, fullscreen=false, centered=true})

    print(love.system.getOS())
    Utils.sleeptTime = engine.timer.getTime()
end

function engine.update(dt)
    Utils:update()
    GameControl:update(dt, Utils:getTime())
    Utils.input.start = false
end

function engine.keyreleased(key)
    Utils.input.start = key == "space"
end

function engine.draw()
    GameControl:draw(Utils:getTime())
    --engine.graphics.print(tostring(engine.timer.getFPS()), 25, 25, 0, 2, 2)
end

function engine.quit()
    if GameControl.tag ~= nil then
        table.insert(GameControl.highscores, {GameControl.tag, GameControl.score})
        GameControl:serializeScores()
    end
end
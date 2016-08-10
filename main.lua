require("util")
Class=require("middleclass")
Soft=require("softbody")
function love.load(arg)
    world = love.physics.newWorld(0, 9.8*32, false)
    love.physics.setMeter(32)
    tab={}
    for i=1,16 do
        local x=math.sin(i*2*math.pi/16)
        local y=math.cos(i*2*math.pi/16)
        table.insert(tab,x*120+93)
        table.insert(tab,y*120+101)
    end
    local pic = love.graphics.newImage("02.png")
    local cat = love.graphics.newImage("01.png")
    local p={0,0,186,0,186,202,0,202}
    --格式重改，x,y 相对位置，tab 目标绘制区域在图片中的坐标
    p1=Soft(400,100,tab,pic,20)
    p2=Soft(100,100,p,cat,10)
    surface = {}
    surface.body = love.physics.newBody(world, 0, 0)
    surface.shape = love.physics.newChainShape(true, 0, 0, 800, 0, 800, 600, 0, 600)
    surface.fixture = love.physics.newFixture(surface.body, surface.shape)
end

function love.draw()
    p1:draw()
    p2:draw()
    love.graphics.line(p2.smoothPoints)
end

function love.update(dt)
    love.window.setTitle( love.timer.getFPS())
    world:update(dt)
    p1:update()
    p2:update()
end





--[[
function love.quit() --Callback function triggered when the game is closed.
end 
function love.resize(w,h) --Called when the window is resized.
end 
function love.textinput(text) --Called when text has been entered by the user.
end 
function love.threaderror(thread, err ) --Callback function triggered when a Thread encounters an error.
end 
function love.visible() --Callback function triggered when window is shown or hidden.
end 
function love.mousefocus(f)--Callback function triggered when window receives or loses mouse focus.
end
function love.mousepressed(x,y,button) --Callback function triggered when a mouse button is pressed.
end 
function love.mousereleased(x,y,button)--Callback function triggered when a mouse button is released.
end 
function love.errhand(err) --The error handler, used to display error messages.
end 
function love.focus(f) --Callback function triggered when window receives or loses focus.
end 
function love.keypressed(key,isrepeat) --Callback function triggered when a key is pressed.
end
function love.keyreleased(key) --Callback function triggered when a key is released.
end 
function love.run() --The main function, containing the main loop. A sensible default is used when left out.

    if love.math then
        love.math.setRandomSeed(os.time())
        for i=1,3 do love.math.random() end
    end

    if love.event then
        love.event.pump()
    end

    if love.load then love.load(arg) end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local dt = 0

    -- Main loop time.
    while true do
        -- Process events.
        if love.event then
            love.event.pump()
            for e,a,b,c,d in love.event.poll() do
                if e == "quit" then
                    if not love.quit or not love.quit() then
                        if love.audio then
                            love.audio.stop()
                        end
                        return
                    end
                end
                love.handlers[e](a,b,c,d)
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        -- Call update and draw
        if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

        if love.window and love.graphics and love.window.isCreated() then
            love.graphics.clear()
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end
]]
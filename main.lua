--love.filesystem.setIdentity(love.filesystem.getIdentity(),false)
local discordRPC = require "discordRPC"
local appId = require("applicationId")
local presence

camera = require 'lib/camera'
local cam = camera()
urutora = require 'lib/urutora'

local u = urutora:new()
local mainUI = urutora:new()


playGame = require("pressedPlay")

function love.mousemoved(x, y, dx, dy) u:moved(x, y, dx, dy) mainUI:moved(x, y, dx, dy) end
function love.mousereleased(x, y, button) u:released(x, y) mainUI:released(x, y) end
function love.textinput(text) u:textinput(text) mainUI:textinput(text) end
function love.keypressed(k, scancode, isrepeat) u:keypressed(k, scancode, isrepeat) mainUI:keypressed(k, scancode, isrepeat) end

local width = nil
local height = nil

local UI_COLOR = {126/255,99/255,118/255}

local camX = 0
local camY = 0
local camXstart = 0
local camYstart = 0

local scale = 1

local scene = "main"
local offset = -500
local name_project = nil

local create = mainUI.button({
    text = '+ New Project',
    x = 500, y = 65,
    w = 150,
    h = 50,
})

local start = mainUI.button({ text = "NEXT", w = 100, h = 35 })
local stopp = mainUI.button({ text = "CANCEL", w = 100, h = 35 }):setStyle({ bgColor = {0.7, 0.2, 0.2} })
local projectname = mainUI.text({ text = "Project Name", w = 200, h = 35})
local ex = mainUI.text({ text = "1080", w = 75, h = 35})
local why = mainUI.text({ text = "720", w = 75, h = 35})
local threeDee = mainUI.toggle({ text = "Patformer Gravity", false, w = 165, h = 35})
local engineType = mainUI.multi({ items = {"2D Game","3D Game (g3d library)", "DS game (microLua)"}, w = 165, h = 35})

function love.load(arg, otherarg) 
    ------------------------------------------------------------
    discordRPC.initialize(appId, true)
    local now = os.time(os.date("*t"))
    presence = {
        state = "In the menus, viewing their projects...",
        largeImageKey = "hyperpsad"
    }

    nextPresenceUpdate = 0
    ------------------------------------------------------------
    behavior = love.graphics.newImage("assets/behavior.png")

    love.filesystem.setIdentity(love.filesystem.getIdentity(),false)

    local clickMe = u.button({
        text = 'Play',
        x = 10, y = 10,
        w = 100,
        h = 100,
    })

    local export = u.button({
        text = 'Export',
        x = 125, y = 10,
        w = 100,
        h = 100,
    })

    width = u.text({
        text = '1080',
        x = 250, y = 50,
        w = 50,
    })

    height = u.text({
        text = '720',
        x = 350, y = 50,
        w = 50,
    })
    
    clickMe:action(function(e)
        if scene == "editor" then
            setConfLua()
            e.target.text = 'playtesting...'
            playGame.load(arg, otherarg)
        end
    end)

    export:action(function(e)
        if scene == "editor" then
            setConfLua()
            e.target.text = 'exporting...'
            --love.filesystem.write('EXPORT-main.lua', playGame.secondary_main_dot_lua)
            print(playGame.secondary_main_dot_lua);
            print(playGame.secondary_conf_dot_lua);
        end
    end)
    
    u:add(clickMe)
    u:add(export)
    u:add(width)
    u:add(height)

    create:action(function(e)
        if scene == "main" then
            print("test")
            offset = 50
        end
    end)
        
    stopp:action(function(e)
        if scene == "main" then
            print("test")
            offset = -500
        end
    end)

    start:action(function(e)
        if scene == "main" then
            name_project = projectname.text
            scene = "editor"
            presence = {
                state = "Editing the project - ".. name_project,
                largeImageKey = "edit",
                smallImageKey = "hyperpsad"
            }
        end
    end)

    mainUI:add(create)
    mainUI:add(stopp)
    mainUI:add(start)
    mainUI:add(projectname)
    mainUI:add(ex) 
    mainUI:add(why)
    mainUI:add(threeDee)
    mainUI:add(engineType)
    
end

function love.update(dt) 
    ------------------------------------------------------
    if nextPresenceUpdate < love.timer.getTime() then
        discordRPC.updatePresence(presence)
        nextPresenceUpdate = love.timer.getTime() + 2.0
    end
    discordRPC.runCallbacks()
    ------------------------------------------------------
    u:update(dt)
    mainUI:update(dt)
    --camX = (camX + dt) * 1
    --cam:move(camX, camY)

	if love.mouse.isDown(3) then
		local currentX, currentY = love.mouse.getPosition()

        camX = (currentX - camXstart)*-1
        camY = (currentY - camYstart)*-1


        
        --directionY = camYstart - CurrentY

        --camX = (camX + directionX)/10
        --camY = (camY + directionY)/10

        cam:move(camX, camY)

        camXstart = currentX
        camYstart = currentY
	end	   

    --scenes--
    if scene == "main" then 

    

        create.x = ((love.graphics.getWidth() - create.w)-10)

        start.x = (love.graphics.getWidth()/2 - start.w/2) + 55
        stopp.x = (love.graphics.getWidth()/2 - stopp.w/2) - 55
        projectname.x = (love.graphics.getWidth()/2 - projectname.w/2)
        ex.x = (love.graphics.getWidth()/2 - ex.w/2)-50
        why.x = (love.graphics.getWidth()/2 - why.w/2)+50
        threeDee.x = (love.graphics.getWidth()/2 - threeDee.w/2)
        engineType.x = (love.graphics.getWidth()/2 - engineType.w/2)

        projectname.y = 150 +offset
        ex.y = 250 +offset
        why.y = 250 +offset 
        threeDee.y = 300 +offset
        engineType.y = 350 +offset
        stopp.y = 400 +offset
        start.y = 400 +offset
    end
end

function love.draw()
    love.graphics.setNewFont("font/FreeSans.ttf", 25)
    if scene == "editor" then
        cam:attach()
            love.graphics.scale(scale,scale)
            love.graphics.setColor(UI_COLOR)
            love.graphics.draw(behavior, 250, 250, 0, 0.15, 0.15)
        cam:detach()

        love.graphics.setBackgroundColor(54/255,61/255,69/255) 

        love.graphics.setColor(34/255,38/255,41/255)
        love.graphics.rectangle("fill", 0, 0, 225, love.graphics.getHeight())

        love.graphics.setColor(51/255,51/255,51/255)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 120)
        love.graphics.setColor(72/255,77/255,81/255)
        love.graphics.rectangle("fill", 0, 120, love.graphics.getWidth(), 5)
        love.graphics.setColor(1,1,1)

        u:draw()
    end

    if scene == "main" then
        love.graphics.setBackgroundColor(54/255,61/255,69/255) 

        love.graphics.setColor(51/255,51/255,51/255)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 50)
        love.graphics.setColor(72/255,77/255,81/255)
        love.graphics.rectangle("fill", 0, 50, love.graphics.getWidth(), 5)
        love.graphics.setColor(1,1,1)

        love.graphics.setColor(51/255,51/255,51/255)
        love.graphics.rectangle("fill", 0, love.graphics.getHeight() - 50, love.graphics.getWidth(), 50)
        love.graphics.setColor(72/255,77/255,81/255)
        love.graphics.rectangle("fill", 0, love.graphics.getHeight() - 50, love.graphics.getWidth(), 5)
        love.graphics.setColor(1,1,1)

        local widthBox = 450
        local heightBox = 400
        love.graphics.setColor(49/255,45/255,52/255)
        love.graphics.rectangle("fill", love.graphics.getWidth()/2 - widthBox/2, 70 + offset, widthBox, heightBox)
        love.graphics.setColor(1,1,1)

        love.graphics.setNewFont("font/FreeSans.ttf", 23)
        love.graphics.setColor(6/255,178/255,116/255)
        love.graphics.printf("Create New Project", love.graphics.getWidth()/2 - 100, 100 +offset, 200,"center")
        love.graphics.setColor(95/255,91/255,98/255)
        love.graphics.setNewFont("font/FreeSans.ttf", 18)
        love.graphics.printf("Game Resolution (Width and Height)", love.graphics.getWidth()/2 - 200, 210 +offset, 400,"center")
        love.graphics.setColor(1,1,1)

        mainUI:draw()

        love.graphics.setColor(143/255,143/255,143/255)
        love.graphics.setNewFont("font/FreeSans.ttf", 25)
        love.graphics.printf("All Projects", love.graphics.getWidth()/2 - 100, 60, 200,"center")

        local offset = 100
        local Items = 4
        love.graphics.setNewFont("font/FreeSans.ttf", 20)

        love.graphics.printf("Projects", (love.graphics.getWidth()/Items - offset), love.graphics.getHeight() - 40, 200,"center")
        love.graphics.printf("Settings", (love.graphics.getWidth()/Items - offset)*2, love.graphics.getHeight() - 40, 200,"center")
        love.graphics.printf("Packages", (love.graphics.getWidth()/Items - offset)*3, love.graphics.getHeight() - 40, 200,"center")
        love.graphics.printf("Help", (love.graphics.getWidth()/Items - offset)*4, love.graphics.getHeight() - 40, 200,"center")
    end
end

function setConfLua()
    playGame.secondary_conf_dot_lua = [[
        function love.conf(t)
            t.window.width = ]].. width.text.. 
            [[ t.window.height = ]].. height.text.. 
            [[ t.console = false
        end
    ]]
end

function love.mousepressed(x, y, button, istouch)
    if button == 3 and scene == "editor" then -- Versions prior to 0.10.0 use the MouseConstant 'l'
        camXstart = x
        camYstart = y
        print(x)
    end
    u:pressed(x, y)
    mainUI:pressed(x, y)
end

function love.wheelmoved(x, y)
    if y > 0 and scene == "editor" then
        scale = scale + y/15
    elseif y < 0 and scene == "editor" then
        scale = scale + y/15
    end
    u:wheelmoved(x, y)
    mainUI:wheelmoved(x, y)
end


--filler--
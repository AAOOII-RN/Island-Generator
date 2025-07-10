Object = require "classic"
require "hillNoise"

function love.load()
    math.randomseed(os.clock())
    ww, wh = love.window.getMode()

    hillnoise = Noise(5)

    screen = {}
    screenQuality = 128
    screenCellSize = 6

    screenZoom = 0.01
    screenColors = {
        {0.243, 0.729, 0.286},
        {1, 0.89, 0.89},
        {0, 0.761, 1},
        {0, 0.549, 1},
        {0, 0.416, 0.831}
    }
    screenMode = 0

    tx = 0
    ty = 0

    before = 0
    ticker = 0
end


function love.update(dt)
    ticker = ticker + 1
    screenZoom = math.max(screenZoom, 0.005)
    local kd = love.keyboard.isDown
    
    -- TRAVEL
    if kd("w") then
        ty = ty + 10 * dt
    elseif kd("s") then
        ty = ty - 10 * dt
    end
    
    if kd("a") then
        tx = tx + 10 * dt
    elseif kd("d") then
        tx = tx - 10 * dt
    end
    
    -- ZOOM
    if kd("u") then -- Zoom in
        screenZoom = screenZoom - 0.1 * dt
    elseif kd("i") then -- Zoom out
        screenZoom = screenZoom + 0.1 * dt
    end
    for y = 1, screenQuality do
        local noises = {}
        screen[y] = {}
        for x = 1, screenQuality do
            for i = 1, hillnoise.randoms do
                noises[i] = hillnoise:hillNoise(
                    tx-screenZoom*(x-screenQuality/2), -- Idk how either of these works...
                    ty-screenZoom*(y-screenQuality/2),
                    i
                )
            end
            noise = 0
            for n = 1, #noises do -- I used Copilot for this. Sorry, guysz.
                noise = noise + noises[n]
            end
            noise = noise / #noises
            -- 3 hill noises are enough to make a decent generation
            -- use a*b*c for singular islands
            -- but damn, (a + b + c) / 3 is so beautiful
            screen[y][x] = noise
        end
    end
    
    if screenQuality <= 1 then
        screenQuality = 1
        screenCellSize = 768
    end
    
    if ticker % 2 == 0 then -- delaying
        before = screenQuality
    end
end

function love.keypressed(k)
    if k == "space" then
        screenMode = math.fmod(screenMode + 1, 4)
    end
    if k == "o" then
        screenQuality = screenQuality / 2
        screenCellSize = screenCellSize * 2
        screenZoom = screenZoom * 2
    elseif k == "p" then
        screenQuality = screenQuality * 2
        screenCellSize = screenCellSize / 2
        screenZoom = screenZoom / 2
    end
    if screenQuality ~= before then
        for y = 1, screenQuality do
            table.remove(screen,y)
        end
    end
end

function love.draw()
    love.graphics.setBackgroundColor(0.1,0.1,0.1)
    for y, row in ipairs(screen) do
        for x, tile in ipairs(row) do
            if screenMode == 0 then
                if tile >= 0.25 then
                    love.graphics.setColor(screenColors[1]) -- Grass
                elseif tile >= 0.20 then
                    love.graphics.setColor(screenColors[2]) -- Shore
                elseif tile >= 0.17 then
                    love.graphics.setColor(screenColors[3]) -- Shallow water
                elseif tile >= 0.11 then
                    love.graphics.setColor(screenColors[4]) -- Mid-water
                else
                    love.graphics.setColor(screenColors[5]) -- Deep water
                end
            elseif screenMode == 1 then
                love.graphics.setColor(1, 1, 1, math.max(tile,0))
            elseif screenMode == 2 then
                love.graphics.setColor(0.2, 0.2, 0.3, math.abs(math.min(tile,0)))
            elseif screenMode == 3 then
                if tile > 0 then
                    love.graphics.setColor(1, 1, 1, math.max(tile,0))
                elseif tile < 0 then
                    love.graphics.setColor(0.2, 0.2, 0.3, math.abs(tile))
                end
            end

            love.graphics.rectangle("fill", (x-1) * screenCellSize, (y-1) * screenCellSize, screenCellSize, screenCellSize)
        end
    end

    love.graphics.setColor(0.9, 0.9, 0.9)
    -- Title, Credits, Pixels, Coordinates, Zoom, Quote
    love.graphics.print("Island Generator", 2*ww/3, wh/10)
    love.graphics.print("Made By AAOOII-RN and with Love", 2*ww/3, 2*wh/10)
    love.graphics.print("Quality & Tile Size: " .. screenQuality .. ", " .. screenCellSize, 2*ww/3, 3*wh/10)
    love.graphics.print("Coordinates: " .. math.floor(tx) .. ", " .. math.floor(ty), 2*ww/3, 4*wh/10)
    love.graphics.print("Zoom: " .. math.floor(screenZoom*100), 2*ww/3, 5*wh/10)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 2*ww/3, 6*wh/10)
    love.graphics.print("WASD to move, U and I to zoom, O and P to change quality, \nSPACE to change mode", 2*ww/3, 7*wh/10)
    love.graphics.print('This has a horrible flaw, I hate it.', 2*ww/3, 8*wh/10)
end

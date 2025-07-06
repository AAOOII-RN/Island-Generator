function hillNoise(x, y, n)
    math.randomseed(os.clock())
    if not do_once then
        for j = 1, randoms do
            offset[j] = {}
            amp[j] = {}
            for i = 1, 6 do
                offset[j][i] = math.random(-6000, 6000)/1000
                amp[j][i] = math.random(1500)/1000-0.75
            end
        end
        do_once = true
    end

    xv = {}
    yv = {}
    for i = 1, 6 do
        xv[math.ceil(i/2)] = x*amp[n][math.ceil(i/2)*2-1]+offset[n][math.ceil(i/2)*2-1]
        yv[math.ceil(i/2)] = y*amp[n][math.ceil(i/2)*2]+offset[n][math.ceil(i/2)*2]
    end

    return math.sin(xv[1] + yv[1] * 5^0.5/2) * math.sin(xv[2] - yv[2] * 3^0.5) * math.sin(xv[3] + yv[3] * 2^0.5)
end

function love.load()
    ww, wh = love.window.getMode()
    randoms = 3
    offset = {}
    amp = {}
    do_once = false

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
        screen[y] = {}
        for x = 1, screenQuality do
            local a = hillNoise(
                tx-screenZoom*(x-screenQuality/2), -- Idk how either of these works...
                ty-screenZoom*(y-screenQuality/2),
                1
            )
            local b = hillNoise(
                tx-screenZoom*(x-screenQuality/2),
                ty-screenZoom*(y-screenQuality/2),
                2
            )
            local c = hillNoise(
                tx-screenZoom*(x-screenQuality/2),
                ty-screenZoom*(y-screenQuality/2),
                3
            )
            
            noise =  (a + b + c) / 3
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
    love.graphics.print("WASD to move, U and I to zoom, O and P to change quality", 2*ww/3, 7*wh/10)
    love.graphics.print('"You may encounter an obvious pattern.\nRestart the program if you hate it"', 2*ww/3, 8*wh/10)
end

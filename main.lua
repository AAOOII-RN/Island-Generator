function hillNoise(x, y, n)
    math.randomseed(os.clock())
    if not do_once then
        for j = 1, randoms do
            offset[j] = {}
            amp[j] = {}
            for i = 1, 6 do
                offset[j][i] = math.random(-6000, 6000)/1000
                amp[j][i] = math.random(750)/1000+0.25
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
    randoms = 2
    offset = {}
    amp = {}
    do_once = false

    screen = {}
    screen.quality = 1
    screen.cellSize = 768

    screen.range = 0.01
    screen.colors = {
        {0.243, 0.729, 0.286},
        {1, 0.89, 0.89},
        {0, 0.761, 1},
        {0, 0.549, 1},
        {0, 0.416, 0.831}
    }

    tx = 0
    ty = 0
end


function love.update(dt)
    screen.range = math.max(screen.range, 0.005)
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
    if kd("q") then -- Zoom out
        screen.range = screen.range + 0.1 * dt
    elseif kd("e") then -- Zoom in
        screen.range = screen.range - 0.1 * dt
    end

    for y = 1, screen.quality do
        screen[y] = {}
        for x = 1, screen.quality do
            local a = hillNoise(
                tx-screen.range*(x-screen.quality/2), -- Idk how either of these works...
                ty-screen.range*(y-screen.quality/2),
                1
            )
            local b = hillNoise(
                tx-screen.range*(x-screen.quality/2),
                ty-screen.range*(y-screen.quality/2),
                2
            )

            noise =  a * b
            screen[y][x] = noise
        end
    end

    if screen.quality <= 1 then
        screen.quality = 1
        screen.cellSize = 768
    end
end

function love.keypressed(k)
    if k == "r" then
        screen.quality = screen.quality / 2
        screen.cellSize = screen.cellSize * 2
    elseif k == "t" then
        screen.quality = screen.quality * 2
        screen.cellSize = screen.cellSize / 2
    end
end

function love.draw()
    love.graphics.setBackgroundColor(0.1,0.1,0.1)
    for y, row in ipairs(screen) do
        for x, tile in ipairs(row) do
            if tile >= 0.25 then
                love.graphics.setColor(screen.colors[1])
            elseif tile >= 0.2 then
                love.graphics.setColor(screen.colors[2])
            elseif tile >= 0.125 then
                love.graphics.setColor(screen.colors[3])
            elseif tile >= 0.025 then
                love.graphics.setColor(screen.colors[4])
            else
                love.graphics.setColor(screen.colors[5])
            end

            love.graphics.rectangle("fill", x * screen.cellSize, y * screen.cellSize, screen.cellSize, screen.cellSize)
        end
    end

    love.graphics.setColor(0.9, 0.9, 0.9)
    -- Title, Credits, Pixels, Coordinates, Zoom, Quote
    love.graphics.print("Island Generator", 2*ww/3, wh/10)
    love.graphics.print("Made By AAOOII-RN and with Love", 2*ww/3, 2*wh/10)
    love.graphics.print("Quality & Tile Size: " .. screen.quality .. ", " .. screen.cellSize, 2*ww/3, 3*wh/10)
    love.graphics.print("Coordinates: " .. math.floor(tx) .. ", " .. math.floor(ty), 2*ww/3, 4*wh/10)
    love.graphics.print("Zoom: " .. math.floor(screen.range*100), 2*ww/3, 5*wh/10)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 2*ww/3, 6*wh/10)
    love.graphics.print("WASD to move, Q and E to zoom, R and T to change quality", 2*ww/3, 7*wh/10)
    love.graphics.print('"You may encounter an obvious pattern.\nRestart the program if you hate it"', 2*ww/3, 8*wh/10)
end

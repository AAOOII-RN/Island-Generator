--[[
Todo:
Optimize the generator
]]
function hillNoise(x, y, n)
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

    return math.sin((x*amp[n][1]+offset[n][1] + y*amp[n][2]+offset[n][2])*5^0.5/2) * math.sin((x*amp[n][3]+offset[n][3] - y*amp[n][4]+offset[n][4])*3^0.5) * math.sin((x*amp[n][5]+offset[n][5] + y*amp[n][6]+offset[n][6])*2^0.5)
end

function love.load()
    randoms = 2
    offset = {}
    amp = {}
    do_once = false

    screen = {}
    screen.quality = 6
    screen.cellSize = 7

    screen.range = 0.05

    tx = 0
    ty = 0
end


function love.update(dt)
    local kd = love.keyboard.isDown
    if kd("w") then
        ty = ty + 100 * dt
    elseif kd("s") then
        ty = ty - 100 * dt
    end

    if kd("a") then
        tx = tx + 100 * dt
    elseif kd("d") then
        tx = tx - 100 * dt
    end

    for y = 1, 2^screen.quality do
        screen[y] = {}
        for x = 1, 2^screen.quality do
            screen[y][x] = hillNoise((x-tx)*screen.range, (y-ty)*screen.range, 1) * hillNoise((x-tx)*screen.range, (y-ty)*screen.range, 2)
        end
    end
end

function love.draw()
    love.graphics.setBackgroundColor(0.9,0.9,0.9)
    for y, row in ipairs(screen) do
        for x, tile in ipairs(row) do
            love.graphics.setColor(0.1,0.1,0.1, math.max(tile, 0))
            love.graphics.rectangle("fill", x * screen.cellSize, y * screen.cellSize, screen.cellSize, screen.cellSize)
        end
    end

    love.graphics.setColor(1,1,1,1)
end

--[[
Todo:
Optimize the generator
]]

function love.load()
    randoms = 1
    offset = {}
    amp = {}
    do_once = false

    t = 0
end

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

function love.update(dt)
    t = t + 1 * dt
end

function love.draw()
    
end

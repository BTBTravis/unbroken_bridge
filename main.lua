function gray(num)
    return { num/255, num/255, num/255 }
end

colors = {
    black = {0, 0, 0, 1},
    gray1 = gray(85),
    gray2 = gray(155),
    gray3 = gray(180),
    white = {1, 1, 1, 1},
    dev_blue = {0, 0, 1, 1},
}

scaleMutiplier = 4

function loadImage(path)
    img = love.graphics.newImage(path)
    img:setFilter('nearest', 'nearest')
    return img
end

function resetColor()
    love.graphics.setColor(1, 1, 1)
end

function drawGrid()
    love.graphics.setColor(colors.dev_blue)
    for x = 1, 4 do  -- The range includes both ends.
        love.graphics.line(x * 32 * scaleMutiplier, 0, x * 32 * scaleMutiplier, 160 * scaleMutiplier)
        for y = 1, 3 do  -- The range includes both ends.
            love.graphics.line(0, y * 36 * scaleMutiplier, 160 * scaleMutiplier, y * 36 * scaleMutiplier)
        end
    end
    resetColor()
end




-- globals
worldOffset = { x = 0, y = 0}
tileRandomGen = love.math.newRandomGenerator()
track = {}

-- love callbacks
function love.load()
    love.window.setMode(160 * scaleMutiplier, 144 * scaleMutiplier) -- gameboy screen size
    dock_with_pole = loadImage("art/dock_piece_small.png")
    dock_blank = loadImage("art/dock_piece_small_blank.png")


    -- gen track
    for i = 0, 300 do  -- The range includes both ends.
	r = tileRandomGen:random(1,2)
        if r == 1 then
            table.insert(track, {sprite = dock_with_pole, x = 32 * i, y = 36})
        else
            table.insert(track, {sprite = dock_blank, x = 32 * i, y = 36})
        end
    end
end


function love.draw()
    -- love.graphics.setBackgroundColor({0.5, 0.5, 0.5, 1})
    --love.graphics.print('Hello World! Fuck you', 400, 300)
    -- draw stuff at scale 1, like dev stuff
    drawGrid()
    -- setup
    love.graphics.scale(4)
    love.graphics.translate(worldOffset.x, worldOffset.y)
    love.graphics.setBackgroundColor(colors.gray2)

    -- drack track
    for i = 1, #track do  -- #v is the size of v for lists.
        love.graphics.draw(track[i].sprite, track[i].x, track[i].y)
    end


end

function love.update(dt)
  worldOffset.x = worldOffset.x - 30 * dt
end

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

function loadWater()
    wavesSprite = love.graphics.newImage("art/waves.png")
    wavesSprite:setFilter('nearest', 'nearest')
    local width = wavesSprite:getWidth()
    local height = wavesSprite:getHeight()
    wavesFrames = {}
    local frame_width = 32
    local frame_height = 36

    for i = 0, 32 do
        table.insert(wavesFrames, love.graphics.newQuad(i * frame_width, 0, frame_width, frame_height, width, height))
    end
end

function drawWater()
    for x = 0, 4 do
        for y = 0, 3 do
            love.graphics.draw(wavesSprite, wavesFrames[math.floor(waterFrame)], x * 32 - worldOffset.x, y * 36)
        end
    end
end


-- globals
worldOffset = { x = 0, y = 0}
tileRandomGen = love.math.newRandomGenerator(2)
track = {}

-- love callbacks
function love.load()
    love.window.setMode(160 * scaleMutiplier, 144 * scaleMutiplier) -- gameboy screen size
    dock_with_pole_img = loadImage("art/dock_piece_small.png")
    dock_blank_img = loadImage("art/dock_piece_small_blank.png")
    dock_up_img = loadImage("art/dock_piece_up.png")
    dock_down_img = loadImage("art/dock_piece_down.png")

    dock_with_pole = { sp = dock_with_pole_img, changeY = 0, changeX = 1, offsetY = 1 }
    dock_blank = { sp = dock_blank_img, changeY = 0, changeX = 1, offsetY = 1 }
    dock_up = { sp = dock_up_img, changeY = 1, changeX = 3, offsetY = 2 }
    dock_down = { sp = dock_down_img, changeY = 1, changeX = 3, offsetY = 2 }

    -- gen track
    local trackLvl = 2
    local trackEndX = 0

    function insertWithPole()
        table.insert(track, {segment = dock_with_pole, x = trackEndX, y = trackLvl * 36})
        trackEndX = trackEndX + 32
    end

    function insertBlank()
        table.insert(track, {segment = dock_blank, x = trackEndX, y = trackLvl * 36})
        trackEndX = trackEndX + 32
    end

    function insertUp()
        if trackLvl >= 1 then
            table.insert(track, {segment = dock_up, x = trackEndX, y = trackLvl * 36 - 36})
            trackEndX = trackEndX + (32 * 3)
            trackLvl = trackLvl - 1
        end
    end

    function insertDown()
        if trackLvl <= 2 then
            table.insert(track, {segment = dock_down, x = trackEndX, y = trackLvl * 36})
            trackEndX = trackEndX + (32 * 3)
            trackLvl = trackLvl + 1
        end
    end


    local count = 0
    repeat
        local r = tileRandomGen:random(0,100)
        local r1 = tileRandomGen:random(1,2)

        if r <= 15 then
            if r1 == 1 then
                insertDown()
                insertDown()
            else
                insertUp()
                insertUp()
            end
        elseif r > 15 and r <= 80 then
            if r1 == 1 then
                insertWithPole()
            else
                insertBlank()
            end
        else
            if r1 == 1 then
                insertDown()
            else
                insertUp()
            end
        end
        count = count + 1
    until count > 300

    -- water animation
    loadWater()

    -- init globals
    waterFrame = 1
end


function love.draw()
    -- draw stuff at scale 1, like dev stuff
    --drawGrid()
    -- setup
    love.graphics.scale(4)
    love.graphics.translate(worldOffset.x, worldOffset.y)
    love.graphics.setBackgroundColor(colors.gray2)

    -- draw water
    drawWater()

    -- drack track
    for i = 1, #track do  -- #v is the size of v for lists.
        love.graphics.draw(track[i].segment.sp, track[i].x, track[i].y)
    end
end

speed = 50
function love.update(dt)
    worldOffset.x = worldOffset.x - speed * dt

    -- handle water animation
    waterFrame = waterFrame + dt + 0.25
    if waterFrame >= 32 then
	waterFrame = 1
    end
end


-- Mandelbrot set renderer by Yu Chen Hou

-- screenshot feature please
-- arrow to pan, scroll to zoo

function love.load()
	font = love.graphics.newFont(16)
	love.graphics.setFont(font)

	--boolean to indicate if we should redraw
	invalidated = true
	--boolean to show the welcome page
	start = false
	max_iter = 32
	--panning speed
	speed = 1
	--x,y value of the cursor at the center of the screen
	x = 0
	y = 0
	--Window size to define the bounds later
	window_width = love.graphics.getWidth()
	window_height = love.graphics.getHeight()
	scale = window_width / ((2 + 3))
	
	palette = {}
	for i=0,max_iter do
	r = math.floor(i / max_iter * 1024)
	if r > 255 then
		r = 255
	end
	g = math.floor((i - max_iter / 3) / max_iter * 1024)
	if g > 255 then
		g = 255
	end
	if g < 0 then
		g = 0
	end
	b = math.floor((i - max_iter / 3 * 2) / max_iter * 1024)
	if b > 255 then
		b = 255
	end
	if b < 0 then
		b = 0
	end
	palette[i] = {R = r, G = g, B = b}
	end
end

function love.update(dt)
	if love.keyboard.isDown("return") or love.keyboard.isDown("kpenter") then
		start = true
	end
   if love.keyboard.isDown("right") then
      x = x + (speed * dt)
   elseif love.keyboard.isDown("left") then
      x = x - (speed * dt)
   end

   if love.keyboard.isDown("down") then
      y = y + (speed * dt)
   elseif love.keyboard.isDown("up") then
      y = y - (speed * dt)
   end
end

--handles panning
function love.keyreleased(key, unicode)
	if key == 'left' or key == 'right' or key == 'up' or key == 'down' then
		invalidated=true
	 end
end

--zoom
function love.mousereleased(x, y, button)
   if button == 'wd' then
      scale = scale/2
	  invalidated=true
   end
   if button == 'wu' then
      scale = scale*2
	  invalidated=true
   end
end



function love.draw()
	if start == false then
	local welcome = "Mandelbrot set explorer\nby Yu Chen Hou\n\npress ENTER to start"
	love.graphics.print(welcome, window_width/2 - font:getWidth(welcome)/2, window_height/2)
	else
	
	
	if invalidated then
		image = love.graphics.newImage(draw_mandelbrot(x,y,scale))
		invalidated = false
	end
	if image then
		love.graphics.draw(image,x,y)
	else
		love.graphics.print("Loading", window_width/2, window_height/2)
	end
	love.graphics.print("x: "..x .. " , y: " .. y .. ", scale: "..scale, 0, 0)
	end
end

function draw_mandelbrot(centerx,centery,scale)
	local image = love.image.newImageData(window_width, window_height)
	local iy=0
	local ix=0
	
	--could be useful
	xmin = centerx - 3
	xmax = centerx + 2
	ymin = centery - 1.75
	ymax = centery + 2
	
	while iy<window_height do
		ix=0
		while ix<window_width do
			i = num_iter(ix/scale+xmin, iy/scale+ymin);
			--print( "At " .. ix .. " , " .. iy .. ": " .. i)
			p = palette[i]
			image:setPixel(ix, iy, p.R, p.G, p.B, 255)
			ix = ix+1
		end
		iy = iy+1
	end
	return image
end

function num_iter(cx,cy)
	local x=0.0
	local y=0.0
	max = 0
	while max < max_iter and x*x + y*y <=4 do
		t=2*x*y
		x= x*x - y*y +cx
		y= t + cy
		max = max+1
	end
	
	return max
end
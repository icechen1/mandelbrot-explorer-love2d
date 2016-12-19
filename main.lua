-- Mandelbrot set renderer by Yu Chen Hou

-- screenshot feature please
-- rendering should be done in another thread
-- arrow to pan, scroll to zoo

ch_image = love.thread.getChannel("image")
ch_progress = love.thread.getChannel("progress")

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
end

function love.update(dt)
	if invalidated and start and gen_thread == nil then
		gen_thread = love.thread.newThread("render.lua")
		gen_thread:start()
		local msg = {
			window_width = window_width,
			window_height = window_height,
			x = x,
			y = y,
			scale = scale,
			max_iter = max_iter,
		}
		local ch = love.thread.getChannel("config")
		ch:push(msg)
		invalidated = false
	end
	
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
   if gen_thread then
		err_msg = gen_thread:getError()
		if err_msg then
			print (err_msg)
		end
		imagedata = ch_image:pop()
		progress = ch_progress:peek()
		if imagedata then
			image = love.graphics.newImage(imagedata)
			--Clean out the thread to reuse later
			gen_thread = nil
			collectgarbage()
		else
		end
	end
end

--handles panning
function love.keyreleased(key, unicode)
	if key == 'left' or key == 'right' or key == 'up' or key == 'down' then
		invalidated=true
	 end
end

--zoom
function love.mousereleased(mx, my, button)
   if button == 1 then
      scale = scale/2
	  --x = mx/window_width
	  --y = my/window_height
	  invalidated=true
   end
   if button == 2 then
      scale = scale*2
	  --x = mx/window_width
	  --y = my/window_height
	  invalidated=true
   end
end



function love.draw()
	if start == false then
	local welcome = "Mandelbrot set explorer\nby Yu Chen Hou\n\npress ENTER to start"
	love.graphics.print(welcome, window_width/2 - font:getWidth(welcome)/2, window_height/2)
	else
	
	if image then
		love.graphics.draw(image,x,y)
	elseif progress then
		love.graphics.print("Loading: " .. progress .. "%", window_width/2, window_height/2)
	end
	love.graphics.print("x: "..x .. " , y: " .. y .. ", scale: "..scale, 0, 0)
	end
end

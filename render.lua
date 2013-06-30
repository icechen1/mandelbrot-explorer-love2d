--Thread to do all the rendering
require 'love.image'
local this_thread = love.thread.getThread()

local window_width = this_thread:demand("window_width")
local window_height = this_thread:demand("window_height")
local x = this_thread:demand("x")
local y = this_thread:demand("y")
local scale = this_thread:demand("scale")
local max_iter = this_thread:demand("max_iter")

--Generates a palette to define the colors used for the iteration values
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
		progress = math.floor(100/(window_height-1)*(iy+1))
		print (progress)
		this_thread:set("progress", progress)
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

local image = draw_mandelbrot(x,y,scale)
this_thread:set("image", image)
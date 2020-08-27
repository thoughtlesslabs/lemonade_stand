pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- lemonade stand
-- a thoughtless labs experiment

function _init()
	cls()
	mode="start"
	lemons=0
	sugar=0
	cups=0
	menu={"lemons","sugar","cups"}
	selector=0
end

function _update60()
	if mode=="start" then
		updatestart()
	elseif mode=="game" then
		updategame()
	elseif mode=="gameover" then
		updategameover()
	end
end

function _draw()
	if mode=="start" then
		drawstart()	
	elseif mode=="game" then
		drawgame()
	elseif mode=="gameover" then
		drawgameover()
	end
end

function updatestart()
	if btnp(5) then
		mode="game"
	end
end

function drawstart()
	cls(10)
	fillp(0b1010010000000001.1)
	rectfill(0,0,128,128,9)
	print("lemonade stand",38,20,7)
	print("press ❎ to start",35,88,7)
end

function updategame()
	debug=selector
	if btnp(2) then
		if selector<#menu then
			selector+=1
		end
	end
	if btnp(3) then
		if selector>0 then
			selector-=1
		end
	end
	if btnp(4) then
	end
end

function drawgame()
	cls(10)
	fillp()
	
	-- print debug
	print(debug,10,125,8)
	
	-- player inventory
	rectfill(10,10,60,100,7)
	print("lemons: "..lemons,15,15,0)
	print("sugar: "..sugar,15,25,0)
	print("cups: "..cups,15,35,0)

	-- store
	local sx,sy
	sx=70
	sy=10
	rectfill(sx,sy,sx+45,sy+90,7)
	print("➡️")
	print("lemons: "..lemons,sx+5,sy+5,0)
	print("sugar: "..sugar,sx+5,sy+15,0)
	print("cups: "..cups,sx+5,sy+25,0)	
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

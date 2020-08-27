pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- lemonade stand
-- a thoughtless labs experiment

function _init()
	cls()
	mode="start"
	itm={lemons="lemons",sugar="sugar",cups="cups"}
	menu={itm[1],itm[2],itm[3]}
	selector=0
	money=1000
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
		if selector==0 then
			purchase(20,lemons)
		end
	end
end

function drawgame()
	cls(10)
	fillp()
	debug=itm.lemons
	-- print debug
	print(debug,10,120,8)
--	
--	-- player inventory
--	local ix,iy
--	ix=10
--	iy=10
--	rectfill(ix,iy,ix+50,iy+90,7)
--	print("lemons: "..itm[1],ix+5,iy+5,0)
--	print("sugar: "..itm[2],ix+5,iy+15,0)
--	print("cups: "..itm[3],ix+5,iy+25,0)
--	print("money: "..money,ix+5,iy+80,0)
--
--	-- store
--	local sx,sy
--	sx=70
--	sy=10
--	rectfill(sx,sy,sx+45,sy+90,7)
----	print("➡️")
--	print("lemons: "..itm[1],sx+5,sy+5,0)
--	print("sugar: "..itm[2],sx+5,sy+15,0)
--	print("cups: "..itm[3],sx+5,sy+25,0)	
end

function purchase(cost,item)
	if money>cost then
		money=money-cost
--		item+=1
--		item.inventory+=1
	end
end

		
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

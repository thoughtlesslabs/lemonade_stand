pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- lemonade stand
-- a thoughtless labs experiment

function _init()
	cls()
	mode="start"
	selector=1
	recipeselector=1
	activemenu=1
	money=1000
	selx=65
	sely=22
	initinventory()
end

function _update60()
	if mode=="start" then
		updatestart()
	elseif mode=="game" then
		updategame()
	elseif mode=="balance" then
		updatebalance()
	elseif mode=="gameover" then
		updategameover()
	end
end

function _draw()
	if mode=="start" then
		drawstart()	
	elseif mode=="game" then
		drawgame()
	elseif mode=="balance" then	
		drawbalance()
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
	if activemenu==1 then
		if btnp(2) then
			if selector>1 then
				selector-=1
				sely-=10
			end
		end
		if btnp(3) then
			if selector<#inventory then
				selector+=1
				sely+=10
			end
		end
		if btnp(5) then
			purchase(selector)
		end	
	elseif activemenu==2 then
		local make=inventory[recipeselector]
		if btnp(0) then
			if make.recipe>0 then
				make.owned+=1
				make.recipe-=1
		end
	end
		if btnp(1) then
			if make.owned>0 then
				make.owned-=1
				make.recipe+=1
			end		
		end
		if btnp(2) then
			if recipeselector>1 then
				recipeselector-=1
			end
		end
		if btnp(3) then
			if recipeselector<#inventory then
				recipeselector+=1
			end			
		end
		if btnp(5) then

		end
	end
	-- change menu
	if btnp(4) then
		switchmenu()
	end
end

function drawgame()
	cls(10)
	fillp()
	print(_item,80,100,8)
	print(_price,80,110,8)
	print(selector,80,80,8)
	print(activemenu,80,120,8)
	
	-- menu selection indicator
	rect(menux,menuy)
	
	-- player inventory
	local ix,iy,funds
	funds=" "..money
	ix=10
	iy=10
	rectfill(ix,iy,ix+50,iy+60,7)
	print("inventory",ix+5,iy+5,0)
	print("lEMONS: ",ix+5,iy+15,0)
	print("sUGAR: ",ix+5,iy+25,0)
	print("cUPS: ",ix+5,iy+35,0)
	print("$ ",ix+5,iy+50,0)
	print(funds,(ix+5)-(#funds*4-40),iy+50,0)
		-- print current inventory
	for i=1,#inventory do
		current=" "..inventory[i].owned
		print(current,(ix+5)-(#current*4-40),iy+5+10*i,0)
	end
	
	-- store
	local sx,sy
	sx=65
	sy=10
	rectfill(sx,sy,sx+50,sy+60,7)
	print("store",sx+5,sy+5,0)
	print("lEMONS: ",sx+5,sy+15,0)
	print("sUGAR: ",sx+5,sy+25,0)
	print("cUPS: ",sx+5,sy+35,0)	
	print("❎ to buy",sx+5,sy+50,9)	
	
	-- print store prices
	for i=1,#inventory do
		price=" "..inventory[i].cost
		print(price,(sx+5)-(#price*4-40),sy+5+10*i,0)
	end
	
	-- store selector
	rect(selx,sely,selx+50,sely+10,8)

	-- recipe creator
	local rx,ry
	rx=10
	ry=80
	rectfill(rx,ry,rx+80,ry+50,7)
	print("recipe",rx+5,ry+5,0)
	print("lEMONS: ",rx+5,ry+15,0)
	print("sUGAR: ",rx+5,ry+25,0)
	print("cUPS: ",rx+5,ry+35,0)


		-- print current recipe
	for i=1,#inventory do
		rec=" "..inventory[i].recipe
		print("⬅️",rx+40,ry+5+10*i,0)
		print(rec,(rx+18)-(#rec*4-40),ry+5+10*i,0)
		print("➡️",rx+60,ry+5+10*i,0)
	end
	
	--weather forecast

end

function purchase(item)	
	choice=inventory[item]
	if money>=choice.cost then
		money-=choice.cost
		choice.owned+=1
	end
end

function switchmenu()
	if activemenu==1 then
		activemenu=2
	elseif activemenu==2 then
		activemenu=1
	end
end

function initinventory()
	inventory=
	{
		{name="lemons"
		,avail=100
		,owned=0
		,cost=50
		,recipe=0
		},
		{name="sugar"
		,avail=100
		,owned=0
		,cost=10
		,recipe=0
		},
		{name="cups"
		,avail=100
		,owned=0
		,cost=20
		,recipe=0
		}
	}	
end	
		
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

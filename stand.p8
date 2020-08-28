pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- lemonade stand
-- a thoughtless labs experiment

function _init()
	cls()
	debug=""
	mode="start"
	selector=1
	recipeselector=1
	activemenu=2
	money=1000
	levelstart=false
	sx=70
	sy=5
	ix=5
	iy=5
	rx=5
	ry=75
	wx=85
	wy=75
	selx=sx
	sely=sy+11
	c=0
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
		levelstart=true
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
	if levelstart then
		weather()
		switchmenu()
	end
	if activemenu==1 then
		if btnp(2) then
			if selector>1 then
				selector-=1
				sely-=8
			end
		end
		if btnp(3) then
			if selector<#inventory then
				selector+=1
				sely+=8
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
	print(debug)
	print(_item,80,100,8)
	print(_price,80,110,8)
	print(selector,80,80,8)
	print(activemenu,80,120,8)
	
	-- menu selection indicator
	rectfill(menux,menuy,menudx,menudy,2)

	-- player inventory
	local funds=" "..money
	rectfill(ix,iy,ix+50,iy+60,7)
	print("inventory",ix+5,iy+5,0)
	print("lEMONS: ",ix+5,iy+13,0)
	print("sUGAR: ",ix+5,iy+21,0)
	print("cUPS: ",ix+5,iy+29,0)
	print("$ ",ix+5,iy+50,0)
	print(funds,(ix+5)-(#funds*4-40),iy+50,0)
		-- print current inventory
	for i=1,#inventory do
		current=" "..inventory[i].owned
		print(current,(ix+5)-(#current*4-40),iy+5+8*i,0)
	end
	
	-- store
	rectfill(sx,sy,sx+50,sy+60,7)
	print("store",sx+5,sy+5,0)
	print("lEMONS: ",sx+5,sy+13,0)
	print("sUGAR: ",sx+5,sy+21,0)
	print("cUPS: ",sx+5,sy+29,0)	
	print("❎ to buy",sx+5,sy+50,9)	
	
	-- print store prices
	for i=1,#inventory do
		price=" "..inventory[i].cost
		print(price,(sx+5)-(#price*4-40),sy+5+8*i,0)
	end
	
	-- store selector
	rect(selx,sely,selx+50,sely+8,8)

	-- recipe creator
	rectfill(rx,ry,rx+74,ry+45,7)
	print("recipe",rx+5,ry+5,0)
	print("lEMONS: ",rx+5,ry+13,0)
	print("sUGAR: ",rx+5,ry+21,0)
	print("cUPS: ",rx+5,ry+29,0)

		-- print current recipe
	for i=1,#inventory do
		if recipeselector==i then
			col=9
		else
			col=0
		end
		
		rec=" "..inventory[i].recipe
		print("⬅️",rx+40,ry+5+8*i,col)
		print(rec,(rx+18)-(#rec*4-40),ry+5+8*i,col)
		print("➡️",rx+60,ry+5+8*i,col)
	end
	
	--weather forecast
	rectfill(wx,wy,wx+35,wy+45,7)
	print("weather",wx+5,ry+5,0)
	spr(wspr,wx+10,wy+15,2,2)	
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
		menux=rx-3
		menuy=ry-3
		menudx=rx+77
		menudy=ry+48
	elseif activemenu==2 then
		activemenu=1
		menux=sx-3
		menuy=sy-3
		menudx=sx+53
		menudy=sy+63	
	end
end

function weather()
		wspr=flr(rnd(8)+1/2)
		levelstart=false
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
cccccccccccccccccccccccccccccccccccccccccccccccc11111111111111111111111111111111000000000000000000000000000000000000000000000000
ccccccccccccccccccccc999999cccccccccc999999ccccc11111777111111111111177711111111000000000000000000000000000000000000000000000000
cccccccccccccccccccc99999999cccccccc99999999cccc11117777711777111111777771177711000000000000000000000000000000000000000000000000
ccccccccccccccccccc9999999999cccccc9999999999ccc11777777777777711177777777777771000000000000000000000000000000000000000000000000
cccccccccccccccccc999999999999cccc999999999999cc77777777777766777777777777776677000000000000000000000000000000000000000000000000
ccccccccccccccccc99999999999999cc99999999999999c76676677666666677667667766666667000000000000000000000000000000000000000000000000
ccccccccccccccccc99999999999999cc99999999999999c66666666666666616666666666666661000000000000000000000000000000000000000000000000
ccccccccccccccccc99999999999999cc99999999999999c16666666666666111666666666666611000000000000000000000000000000000000000000000000
ccccccccccccccccc99999999999999cc99999977799999c11666661666111111166666966611111000000000000000000000000000000000000000000000000
ccccccccccccccccc99999999999999cc99999777779977711111111111161111111119991116111000000000000000000000000000000000000000000000000
ccccccccccccccccc99999999999999cc99977777777777711161111111116111116111199111611000000000000000000000000000000000000000000000000
cccccccccccccccccc999999999999cccc7777777777776611116111111111611111611119111161000000000000000000000000000000000000000000000000
ccccccccccccccccccc9999999999ccccc7667667766666611111611161111111111161199911111000000000000000000000000000000000000000000000000
cccccccccccccccccccc99999999cccccc6666666666666611111111116111111111111911911111000000000000000000000000000000000000000000000000
ccccccccccccccccccccc999999cccccccc666666666666611111111111611111111119111961111000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccc66666c666ccc11111111111161111111119111196111000000000000000000000000000000000000000000000000

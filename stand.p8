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
	sx=65
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
	people={}
end

function _update60()
	if mode=="start" then
		updatestart()
	elseif mode=="game" then
		updategame()
	elseif mode=="day" then
		updateday()
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
	elseif mode=="day" then
		drawday()
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
		levelstart=false
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
		
		-- start day
		if btnp(5) then
			mode="day"
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
	rectfill(sx,sy,sx+53,sy+60,7)
	-- store selector
	rectfill(selx,sely,selx+53,sely+8,9)
	-- store list
	print("store",sx+5,sy+5,0)
	print("lEMONS: ",sx+5,sy+13,0)
	print("sUGAR: ",sx+5,sy+21,0)
	print("cUPS: ",sx+5,sy+29,0)	
	print("❎ to buy",sx+9,sy+50,9)	
	
	-- print store prices
	for i=1,#inventory do
		price=" "..inventory[i].cost
		print("$ ",sx+35,sy+5+8*i,0)
		print(price,(sx+10)-(#price*4-40),sy+5+8*i,0)
	end
	
	-- recipe creator
	rectfill(rx,ry,rx+74,ry+45,7)
	print("recipe",rx+5,ry+5,0)
	print("lEMONS: ",rx+5,ry+13,0)
	print("sUGAR: ",rx+5,ry+21,0)
	print("❎ to start day",rx+6,ry+38,9)

		-- print current recipe
	for i=1,#inventory-1 do
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

function updateday()
 updatepeople()
 -- set number of people
 -- set chance of purchase
	-- use recipe to determine
	-- the number of cups avail
	-- check if cup avail 
	-- if cups avail then sell
	-- day ends when cups=0
	if btnp(5) then
		inventory[3].owned=0
	end
	
	if #people==0 then
		mode="game"
		levelstart=true
	end
end

function drawday()
 -- need screen for running calcs
	cls()
	drawpeople()
	debug=#people
	print(debug,10,10,8)
end

function updatebalance()
end

function drawbalance()
end


-- purchase based on item
function purchase(item)	
	choice=inventory[item]
	if money>=choice.cost then
		money-=choice.cost
		choice.owned+=1
	end
end

-- switch active menu
function switchmenu()
	if activemenu==1 then
		activemenu=2
		-- move active menu box
		menux=rx-3
		menuy=ry-3
		menudx=rx+77
		menudy=ry+48
	elseif activemenu==2 then
		activemenu=1
		-- move active menu box
		menux=sx-3
		menuy=sy-3
		menudx=sx+56
		menudy=sy+63	
	end
end

-- weather randomizer
function weather()
	-- show forecast sprite
	chooseweather=flr(rnd(9)/2)*2
	wspr=chooseweather
		
	if weather==0 then
		customers=20+rnd(10)
		spawnperson(customers)
	elseif weather==2 then
	elseif weather==4 then
	elseif weather==6 then
	elseif weather==8 then
	end
	-- set number of people
	-- set chance of purchase
end

-- add inventory
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
		,cost=5
		,recipe=0
		}
	}	
end	
		
-->8
-- people generator

function addpeople(_x,_dx)
	p={}
	p.x=_x
	p.y=90
	p.dx=_dx
	add(people,p)
end

function spawnperson(ppl)
	for i=1,ppl do
		local direction=flr(rnd(2)+1)
		local pdx=rnd()+0.2
		if direction==1 then
			pdx=-pdx
		end
		addpeople(rnd(100),pdx)
	end
end

function updatepeople()
	local _p
	for i=#people,1,-1 do
		_p=people[i]
		if _p.x<0 or _p.x>128 then
			del(people,_p)
		else	
		_p.x+=_p.dx
		end
	end
end

function drawpeople()
	for i=1,#people do
	 _p = people[i]
		print("🐱",_p.x,_p.y,8)
	end
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

pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- lemonade stand
-- a thoughtless labs experiment

function _init()
	cls()
	recipevar=0
	pricevar=0
	selloption=0
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
	initinventory()
	people={}
	customers=0
	weathername="none"
	drinks=0
	drinkprice=0
	option="buy"
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
		switchmenu()
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
		levelstart=false
	end
	if activemenu==1 then
		if btnp(0) then
			option="buy"
		end
		if btnp(1) then
			option="sell"
		end
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
			if recipeselector==3 then
				if drinkprice>0 then
				drinkprice-=5
				else
				drinkprice=95
				end
			else
			if make.recipe>0 then
				make.recipe-=1
			else
				make.recipe=99
			end
		end
	end
		if btnp(1) then
			if recipeselector==3 then
				if drinkprice<94 then
				drinkprice+=5
				else
				drinkprice=0
				end
			else
			if make.recipe<99 then
				make.recipe+=1
			else
				make.recipe=0
			end
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
			startday=true
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
	
	if activemenu==1 then
	end
	-- player inventory
	local funds=" "..money
	rectfill(ix,iy,ix+50,iy+60,7)
	print("inventory",ix+5,iy+5,0)
	print("lEMONS: ",ix+5,iy+13,0)
	print("sUGAR: ",ix+5,iy+21,0)
	print("cUPS: ",ix+5,iy+29,0)
	print("money ",ix+5,iy+42,0)
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
	print("❎ confirm",sx+9,sy+50,9)	
	
	-- print buy or sell option
	local bs=" "..option
	print("⬅️",sx+10,sy+40,0)
	print("➡️",sx+36,sy+40,0)
	print(bs,58+((sx/2)-(#bs*2)),sy+40,0)
	
	-- print store prices
	for i=1,#inventory do
		local expense=" "..inventory[i].cost
		print("$ ",sx+35,sy+5+8*i,0)
		print(expense,(sx+10)-(#expense*4-40),sy+5+8*i,0)
	end
	
	-- recipe creator
	rectfill(rx,ry,rx+74,ry+45,7)
	print("recipe",rx+5,ry+5,0)
	print("lEMONS: ",rx+5,ry+13,0)
	print("sUGAR: ",rx+5,ry+21,0)
	print("pRICE: ",rx+5,ry+29,0)
	print("❎ to start day",rx+6,ry+38,9)

		-- print current recipe
	for i=1,#inventory do
		if recipeselector==i then
			col=9
		else
			col=0
		end
		local rec=" "..inventory[i].recipe
		local prc=" "..drinkprice
		print("⬅️",rx+40,ry+5+8*i,col)
		print("➡️",rx+60,ry+5+8*i,col)
		if i<3 then
		print(rec,(rx+18)-(#rec*4-40),ry+5+8*i,col)
		else
		print(prc,(rx+18)-(#prc*4-40),ry+5+8*i,col)
		end
	end
	
	--weather forecast
	rectfill(wx,wy,wx+35,wy+45,7)
	print("weather",wx+5,ry+5,0)
	spr(wspr,wx+10,wy+15,2,2)	
	local wn
	wn=weathername
	print(wn,62+((wx/2)-(#wn*2)),wy+35,0)
end

function updateday()
 -- set number of people
 -- set chance of purchase
	-- use recipe to determine
	-- the number of cups avail
	-- check if cup avail 
	-- if cups avail then sell
	-- day ends when customers=0
	
	-- make drinks for selling
	lem=inventory[1]
	sug=inventory[2]
	cps=inventory[3]
	
	recipe={lem.recipe,sug.recipe}
	
	if lem.recipe>0 and sug.recipe>0 then
	if (lem.owned-lem.recipe)>=0
	and (sug.owned-sug.recipe)>=0
	and (cps.owned-1)>=0
	then
		lem.owned=lem.owned-lem.recipe
		sug.owned=sug.owned-sug.recipe
		cps.owned=cps.owned-1
		drinks+=1
	end
	end
	
	-- sell drinks for cash
	for i=1,#people do
		local _ppls=people[i]
	
		if drinkprice > 70 then
			pricevar=-0.2
		elseif drinkprice > 50 then
			pricevar=-0.1
		elseif drinkprice > 30 then
			pricevar=0
		elseif drinkprice >15 then
			pricevar=0.1
		elseif drinkprice >=5 then
			pricevar=0.15
		elseif drinkprice==0 then
			pricevar=0.5
		end
		
		if recipe[1]>recipe[2] then
			recipevar=0.15
		elseif recipe[1]==recipe[2] then
			recipevar=0.1
		elseif recipe[1]==recipe[2] then
			recipevar=0.05
		end
		
		selloption=1-weatherchance-pricevar-recipevar
		if _ppls.x>128 or _ppls.x<0 then	
			if _ppls.checked then
				_ppls.visible=false
			else
				_ppls.checked=true
				if _ppls.chance>selloption then
					if drinks>0 then
						drinks-=1
						money+=drinkprice
					end
				end
			end
		end
	end		

	updatepeople()
	if #people==0 then
		resetgame()
	end
end

function drawday()
 -- need screen for running calcs
	cls()
	drawpeople()
	print("pricevar: "..pricevar,10,10,8)
	print("recipevar: "..recipevar,10,18,8)
	print("drinkprice: "..drinkprice,10,26,8)
	print("weather: "..weatherchance,10,34,8)
	print("selloption: "..selloption,10,42,8)
	for i=1,#people do
		print(people[i].chance,80,5+6*i,8)
	end
	for i=1,drinks do
		spr(10,10,10+9*i)
	end
end

function updatebalance()
end

function drawbalance()
end


-- purchase based on item
function purchase(item)	
	choice=inventory[item]
	if option=="buy" then
		if money>=choice.cost then
			money-=choice.cost
			choice.owned+=1
		end
	elseif option=="sell" then
		if choice.owned>0 then
			money+=choice.cost
			choice.owned-=1
		end
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
		
	if chooseweather==0 then
		customers=10
		weathername="clear"
		weatherchance=0.2
	elseif chooseweather==2 then
		customers=10
		weathername="sunny"
		weatherchance=0.25
	elseif chooseweather==4 then
		customers=10	
		weathername="cloudy"
		weatherchance=0.15
	elseif chooseweather==6 then
		customers=10
		weathername="rainy"	
		weatherchance=0.10
	elseif chooseweather==8 then
		customers=10
		weathername="stormy"	
		weatherchance=0.05
	end
	spawnperson(customers)
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

function resetgame()
	levelstart=true
	switchmenu()
	mode="game"
	drinks=0
	for i=1,#people do
		del(people,i)
	end
	gamecountdown=400
end
-->8
-- people generator

function addpeople(_x,_dx,_pchance)
	p={}
	p.x=_x
	p.y=90
	p.dx=_dx
	p.chance=_pchance
	p.checked=false
	p.visible=true
	add(people,p)
end

function spawnperson(ppl)
	for i=1,ppl do
		local direction=flr(rnd(2)+1)
		local pdx=rnd()+0.25
		local _pc=mid(0,(flr(rnd(1*100))/100),1)
		if direction==1 then
			pdx=-pdx
		end
		addpeople(40+rnd(20),pdx,_pc)
	end
end

function updatepeople()
	local _p
	for i=#people,1,-1 do
		_p=people[i]
		if not(_p.visible) then
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
ccccccccccccccccccccc999999cccccccccc999999ccccc11111777111111111111177711111111066666600000000000000000000000000000000000000000
cccccccccccccccccccc99999999cccccccc99999999cccc111177777117771111117777711777116aaaaaa60000000000000000000000000000000000000000
ccccccccccccccccccc9999999999cccccc9999999999ccc11777777777777711177777777777771066666600000000000000000000000000000000000000000
cccccccccccccccccc999999999999cccc999999999999cc77777777777766777777777777776677067777600000000000000000000000000000000000000000
ccccccccccccccccc99999999999999cc99999999999999c76676677666666677667667766666667006776000000000000000000000000000000000000000000
ccccccccccccccccc99999999999999cc99999999999999c66666666666666616666666666666661006776000000000000000000000000000000000000000000
ccccccccccccccccc99999999999999cc99999999999999c16666666666666111666666666666611000660000000000000000000000000000000000000000000
ccccccccccccccccc99999999999999cc99999977799999c11666661666111111166666966611111000000000000000000000000000000000000000000000000
ccccccccccccccccc99999999999999cc99999777779977711111111111161111111119991116111000000000000000000000000000000000000000000000000
ccccccccccccccccc99999999999999cc99977777777777711161111111116111116111199111611000000000000000000000000000000000000000000000000
cccccccccccccccccc999999999999cccc7777777777776611116111111111611111611119111161000000000000000000000000000000000000000000000000
ccccccccccccccccccc9999999999ccccc7667667766666611111611161111111111161199911111000000000000000000000000000000000000000000000000
cccccccccccccccccccc99999999cccccc6666666666666611111111116111111111111911911111000000000000000000000000000000000000000000000000
ccccccccccccccccccccc999999cccccccc666666666666611111111111611111111119111961111000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccc66666c666ccc11111111111161111111119111196111000000000000000000000000000000000000000000000000

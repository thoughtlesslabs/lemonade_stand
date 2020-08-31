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
	drinksold=0
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
	fillp(0b1010010100000001.1)
	rectfill(0,0,128,128,15)
	spr(32,15,20,13,5)
	print("press ❎ to start",30,88,9)
end

function updategame()
	if levelstart then
		weather()
		levelstart=false
	end
	if activemenu==1 then
		if btnp(0) or btnp(1) then
			if option=="buy" then
				option="sell"
			elseif option=="sell" then	
				option="buy"
			end
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
			makedrinks()
			sellalgo()
			moneystart=money
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
	
	-- sell drinks for cash
	for i=1,#people do
		local _ppls=people[i]
		if flr(_ppls.x)>50 and flr(_ppls.x)<55 then	
			if _ppls.checked then
				_ppls.visible=false
			else
				_ppls.checked=true
				if _ppls.chance>selloption then
					if drinks>0 then
						drinks-=1
						drinksold+=1
						money+=drinkprice
					end
				end
			end
		end
	end		

	updatepeople()
	if #people==0 then
		mode="balance"
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
	if btnp(5) then
		mode="game"
		levelstart=true
		switchmenu()
		drinks=0
	end
end

function drawbalance()
	rectfill(0,30,128,90,8)
	print("drinks made: "..drinksmade,5,35,7)
	print("drinks sold: "..drinksold,5,45,7)
	print("money earned: "..money-moneystart,5,55,7)
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
	local randppl=flr(rnd(5))
	chooseweather=flr(rnd(9)/2)*2
	wspr=chooseweather
		
	if chooseweather==0 then
		customers=15+randppl
		weathername="clear"
		weatherchance=0.2
	elseif chooseweather==2 then
		customers=20+randppl
		weathername="sunny"
		weatherchance=0.25
	elseif chooseweather==4 then
		customers=10+randppl
		weathername="cloudy"
		weatherchance=0.15
	elseif chooseweather==6 then
		customers=8+randppl
		weathername="rainy"	
		weatherchance=0.10
	elseif chooseweather==8 then
		customers=2+randppl
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
	for i=1,#people do
		del(people,i)
	end
end

function makedrinks()
	-- make drinks for selling
	lem=inventory[1]
	sug=inventory[2]
	cps=inventory[3]
	
	recipe={lem.recipe,sug.recipe}
	for i=1,cps.owned do
		if lem.recipe>0 and sug.recipe>0 then
			if (lem.owned-lem.recipe)>=0
			and (sug.owned-sug.recipe)>=0
			then
				lem.owned=lem.owned-lem.recipe
				sug.owned=sug.owned-sug.recipe
				cps.owned=cps.owned-1
				drinks+=1
			end
		end
	end
	drinksmade=drinks
end

function sellalgo()
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
	elseif recipe[1]<recipe[2] then			recipevar=0.1
		recipevar=-0.1
	elseif recipe[1]==recipe[2] then
		recipevar=0.05
	end
		
	selloption=1-weatherchance-pricevar-recipevar
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
		local pdx=rnd()+0.45
		local _pc=mid(0,(flr(rnd(1*100))/100),1)
		if direction==1 then
			pdx=-pdx
			_startx=128+5+flr(rnd(30))
		else
			_startx=0-5-flr(rnd(30))
		end
		addpeople(_startx,pdx,_pc)
	end
end

function updatepeople()
	local _p
	for i=#people,1,-1 do
		_p=people[i]
		if _p.x>175 or _p.x<-40 then
		if not(_p.visible) then
				del(people,_p)
			end
		else	
		_p.x+=_p.dx
		end
	end
end

function drawpeople()
	for i=1,#people do
	 _p = people[i]
		spr(11,_p.x,_p.y,2,2)
	end
end
-->8
-- to do list

-- adjust algo
-- create balance sheet page
--			- overview of day
--			- money earned
--			- product wasted
-- 		- give customer feedback
--     on recipe ie too sweet
-- intro story
-- logo

-- future
-- add in levels
-- stand upgrades
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
00000007777700000000000000000000000000000000000000000000000000000000000000000000007777700000000000000000000000000000000000000000
00000077777770000000000000000000000000000000000000000000000000000000000000000000077777770000000000000000000000000000000000000000
00000777999777000000000000000000000000000000000000000000000000000000000000000000777999770000000000000000000000000000000000000000
00000779999977000000000000000000000000000000000000000000000000000000000000000007779997770000000000000000000000000000000000000000
00007779979977000000000000000000000000000000000000000000000000000000000000000007799997700000000000000000000000000000000000000000
00007799979777000000000000000000000000000000000000000000000000000000000000000007799977700000000000000000000000000000000000000000
00077799779770000000000000000000000000000000000000000000000000000000000000000077799977000000000000000000000000000000000000000000
00077999799770777700077777777777777077777777770007777777770000007777777700007777999977077777000000000000000000000000000000000000
00077999797777777770777777777777777777999999777077777777777000777777777770777777999777777777700000000000000000000000000000000000
007779977977777997777799977997799977799aaaa9977777999779977707777997999777777997999777779997770000000000000000000000000000000000
00779997977779999977779999999999999799aa7aaa997777999799997777799999999777799999999777999999777000000000000000000000000000000000
00779997977799979997779999799997999997aaaaaa799779997979997777999779997777999779997779997799977000000000000000000000000000000000
077799797779997799977999977999779999aa7aa7a7aa9979999779997779999779997779999779997779997799977770000000000000000000000000000000
07799999779999779997799977999977999aaaa7aa7a7aa979999779997779997799997779997799997799977799777777000000000000000000000000000000
07799997779997799977799977999779999a7aaaa7aaaaa979997799997799997799997799997799977799977999779977000000000000000000000000000000
07799977779997999777999977999779999aaa7a77aa7aa999997799977799977799977799977799977999979997779977000000000000000000000000000000
77799977799999997777999777999779999aaaa7aa7aaaa999977799977799977799977799977799977999999977799777000000000000000000000000000000
779999777999997777799997799977999979aa7aaaa7aa9999977799977799977999977999977999977999977777799770000000000000000000000000000000
77999777999997777799999779997799977997a7aaaa799999977999777999977999777999977999777999777779997770000000000000000000000000000000
77999779999997779997999779997799977999aaa7aa997799777999779999979999779999979999779999977794444400000000000000000000000000000000
779999997799999999799977999977999999799aaaa9977999777999999799999799999799999799995555555554444400000000000000000000000000000000
77799997777999997779997779977779999777999999777999777799997799997799997799555544444444444444555500000000000000000000000000000000
07777777777777777777777777777777777777777777777777777777777777777444444444444444444444444555444440000000000000000000000000000000
00777777007777777077777077770077777777777770007777700777555555555444444444444444477777744444444440000000000000000000000000000000
00000000000000000000000000000000000000000000000055555555544444444447444477444447474444477444444440000000000000000000000000000000
00000000000000000000000000000000000000000005555554444444444444777447744474744447447444444744444440000000000000000000000000000000
00000000000000000000000000000000000000000004444444474444447777444447474447474447447444444474444455000000000000000000000000000000
00000000000000000000000000000000000000000004444444747747774744455474474447447444747444455447455544000000000000000000000000000000
00000000000000000000000000000000000000000000444447444474444745544474447444744744744745544447444444000000000000000000000000000000
00000000000000000000000000000000000000000000445557444444454474444474477744744474744744444474444444000000000000000000000000000000
00000000000000000000000000000000000000000000554447444444444474444477744474744447744744444474444544000000000000000000000000000000
00000000000000000000000000000000000000000000444444777774444474444474445574474444774474444744444444400000000000000000000000000000
00000000000000000000000000000000000000000000044444444447444474444744554447474444474477777444444444500000000000000000000000000000
00000000000000000000000000000000000000000000044444444447444557444744444444444454444444444444444555500000000000000000000000000000
00000000000000000000000000000000000000000000044444744474455447444744444444444444444444445555500000000000000000000000000000000000
00000000000000000000000000000000000000000000054454477744444444444444444444444455555555550000000000000000000000000000000000000000
00000000000000000000000000000000000000000000054444444444444444554444445550000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000005444444455544555550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000005544455500000000000000000000000000000000000000000000000000000000000000000000000000

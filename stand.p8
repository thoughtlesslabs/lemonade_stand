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
	money=100
	levelstart=false
	sx=62
	sy=5
	ix=5
	iy=5
	rx=5
	ry=70
	wx=85
	wy=70
	selx=sx
	sely=sy+11
	initinventory()
	people={}
	sale={}
	customers=0
	weathername="none"
	drinks=0
	drinkprice=0
	drinksold=0
	option="buy"
	spawnperson(20,0)
	profit=0
	daynum=0
	rcom="test"
	pcom="test2"
end

function _update60()
	if mode=="start" then
		updatestart()
	elseif mode=="game" then
		updategame()
	elseif mode=="confirm" then
		updateconfirm()
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
	elseif mode=="confirm" then
		drawconfirm()
	elseif mode=="day" then
		drawday()
	elseif mode=="balance" then	
		drawbalance()
	elseif mode=="gameover" then
		drawgameover()
	end
end

function updatestart()
	updatepeople()
			
	if btnp(5) then
		mode="game"
		levelstart=true
		switchmenu()
		for i=#people,1,-1 do
			del(people,people[i])
		end
	end
end

function drawstart()
	cls(10)
	fillp(0b1010010100000001.1)
	rectfill(0,0,128,128,15)
	spr(32,15,20,13,5)
	print("press ❎ to start",30,78,9)
	drawpeople()
	print(debug,10,10,8)
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
					drinkprice-=2
				else
					drinkprice=10
				end
			else
			if make.recipe>0 then
				make.recipe-=1
			else
				make.recipe=10
			end
		end
	end
		if btnp(1) then
			if recipeselector==3 then
				if drinkprice<9 then
					drinkprice+=2
				else
					drinkprice=0
				end
			else
			if make.recipe<10 then
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
			mode="confirm"
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
		col1=5
		col2=6
		col1h=0
		col2h=6
		colbtn1=9
		colbtn2=15
	elseif activemenu==2 then
		col2=5
		col1=6
		col2h=0
		col1h=6
		colbtn1=15
		colbtn2=9
	end
	-- player inventory
	local funds=" "..money
	rectfill(ix,iy,ix+50,iy+60,7)
	print("inventory",ix+5,iy+5,0)
	print("lEMONS: ",ix+5,iy+13,5)
	print("sUGAR: ",ix+5,iy+21,5)
	print("cUPS: ",ix+5,iy+29,5)
	print("money ",ix+5,iy+42,0)
	print("$ ",ix+5,iy+50,5)
	print(funds,(ix+5)-(#funds*4-40),iy+50,5)
		-- print current inventory
	for i=1,#inventory do
		current=" "..inventory[i].owned
		print(current,(ix+5)-(#current*4-40),iy+5+8*i,5)
	end
	
	-- store
	rectfill(sx,sy,sx+58,sy+60,7)
	-- store selector
	rectfill(selx,sely,selx+58,sely+8,colbtn1)
	-- store list
	print("store",sx+5,sy+5,col1h)
	print("10XlEMONS",sx+5,sy+13,col1)
	print(" 5XsUGAR",sx+5,sy+21,col1)
	print(" 1XcUPS",sx+5,sy+29,col1)	
	print("❎ confirm",sx+9,sy+50,colbtn1)	
	
	-- print buy or sell option
	local bs=" "..option
	print("⬅️",sx+12,sy+40,col1)
	print("➡️",sx+38,sy+40,col1)
	print(bs,58+((sx/2)-(#bs*2)),sy+40,col1)
	
	-- print store prices
	for i=1,#inventory do
		local expense=" "..inventory[i].cost
		print("$ ",sx+46,sy+5+8*i,col1)
		print(expense,(sx+15)-(#expense*4-40),sy+5+8*i,col1)
	end
	
	-- recipe creator
	rectfill(rx,ry,rx+74,ry+45,7)
	print("recipe",rx+5,ry+5,col2h)
	print("lEMONS: ",rx+5,ry+13,col2)
	print("sUGAR: ",rx+5,ry+21,col2)
	print("pRICE: ",rx+5,ry+29,col2)
	print("❎ to start day",rx+6,ry+38,colbtn2)

		-- print current recipe
	for i=1,#inventory do
		if activemenu==2 then
			if recipeselector==i then
				col=9
			else
				col=col2
			end
		else
			if recipeselector==i then
				col=15
			else
				col=col2
			end
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
		
		print("🅾️ to switch menu",30,120,0)
	end
	
	--weather forecast
	rectfill(wx,wy,wx+35,wy+45,7)
	print("weather",wx+5,ry+5,0)
	spr(wspr,wx+10,wy+15,2,2)	
	local wn
	wn=weathername
	print(wn,62+((wx/2)-(#wn*2)),wy+35,5)
end

function updateconfirm()
	if btnp(5) then
		mode="day"
		startday=true
		makedrinks()
		sellalgo()
		moneystart=money
	end
	if btnp(4) then
		mode="game"
	end
end

function drawconfirm()
	local cx=20 cy=40
	rectfill(cx,cy,cy+70,cy+42,9)
	print("are you ready\nto hit the streets?",cx+5,cy+5,7)
	print("❎ start day",cx+5,cy+25,7)
	print("🅾️ go back",cx+5,cy+33,7)
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
				if (_ppls.chance+weathervar)>selloption then
					if drinks>0 then
						drinks-=1
						spawnsale(_ppls.x,_ppls.y)
						drinksold+=1
						money+=drinkprice
					end
				end
			end
		end
	end		

	updatepeople()
	updatesale()
	if #people==0 then
		daynum+=1
		mode="balance"
	end
	
	if btnp(4) then
		for i=1,#people do
			local _ppls=people[i]
			if _ppls.checked then
				_ppls.visible=false
			else
				_ppls.checked=true
				if (_ppls.chance+weathervar)>selloption then
					if drinks>0 then
						drinks-=1
						spawnsale(_ppls.x,_ppls.y)
						drinksold+=1
						money+=drinkprice
					end
				end
			end
		end
		daynum+=1
		mode="balance"
	end
end

function drawday()
 -- need screen for running calcs
	cls()
	-- show drinks on screen
	for i=1,drinks do
		spr(10,5+flr((i-1)/8)*9,((i-1)%8)*8)
	end
--	for i=1,#people do
--	print("p: "..people[i].chance,100,6*i,8)
--	end
	print("pricevar: "..pricevar,40,10,8)
--	print("drink price: "..drinkprice,40,18,8)
--	print("recipevar: "..recipevar,40,26,8)
--	print("rvar: "..rvar,40,34,8)
--	print("weathervar: "..weathervar,40,42,8)
--	print("weathervar: "..weathervar,40,50,8)
--	print("selloption: "..selloption,40,58,8)
	drawpeople()
	drawsale()
end

function updatebalance()
	helpfulhint()
	profit=money-moneystart
	if profit>0 then
		profitcol=3
	else
		profitcol=5
	end
	if btnp(5) then
		mode="game"
		levelstart=true
		switchmenu()
		resetgame()
	end
	if money<=0 then
		mode="gameover"
	end
end

function drawbalance()
 local _x=25 _y=15
 local dm=" "..drinksmade
 local ds=" "..drinksold
	rectfill(_x,_y,_x+80,_y+95,7)
	print("-- day "..daynum.." sales --",_x+7,_y+5,9)
	print("dRINKS MADE: ",_x+10,_y+16,5)
	print("dRINKS SOLD: ",_x+10,_y+24,5)
	print("pROFIT: ",_x+10,_y+40,5)
	print("$",_x+54,_y+40,5)
	print(dm,(_x+29)-(#dm*4-40),_y+16,5)
	print(ds,(_x+29)-(#ds*4-40),_y+24,5)
	line(_x+7,_y+33,_x+72,_y+33,6)
	local pro=" "..profit
	print(pro,(_x+29)-(#pro*4-40),_y+40,profitcol)
	print("cOMMENTS:",_x+7,_y+55,5)
	print(rcom.."\n\n"..pcom,_x+10,_y+63,5)
end

function updategameover()
end

function drawgameover()
end


-- purchase based on item
function purchase(item)	
	choice=inventory[item]
	if option=="buy" then
		if money>=choice.cost then
			money-=choice.cost
			if item==1 then
				choice.owned+=10
			elseif item==2 then
				choice.owned+=5
			else
				choice.owned+=1
			end
		end
	elseif option=="sell" then
		if choice.owned>0 then
			money+=choice.cost
			if item==1 then
				choice.owned-=10
			elseif item==2 then
				choice.owned-=5
			else
				choice.owned-=1
			end
		end
	end
end

-- switch active menu
function switchmenu()
	if activemenu==1 then
		activemenu=2
		-- move active menu box
		menux=rx-2
		menuy=ry-2
		menudx=rx+76
		menudy=ry+47
	elseif activemenu==2 then
		activemenu=1
		-- move active menu box
		menux=sx-2
		menuy=sy-2
		menudx=sx+60
		menudy=sy+62	
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
		weathervar=4
	elseif chooseweather==2 then
		customers=20+randppl
		weathername="sunny"
		weathervar=5
	elseif chooseweather==4 then
		customers=10+randppl
		weathername="cloudy"
		weathervar=3
	elseif chooseweather==6 then
		customers=8+randppl
		weathername="rainy"	
		weathervar=2
	elseif chooseweather==8 then
		customers=2+randppl
		weathername="stormy"	
		weathervar=1
	end
	spawnperson(customers)
end

-- add inventory
function initinventory()
	inventory=
	{
		{name="lemons"
		,owned=0
		,cost=3
		,recipe=0
		},
		{name="sugar"
		,owned=0
		,cost=1
		,recipe=0
		},
		{name="cups"
		,owned=0
		,cost=2
		,recipe=0
		}
	}	
end

function resetgame()
	for i=1,#people do
		del(people,i)
	end
	drinksold=0
	drinks=0
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
	-- weather times drinkprice
	pricevar=weathervar*drinkprice
	
	-- recipe gets a score
	if flr(recipe[1]/recipe[2])==3 then
		rvar=1
	elseif flr(recipe[1]/recipe[2])==2 then
		rvar=3
	elseif flr(recipe[1]/recipe[2])==1 then
		rvar=5
	elseif flr(recipe[1]/recipe[2])<1 and flr(recipe[1]/recipe[2])>0 then
		rvar=7
	else
		rvar=10
	end
	
	--recipe score times weather
	recipevar=weathervar*rvar
	
	--set sell option
	selloption=100-pricevar-recipevar
end

function helpfulhint()
	if rvar==1 then
		rcom="- dELICIOUS!"
	elseif rvar==3 then
		rcom="- a LITTLE SWEET"
	elseif rvar==5 then
		rcom="- nOT SOUR ENOUGH"
	elseif rvar==7 then
		rcom="- wAY TOO SWEET"
	else
		rcom="- wHERE WERE THE\nDRINKS?"
	end
	
	if pricevar>=20 then
		pcom="- lITTLE EXPENSIVE"
	elseif pricevar>10 then
		pcom="- pERFECTLY PRICED"
	elseif pricevar > 0 then
		pcom="- i'D PAY MORE"
	else
		if rvar==10 then
			pcom=" "
		else
			pcom="- I LOVE FREEBIES"
		end
	end
end
-->8
-- people generator

function addpeople(_x,_dx,_pchance,_spdelay,_spref,_lpref,_ppref)
	p={}
	p.x=_x
	p.y=90
	p.dx=_dx
	p.chance=_pchance
	p.sugpref=_spref
	p.lemonpref=_lpref
	p.pricepref=_ppref
	p.checked=false
	p.visible=true
	p.sdelay=_spdelay
	add(people,p)
end

function spawnperson(ppl,wc)
	for i=1,ppl do
		local direction=flr(rnd(2)+1)
		local pdx=mid(0.25,rnd()-0.45,1)
		local _pc=mid(0,(flr(rnd(100))),100)
		local _sc=mid(0,(flr(rnd(100))),100)
		local _lc=mid(0,(flr(rnd(100))),100)
		local _cc=mid(0,(flr(rnd(100))),100)
		if direction==1 then
			pdx=-pdx
			_startx=136
		else
			_startx=-8
		end
		addpeople(_startx,pdx,_pc,i*(30+rnd(30)),_sc,_lc,_cc)
	end
end

function updatepeople()
	local _p
	for i=#people,1,-1 do
		_p=people[i]
		_p.sdelay-=1
		if _p.x>140 or _p.x<-15 then
			if not(_p.visible) then
				del(people,_p)
			end
		else	
			if _p.sdelay<0 then
				_p.x+=_p.dx
			end
		end
	end
end

function drawpeople()
	for i=1,#people do
	 _p = people[i]
	 if _p.sdelay<0 then
		 if _p.dx>0 then
		 	direction=false
		 else
		 	direction=true
		 end
		palt(3,true)
		palt(0,false)
		spr(11,_p.x,_p.y,2,2,direction)
		palt()
		end
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
-->8
-- lemon juice

function spawnsale(_x,_y)
	sa={}
	sa.timer=40
	sa.x=_x
	sa.y=_y
	sa.v=true
	sa.dy=-1
	add(sale,sa)
end

function updatesale()
	for i=#sale,1,-1 do
		local _s=sale[i]
		_s.timer-=1
		if _s.timer>0 then
			_s.y+=_s.dy
		else
			_s.v=false
		end
	end
end		

function drawsale()
	for i=1,#sale do
		local _s=sale[i]
		if _s.v then
			if _s.timer<10 then
				pal(11,3)
			else
				pal()
			end
			print("$",_s.x,_s.y,11)
		end
	end
end

__gfx__
cccccccccccccccccccccccccccccccccccccccccccccccc11111111111111111111111111111111000000003333309090903333000000000000000000000000
ccccccccccccccccccccc999999cccccccccc999999ccccc11111777111111111111177711111111066666603333090999903333000000000000000000000000
cccccccccccccccccccc99999999cccccccc99999999cccc111177777117771111117777711777116aaaaaa63333099ffff033330000000000aaaaaaa9000000
ccccccccccccccccccc9999999999cccccc9999999999ccc1177777777777771117777777777777106666660333309ff1f10333300000000aaaaaaaa7a900000
cccccccccccccccccc999999999999cccc999999999999cc7777777777776677777777777777667706777760333309fffff03333000000aaaaaaaaaaa7a90000
ccccccccccccccccc99999999999999cc99999999999999c7667667766666667766766776666666700677600333330ff88f0333300000aaaaaaaaaaa7aaa0000
ccccccccccccccccc99999999999999cc99999999999999c66666666666666616666666666666661006776003333301fff03333300000aaaaaaaaaaaaaaa0000
ccccccccccccccccc99999999999999cc99999999999999c166666666666661116666666666666110006600033330111111033330000a9aaaaaaaaaaaaaa0000
ccccccccccccccccc99999999999999cc99999977799999c11666661666111111166666966611111000000003333011111103333000aaaaaaaaaaaaaaaaa0000
ccccccccccccccccc99999999999999cc9999977777997771111111111116111111111999111611100000000333301111f1f03330009a9a9aaaaaaaaaaa00000
ccccccccccccccccc99999999999999cc9997777777777771116111111111611111611119911161100000000333301111110033300099aaaaaaaa9aaaa000000
cccccccccccccccccc999999999999cccc77777777777766111161111111116111116111191111610000000033330551555033330009a9a9aa9aaaaaa9000000
ccccccccccccccccccc9999999999ccccc766766776666661111161116111111111116119991111100000000333305505550333300009a9a9aaa9a9a00000000
cccccccccccccccccccc99999999cccccc6666666666666611111111116111111111111911911111000000003333055005500333000099a9a9a9a90000000000
ccccccccccccccccccccc999999cccccccc66666666666661111111111161111111111911196111100000000333305550555033300000099999a000000000000
cccccccccccccccccccccccccccccccccccc66666c666ccc11111111111161111111119111196111000000003333000000000333000000000000000000000000
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

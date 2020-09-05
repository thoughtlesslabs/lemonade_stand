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
	parts={}
	customers=0
	weathername="none"
	drinks=0
	drinkprice=0
	drinksold=0
	option="buy"
	revenue=0
	daynum=0
	rcom="test"
	pcom="test2"
		--particle patterns
	parttimer=0
	partrow=0
	startpeople=true
	startparts(8)
	lighttimer=30
	_numparts=0
end

function _update60()
	updatepeople()
	updatejuice()	
	updatesale()
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
	-- raining particles
	parttimer=parttimer+1
	spawnbgparts(true,parttimer,8)
	for i=#people,1,-1 do
		if people[i].x >140 or people[i].x<-10 then
			del(people,people[i])
		end
	end
	if #people<5 then
		spawnperson(20,0)
	end
	if btnp(5) then
		mode="game"
		levelstart=true
		switchmenu()
		resetgame()
	end
end

function drawstart()
	cls(12)
	drawjuice()
	
	spr(32,15,20,13,5)
	print("press ❎ to start",31,70,7)
	print("press ❎ to start",30,70,5)
	map(0,0,0,48)
	rectfill(0,100,128,103,3)
	spr(112,45,78,3,4)

	drawpeople()
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
				make.recipe=5
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
			if make.recipe<5 then
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
		spawnperson(customers)
		startday=true
		makedrinks()
		sellalgo()
		moneystart=money
		startparts(30)
		parttimer=0
	end
	if btnp(4) then
		mode="game"
	end
end

function drawconfirm()
	local cx=20 cy=40
	rectfill(cx-2,cy-2,cy+72,cy+44,5)
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
	lighttimer-=1
	if lighttimer<-1 then
		lighttimer=flr(180+rnd(50))
	end
	parttimer=parttimer+1
	spawnbgparts(true,parttimer,30)
--	addweather(chooseweather)
	
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
						spawnsale(_ppls.x,_ppls.y)
						drinksold+=1
						money+=drinkprice
					end
				end
			end
		end
	end		
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
				if (_ppls.chance)+(weathervar*2)>selloption then
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
	helpfulhint()
end

function drawday()
 -- need screen for running calcs
	cls(weatherbg)
	-- draw stand and road
	map(0,0,0,48)
	rectfill(0,100,128,103,3)
	palt(3,true)
	palt(0,false)
	spr(15,48,86,1,2)
	palt()
	spr(112,45,77,3,4)
	print("OPEN",49,97,6)
	
	-- show drinks on screen
	for i=1,drinks do
		spr(10,5+flr((i-1)/8)*9,((i-1)%8)*8)
	end
--	for i=1,#people do
--	print("p: "..people[i].chance,100,6*i,8)
--	end
--	print("pricevar: "..pricevar,40,30,8)
--	print("recipevar: "..recipevar,40,40,8)
--	print("selloption: "..selloption,40,58,8)
	drawpeople()
	drawsale()
	print("🅾️ to end day",40,118,7)
	print(lighttimer,10,118,7)
	drawjuice()
	if	lighttimer==0 or lighttimer==flr(rnd(20)) then
		if chooseweather==8 then
			cls(7)
		end
	end
end

function updatebalance()
	balanceactive=true
	revenue=money-moneystart
	if revenue>0 then
		revcol=3
	else
		revcol=5
	end
	if btnp(5) then
		resetgame()
		mode="game"
		levelstart=true
		switchmenu()
	end
	if money<=0 then
		mode="gameover"
	end
end

function drawbalance()
 cls(10)
 local _x=25 _y=15
 local dm=" "..drinksmade
 local ds=" "..drinksold
	rectfill(_x,_y,_x+83,_y+95,7)
	print("-- day "..daynum.." sales --",_x+7,_y+5,9)
	print("dRINKS MADE: ",_x+10,_y+16,5)
	print("dRINKS SOLD: ",_x+10,_y+24,5)
	print("rEVENUE: ",_x+10,_y+40,5)
	print("$",_x+53,_y+40,5)
	print(dm,(_x+29)-(#dm*4-40),_y+16,5)
	print(ds,(_x+29)-(#ds*4-40),_y+24,5)
	line(_x+7,_y+33,_x+72,_y+33,6)
	local rev=" "..revenue
	print(rev,(_x+29)-(#rev*4-40),_y+40,revcol)
	print("cOMMENTS:",_x+7,_y+55,5)
	print(rcom.."\n\n"..pcom,_x+10,_y+63,5)
	print("❎ to start next day",30,118,0)
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
	chooseweather=6
--	wspr=chooseweather
		
	if chooseweather==0 then
		customers=30+randppl
		weathername="clear"
		weatherbg=12
		weathervar=4
	elseif chooseweather==2 then
		customers=40+randppl
		weathername="sunny"
		weatherbg=12
		weathervar=5
	elseif chooseweather==4 then
		customers=20+randppl
		weathername="cloudy"
		weatherbg=12
		weathervar=3
	elseif chooseweather==6 then
		customers=10+randppl
		weathername="rainy"	
		weatherbg=1
		weathervar=2
	elseif chooseweather==8 then
		customers=5+randppl
		weathername="stormy"	
		weatherbg=0
		weathervar=1
	end
end

-- add inventory
function initinventory()
	inventory=
	{
		{name="lemons"
		,owned=0
		,cost=6
		,recipe=0
		},
		{name="sugar"
		,owned=0
		,cost=2
		,recipe=0
		},
		{name="cups"
		,owned=0
		,cost=3
		,recipe=0
		}
	}	
end

function resetgame()
	sale={}
	people={}
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

	
	if weathername=="sunny" or weathername=="clear" then
		if drinkprice==10 then
			pricevar=10*2
		elseif drinkprice==8 then
			pricevar=10*3
		elseif drinkprice==6 then
			pricevar=10*5
		else 
			pricevar=10*6
		end
	elseif weathername=="cloudy" then
		if drinkprice==10 then
			pricevar=6*2
		elseif drinkprice==8 then
			pricevar=8*3
		elseif drinkprice==6 then
			pricevar=10*5
		elseif drinkprice<6 then
			pricevar=10*6
		end
	elseif weathername=="rainy" then
		if drinkprice==10 then
			pricevar=4*2
		elseif drinkprice==8 then
			pricevar=6*3
		elseif drinkprice==6 then
			pricevar=8*5
		elseif drinkprice==4 then
			pricevar=8*6
		else
			pricevar=10*6	
		end
	elseif weathername=="stormy" then
		if drinkprice==10 then
			pricevar=2*2
		elseif drinkprice==8 then
			pricevar=4*3
		elseif drinkprice==6 then
			pricevar=6*5
		elseif drinkprice==4 then
			pricevar=8*6
		else
			pricevar=10*6
		end
	end
	
	-- recipe gets a score
	if flr(recipe[1]/recipe[2])==3 then
		rvar=1
	elseif flr(recipe[1]/recipe[2])==2 then
		rvar=3
	elseif flr(recipe[1]/recipe[2])==1 then
		rvar=5
	elseif flr(recipe[1]/recipe[2])<1 and flr(recipe[1]/recipe[2])>0 then
		rvar=7
	elseif flr(recipe[1]/recipe[2])>3 then
		rvar=9
	else
		rvar=10
	end
	
	--recipe score times weather
	recipevar=weathervar*rvar
	
	--set sell option
	if drinkprice==0 then
		selloption=0
	else
		selloption=100-pricevar-recipevar
	end
end

function helpfulhint()
	if drinksmade==0 then
		rcom="- wHERE WERE THE\nDRINKS?"
	elseif rvar==1 then
		rcom="- dELICIOUS!"
	elseif rvar==3 then
		rcom="- a LITTLE SWEET"
	elseif rvar==5 then
		rcom="- nOT SOUR ENOUGH"
	elseif rvar==7 then
		rcom="- wAY TOO SWEET"
	elseif rvar==9 then
		rcom="- wAY TOO SOUR"
	end
	
	if drinksmade==0 or drinksold==0 then
		pcom=" "
	elseif pricevar>=60 then
		pcom="- i'D PAY MORE"
	elseif pricevar==50 then
		pcom="- pERFECTLY PRICED"
	elseif pricevar<50 then
		pcom="- tOO EXPENSIVE"
	else
		pcom="- I LOVE FREEBIES"
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
	p.checked=false
	p.visible=true
	p.sdelay=_spdelay
	p.sprite={11,13,11,45}
	p.spchoice=1
	p.shirt={8,11,12,13}
	p.shirtcol=flr(rnd(4)+1)
	p.spritetimer=4/abs(_dx)
	add(people,p)
end

function spawnperson(ppl,wc)
	for i=1,ppl do
		local direction=flr(rnd(2)+1)
		local pdx=mid(0.25,rnd(),0.8)
		local _pc=mid(0,(flr(rnd(100))),100)
		if direction==1 then
			pdx=-pdx
			_startx=136
		else
			_startx=-8
		end
		addpeople(_startx,pdx,_pc,i*(80+rnd(30)))
	end
end

function updatepeople()
	local _p
	for i=#people,1,-1 do
		_p=people[i]
	 _p.spritetimer-=1
		_p.sdelay-=1
		if _p.x>140 or _p.x<-15 then
			if not(_p.visible) then
				del(people,_p)
			end
		else	
			if _p.spritetimer<0 then
				_p.spchoice+=1
				_p.spritetimer=4/abs(_p.dx)
				if _p.spchoice>4 then
				_p.spchoice=1
				end
			end
			
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
		pal(1,_p.shirt[_p.shirtcol])
		spr(_p.sprite[_p.spchoice],_p.x,_p.y,2,2,direction)
		pal()
		palt()
		end
	end
end
-->8
-- to do list

-- intro story
-- save functionality
-- weather during day
-- more people versions
-- phase transitions
-- player charcter at stand

-- future
-- add in levels
-- stand upgrades
-- 
-->8
-- lemon juice

function addjuice(_sprite,_x,_y,_dx,_dy,_maxage,_type)
	j={}
	j.x=_x
	j.y=_y
	j.dx=_dx
	j.dy=_dy
	j.age=0
	j.maxage=_maxage
	j.sp=_sprite
	j.tpe=_type
	add(parts,j)
end

-- generate juice
function squeeze(_x,_y)
	
end

function addweather(_wth)
	if _wth==6 then		
		for i=1,3 do
			addjuice(12,-10+rnd(170),-30,0,1+rnd(),150,0)
		end
	elseif _wth==8 then
		for i=1,10 do
			addjuice(6,-70+rnd(190),-20,1,1.5+rnd(),150,0)
		end
	elseif _wth==4 then
	for i=1,5 do
		if lighttimer<0 then
			addjuice(120,130+rnd(30),rnd(80),-0.5+rnd(0.25),0,600,2)
		end
		end
	end
end

-- move juice particles
function updatejuice()
	for i=#parts,1,-1 do
		local _juice=parts[i]
		_juice.age+=1
		if _juice.tpe==1 and mode!="start" then
				del(parts,_juice)
		end
		if _juice.age>_juice.maxage and mode!="start" then
			del(parts,_juice)
		else
		_juice.x+=_juice.dx
		_juice.y+=_juice.dy
		end
	end
end


-- add juice particles
function drawjuice()
	for i=1,#parts do
		local _juice=parts[i]
		if _juice.tpe==1 then
			spr(_juice.sp,_juice.x,_juice.y,3,2)
		elseif _juice.tpe==2 then		
			spr(_juice.sp,_juice.x,_juice.y,2,2)
		elseif _juice.tpe==0 then
			pset(_juice.x,_juice.y,_juice.sp)
		end	
	end
end

-- show dollar sign for purchase
function spawnsale(_x,_y)
	sa={}
	sa.timer=40
	sa.x=_x
	sa.y=_y
	sa.v=true
	sa.dy=-1
	add(sale,sa)
end

-- move $ sign
function updatesale()
	for i=#sale,1,-1 do
		local _s=sale[i]
		_s.timer-=1
		if _s.timer<0 then
			del(sale,_s)
		else
			if _s.timer>0 then
				_s.y+=_s.dy
			end
		end
	end
end		

-- draw $ sign
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

-- lemons on start
function startparts(number)
	for i=0,400 do
		spawnbgparts(false,i,number)
	end
end

function spawnbgparts(_top,_t,numparts)
		if _t%30==0 then
			if partrow==0 then
				partrow=1
			else
				partrow=0
			end
			for i=0,numparts do
			if mode=="start" then
				if _top then
					_y=-8
					_x=-14
				else
					_y=-8 + 0.4*_t
					_x=0
				end
			else if chooseweather==4 then
				if _top then
					_y=-10
					_x=130  
				else
					_y=-10
					_x=-40+0.4*_t
				end
			elseif chooseweather==6 then
					if _top then
						_y=-8
						_x=0
					else
						_y=-50 + 0.4*_t
						_x=0
					end
				end
			end			
				if (i+partrow)%2==0 then
					if mode=="start" then
						addjuice(117,_x+i*16-4,_y-4,0,0.5,0,1)
					elseif mode=="day" then
						if chooseweather==4 then
							addjuice(120,_x+rnd(20),_y+flr(rnd(8))*i,-0.4+rnd(0.25),0,1000,2)
						elseif chooseweather==6 then
							addjuice(6,rnd(140),_y,0,1.5+rnd(),100,0)
						end
					end
				end
			end
		end
	
end
__gfx__
cccccccccccccccccccccccccccccccccccccccccccccccc11111111111111111111111111111111000000003333333003333333333333333333333333000003
ccccccccccccccccccccc999999cccccccccc999999ccccc11111777111111111111177711111111066666603333330990333333333333300333333330044400
cccccccccccccccccccc99999999cccccccc99999999cccc111177777117771111117777711777116aaaaaa633333099f0333333333333099033333330444440
ccccccccccccccccccc9999999999cccccc9999999999ccc11777777777777711177777777777771066666603333309ff033333333333099f0333333304fff40
cccccccccccccccccc999999999999cccc999999999999cc77777777777766777777777777776677067777603333309ff03333333333309ff0333333300fff00
ccccccccccccccccc99999999999999cc99999999999999c76676677666666677667667766666667006776003333330f033333333333309ff03333333300f003
ccccccccccccccccc99999999999999cc99999999999999c666666666666666166666666666666610067760033333011103333333333330f0333333330099900
ccccccccccccccccc99999999999999cc99999999999999c16666666666666111666666666666611000660003333301110333333333330111033333330999990
ccccccccccccccccc99999999999999cc99999977799999c11666661666111111166666966611111000000003333301110333333333330111003333330999990
ccccccccccccccccc99999999999999cc999997777799777111111111111611111111199911161110000000033333011103333333333301111f0333330999990
ccccccccccccccccc99999999999999cc99977777777777711161111111116111116111199111611000000003333301f10333333333330111003333330999990
cccccccccccccccccc999999999999cccc7777777777776611116111111111611111611119111161000000003333305550333333333330f55503333330f111f0
ccccccccccccccccccc9999999999ccccc7667667766666611111611161111111111161199911111000000003333305550333333333330550550333330011100
cccccccccccccccccccc99999999cccccc6666666666666611111111116111111111111911911111000000003333305050333333333305503050333333011103
ccccccccccccccccccccc999999cccccccc666666666666611111111111611111111119111961111000000003333305555033333333305033055033330011100
cccccccccccccccccccccccccccccccccccc66666c666ccc11111111111161111111119111196111000000003333300030033333333330333300333330555550
00000007777700000000000000000000000000000000000000000000000000000000000000000000007777700000000000000000333333333333333300000000
00000077777770000000000000000000000000000000000000000000000000000000000000000000077777770000000000000000333333300333333300000000
00000777999777000000000000000000000000000000000000000000000000000000000000000000777999770000000000000000333333099033333300000000
0000077999997700000000000000000000000000000000000000000000000000000000000000000777999777000000000000000033333099f033333300000000
000077799799770000000000000000000000000000000000000000000000000000000000000000077999977000000000000000003333309ff033333300000000
000077999797770000000000000000000000000000000000000000000000000000000000000000077999777000000000000000003333309ff033333300000000
000777997797700000000000000000000000000000000000000000000000000000000000000000777999770000000000000000003333330f0333333300000000
00077999799770777700077777777777777077777777770007777777770000007777777700007777999977077777000000000000333330111033333300000000
00077999797777777770777777777777777777999999777077777777777000777777777770777777999777777777700000000000333330111003333300000000
007779977977777997777799977997799977799aaaa99777779997799777077779979997777779979997777799977700000000003333301111f0333300000000
00779997977779999977779999999999999799aa7aaa997777999799997777799999999777799999999777999999777000000000333330111003333300000000
00779997977799979997779999799997999997aaaaaa799779997979997777999779997777999779997779997799977000000000333330555503333300000000
077799797779997799977999977999779999aa7aa7a7aa9979999779997779999779997779999779997779997799977770000000333330550550333300000000
07799999779999779997799977999977999aaaa7aa7a7aa979999779997779997799997779997799997799977799777777000000333305503050333300000000
07799997779997799977799977999779999a7aaaa7aaaaa979997799997799997799997799997799977799977999779977000000333305033055033300000000
07799977779997999777999977999779999aaa7a77aa7aa999997799977799977799977799977799977999979997779977000000333330333300333300000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000666665660000000000000000000000000000000000000000100000000000000000000000000000000000000000000000
05555555555555555555555500000000666656660000000000000000000000000000077700000000100000000000000000000000000000000000000000000000
44444444444444444444444500000000666566660000000000aaaaaaa90000000000777770077700100000000000000000000000000000000000000000000000
444444444444444444444445000000006656666600000000aaaaaaaa7a9000000077777777777770100000000000000000000000000000000000000000000000
5555545555445555555544450000000065666666000000aaaaaaaaaaa7a900007777777777776677700000000000000000000000000000000000000000000000
444444444444444444444445000000005666666600000aaaaaaaaaaa7aaa00007667667766666666700000000000000000000000000000000000000000000000
555545445545554455555555000000005666666600000aaaaaaaaaaaaaaa00006666666666666660100000000000000000000000000000000000000000000000
44444444444444444444444500000000566666660000a9aaaaaaaaaaaaaa00000666666666666600100000000000000000000000000000000000000000000000
4444555554444555555544400000000055555555000aaaaaaaaaaaaaaaaa00000066666066600000100000000000000000000000000000000000000000000000
00400000000000000000040000000000555555550009a9a9aaaaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000
004000000000000000000400000000005555555500099aaaaaaaa9aaaa0000000000000000000000000000000000000000000000000000000000000000000000
00400000000000000000040000000000555555550009a9a9aa9aaaaaa90000000000000000000000000000000000000000000000000000000000000000000000
004000000000000000000400000000005555555500009a9a9aaa9a9a000000000000000000000000000000000000000000000000000000000000000000000000
0040000000000000000004000000000055555555000099a9a9a9a900000000000000000000000000000000000000000000000000000000000000000000000000
004000000000000000000400000000005555555500000099999a0000000000000000000000000000000000000000000000000000000000000000000000000000
00400000000000000000040000000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05455555555555555555545555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
54454444444444444444445455000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555444445555555554455555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555445555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55544455555555445555444555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7474747474747474747474747474747400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8484848484848484848484848484848400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8484848484848484848484848484848400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

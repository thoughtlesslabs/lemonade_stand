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
	activemenu=0
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
	rcom=" "
	pcom=" "
		--particle patterns
	parttimer=0
	partrow=0
	startpeople=true
	startparts(8)
	lighttimer=30
	_numparts=0
	gamecounter=0
	startmusic(o)
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
		resetgame()
		showstory=true
		victory=false
		loss=false
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
	spr(112,45,76,3,4)
	print("CLOSED",45,97,6)

	drawpeople()
end

function updategame()
	if levelstart then
		weather()
		levelstart=false
	end
	if showstory then
		if btnp(5) then
			stopmusic()
			startmusic(4)
			showstory=false
			switchmenu()
		end
	else
		-- change menu
		if btnp(4) then
			sfx(54)
			switchmenu()
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
			sfx(57)
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
			sfx(58)
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
	end
end

function drawgame()
	cls(10)
	if showstory then
		rectfill(20,10,108,110,7)
		if gamecounter==0 then
			print("caleb,\n\nfor your 9th\nbirthday, your mom\nand i decided it's\ntime for you to\nstart building your\nlemonade empire.\n\nhere's $100 to get\nyou going.\n\ngood luck!",25,15,5)
		elseif gamecounter>=1 then
			if victory then
				print("you did great!\n\nnow that you've put\nthat money away we\nthought you could\ntry again.\n\nhere's another $100.\n\ngood luck!",25,25,5)
			elseif loss then 
				print("back again?\n\nwell, i guess we\ncan help you out.\nhere's another $100.\nplease try not to\nspend it all right\naway.\n\ngood luck!",25,25,5)
			end
		end		
		print("❎ to start",25,100,5)
	else
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
end

function updateconfirm()
	if btnp(5) then
		sfx(55)
		if weathervar == 1 or weathervar == 2 then
			stopmusic()
			startmusic(18)
		end
		startmusic(_weatherp)
		mode="day"
		spawnperson(customers)
		startday=true
		makedrinks()
		sellalgo()
		moneystart=money
		startparts(_weatherp)	
		parttimer=0
	end
	if btnp(4) then
		mode="game"
		sfx(53)
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
	spawnbgparts(true,parttimer,spawnwetnum)
	
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
						sfx(56)
					end
				end
			end
		end
	end		
	if #people==0 then
		if money<=0 or money>=500 then
			resetgame()
			mode="gameover"
		else
			daynum+=1
			mode="balance"
			if track!=4 then
				stopmusic()
				startmusic(4)
			end
		end
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
		if money<=0 or money>=500 then
			resetgame()
			mode="gameover"
		else
			daynum+=1
			mode="balance"
			if track!=4 then
				stopmusic()
				startmusic(4)
			end
		end
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
	if fistpump then
	 fpump=47
	 fistpump=false
	else
		fpump=15
	end
	spr(fpump,48,85,1,2)
	palt()
	spr(112,45,76,3,4)
	print("OPEN",49,97,6)


 drawpeople()
	drawsale()
	print("🅾️ to end day",40,118,7)
	drawjuice()
		-- show drinks on screen
	for i=1,drinks do
		spr(10,5+flr((i-1)/8)*9,5+((i-1)%8)*8)
	end
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
	if money>=500 then
		victory=true
	elseif money<=0 then
		loss=true
	end
	
	if victory then
		parttimer=parttimer+1
		spawnbgparts(true,parttimer,8)
	end
	
	if btnp(5) then
		mode="game"
		gamecounter+=1
		levelstart=true
		resetgame()
		showstory=true
	end
end

function drawgameover()
	cls()
	if victory then
		text="congratulations!\n\nyou are the king of\nlemonade.\n\ndon't forget to pay\nback your parents."
  
	elseif loss then
		text="you're out of money!"
	end
	drawjuice()
	rectfill(20,20,108,100,7)
	local x=25 y=30
	
	print(text,x,y,5)
	print("❎ to play again",x, y+48,8)
end

-- purchase based on item
function purchase(item)	
	choice=inventory[item]
	if option=="buy" then
		sfx(58)
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
		if choice.owned>0 and choice.owned-choice.q>=0  then
			sfx(57)
			money+=choice.cost
			if item==1 then
				choice.owned-=10
			elseif item==2 then
				choice.owned-=5
			else
				choice.owned-=1
			end
		else
			sfx(62)
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
	elseif activemenu==2 or activemenu==0 then
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
		customers=30+randppl
		weathername="clear"
		weatherbg=12
		weathervar=4
		_weatherp=0
		spawnwetnum=0
	elseif chooseweather==2 then
		customers=40+randppl
		weathername="sunny"
		weatherbg=12
		weathervar=5
		_weatherp=0
		spawnwetnum=0
	elseif chooseweather==4 then
		customers=20+randppl
		weathername="cloudy"
		weatherbg=12
		weathervar=3
		_weatherp=3
		spawnwetnum=3
	elseif chooseweather==6 then
		customers=10+randppl
		weathername="rainy"	
		weatherbg=1
		weathervar=2
		_weatherp=10
		spawnwetnum=50
	elseif chooseweather==8 then
		customers=5+randppl
		weathername="stormy"	
		weatherbg=0
		weathervar=1
		_weatherp=20
		spawnwetnum=100
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
		,q=10
		},
		{name="sugar"
		,owned=0
		,cost=2
		,recipe=0
		,q=5
		},
		{name="cups"
		,owned=0
		,cost=3
		,recipe=0
		,q=1
		}
	}	
end

function resetgame()
	sale={}
	people={}
	parts={}
	drinksold=0
	drinks=0
	if victory or loss then
		money=100
		for i=1,#inventory do
			inventory[i].owned=0
		end
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

function startmusic(n)
	if (not music_playing) then
		music(n) music_playing=true
		track=n
	end
end

function stopmusic()
	music(-1) music_playing=false
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
-- more people versions
-- phase transitions

-- future
-- add in levels
-- stand upgrades
-- add check to ensure selling
-- doesn't make it less than 0
-- if it does, then set to 0
-->8
-- lemon juice

-- fader
function fade()
	fadecol={0,1,1,2,3,4,5,6,7,8}
	for i=1,15 do
		col=fadecol[i]
		pal(col)
	end

end

-- particle adder
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

-- move juice particles
function updatejuice()
	for i=#parts,1,-1 do
		local _juice=parts[i]
		_juice.age+=1
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
			line(_juice.x,_juice.y,_juice.x-1,_juice.y+4,_juice.sp)
		elseif _juice.tpe==3 then
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
				fistpump=true
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
			if mode=="start" or mode=="gameover" then
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
			elseif chooseweather==6 or chooseweather==8 then
					if _top then
						_y=-8*10
					else
						_y=-80+0.4*_t
					end
				end
			end			
				if (i+partrow)%2==0 then
					if mode=="start" or mode=="gameover" then
						addjuice(117,_x+i*16-4,_y-4,0,0.5,300,1)
					elseif mode=="day" then
						if chooseweather==4 then
							addjuice(120,_x+rnd(20),_y+flr(rnd(25))*i,-0.4+rnd(0.25),0,1000,2)
						elseif chooseweather==6 then
							addjuice(12,rnd(140),_y,0,1.5+rnd(),180,3)
						elseif chooseweather==8 then
							addjuice(6,10+rnd(200),_y,-1,1.75+rnd(),160,0)
						end
					end
				end
			end
		end
end
__gfx__
cccccccccccccccccccccccccccccccccccccccccccccccc11111111111111111111111111111111000000003333333003333333333333333333333330000033
ccccccccccccccccccccc999999cccccccccc999999ccccc11111777111111111111177711111111066666603333330990333333333333300333333300444003
cccccccccccccccccccc99999999cccccccc99999999cccc111177777117771111117777711777116aaaaaa633333099f0333333333333099033333304444403
ccccccccccccccccccc9999999999cccccc9999999999ccc11777777777777711177777777777771066666603333309ff033333333333099f033333304fff403
cccccccccccccccccc999999999999cccc999999999999cc77777777777766777777777777776677067777603333309ff03333333333309ff033333300fff003
ccccccccccccccccc99999999999999cc99999999999999c76676677666666677667667766666667006776003333330f033333333333309ff0333333300f0033
ccccccccccccccccc99999999999999cc99999999999999c666666666666666166666666666666610067760033333011103333333333330f0333333300999003
ccccccccccccccccc99999999999999cc99999999999999c16666666666666111666666666666611000660003333301110333333333330111033333309999903
ccccccccccccccccc99999999999999cc99999977799999c11666661666111111166666966611111000000003333301110333333333330111003333309999903
ccccccccccccccccc99999999999999cc999997777799777111111111111611111111199911161110000000033333011103333333333301111f0333309999903
ccccccccccccccccc99999999999999cc99977777777777711161111111116111116111199111611000000003333301f10333333333330111003333309999903
cccccccccccccccccc999999999999cccc7777777777776611116111111111611111611119111161000000003333305550333333333330f5550333330f111f03
ccccccccccccccccccc9999999999ccccc7667667766666611111611161111111111161199911111000000003333305550333333333330550550333300111003
cccccccccccccccccccc99999999cccccc6666666666666611111111116111111111111911911111000000003333305050333333333305503050333330111033
ccccccccccccccccccccc999999cccccccc666666666666611111111111611111111119111961111000000003333305555033333333305033055033300111003
cccccccccccccccccccccccccccccccccccc66666c666ccc11111111111161111111119111196111000000003333300030033333333330333300333305555503
00000007777700000000000000000000000000000000000000000000000000000000000000000000007777700000000000000000333333333333333330000033
00000077777770000000000000000000000000000000000000000000000000000000000000000000077777770000000000000000333333300333333300444003
00000777999777000000000000000000000000000000000000000000000000000000000000000000777999770000000000000000333333099033333304444403
0000077999997700000000000000000000000000000000000000000000000000000000000000000777999777000000000000000033333099f033333304fff4f3
000077799799770000000000000000000000000000000000000000000000000000000000000000077999977000000000000000003333309ff033333300fff093
000077999797770000000000000000000000000000000000000000000000000000000000000000077999777000000000000000003333309ff0333333300f0903
000777997797700000000000000000000000000000000000000000000000000000000000000000777999770000000000000000003333330f0333333300999903
00077999799770777700077777777777777077777777770007777777770000007777777700007777999977077777000000000000333330111033333309999033
00077999797777777770777777777777777777999999777077777777777000777777777770777777999777777777700000000000333330111003333309999033
007779977977777997777799977997799977799aaaa99777779997799777077779979997777779979997777799977700000000003333301111f0333309999033
00779997977779999977779999999999999799aa7aaa997777999799997777799999999777799999999777999999777000000000333330111003333309999033
00779997977799979997779999799997999997aaaaaa79977999797999777799977999777799977999777999779997700000000033333055550333330f111033
077799797779997799977999977999779999aa7aa7a7aa9979999779997779999779997779999779997779997799977770000000333330550550333300111033
07799999779999779997799977999977999aaaa7aa7a7aa979999779997779997799997779997799997799977799777777000000333305503050333330111033
07799997779997799977799977999779999a7aaaa7aaaaa979997799997799997799997799997799977799977999779977000000333305033055033300111003
07799977779997999777999977999779999aaa7a77aa7aa999997799977799977799977799977799977999979997779977000000333330333300333305555503
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
__label__
ccccccaaaaaaaa7a9cccccccccccccccccccccaaaaaaaa7a9cccccccccccccccccccccaaaaaaaa7a9cccccccccccccccccccccaaaaaaaa7a9ccccccccccccccc
ccccaaaaaaaaaaa7a9ccccccccccccccccccaaaaaaaaaaa7a9ccccccccccccccccccaaaaaaaaaaa7a9ccccccccccccccccccaaaaaaaaaaa7a9cccccccccccccc
cccaaaaaaaaaaa7aaacccccccccccccccccaaaaaaaaaaa7aaacccccccccccccccccaaaaaaaaaaa7aaacccccccccccccccccaaaaaaaaaaa7aaacccccccccccccc
cccaaaaaaaaaaaaaaacccccccccccccccccaaaaaaaaaaaaaaacccccccccccccccccaaaaaaaaaaaaaaacccccccccccccccccaaaaaaaaaaaaaaacccccccccccccc
cca9aaaaaaaaaaaaaacccccccccccccccca9aaaaaaaaaaaaaacccccccccccccccca9aaaaaaaaaaaaaacccccccccccccccca9aaaaaaaaaaaaaacccccccccccccc
caaaaaaaaaaaaaaaaacccccccccccccccaaaaaaaaaaaaaaaaacccccccccccccccaaaaaaaaaaaaaaaaacccccccccccccccaaaaaaaaaaaaaaaaacccccccccccccc
c9a9a9aaaaaaaaaaacccccccccccccccc9a9a9aaaaaaaaaaacccccccccccccccc9a9a9aaaaaaaaaaacccccccccccccccc9a9a9aaaaaaaaaaaccccccccccccccc
c99aaaaaaaa9aaaaccccccccccccccccc99aaaaaaaa9aaaaccccccccccccccccc99aaaaaaaa9aaaaccccccccccccccccc99aaaaaaaa9aaaacccccccccccccccc
c9a9a9aa9aaaaaa9ccccccccccccccccc9a9a9aa9aaaaaa9ccccccccccccccccc9a9a9aa9aaaaaa9ccccccccccccccccc9a9a9aa9aaaaaa9cccccccccccccccc
cc9a9a9aaa9a9acccccccccccccccccccc9a9a9aaa9a9acccccccccccccccccccc9a9a9aaa9a9acccccccccccccccccccc9a9a9aaa9a9acccccccccccccccccc
cc99a9a9a9a9cccccccccccccccccccccc99a9a9a9a9cccccccccccccccccccccc99a9a9a9a9cccccccccccccccccccccc99a9a9a9a9cccccccccccccccccccc
cccc99999acccccccccccccccccccccccccc99999acccccccccccccccccccccccccc99999acccccccccccccccccccccccccc99999acccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccaaaaaaa9ccccccccccccccccccccccccaaaaaaa9ccccccccccccccccccccccccaaaaaaa9ccccccccccccccccccccccccaaaaaaa9
9cccccccccccccccccccccaaaaaaaa7a9cccccccccccccccccccccaaaaaaaa7a9cccccccccccccccccccccaaaaaaaa7a9cccccccccccccccccccccaaaaaaaa7a
a9ccccccccccccccccccaaaaaaaaaaa7a9ccccccccccccccccccaaaaaaaaaaa7a9ccccccccccccccccccaaaaaaaaaaa7a9ccccccccccccccccccaaaaaaaaaaa7
aacccccccccccccccccaaaaaaaaaaa7aaacccccccccccccccccaaaaaaaaaaa7aaacccccccccccccccccaaaaaaaaaaa7aaacccccccccccccccccaaaaaaaaaaa7a
aacccccccccccccccccaaaaaaaaaaaaaaacccccccccccccccccaaaaaaaaaaaaaaacccccccccccccccccaaaaaaaaaaaaaaacccccccccccccccccaaaaaaaaaaaaa
aacccccccccccccccca9aaaaaaaaaaaaaacccccccccccccccca9aaaaaaaaaaaaaacccccccccccccccca9aaaaaaaaaaaaaacccccccccccccccca9aaaaaaaaaaaa
aacccccccccccccccaaaaa77777aaaaaaacccccccccccccccaaaaaaaaaaaaaaaaacccccccccccccccaaaaaaaaaaaaaaaa77777cccccccccccaaaaaaaaaaaaaaa
acccccccccccccccc9a9a7777777aaaaacccccccccccccccc9a9a9aaaaaaaaaaacccccccccccccccc9a9a9aaaaaaaaaa7777777cccccccccc9a9a9aaaaaaaaaa
ccccccccccccccccc99a777999777aaaccccccccccccccccc99aaaaaaaa9aaaaccccccccccccccccc99aaaaaaaa9aaa77799977cccccccccc99aaaaaaaa9aaaa
ccccccccccccccccc9a9779999977aa9ccccccccccccccccc9a9a9aa9aaaaaa9ccccccccccccccccc9a9a9aa9aaaaa777999777cccccccccc9a9a9aa9aaaaaa9
cccccccccccccccccc97779979977acccccccccccccccccccc9a9a9aaa9a9acccccccccccccccccccc9a9a9aaa9a9a77999977cccccccccccc9a9a9aaa9a9acc
cccccccccccccccccc97799979777ccccccccccccccccccccc99a9a9a9a9cccccccccccccccccccccc99a9a9a9a9cc77999777cccccccccccc99a9a9a9a9cccc
cccccccccccccccccc7779977977cccccccccccccccccccccccc99999acccccccccccccccccccccccccc99999accc77799977ccccccccccccccc99999acccccc
cccccccccccccccccc7799979977c7777ccc77777777777777c7777777777ccc777777777cccccc77777777cccc7777999977c77777ccccccccccccccccccccc
cccccccccccccccccc7799979777777777c777777777777777777999999777c77777777777ccc77777777777c7777779997777777777cccccccccccccccccccc
ccccccccaaaaaaa9c7779977977777997777799977997799977799aaaa99777779997799777a777799799977777799799977777999777aa9cccccccccccccccc
ccccccaaaaaaaa7a9779997977779999977779999999999999799aa7aaa9977779997999977777999999997777999999997779999997777a9ccccccccccccccc
ccccaaaaaaaaaaa7a779997977799979997779999799997999997aaaaaa799779997979997777999779997777999779997779997799977a7a9cccccccccccccc
cccaaaaaaaaaaa7a77799797779997799977999977999779999aa7aa7a7aa997999977999777999977999777999977999777999779997777aacccccccccccccc
cccaaaaaaaaaaaaa7799999779999779997799977999977999aaaa7aa7a7aa979999779997779997799997779997799997799977799777777acccccccccccccc
cca9aaaaaaaaaaaa7799997779997799977799977999779999a7aaaa7aaaaa979997799997799997799997799997799977799977999779977acccccccccccccc
caaaaaaaaaaaaaaa7799977779997999777999977999779999aaa7a77aa7aa999997799977799977799977799977799977999979997779977acccccccccccccc
c9a9a9aaaaaaaaa77799977799999997777999777999779999aaaa7aa7aaaa999977799977799977799977799977799977999999977799777ccccccccccccccc
c99aaaaaaaa9aaa779999777999997777799997799977999979aa7aaaa7aa999997779997779997799997799997799997799997777779977cccccccccccccccc
c9a9a9aa9aaaaaa77999777999997777799999779997799977997a7aaaa79999997799977799997799977799997799977799977777999777cccccccccccccccc
cc9a9a9aaa9a9ac77999779999997779997999779997799977999aaa7aa9977997779997799999799997799999799997799999777944444ccccccccccccccccc
cc99a9a9a9a9ccc779999997799999999799977999977999999799aaaa99779997779999997999997999997999997999955555555544444ccccccccccccccccc
cccc99999accccc777999977779999977799977799777799997779999997779997777999977999977999977995555444444444444445555ccccccccccccccccc
cccccccccccccccc777777777777777777777777777777777777777777777777777777777777777744444444444444444444444455544444cccccccccccccccc
ccccccccccccccccc777777cc7777777c77777c7777cc7777777777777ccc77777cc77755555555544444444444444447777774444444444cccccccccccccccc
ccccccccccccccccccccccccaaaaaaa9ccccccccccccccccccccccccaaaaaaa5555555554444444444744447744444747444447744444444ccccccccaaaaaaa9
9cccccccccccccccccccccaaaaaaaa7a9cccccccccccccccccccccaaaa555555444444444444477744774447474444744744444474444444ccccccaaaaaaaa7a
a9ccccccccccccccccccaaaaaaaaaaa7a9ccccccccccccccccccaaaaaa4444444474444447777444447474447474447447444444474444455cccaaaaaaaaaaa7
aacccccccccccccccccaaaaaaaaaaa7aaacccccccccccccccccaaaaaaa4444444747747774744455474474447447444747444455447455544ccaaaaaaaaaaa7a
aacccccccccccccccccaaaaaaaaaaaaaaacccccccccccccccccaaaaaaaa444447444474444745544474447444744744744745544447444444ccaaaaaaaaaaaaa
aacccccccccccccccca9aaaaaaaaaaaaaacccccccccccccccca9aaaaaaa445557444444454474444474477744744474744744444474444444ca9aaaaaaaaaaaa
aacccccccccccccccaaaaaaaaaaaaaaaaacccccccccccccccaaaaaaaaaa554447444444444474444477744474744447744744444474444544aaaaaaaaaaaaaaa
acccccccccccccccc9a9a9aaaaaaaaaaacccccccccccccccc9a9a9aaaaa4444447777744444744444744455744744447744744447444444444a9a9aaaaaaaaaa
ccccccccccccccccc99aaaaaaaa9aaaaccccccccccccccccc99aaaaaaaa94444444444744447444474455444747444447447777744444444459aaaaaaaa9aaaa
ccccccccccccccccc9a9a9aa9aaaaaa9ccccccccccccccccc9a9a9aa9aaa444444444474445574447444444444444544444444444444445555a9a9aa9aaaaaa9
cccccccccccccccccc9a9a9aaa9a9acccccccccccccccccccc9a9a9aaa9a444447444744554474447444444444444444444444455555cccccc9a9a9aaa9a9acc
cccccccccccccccccc99a9a9a9a9cccccccccccccccccccccc99a9a9a9a95445447774444444444444444444444445555555555ccccccccccc99a9a9a9a9cccc
cccccccccccccccccccc99999acccccccccccccccccccccccccc99999acc54444444444444444554444445559acccccccccccccccccccccccccc99999acccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc544444445554455555ccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc55444555ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccaaaaaaa9ccccccccccccccccccccccccaaaaaaa9ccccccccccccccccccccccccaaaaaaa9ccccccccccccccccccccccccaaaaaaa9cccccccccccccccc
ccccccaaaaaaaa7a9cccccccccccccccccccccaaaaaaaa7a9cccccccccccccccccccccaaaaaaaa7a9cccccccccccccccccccccaaaaaaaa7a9ccccccccccccccc
ccccaaaaaaaaaaa7a9ccccccccccccccccccaaaaaaaaaaa7a9ccccccccccccccccccaaaaaaaaaaa7a9ccccccccccccccccccaaaaaaaaaaa7a9cccccccccccccc
cccaaaaaaaaaaa7aaacccccccccccccccccaaaaaaaaaaa7aaacccccccccccccccccaaaaaaaaaaa7aaacccccccccccccccccaaaaaaaaaaa7aaacccccccccccccc
cccaaaaaaaaaaaaaaacccccccccccccccccaaaaaaaaaaaaaaacccccccccccccccccaaaaaaaaaaaaaaacccccccccccccccccaaaaaaaaaaaaaaacccccccccccccc
cca9aaaaaaaaaaaaaacccccccccccccccca9aaaaaaaaaaaaaacccccccccccccccca9aaaaaaaaaaaaaacccccccccccccccca9aaaaaaaaaaaaaacccccccccccccc
caaaaaaaaaaaaaaaaacccccccccccccccaaaaaaaaaaaaaaaaacccccccccccccccaaaaaaaaaaaaaaaaacccccccccccccccaaaaaaaaaaaaaaaaacccccccccccccc
c9a9a9aaaaaaaaaaacccccccccccccccc9a9a9aaaaaaaaaaacccccccccccccccc9a9a9aaaaaaaaaaacccccccccccccccc9a9a9aaaaaaaaaaaccccccccccccccc
c99aaaaaaaa9aaaaccccccccccccccccc99aaaaaaaa9aaaaccccccccccccccccc99aaaaaaaa9aaaaccccccccccccccccc99aaaaaaaa9aaaacccccccccccccccc
c9a9a9aa9aaaaaa9ccccccccccccccccc9a9a9aa9aaaaaa9ccccccccccccccccc9a9a9aa9aaaaaa9ccccccccccccccccc9a9a9aa9aaaaaa9cccccccccccccccc
cc9a9a9aaa9a9acccccccccccccccccccc9a9a9aaa9a9acccccccccccccccccccc9a9a9aaa9a9acccccccccccccccccccc9a9a9aaa9a9acccccccccccccccccc
cc99a9a9a9a9cccccccccccccccccc555755575557a557c557ccccc555557ccccc5557a557a9ccc557555755575557555799a9a9a9a9cccccccccccccccccccc
cccc99999acccccccccccccccccccc57575757579a57cc57cccccc55757557ccccc5795757cccc57ccc57c57575757c57ccc99999acccccccccccccccccccccc
cccccccccccccccccccccccccccccc5557557c557c55575557cccc55575557ccccc57c5757cccc5557c57c5557557cc57ccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc57cc575757cccc57cc57cccc55757557ccccc57c5757cccccc57c57c57575757c57ccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccaaaaaa57cc57575557557c557cccccc555557aa9ccc57c557ccccc557cc57c57575757a57cccccccccccccccccccccccaaaaaaa9
9cccccccccccccccccccccaaaaaaaa7a9cccccccccccccccccccccaaaaaaaa7a9cccccccccccccccccccccaaaaaaaa7a9cccccccccccccccccccccaaaaaaaa7a
a9ccccccccccccccccccaaaaaaaaaaa7a9ccccccccccccccccccaaaaaaaaaaa7a9ccccccccccccccccccaaaaaaaaaaa7a9ccccccccccccccccccaaaaaaaaaaa7
aacccccccccccccccccaaaaaaaaaaa7aaacccccccccccc55555555555555555555555ccccccccccccccaaaaaaaaaaa7aaacccccccccccccccccaaaaaaaaaaa7a
aacccccccccccccccccaaaaaaaaaaaaaaaccccccccccc444444444444444444444445ccccccccccccccaaaaaaaaaaaaaaacccccccccccccccccaaaaaaaaaaaaa
aacccccccccccccccca9aaaaaaaaaaaaaaccccccccccc444444444444444444444445ccccccccccccca9aaaaaaaaaaaaaacccccccccccccccca9aaaaaaaaaaaa
aacccccccccccccccaaaaaaaaaaaaaaaaaccccccccccc555554555544555555554445ccccccccccccaaaaaaaaaaaaaaaaacccccccccccccccaaaaaaaaaaaaaaa
acccccccccccccccc9a9a9aaaaaaaaaaacccccccccccc444444444444444444444445cccccccccccc9a9a9aaaaaaaaaaacccccccccccccccc9a9a9aaaaaaaaaa
ccccccccccccccccc99aaaaaaaa9aaaaccccccccccccc555545445545554455555555cccccccccccc99aaaaaaaa9aaaaccccccccccccccccc99aaaaaaaa9aaaa
ccccccccccccccccc9a9a9aa9aaaaaa9ccccccccccccc444444444444444444444445cccccccccccc9a9a9aa9aaaaaa9ccccccccccccccccc9a9a9aa9aaaaaa9
cccccccccccccccccc9a9a9aaa9a9accccccccccccccc44445555544445555555444cccccccccccccc9a9a9aaa9a9acccccccccccccccccccc9a9a9aaa9a9acc
cccccccccccccccccc99a9a9a9a9ccccccccccccccccccc4cc99a9a9a9a9cccccc4ccccccccccccccc99a9a9a9a9cccccccccccccccccccccc99a9a9a9a9cccc
cccccccccccccccccccc99999accccccccccccccccccccc4cccc99999acccccccc4ccccccccccccccccc99999acccccccccccccccccccccccccc99999acccccc
ccccccccccccccccccccccccccccccccccccccccccccccc4cccccccccccccccccc4ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccc4cccccccccccccccccc4ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccaaaaaaa9ccccccccccccccccccccccccaaaaaaa4cccccccccccccccccc4cccccaaaaaaa9ccccccccccccccccccccccccaaaaaaa9cccccccccccccccc
ccccc00aaaaaaa7a9cccccccccccccccccccccaaaaaaaa749ccccccccccccccccc4cccaaaaaaaa7a9cccccccccccccccccccccaaaa00aa7a9ccccccccccccccc
cccc0990aaaaaaa7a9cccccccccccccc00ccaaaaaaaaaaa4a9cccccccccccccccc4caaaaaaaaaaa7a9ccccccccccccccccccaaaaa0990aa7a9cccccccccccccc
ccc099f0aaaaaa7aaaccccccccccccc0990aaaaaaaaaaa54555555555555555555455aaaaaaaaa7aaacccccccccccccccccaaaaa099f0a7aaacccccccccccccc
ccc09ff0aaaaaaaaaaccccccccccccc0f990aaaaaaaaa544544444444444444444454aaaaaaaaaaaaacccccccccccccccccaaaaa09ff0aaaaacccccccccccccc
cca09ff0aaaaaaaaaaccccccccccccc0ff90aaaaaaaaa555555555555555555555555aaaaaaaaaaaaacccccccccccccccca9aaaa09ff0aaaaacccccccccccccc
caaa0f0aaaaaaaaaaaccccccccccccc0ff90aaaaaaaaa444444444444444444444445aaaaaaaaaaaaacccccccccccccccaaaaaaaa0f0aaaaaacccccccccccccc
c9a0ccc0aaaaaaaaaccccccccccccccc0f09a9aaaaaaa5555544444555555555445559aaaaaaaaaaacccccccccccccccc9a9a9aa0ddd0aaaaccccccccccccccc
c990ccc0aaa9aaaaccccccccccccccc0bbb0aaaaaaa9a444444444444444444444445aaaaaa9aaaaccccccccccccccccc99aaaaa0ddd0aaacccccccccccccccc
c9a0ccc09aaaaaa9cccccccccccccc00bbb0a9aa9aaaa4664644446644664666466459aa9aaaaaa9ccccccccccccccccc9a9a9aa0ddd0aa9cccccccccccccccc
cc90ccc0aa9a9accccccccccccccc0fbbbb09a9aaa9a9655564456565655566556565a9aaa9a9acccccccccccccccccccc9a9a9a0ddd0acccccccccccccccccc
3330cfc0333333333333333333333300bbb0333333333644464446464446464446465333333333333333333333333333333333330dfd03333333333333333333
33305550333333333333333333333305555033333333346644664664466444664664533333333333333333333333333333333333055503333333333333333333
33305550333333333333333333333055055033333333355544455555555445555444533333333333333333333333333333333333055503333333333333333333
33305050333333333333333333333050305503333333344444444444444444444444533333333333333333333333333333333333050503333333333333333333
66605555066665666666656666660550660505666666644444444444444444444444556666666566666665666666656666666566055550666666656666666566
66600060066656666666566666665006666056666666566666665666666656666666566666665666666656666666566666665666000600666666566666665666
66656666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666
66566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666666566666
65666666656666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666
56666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666666
56666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666666
56666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666666
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555

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
__sfx__
010800000c7430c7000b0000d0000000000000000000000018605350003f0003f0000c703340003f0003600035000360003600000000186050000000000000000000000000000000000000000000000000000000
01080000246150c7000b0000d0000000000000000000000018605350003f0003f0000c703340003f0003600035000360003600000000186050000000000000000000000000000000000000000000000000000000
014d00010061300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603
013d00200a6100f611156111c6112c6113161131611236111b6110d6110d6110c6110b6110a621096110861107611096110b6110161106611076110f611186111c61125611256111c61116611126110d61109611
010100001330013300133001330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0106001c1f615000000000000000306053b0001f6150000018323000000000000000306150000024605246052b6150000030605000001631322000220003200030615000002461503000010001c0001c00033000
011000010c76000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
010a00001873400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
010c00001ff3521f4500f0528f4500f0528f0524f4500f0526f3528f4526f0526f4528f3526f4526f0521f451ff351cf4521f0500f0524f4526f3528f4500f0526f3524f4526f3511f0526f3528f4526f3523f45
010c00000ce400ce310ce2118e1113e4013e211ce401ce311ce211ce1113e4013e211ae401ae211ce4013e2009e4009e3009e2015e1118e4018e2113e4013e3113e2013e111ce401ce211ae401ae2113e401fe20
010c00001af351cf351ff2623f351af351cf351ff2623f351af351cf351ff2623f351af351cf351ff2623f351af351cf351ff2624f251af351cf351ff2626f151af351cf351ff2623f151af351cf351ff2624f15
010c00200c043000001cd251cd251cd251cd251cd251cd251cd151cd151cd151cd151cd151cd151cd151cd150c043020051ed251ed251ed251ed251ed251ed251ed151ed151ed151ed151ed151ed151ed151ed15
010c00002bf351ff450000028f450000026f4528f352bf452df352bf450000028f4526f3528f4521f351ff452bf351ff450000028f450000026f4528f352df452ff352bf450000028f4526f3528f4521f351ff45
010c000011e4011e3111e2111e1113e4013e211ce401ce311ce211ce1118e3018e111ae401ae211ce401ce2113e4013e3113e2113e1113e4013e211ce401ce311ce211ce1118e3018e111ae401ae211ce4018e20
010c00001cf351df3521f2624f351cf351df3521f2624f351cf351df3521f2624f351cf351df3521f2624f351af351cf351ff2624f251af351cf351ff2626f151af351cf351ff2623f151af351cf351ff2624f15
010c00002bf351ff450000028f450000026f4528f352bf452df352bf450000028f4526f3528f4521f351ff4530f3524f450000028f450000026f4528f352df452ff2530f3534f2537f353bf2537f3534f2532f35
011000000ee400ee251ef341ef0415e4015e250be3017e111af3400e0019e4019e2500e001af3412e4012e4423f3423f3413e4013e2107e110000015e4015e2121f3421f3410e4010e4415e4015e2109e4009e44
011000001d845188001af24000001892500000188451880017f341880018925008000080017f141b845008001ff141ff14189250080000800008001a845008001892519f1400800008001d835008000080000800
0110000012e4012e251ef341ef041ae301ae150be3017e111bf3400e001ae401ae2500e001af3410e4010e4423f3423f3412e4012e2106e110000013e4013e2121f3421f3410e4010e4415e4015e2109e4009e44
01100000155201551115515000001550015501155021550517520175111751500000005001750400500005001a5201a5111a51500500000000050000500005001c5201c5111c5150050000500005000050000000
011000001c5201c5111c5121c51525e0028e002ae002de001a5201a5111a5121a51525e0028e002ae002de001752017511175121751525e0028e002ae002de001552015511155121551525e0028e002ae002de00
011000001552015511155151550021e00260002a000260001752017511175150050021e00260002a000260001a5201a5111a5150050021e00260002a000260001f5201f5111f5111f51500500005001c5201c511
011000000ee400ee251ef341ef0415e4015e250be3017e111af3400e0019e4019e2500e001af3412e4012e4423f3423f3413e4013e2107e110000015e4015e2116e4016e3116e2116e1113e4013e3114e4014e00
0110000015e4000000125150000009e4000000000000000015e400000009e400000015e400000000000000000ee400000012705000000be200be110be000be0010e2010e1110e0010e0009e2009e1115e2100000
011000001e5200000015515000001e5200000000000000001c520000001e520000001c5200000000000000001a520180000e70121015150150000000000150151701500000000001701519015000000000000000
001000001d845000000000000000189250000000000000001d8450000018925000001d8450000000000000001d8450000000000000000c9250000000000189050b9250000000000189050c925000000000000000
011000001552015511155150000021e16260002a000260001752017511175150000021e1623e0026e002ae001a5201a5111a5150050023e1626e0028e002be001c5201c5111c515005001fe1623e0025e002ae00
011000001c5201c5111c5121c51525e1628e002ae002de001a5201a5111a5121a51523e1627e002ae002de001752017511175121751523e1626e0028e002be00155201551115512155151fe1623e0025e002ae00
011000001552015511155151550021e16260002a000260001752017511175150050021e1623e0026e002ae001a5201a5111a5150050023e1626e0028e002be001f5201f5111f5111f51500500005001c5201c511
0110000012e4012e2522f10000001ce301ce150de3019e1121f1022f100de3022f1000000000000de300000012e4012e2522f100000014e3014e150de000de0115e3015e1527f1025f1016e3016e1525f1000000
011000001e5201e5111e5121e5151ce1620e0022e0027e001e5201e5111e5121e5151ce1620e0022e0027e001e5201e5111e5121e5151ce1620e0022e0027e00205202051120512205151ce1620e0022e0027e00
011000001d845188001cf1000000189250000018845188001bf101cf10189251cf100080017f041b845008001ff041ff04189250080000800008001a845008001892519f041ef101cf101d835008001cf1000800
011000000be400be2520f1021f1015e3021f1012e301ee111af001bf0012e3036e0538e051bf1512e3027f150be300be151bf00000000de300de1506e0006e010ee300ee1520f001ef000fe300fe151ef0000000
011000001e5201e5111e5121e5151be1620f0021f0025f001e5201e5111e5121e5151be1620f0021f0025f001e5201e5111e5121e51523f1021f101752017511175121751512f1015f1023f1021f1020f101ef10
011000001d8451880026f1027f101892523f1018845188001bf001cf00189251ef2520f1523f251b8452cf101ff042af1018925008002cf102af101a84500800189251ad101bf101ef101d835008001cf0000800
0110000010e4010e2520f10000001ae301ae150be3017e111ff1020f100be3020f1000000000000be300000010e4010e2520f100000012e3012e150be000be0113e3013e1525f1023f1014e3014e1523f1000000
001000001c5201c5111c5121c5151ae161ee0020e0025e001c5201c5111c5121c5151ae161ee0020e0025e001c5201c5111c5121c5151ae161ee0020e0025e001e5201e5111e5121e5151ae161ee0020e0025e00
011000001d845188001af1027f001892523f00188451880019f101af10189251af1520f0523f051b8452cf001ff042af0018925008002cf002af001a84500800189251ad101cf101af101d835008001af1000800
0110000009e4009e251ef101ff1013e3013e1510e301ce1118f0019f0010e3034e0536e0539e0510e300000009e3009e1519f00000000be300be1504e0004e010ce300ce151ef001cf000de300de1519e1100000
011000001c5201c5111c5121c515000001ff10000001ff101c5201c5111c5121c51519e161ef001ff0023f0021520215112151021510215122151221512215151bf201e50500000000001cf20000000000000000
011000001d8451880024f1025f101892521f101884521f1019f001af00189251af0520f0523f051b8452cf0019f2019f0518925008001af102af001a84500800189251ad001cf001af001d8352df1021f1000800
015800200ca130da1100a110da1100a1101a1100a1101a1102a1105a1108a1105a1106a1107a1106a1105a1104a1106a1111a1106a1104a1111a1107a1107a1108a1106a1110a1106a1109a1107a1111a1104a11
01a8000200a2400a2500a0400a0500a0400a0500a0400a0500a0400a0500a0400a0500a0400a0500a0400a0500a0400a0500a0400a0500a0400a0500a0400a0500a0400a0500a0400a0500a0400a0500a0400a05
01ff00200cb100cb100cb100cb100cb100cb100cb100cb100eb100eb100eb100eb100eb100eb100eb100eb100fb100fb100fb100fb100fb100fb100fb100fb100cb100cb100cb100cb100cb100cb100cb100cb10
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000227451d735187250070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050000000000
01030000187251d735227452470500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
010900001a5361c5361f526245261a5161c5161f51624506005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0109000030614363253b3153b30500300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
010300001d55518535000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500000
01030000185351d555000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
000200000b0500b0500b0500d05013050350503f0503f05029000340003f000360003500036000360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000011020110201102012020120200f0000200000000000000100001000000000000001000020000200010000100001000010000100001000010000030002f00031000330003300033000320003100030000
000100002032020320203202032000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
0002000006320063200632006320120002a0000f000100001000011000170002a0000a0000e0000f00010000130001e0003100019000190001a0001b0001d0001f00025000370002c00027000240002400026000
000100001332013320133201332000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 08090a0b
00 08090a0b
00 0c0d0e0b
02 0f0d0e0b
01 10115244
00 10115244
00 10131144
00 12141144
00 16151144
00 17181944
00 101a1144
00 121b1144
00 161c1144
00 17181944
00 1d1e1f44
00 20212244
00 2324255f
02 26272844
03 292a2b44


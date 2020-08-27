pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- lemonade stand
-- a thoughtless labs experiment

function _init()
	cls()
	mode="start"
	selector=0
	money=1000
	menu={1,2,3}
	initinventory()
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
	if btnp(2) then
		if selector<#menu then
			selector+=1
		end
	end
	if btnp(3) then
		if selector>1 then
			selector-=1
		end
	end
	if btnp(4) then
		if selector>0 and selector<#menu+1 then
		if selector==1 then
			itmchoice=lemons
		elseif selector==2 then
			itmchoice=sugar
		elseif selector==3 then
			itmchoice=cups
		else
			itmchoice=0
		end
		purchase(prices[selector],itmchoice)
	end
	end
end

function drawgame()
	cls(10)
	fillp()
	print(_item,10,100,8)
	print(_price,10,110,8)
	print(selector,10,80,8)
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
		-- print store prices
	for i=1,#inventory do
		available=" "..inventory[i].avail
		print(available,(ix+5)-(#available*4-40),iy+5+10*i,0)
	end
	
	
	-- store
	local sx,sy
	sx=70
	sy=10
	rectfill(sx,sy,sx+45,sy+60,7)
	print("store",sx+5,sy+5,0)
	print("lEMONS: ",sx+5,sy+15,0)
	print("sUGAR: ",sx+5,sy+25,0)
	print("cUPS: ",sx+5,sy+35,0)	
	
	-- print store prices
	for i=1,#inventory do
		price=" "..inventory[i].cost
		print(price,(sx+5)-(#price*4-40),sy+5+10*i,0)
	end
end

function purchase()	
	
end

function initinventory()
	inventory=
	{
		{name="lemons"
		,avail=100
		,owned=0
		,cost=50
		}
		{name="sugar"
		,avail=100
		,owned=0
		,cost=10
		}
		{name="cups"
		,avail=100
		,owned=0
		,cost=20
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

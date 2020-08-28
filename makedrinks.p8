pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
x=100
l=100
v=3

rx=10
rl=10
rv=1

drinks=0

function _draw()
cls(7)
for i=1,v do
	if (x-rx)>=0 and (l-rl)>=0 and (v-rv)>=0 then
		x=x-rx
		l=l-rv
		v=v-rv
		
		drinks+=1
	end
end
print(drinks)
print(x)
print(l)
print(v)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

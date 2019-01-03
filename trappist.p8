pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- trappist-1
-- by bicubico

cx=64
cy=64

planets={b={},c={},d={},e={},f={},g={},h={}}
for p in all(planets) do
 add(p,{temp=0,dist=0})
end
planets.b.dist=0.011
planets.c.dist=0.015
planets.d.dist=0.021
planets.e.dist=0.028
planets.f.dist=0.037
planets.g.dist=0.045
planets.h.dist=0.063 

rtc=60    --real time clock
speed=8
zoom=9
offy=0.07
star_radius=5
bright=100
bright_log={}
ruler_offset=14
ruler_gap=0
pause=false

function _init()
	 show_logo()
	 
	 local i
  for i=1,100 do
    bright_log[i]=bright
  end
end

function update_pause()
 if btnp(1) then
   ruler_offset+=1
   if ruler_offset>100 then
     ruler_offset=100
   end
 end
 if btnp(0) then
   ruler_offset-=1
   if ruler_offset<14 then
     ruler_offset=14
   end
 end
 if btn(3) then
   ruler_gap+=1
   if ruler_offset+ruler_gap>100 then
     ruler_gap-=1
   end
 end
 if btn(2) then
   ruler_gap-=1
   if ruler_gap<0 then
     ruler_gap=0
   end
 end
end

function update_telescope()
 if btnp(0) then
   speed+=1
   if speed>9 then
     speed=9
   end
 end
 if btnp(1) then
   speed-=1
   if speed<1 then
     speed=1
   end
 end 
 if btn(3) then
   offy+=0.1
   if offy>1 then 
   		offy=1
   end
 end
 if btn(2) then
   offy-=0.1
   if offy<-1 then 
     offy=-1
   end
 end
end

function _update()
 if not pause then
   rtc=rtc+1
   log_bright(get_brightness())
   update_telescope()
 else
   update_pause()
 end
 
 if btnp(5) then
   pause= not pause
 end
end

function _draw()
 draw_system()
end

function log_bright(b)
  local i
  for i=1,99 do
    bright_log[i]=bright_log[i+1]
  end
  bright_log[100]=b
end

function get_brightness()
 local shadow
 local c
 local t
 local ld
 local adj_bright=bright
 
 for k,v in pairs(planets) do
   c=(1/v.dist)/(500*speed)
   t=(rtc*c)%100
   ld=v.dist*1000
   if cos(t)>0 and abs(sin(t)*ld)<star_radius then
     adj_bright-=10 --planet_radius
   end
 end
 return adj_bright
end

function draw_bright_log()
  local py=10
  print("x"..10-speed,12,4,7)
  rectfill(12,py,116,py+12,0)
  rect(12,py,116,py+12,7)
  local i
  for i=1,100 do
    pset(13+i,py+2+(10-bright_log[i]/10),11)
  end
end

function draw_ruler()
  local py=10
  local off=0
  line(ruler_offset,py+3,ruler_offset,py+10,flr(rnd(2))+6)
 -- while off<100 do
--    line(ruler_x,py+3,ruler_x,py+10,11)
 --   off+=1
 -- end
end

function draw_star()
	circfill(cx,cy,star_radius,8)
end

function draw_planet(letra,dist,side)
 local ld=dist*1000
 local c=(1/dist)/(500*speed)
 local t=(rtc*c)%100

 if (side==1) and cos(t)>=0 
 then 
  circfill(cx+ld*sin(t),cy+ld*cos(t)*offy,3,4)
 end
 if (side==-1) and (cos(t)<0)
 then 
  circfill(cx+ld*sin(t),cy+ld*cos(t)*offy,3,4)
 end
end

function draw_orbit(letra,dist,side)
 local ld=dist*1000
 local c
 local r
 if (side==-1)
 then
   for c=25,75,2 do
    pset(cx+ld*sin(c/100),cy+ld*cos(c/100)*offy,1)
   end
 else
   for c=75,125,2 do
   	r=c%100
    pset(cx+ld*sin(c/100),cy+ld*cos(c/100)*offy,1)
   end
 end
end

function draw_system()
  cls()
  --print(offy,0,0)
  --print(get_brightness(),0,8)
  for k,v in pairs(planets) do
    draw_orbit(k,v.dist,-1)
    draw_planet(k,v.dist,-1)
  end
draw_star()
  for k,v in pairs(planets) do
  		draw_orbit(k,v.dist,1)
    draw_planet(k,v.dist,1)
  end
  draw_bright_log()
  if pause then
    draw_ruler()
  end
end	


-->8
-- logo etilmercurio
-- by bicubico

function show_logo()
  circ(64,64,30,6)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000bbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000bbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000bbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000bbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000bbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
parts={}

function _init()
 for i=1,100 do
  add(parts,{
  id=i,
  posx=rnd(128),
  posy=rnd(128),
  direction=rnd(1),
  speed=rnd(2),
  col=flr(rnd(15))+1
  })
 end
end


function _update()
 for k,v in pairs(parts) do
  v.posx+=cos(v.direction)*v.speed
  v.posy+=sin(v.direction)*v.speed
 end
end



function _draw()
 cls()
 for k,v in pairs(parts) do
 	circ(v.posx,v.posy,1,v.col)
 end
end

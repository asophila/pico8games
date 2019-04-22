pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
direction = 0

function _init()

end


function _update()
 if btn(⬅️)==true then
  direction-=0.01
 end
 if btn(➡️)==true then
  direction+=0.01
 end
end



function _draw()

end

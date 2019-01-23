pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- 
function _init()
	poke(0x5f2d, 1)
    curstate=menu_state()
end

function _update()
    -- mouse utility global variables
 mousex=stat(32)
 mousey=stat(33)
 lclick=stat(34)==1
 rclick=stat(34)==2
 mclick=stat(34)==4
	curstate.update()
end

function _draw()
  curstate.draw()
  line(mousex-5,mousey,mousex-2,mousey,12)
  line(mousex+5,mousey,mousex+2,mousey,12)
  line(mousex,mousey-5,mousex,mousey-2,12)
  line(mousex,mousey+5,mousex,mousey+2,12)
  
--  pset(mousex,mousey, 12) -- draw your pointer here
end
-->8
-- collision detection between bboxes

-- expects entities objects as arguments
function collides(ent1, ent2)
    local e1b=ent1.bounds
    local e2b=ent2.bounds
    
    if  ((e1b.xoff1 <= e2b.xoff2 and e1b.xoff2 >= e2b.xoff1)
    and (e1b.yoff1 <= e2b.yoff2 and e1b.yoff2 >= e2b.yoff1)) then 
        return true
    end

    return false
end

-- expects ent to be an entity object
function point_collides(x,y, ent)
    local eb=ent.bounds
    
    if  ((eb.xoff1 <= x and eb.xoff2 >= x)
    and (eb.yoff1 <= y and eb.yoff2 >= y)) then 
        return true
    end

    return false
end

-- entity -----------------------------------------------
-- implements drawable interface
function bbox(w,h,xoff1,yoff1,xoff2,yoff2)
    local bbox={}
    bbox.offsets={xoff1 or 0,yoff1 or 0,xoff2 or 0,yoff2 or 0}
    bbox.w=w
    bbox.h=h
    -- this values will be overwritten with setx(n) and sety(n)
    bbox.xoff1=bbox.offsets[1]
    bbox.yoff1=bbox.offsets[2]
    bbox.xoff2=bbox.offsets[3]
    bbox.yoff2=bbox.offsets[4]
    -----------------------------------------------------------
-- public    
    function bbox:setx(x)
        self.xoff1=x+self.offsets[1]
        self.xoff2=x+self.w-self.offsets[3]
    end
    function bbox:sety(y)
        self.yoff1=y+self.offsets[2]
        self.yoff2=y+self.h-self.offsets[4]
    end
    function bbox:printbounds()
        rect(self.xoff1, self.yoff1, self.xoff2, self.yoff2, 8)
    end

    return bbox
end

function anim()
    local a={}
	a.list={}
	a.current=false
	a.tick=0
-- private
    function a:_get_fr(one_shot, callback)
		local anim=self.current
		local aspeed=anim.speed
		local fq=anim.fr_cant		
		local st=anim.first_fr
		
		local step=flr(self.tick)*anim.w
		local sp=st+step
		
		self.tick+=aspeed
		local new_step=flr(flr(self.tick)*anim.w)		
		if st+new_step >= st+(fq*anim.w) then 
		    if one_shot then
		        self.tick-=aspeed  
		        callback()
		    else
		        self.tick=0
		    end
		end
		
		return sp
    end
    
-- public
    function a:set_anim(idx)
        if (self.currentidx == nil or idx != self.currentidx) self.tick=0 -- avoids sharing ticks between animations
        self.current=self.list[idx]
        self.currentidx=idx
    end

	function a:add(first_fr, fr_cant, speed, zoomw, zoomh, one_shot, callback)
		local a={}
		a.first_fr=first_fr
		a.fr_cant=fr_cant
		a.speed=speed
		a.w=zoomw
        a.h=zoomh
        a.callback=callback or function()end
        a.one_shot=one_shot or false
		
		add(self.list, a)
	end
    
    -- this must be called in the _draw() function
	function a:draw(x,y,flipx,flipy)
		local anim=self.current
		if( not anim )then
			rectfill(0,117, 128,128, 8)
			print("err: obj without animation!!!", 2, 119, 10)
			return
		end
		
		spr(self:_get_fr(self.current.one_shot, self.current.callback),x,y,anim.w,anim.h,flipx,flipy)
    end
    	
	return a
end

function entity(anim_obj)
    local e={}
    -- use setx(n) and sety(n) to set this values
    e.x=0
    e.y=0
    ---------------------------------------------
    e.anim_obj=anim_obj

    e.debugbounds, e.flipx, e.flipy = false
    e.bounds=nil

-- private    
    -- flickering---------\\
    -- all private here...
    e.flickerer={}
    e.flickerer.timer=0
    e.flickerer.duration=0          -- this value will be overwritten
    e.flickerer.slowness=3
    e.flickerer.is_flickering=false -- change this flag to start flickering
    function e.flickerer:flicker()
        if(self.timer > self.duration) then
            self.timer=0 
            self.is_flickering=false
        else
            self.timer+=1
        end
    end
    -- end flickering ----//

-- public:
    function e:setx(x)
        self.x=x
        if(self.bounds != nil) self.bounds:setx(x)
    end
    function e:sety(y)
        self.y=y
        if(self.bounds != nil) self.bounds:sety(y)
    end
    function e:setpos(x,y)
        self:setx(x)
        self:sety(y)
    end
    function e:set_anim(idx)
		self.anim_obj:set_anim(idx)
    end
    function e:set_bounds(bounds)
        self.bounds = bounds
        self:setpos(self.x, self.y)
    end
    function e:flicker(duration)
        if(not self.flickerer.is_flickering)then
            self.flickerer.duration=duration
            self.flickerer.is_flickering=true
            self.flickerer:flicker()
        end
        return self.flickerer.is_flickering
    end

    -- this must be called in the _draw() function
    function e:draw()
        if(self.flickerer.timer % self.flickerer.slowness == 0)then
            self.anim_obj:draw(self.x,self.y,self.flipx,self.flipy)
        end
        if(self.flickerer.is_flickering) self.flickerer:flicker()        
		if(self.debugbounds) self.bounds:printbounds()
    end
    
    return e
end
-- end entity -------------------------------------------


-- timers -----------------------------------------------
-- implements updatable interface -----------------------
function timer(updatables, step, ticks, max_runs, func)
    local t={}
    t.tick=0
    t.step=step
    t.trigger_tick=ticks
    t.func=func
    t.count=0
    t.max=max_runs
    t.timers=updatables

-- public    
    function t:update()
        self.tick+=self.step
        if(self.tick >= self.trigger_tick)then
            self.func()
            self.count+=1
            if(self.max>0 and self.count>=self.max and self.timers ~= nil)then
                del(self.timers,self) -- removes this timer from the table
            else
                self.tick=0
            end
        end
    end

    function t:kill()
        del(self.timers, self)
    end

    add(updatables,t) -- adds this timer to the table
    return t
end
-- end timers -------------------------------------------

-- text utils -------------------------------------------------
-- implements drawable interface ------------------------------

-- args:{
--   text="", x=2, y=2, fg=7, bg=2, sh=3,
--   bordered=false, shadowed=false, centerx=false, centery=false,
--   blink=false, on_time=5, off_time=5
-- }
-- "text" is the only mandatory argument
function tutils(args)
	local s={}
	s.private={}
	s.private.tick=0
	s.private.blink_speed=1
	s.height=10 -- "line height" use this to calculate "next line" in a paragraph

	s.text=args.text or ""
	s._x=args.x or 2
	s._y=args.y or 2
	s._fg=args.fg or 7
	s._bg=args.bg or 2
	s._sh=args.sh or 3 	-- shadow color
	s._bordered=args.bordered or false
	s._shadowed=args.shadowed or false
	s._centerx=args.centerx or false
	s._centery=args.centery or false
	s._blink=args.blink or false
	s._blink_on=args.on_time or 5
	s._blink_off=args.off_time or 5
	
	function s:draw()
		if self._centerx then self._x =  64-flr((#self.text*4)/2) end
		if self._centery then self._y = 64-(4/2) end

		-- blink related stuff
		if self._blink then 
			self.private.tick+=1
			local offtime=self._blink_on+self._blink_off -- for internal use
			if(self.private.tick>offtime) then self.private.tick=0 end
			local blink_enabled_on = false
			if(self.private.tick<self._blink_on)then
				blink_enabled_on = true
			end
			-- if it's supposed to blink, but it's on a off position, then return
			if(not blink_enabled_on) then
				return
			end
		end

		local yoffset=1
		if self._bordered then 
			yoffset=2
		end

		if self._bordered then
			local x=max(self._x,1)
			local y=max(self._y,1)

			if(self._shadowed)then
				for i=-1, 1 do	
					print(self.text, x+i, self._y+2, self._sh)
				end
			end

			for i=-1, 1 do
				for j=-1, 1 do
					print(self.text, x+i, y+j, self._bg)
				end
			end
		elseif self._shadowed then
			print(self.text, self._x, self._y+1, self._sh)
		end

		print(self.text, self._x, self._y, self._fg)
    end

	return s
end
-->8
-- state
function menu_state()
    local s={}
    local updateables={}
    local drawables={}

    s.update=function()
        for u in all(updateables) do
            u:update()
        end
    end

    s.draw=function()
        for d in all(drawables) do
            d:draw()
        end
    end

    return s
end

--[[ entity
function xxxx_entity(x,y)
    local anim_obj=anim()
    anim_obj:add(first_fr,fr_count,speed,zoomw,zoomh)

    local e=entity(anim_obj)
    e:setpos(x,y)
    e:set_anim(1)

    local bounds_obj=bbox(8,8)
    e:set_bounds(bounds_obj)
    -- e.debugbounds=true

    return e
end
]]
-->8
--[[ state
function xxxxxxx_state()
    local s={}
    local updateables={}
    local drawables={}

    s.update=function()
        for u in all(updateables) do
            u:update()
        end
    end

    s.draw=function()
        for d in all(drawables) do
            d:draw()
        end
    end

    return s
end

-- entity
function xxxx_entity(x,y)
    local anim_obj=anim()
    anim_obj:add(first_fr,fr_count,speed,zoomw,zoomh)

    local e=entity(anim_obj)
    e:setpos(x,y)
    e:set_anim(1)

    local bounds_obj=bbox(8,8)
    e:set_bounds(bounds_obj)
    -- e.debugbounds=true

    return e
end
]]

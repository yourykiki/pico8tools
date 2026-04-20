pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- project config
cfg_anim_cart="picocraft.p8"
cfg_pack_prefix="pack"

-- anim editor
function _init()
 init_default()
 init_ui()
 unpack_gfx()
 loadfn()
 update_anim(1)
 update_frm(1)
 update_t(1)
end

function init_ui()
 -- mouse support
 poke(0x5f2d,0x01)
 timeline,sprsel,sprvwr,animsel,
  frmsel,playp,banktabs,rptbtn,
  msgvwr,colpic=
  make_timeline(0,71,tl_play),
  make_spr_selector(0,87,sprsel_chg),
  make_sprvwr(12,12,32,32),
  make_sellst(72,10,26,60,"anim",anims,selanim),
  make_sellst(100,10,26,60,"frame",anims[1],selfrm),
  make_sprbtn(16,65,71,btnplayp,"play"),
  make_tabgrp(4,96,79,"bank",bank_chg),
  make_sprbtn(28,28,62,rptanim,"loop"),
  make_msgvwr(),
  make_colpic(46,50,chgtra_act)
 
 ui_elements={
  banktabs,
  timeline,
  sprsel,
  playp,
  make_sprbtn(18,65,79,btnstop,"stop"),
  animsel,
  frmsel,
  sprvwr,
  make_sprbtn(21,75,70,copanim,"copy anim"),
  make_sprbtn(20,85,70,delanim,"delete anim"),
  make_sprbtn(21,104,70,copfrm,"copy frame"),
  make_sprbtn(20,114,70,delfrm,"delete frame"),
  make_sprbtn(23,3,12,cntspr,"center sprite"),
  make_sprbtn(29,3,21,vwrmkr,"show marker"),
  make_sprbtn(31,3,30,vwrflip,"flip"),
  make_sprbtn(24,50,16,decofy,"decrease y offset"),
  make_sprbtn(25,50,30,incofy,"increase y offset"),
  make_sprbtn(26,16,50,decofx,"decrease x offset"),
  make_sprbtn(27,30,50,incofx,"increase x offset"),
  make_sprbtn(32,5,1,loadfn,"load"),
  make_sprbtn(33,13,1,savefn,"save"),
  make_sprbtn(34,21,1,expfn,"export to game"),
  make_sprbtn(36,37,1,do_undo,"undo"),
  make_sprbtn(37,45,1,do_redo,"redo"),
  make_sprbtn(35,36,62,showcp,"set transparency"),
  rptbtn,
  msgvwr,
  colpic
 }
 ui_state={
  bank=0,
  tpf=3--tick per frame
 }
end

function _update()
 --handle interactions
 mx,my,mb,mw,mspr=
  stat(32),stat(33),
  stat(34),stat(36),0
 mbtn1,mbtn2,mbtn1r=
  m_pressed(mb,0x01),
  m_pressed(mb,0x02),
  m_released(mb,0x01)
  
 --handle ui
 tooltip=nil
 for ui_elt in all(ui_elements) do
  ui_elt:update(mx,my,mb)
 end

 --common ui synchro
 local t=timeline.t\ui_state.tpf
 sprvwr.sprite=curanim[t+1]
 --reinit m_pressed
 pmb=mb 
end

-- mouse just pressed
function m_pressed(mb,n)
 return mb&n==n and pmb&n==0
end
function m_released(mb,n)
 return pmb and mb&n==0 and pmb&n==n
end

-- anim edit functions
function update_anim(sel)
 animsel.sel=mid(1,sel,#anims)
 curanim=anims[animsel.sel]
 sl_scroll_to(animsel,animsel.sel)
 refreshbtn()
end
function refreshbtn()
 rptbtn.nspr=curanim.once and 30 or 28
 colpic.sel=curanim.transp
 chgtra(curanim.transp)
end
function update_frm(sel)
 sel=mid(1,sel,#curanim)
 frmsel.arr,frmsel.sel=
  curanim,sel
 sl_scroll_to(frmsel,sel)
 update_sprite(sel)
end
function update_sprite(sel)
 local s=curanim[sel]
 if s then
  sprsel.sel,ui_state.bank,
   banktabs.sel,sprsel.scr=
   s,s.b,s.b,s.y\32*32
 end
end
function update_t(t)
 timeline.tmax=#curanim*ui_state.tpf
 timeline.t=(t-1)*ui_state.tpf
end
-- ui element functions
function bank_chg(sel)
 ui_state.bank=sel
end
function btnplayp(b)
 timeline.play=not timeline.play
 b.nspr=timeline.play and 17 or 16
 --todo if play, disable chg
 --else enable chg
end
function btnstop(b)
 timeline.play,
 timeline.t,
 playp.nspr=
  false,0,16
end
function selanim(sl)
 update_anim(sl.sel)
 update_frm(1)
 update_t(1)
end
function selfrm(sl)
 update_frm(sl.sel)
 update_t(sl.sel)
end
function sprsel_chg(ss)
 push_undo()
 frmsel.arr[frmsel.sel]=ss.sel
end
function tl_play(tl)
 update_frm(tl.t\ui_state.tpf+1)
end
function delanim()
 push_undo()
 deli(anims,animsel.sel)
 update_anim(animsel.sel)
end
function copanim()
 push_undo()
 add(anims,new_anim(animsel.sel))
end
function delfrm()
 push_undo()
 deli(anims[animsel.sel],frmsel.sel)
 update_frm(frmsel.sel)
 update_t(frmsel.sel)
end
function copfrm()
 push_undo()
 local frm=
  new_frm(curanim[frmsel.sel])
 add(curanim,frm,frmsel.sel+1)
 frmsel.sel+=1
 if frmsel.sel==#curanim then
  frm.x+=frm.w
 end
 update_frm(frmsel.sel)
 update_t(frmsel.sel)
end
function cntspr()
 if (not sprvwr.sprite) return
 sprvwr.dx,sprvwr.dy=
  (sprvwr.w-sprvwr.sprite.w)\2,
  (sprvwr.h-sprvwr.sprite.h)\2
end
function decofx()
 push_undo()
 sprvwr.sprite.ofx-=1
end
function incofx()
 push_undo()
 sprvwr.sprite.ofx+=1
end
function decofy()
 push_undo()
 sprvwr.sprite.ofy-=1
end
function incofy()
 push_undo()
 sprvwr.sprite.ofy+=1
end
function vwrmkr()
 sprvwr.marker=not sprvwr.marker
end
function rptanim(b)
 push_undo()
 curanim.once=not curanim.once
 refreshbtn()
end
function vwrflip()
 sprvwr.flipx=not sprvwr.flipx
end
function showcp()
 colpic.show=not colpic.show
end
function chgtra(sel)
 curanim.transp=sel
 sprvwr.transp=0x8000>>>sel
end
function chgtra_act(sel)
 push_undo()
 chgtra(sel)
end
--
function addmsg(msg)
 add(msgvwr.msgs,msg)
end

-->8
-- undo / redo
function deep_copy(t)
 if type(t)~="table" then
  return t
 end
 local c={}
 for k,v in pairs(t) do
  c[k]=deep_copy(v)
 end
 return c
end

undo_stk,redo_stk={},{}

function push_undo()
 if #undo_stk>=10 then
  deli(undo_stk,1)
 end
 add(undo_stk,deep_copy(anims))
 redo_stk={}
end

function do_undo()
 if (#undo_stk==0) return
 add(redo_stk,anims)
 anims=deli(undo_stk,#undo_stk)
 animsel.arr=anims
 update_anim(animsel.sel)
 update_frm(frmsel.sel)
 update_t(frmsel.sel)
 addmsg("undo")
end

function do_redo()
 if (#redo_stk==0) return
 add(undo_stk,anims)
 anims=deli(redo_stk,#redo_stk)
 animsel.arr=anims
 update_anim(animsel.sel)
 update_frm(frmsel.sel)
 update_t(frmsel.sel)
 addmsg("redo")
end

-->8
--vspr / unpack
--unpack gfx
function unpack_gfx()
 bank_loaded={}
 for i=1,4 do
  local addr=0x6000+i*0x2000
  -- sentinelle : on ecrit 0xff a dest
  poke(addr,0xff)
  reload(addr,0,0x2000,cfg_pack_prefix..i..".p8")
  -- si la valeur est toujours 0xff,
  -- le fichier etait absent
  bank_loaded[i-1]=@addr~=0xff
  if not bank_loaded[i-1] then
   -- efface la bank (noir)
   memset(addr,0,0x2000)
   addmsg(cfg_pack_prefix..i..".p8 not found")
  end
 end
 -- restore spritesheet bank0
 reload(0,0,0x2000)
end

function prep_spr(nspr,blur)
 --copy sprite in spritesheet
 local src=
  0x8000+nspr\16*512+nspr%16*4
 for i=0,448,64 do
  poke4(1536+i,$(src+i))
 end

 if blur then
  local ocam,oclip=$0x5f28,$0x5f20
  camera() clip()
  poke(0x5f55,0x00)
  fillp(▒)
  rectfill(0,24,7,31,15)
  fillp()
  poke(0x5f55,0x60)
  poke4(0x5f20,oclip)
  poke4(0x5f28,ocam)
 end
end

function vsspr(
  b,sx,sy,w,h,dx,dy,flipx)
 flipx=flipx or false
 
 local src,sw=
  0x8000+b*0x2000+sx\8*4+sy*64,
  (sx%8+w)/2-0.5
 
 for i=0,h*64-64,64 do
  for j=0,sw,4 do
   poke4(1536+i+j,$(src+i+j))
  end
 end
 
 sspr(sx%8,24,w,h,dx,dy,w,h,flipx)
end
-->8
-- draw stuff
function _draw()
 --draw backui
 cls(8)pal()
 rectfill(0,8,127,86,5)
 
 for ui_el in all(ui_elements) do
  ui_el:draw()
 end

-- palt(0)
-- spr(48,40,48,4,3)
 
 palt(0x8000)--1 true
 spr(mspr,mx-1,my)
 -- tooltip
 if tooltip then
  local tw=#tooltip*4+2
  rectfill(0,120,tw,127,0)
  ?tooltip,1,121,6
 end
end


-->8
-- ui elements
--tab group -------------------
function make_tabgrp(n,x,y,label,onchg)
 return {
  nb_elt=n,
  x=x,
  y=y,
  sel=0,
  label=label,
  draw=draw_tabgrp,
  update=update_tabgrp,
  onchange=onchg
 }
end

function draw_tabgrp(tg)
 ?tg.label,tg.x-#tg.label*4,tg.y+2,0
 for i=0,3 do
  local off=tg.sel==i and 5 or 1
  spr(i+off,tg.x+i*8,tg.y)
 end
end
function update_tabgrp(tg,mx,my,mb)
 local xc,yc=
  (mx-tg.x)\8,
  (my-tg.y)\8
 local sel=xc+yc*16
 if (sel<0 or sel>=tg.nb_elt) return
 mspr=9
 if mbtn1 and sel~=tg.sel
  and tg.onchange then
  tg.sel=sel
  tg.onchange(sel)
 end
end

-- timeline --------------------
function make_timeline(x,y,onchg)
 return {
  x=x,
  y=y,
  t=0,tmax=63,
  play=false,
  draw=draw_tl,
  update=update_tl,
  onchange=onchg
 }
end
function draw_tl(tl)
 local x,y=tl.x,tl.y
 rect(x,y,x+64,y+15,6)
 camera(-x-1,-y-1)
 rectfill(0,0,62,13,0)
 for i=0,62 do
  if i%15==0 then
   line(i,0,i,2,12)
  elseif i%3==0 then
   line(i,0,i,1,1)
  end
 end
 fillp(▤)
 line(tl.t,0,tl.t,13,8)
 fillp()
 line(tl.tmax,0,tl.tmax,13,2)
 camera()
end
function update_tl(tl)
 if tl.play then
  tl.t=(tl.t+1)%tl.tmax
  tl:onchange()
 end
end

-- sprite selector ------------
function make_spr_selector(x,y,onchg)
 return {
  x=x,
  y=y,
  w=128,h=34,
  sel={},scr=0,
  draw=draw_sprsel,
  update=update_sprsel,
  onchange=onchg
 }
end

function draw_sprsel(sprsel)
 local ssx,ssy=0,0

 palt(0,false)
 camera(-sprsel.x,-sprsel.y)
 clip(sprsel.x,sprsel.y,128,34)
 rectfill(0,0,127,0,0)
 rectfill(0,33,127,33,0)
 vsspr(ui_state.bank,
  ssx,ssy+sprsel.scr,
  128,32,
  0,1)
 local sel=sprsel.sel
 if sel and sel.x 
  and sel.b==ui_state.bank then
  camera(-sprsel.x,-sprsel.y+sprsel.scr)
  rect(sel.x-1,sel.y,
   sel.x+sel.w,sel.y+sel.h+1,7)
  rect(sel.x-2,sel.y-1,
   sel.x+sel.w+1,sel.y+sel.h+2,0)
 end
 fillp(▒)
 if sprsel.move=="move" then
  rect(sel.x-1,sel.y,
   sel.x+sel.w,sel.y+sel.h+1,7)
 end
 camera()
 if sprsel.mode=="select" then
  rect(startx-1,starty,mx,my+1,7)
 end
 fillp()
 clip()
 if sprsel.mode=="select"
  or sprsel.mode=="resize" then
  ?"x="..min(startx,mx)..",y="..min(starty,my)..",w="..abs(startx-mx)..",h="..abs(starty-my),2,122,2
 else
  ?"x="..sel.x..",y="..sel.y..",w="..sel.w..",h="..sel.h,2,122,2
 end
 
end

function update_sprsel(sprsel)
 if not insidebox(mx,my,sprsel) then
  return 
 end
 local rmy,sel=
  my-sprsel.y+sprsel.scr,
  sprsel.sel
 
 if sel and sel.x then 
  if mx==sel.x+sel.w 
   and rmy==sel.y+sel.h then
   mspr=10
   if mbtn1 then
    --resize mode
    sprsel.mode,startx,starty=
     "resize",mx-sel.w,my-sel.h
   end
  elseif insidebox(mx,rmy,sel) then
   mspr=9
   if mbtn1 then
    --move mode
    sprsel.mode="move"
    startx,starty=
    mx-sel.x,rmy-sel.y
   end
  elseif mbtn1 then
   sprsel.mode="select"
   startx,starty=mx,my
  end
 end
 
 if sprsel.mode=="resize" then
  sprsel.sel.w=max(1,mx-startx)
  sprsel.sel.h=max(1,my-starty)
 elseif sprsel.mode=="move" then
  sprsel.sel.x=mx-startx
  sprsel.sel.y=rmy-starty
 end
 if mbtn1r then
  if sprsel.mode=="select" then
   --select
   if mx==startx and my==starty then
    sprsel.sel={
     b=ui_state.bank,
     x=mx\8*8,
     y=rmy\8*8,
     w=8,h=8,
     ofx=0,ofy=0
    }
   else
    sprsel.sel={
     b=ui_state.bank,
     x=min(startx,mx),
     y=min(starty,my)-sprsel.y+sprsel.scr,
     w=abs(mx-startx),
     h=abs(my-starty),
     ofx=0,ofy=0
    }
   end
  end
  sprsel:onchange()
  startx,starty,sprsel.mode=
   nil,nil,nil
 end
 sprsel.scr-=mw
 sprsel.scr=mid(0,sprsel.scr,96)
end

-- simple sprite btn ----------
function make_sprbtn(n,x,y,onclk,tip)
  return {
  x=x,
  y=y,
  nspr=n,
  draw=draw_sprbtn,
  update=update_sprbtn,
  onclick=onclk,
  tip=tip
 }
end
function draw_sprbtn(sb)
 palt(0x8000)
 spr(sb.nspr,sb.x,sb.y)
end
function update_sprbtn(sb)
 local xc,yc=
  (mx-sb.x)\8,
  (my-sb.y)\8
 local sel=xc+yc*16
 if (sel~=0) return
 mspr=9
 if sb.tip then tooltip=sb.tip end
 if mbtn1 then
  sb:onclick()
 end
end

-- select list ----------------
function make_sellst(x,y,w,h,lab,arr,onclk)
 return {
  x=x,y=y,
  w=w,h=h,
  lab=lab,
  arr=arr,sel=1,
  scr=0,
  drag=false,
  dragoff=0,
  draw=draw_sellst,
  update=update_sellst,
  onclick=onclk
 }
end
-- scrollbar geometry helper
function sl_info(sl)
 local total=max(#sl.arr*7,1)
 local vis=sl.h-8
 local ratio=min(1,vis/total)
 local th=max(4,ratio*vis)
 local maxscr=max(0,total-vis)
 local ty=0
 if maxscr>0 then
  ty=(sl.scr/maxscr)*(vis-th)
 end
 return total,vis,th,ty,maxscr
end
-- ensure item idx is visible
function sl_scroll_to(sl,idx)
 local iy=(idx-1)*7
 local vis=sl.h-8
 if iy<sl.scr then
  sl.scr=iy
 elseif iy+7>sl.scr+vis then
  sl.scr=iy+7-vis
 end
end
function draw_sellst(sl)
 local _,vis,th,ty,maxscr=
  sl_info(sl)
 -- clamp scroll
 sl.scr=mid(0,sl.scr,maxscr)
 -- drawing
 local x,y,w,h=
  sl.x,sl.y,sl.w,sl.h
 ?sl.lab,x+1,y,0
 clip(x,y+6,w+1,h-6)
 rectfill(x,y+6,x+w,y+h,0)
 -- items
 camera(-x-1,-y-7+sl.scr)
 for k,v in ipairs(sl.arr) do
  local ky=k*7
  rectfill(0,ky-7,w-4,ky-1,
   k%2==0 and 5 or 13)
  ?k,1,ky-6,7
  if sl.sel==k then
   rect(0,ky-7,w-4,ky-1,2)
  end
 end
 camera()
 clip()
 -- scrollbar (only if needed)
 if maxscr>0 then
  local bx=x+w-2
  local by=y+7
  -- track
  rectfill(bx,by,bx+1,by+vis-1,1)
  -- thumb
  local thumb_y=by+ty
  rectfill(bx,thumb_y,
   bx+1,thumb_y+th-1,6)
 end
end
function update_sellst(sl)
 if not insidebox(mx,my,sl) then
  -- release drag even outside box
  if (mbtn1r) sl.drag=false
  return
 end

 local _,vis,th,ty,maxscr=
  sl_info(sl)
 local bx=sl.x+sl.w-2
 local by=sl.y+7

 -- scrollbar interaction
 if maxscr>0 then
  local on_track=
   mx>=bx and mx<=bx+1
   and my>=by and my<by+vis
  if on_track and mbtn1 then
   -- grab: store offset from thumb top
   sl.drag=true
   sl.dragoff=my-(by+ty)
   -- if click outside thumb, center it
   if sl.dragoff<0
    or sl.dragoff>th then
    sl.dragoff=th/2
   end
  end
 end
 if sl.drag then
  mspr=9
  if mb&1==1 then
   local rel=my-by-sl.dragoff
   sl.scr=mid(0,
    rel/(vis-th)*maxscr,
    maxscr)
  else
   sl.drag=false
  end
  -- eat input: don't select items
  sl.scr-=mw
  return
 end

 -- item click
 local xc,yc=
  (mx-sl.x)\(sl.w-4),
  (my-sl.y-6+sl.scr)\7
 local sel=yc+1+xc*20
 if sel>0 and sel<=#sl.arr then
  mspr=9
  if mbtn1 then
   sl.sel=sel
   if sl.onclick then
    sl:onclick()
   end
  end
 end
 -- mousewheel
 sl.scr-=mw
end

-- sprite viewer --------------
function make_sprvwr(x,y,w,h)
 return {
  x=x,y=y,
  w=w,h=h,
  dx=0,dy=0,
  transp=0x8000,
  marker=true,
  flipx=false,
  draw=draw_sprvwr,
  update=update_sprvwr
 }
end
function draw_sprvwr(sv)
 local x,y=sv.x,sv.y
 clip(x,y,sv.w,sv.h)
 camera(-x,-y)
 rectfill(0,0,sv.w,sv.h,3)

 pal()
 palt(sv.transp)
 if sv.sprite and sv.x then
  local s=sv.sprite
  local sx,sy,ofx=sv.dx,sv.dy,
   sv.flipx and -1 or 1
   
  ofx*=s.ofx
  --8 is arbitrary, depends...
  if (sv.flipx) ofx+=8-s.w

  if sv.marker then
   --of. marker
   rect(sx+ofx,0,sx+ofx,sv.h,12)
   rect(0,sy+s.ofy,sv.w,sy+s.ofy)
   --origin marker
   rect(sx,0,sx,sv.h,8)
   rect(0,sy,sv.w,sy)
   fillp(▒)
   rect(sx+ofx,
    sy+s.ofy,
    sx+s.w-1+ofx,
    sy+s.h-1+s.ofy,
    12)
   fillp()
  end

  vsspr(s.b,s.x,s.y,
   s.w,s.h,
   sx+ofx,sy+s.ofy,
   sv.flipx)
 end
 camera()
 clip()
end
function update_sprvwr(sv)
 if not insidebox(mx,my,sv) then
  vwr_startx,vwr_starty=nil,nil
  return 
 end
 mspr=11
 if mbtn1 then
  --move mode
  vwr_startx,vwr_starty=
  mx-sv.dx,my-sv.dy
 end
 if vwr_startx then
  sv.dx,sv.dy=
   mx-vwr_startx,my-vwr_starty
 end 
 if mbtn1r then 
  vwr_startx,vwr_starty=nil,nil
 end
end
--messages --------------------
function make_msgvwr()
 return {
  x=0,y=121,t=0,
  msgs={},
  draw=draw_msgvwr,
  update=update_msgvwr
 }
end
function draw_msgvwr(mv)
 if #mv.msgs>0 then
  local mvy=127-min(mv.t,5)+max(mv.t-55,0)
  rectfill(0,mvy,127,mvy+5,8)
  ?mv.msgs[1],mv.x,mvy,15
 end
end
function update_msgvwr(mv)
 if #mv.msgs<=0 then
  mv.t=0
  return
 end
 if mv.t>60 then
  deli(mv.msgs,1)
  mv.t=0
 end
 mv.t+=1
end
--color picker-----------------
function make_colpic(x,y,onchg)
 return {
  x=x,y=y,
  w=16,h=16,
  show=false,
  sel=nil,
  draw=draw_colpic,
  update=update_colpic,
  onchange=onchg
 }
end
function draw_colpic(cp)
 if (not cp.show) return
 for i=0,15 do
  local x,y=
   cp.x+i%4*4,cp.y+i\4*4
  rectfill(x,y,x+3,y+3,i)
  if cp.sel==i then
   fillp(0x5a5a)
   rect(x,y,x+3,y+3,0x07)
   fillp()
  end
 end
 rect(cp.x-1,cp.y-1,cp.x+16,cp.y+16,0)
end
function update_colpic(cp)
 if (not cp.show) return
 if not insidebox(mx,my,cp) then
  return
 end
 mspr=9
 local xc,yc=
  (mx-cp.x)\4,
  (my-cp.y)\4
 if mbtn1 then
  cp.sel=xc+yc*4
  cp.onchange(cp.sel)
 end 
end



-->8
--init load save anims
-- anim structure
--[[
{--anims
 {{--anim
  {b=,x=,y=,w=,h=}--frame
 },
 {}
}
]]--
function init_default()
 anims={
  {{b=0,x=0, y=24,w=8,h=8,ofx=0,ofy=0}
  },
  {{b=1,x=0, y=0, w=8,h=8,ofx=0,ofy=0},
   {b=1,x=8, y=0, w=8,h=8,ofx=0,ofy=0},
   {b=1,x=16, y=0, w=8,h=8,ofx=0,ofy=0},
   {b=1,x=24, y=0, w=8,h=8,ofx=0,ofy=0},
   {b=1,x=32, y=0, w=8,h=8,ofx=0,ofy=0},
   {b=1,x=40, y=0, w=8,h=8,ofx=0,ofy=0},
   {b=1,x=48, y=0, w=8,h=8,ofx=0,ofy=0},
   {b=1,x=56, y=0, w=8,h=8,ofx=0,ofy=0}
  },
  {},
  {{b=0,x=8, y=24,w=8,h=8,ofx=0,ofy=0},
   {b=0,x=16,y=24,w=8,h=8,ofx=0,ofy=0},
   {b=0,x=24,y=24,w=8,h=8,ofx=0,ofy=0},
   {b=0,x=32,y=24,w=8,h=8,ofx=0,ofy=0},
   {b=0,x=40,y=24,w=8,h=8,ofx=0,ofy=0},
   {b=0,x=48,y=24,w=8,h=8,ofx=0,ofy=0},
   {b=0,x=56,y=24,w=8,h=8,ofx=0,ofy=0},
   {b=0,x=64,y=24,w=8,h=8,ofx=0,ofy=0}
  },
  {once=1,
   {b=1,x=0, y=88,w=8,h=8,ofx=0,ofy=0},
   {b=1,x=8, y=88,w=8,h=8,ofx=0,ofy=0},
   {b=1,x=16,y=88,w=8,h=8,ofx=0,ofy=0},
   {b=1,x=24,y=88,w=8,h=8,ofx=0,ofy=0},
   {b=1,x=32,y=88,w=8,h=8,ofx=0,ofy=0},
   {b=1,x=40,y=88,w=8,h=8,ofx=0,ofy=0},
   {b=1,x=40,y=88,w=8,h=8,ofx=0,ofy=0},
   {b=1,x=40,y=88,w=8,h=8,ofx=0,ofy=0},
   {b=1,x=48,y=88,w=8,h=8,ofx=0,ofy=0},
   {b=1,x=56,y=88,w=8,h=8,ofx=0,ofy=0},
   {b=1,x=64,y=88,w=8,h=8,ofx=0,ofy=0},
   {b=1,x=72,y=88,w=8,h=8,ofx=0,ofy=0}
  }
 }
end
function new_anim(sel)
 local new={}
 if (not sel) add(new,new_frm())
 local src=anims[sel]
 new.transp,new.once=
  src.transp,src.once
 for frm in all(src) do
  add(new,new_frm(frm))
 end
 return new
end
function new_frm(src)
 local new={b=ui_state.bank,
  x=0,y=0,w=8,h=8,ofx=0,ofy=0}
 if src then
  new.b,new.x,new.y,
  new.w,new.h,
  new.ofx,new.ofy=
   src.b,src.x,src.y,
   src.w,src.h,
   src.ofx,src.ofy
 end
 return new
end

-- load / save functions ------
local anim_props,frm_props=
 split"once,transp,sfrm,sfx,nbfrm",
 split"b,x,y,w,h,ofx,ofy"

function loadfn()
 --init read addr,here map memory
 read_addr=0x2000
 --nb anims
 local newanims={}
 for i=1,read_byte() do
  local newanim=loadblk(anim_props)
  add(newanims,newanim)
  for j=1,newanim.nbfrm do
   add(newanim,loadblk(frm_props))
  end
  newanim.once=newanim.once==1
 end
 anims=newanims
 --infos
 local len=read_addr-0x2000
 addmsg("load "..#newanims.." anims")
 addmsg("read "..len.." bytes")
 animsel.arr=anims
 --hack anim 25--------------
 --[[
 addmsg("hack anim 26")
 anim25=newanims[25]
 anim26=newanims[26]
 for an in all(anim25)do
  del(anim25,an)
 end
 for an in all(anim26)do
  del(anim26,an)
 end

 for frm=1,90 do
  local ax,ay=
    0+8*cos(frm/90)+5,
    0+8*sin(frm/90)

  add(anim25,{
   b=0,x=56,y=80,
   w=16,h=16,
   ofx=ax,ofy=ay})


  ax,ay=
   ax+12*cos(frm/45)+4,
   ay+12*sin(frm/45)+4
  add(anim26,{
   b=0,x=48,y=80,
   w=8,h=8,
   ofx=ax\1,ofy=ay\1})
 end
 ]]--
 --end hack------------------
end
function loadblk(keys)
 local blk={}
 for v in all(keys) do
  blk[v]=read_byte()
 end
 return blk
end
function savefn()
 writ_addr=0x2000
 --nb anims
 write_byte(#anims)
 --anim
 for i,an in ipairs(anims) do
  --general infos
  --once,transparency
  write_byte(an.once and 1 or 0)
  write_byte(an.transp)
  write_byte(getsfxfrm(i))
  write_byte(getsfx(i))
  write_byte(#an)--nbframes
  --frames
  for fr in all(an) do
   --b,x,y
   write_byte(fr.b)
   write_byte(fr.x)
   write_byte(fr.y)
   --w,h
   write_byte(fr.w)
   write_byte(fr.h)
   --ofx,ofy
   write_byte(fr.ofx)
   write_byte(fr.ofy)
  end
 end
 local len=writ_addr-0x2000
 cstore(0x2000,0x2000,len)
 addmsg("save "..len.." byte")
 return len
end

--editor sfx hack
anims_sfx={
 --ianim=frm,sfx
 [3]={10,55},--pst attack
 [5]={1,17}, --pst death
 [6]={2,54}, --pst hammer
 [9]={1,51}, --fm  attack
 [10]={1,27},--fm  death
 [13]={2,52},--rm  attack
 [14]={1,37},--rm  death
 [20]={1,48},--fire
 [21]={3,53},--pr  attack
 [22]={1,50},--pr  heal
 [23]={1,47},--pr  death
 [24]={1,52},--g.tow attack
 [28]={3,54},--build
}
function getsfxfrm(ianim)
 if anims_sfx[ianim] then
  return anims_sfx[ianim][1]
 end
 return -1
end
function getsfx(ianim)
 if anims_sfx[ianim] then
  return anims_sfx[ianim][2]
 end
 return -1
end

function expfn()
 local len=savefn()
 cstore(0x0800,0x2000,len,cfg_anim_cart)
 addmsg("export to 0x0800@"..cfg_anim_cart)
end

-->8
-- utils
function insidebox(x,y,box)
 return x>=box.x
  and x<=box.x+box.w
  and y>=box.y
  and y<box.y+box.h
end
function read_byte()
 local val=@read_addr-127
 read_addr+=1
 return val
end
function write_byte(val)
 poke(writ_addr,val+127)
 writ_addr+=1
end

__gfx__
01000000000000000000000000000000000000000777770007777700077777000777770000100000011110000010100000000000000000000000000000000000
171000000666660006666600066666000666660077ddd77077dd777077ddd77077ddd77001710000177771000171711000000000000000000000000000000000
1771000066ddd66066dd666066ddd66066ddd66077d7d770777d77707777d770777dd77001711010171110000171717100000000000000000000000000000000
1777100066d6d660666d66606666d660666dd66077d7d770777d777077d777707777d77001717171171000000171717100000000000000000000000000000000
1777710066d6d660666d666066d666606666d66077ddd77077ddd77077ddd77077ddd77011777771171000001177777100000000000000000000000000000000
1771100066ddd66066ddd66066ddd66066ddd6607777777077777770777777707777777071777771010000007177777100000000000000000000000000000000
01171000666666606666666066666660666666607777777077777770777777707777777017777771000000001777777100000000000000000000000000000000
00000000ddddddd0ddddddd0ddddddd0ddddddd06666666066666660666666606666666001177710000000000117771000000000000000000000000000000000
0000000000000000000000000000000000000000000000000dd0000000000000000d000000000000000dd000000dd000000d00000d000000000d0006000d0000
0dd000000dd0dd000ddddd00000dd000000d0000000ddd00dddd00000dddddd000ddd0000000000000dd00000000dd000dddd0d0dddddddd0dddd060000d0000
0dddd0000dd0dd000ddddd00000dd0000ddddd00000000d0dddd00000d0000d00dd0dd00000000000dd0000000000dd0d00d000d0d000000d00d060d0d0d0d00
0dddddd00dd0dd000ddddd000dddddd0ddddddd00ddd00d0000000000d0dd0d0dd000dd0d00000d0dd000000000000ddd000000d0d0000d0d000600ddd0d0dd0
0dddd0000dd0dd000ddddd000dddddd00d0d0d000d00d0d0dddd00000d0dd0d0d00000d0dd000dd00dd0000000000dd0d000d00d0d000000d006d00d0d0d0d00
0dd000000dd0dd000ddddd00000dd0000d0d0d000d00d0d0dddd00000d0000d0000000000dd0dd0000dd00000000dd000d0dddd00d0000d00d6dddd0000d0000
000000000000000000000000000dd0000d0d0d000d00d0000dd000000dddddd00000000000ddd000000dd000000dd0000000d0000d0d0d000600d000000d0000
000000000000000000000000000000000ddddd000dddd000000000000000000000000000000d00000000000000000000000000000d0000000000000000000000
022220000222220002000200000000000020000000000200dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000
2000000002022020200222200dddddd00222220000222220dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000
2022222002022020202002000d0123d00020002002000200dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000
2020002002000020202000000d4567d00000002002000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000
2200020002000020200000200d89abd00000220000220000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000
0222220002222220022222000dcdefd00000000000000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000
0000000000000000000000000dddddd00000000000000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000
000000000000000000000000000000000000000000000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000
00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd
00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd
00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd
00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd
00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd
00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd
00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd
00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd00000000dddddddd
66666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000
66666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000
66666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000
66666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000
66666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000
66666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000
66666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000
66666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000
00000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666
00000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666
00000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666
00000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666
00000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666
00000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666
00000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666
00000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666
66666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000
66666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000
66666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000
66666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000
66666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000
66666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000
66666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000
66666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000
00000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666
00000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666
00000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666
00000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666
00000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666
00000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666
00000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666
00000000666666660000000066666666000000006666666600000000666666660000000066666666000000006666666600000000666666660000000066666666
55555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000
55555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000
55555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000
55555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000
55555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000
55555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000
55555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000
55555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000
00000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555
00000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555
00000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555
00000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555
00000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555
00000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555
00000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555
00000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555
55555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000
55555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000
55555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000
55555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000
55555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000
55555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000
55555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000
55555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000
00000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555
00000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555
00000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555
00000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555
00000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555
00000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555
00000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555
00000000555555550000000055555555000000005555555500000000555555550000000055555555000000005555555500000000555555550000000055555555
ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000
ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000
ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000
ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000
ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000
ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000
ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000
ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000
00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff
00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff
00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff
00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff
00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff
00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff
00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff
00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff
ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000
ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000
ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000
ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000
ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000
ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000
ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000
ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000
00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff
00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff
00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff
00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff
00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff
00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff
00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff
00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff
__map__
9b7f827e7e807f7f9787877f7f7f827e7e87807f7f87877f7f80877f87877f7f808f7f87877f7f80977f87877f7f809f7f87877f7f80a77f87877f7f80af7f87877f7f80b77f87877f7f7f8289b689807f8f89877f7f807f8f89877f7f807f8f89877f7f80898f89877f7f80938f89877f7f809d8f89877f7f80a78f89877d7f
80b18f89877c7f80bb8f89877c7f80c58f89877f7f7f827e7e877f879787877f7f7f8f9787877f7f7f979787877f7f7f9f9787877f7f7fa79787877f7f7faf9787877f7f7fb79787877f7f7fbf9787877f7f8082809089807f8789877f7f80898789877f7f80938789877f7f809d8789877f7f80a78789877f7f80b18789877f
7f80bb8789877f7f80c58789877f7f80cf8789877f7f80d98789877f7f7f8281b58380bf7f88887f8080c87f88887f8080d17f88887f8080da7f88887f807f827e7e8080e77f87887f7f7f827e7e87807fa087887f7f8087a087887f7f808fa087887f7f8097a087887f7f809fa087887f7f80a7a087887f7f80afa087887f7f
80b7a087887f7f7f8280b28780bfd987897f7e80c7d987897e7e80cfd987897e7e80d8d98b897e7e80e4d98c897d7e80f1d98b897e7e80bfd987897f7e80bfd987897f7e8082809a88807faa8b927c7a808baa8b927c7a8097aa8b927c7a80a3aa8b927c7a80afaa8b927c7a80bbaa8b927c7a80c7aa8b927c7a80d3aa8b927c
7a80dfaa8b927c7a7f827e7e8080f77f87887f7f7f827e7e87807f9789887f7f80899789887f7f80939789887f7f809d9789887f7f80a79789887f7f80b19789887f7f80bb9789887f7f80c59789887f7f7f8281b38580cf978788807f80d7978e887e7f80e6978a887e7f80f1978a887e7f80cf978788807f80cf978788807f
808280a488817f7f8d8f7d78818d7f8d8f7d78819b7f8d8f7d7881a97f8d8f7d7881b77f8d8f7d7881c57f8d8f7f7881d37f8d8f7f7881e17f8d8f7f7881ef7f8d8f7f787f827e7e8080ef7f87897f7f7f827e7e8780bfa087897f7f80c7a087897f7f80cfa087897f7f80d7a087897f7f80dfa087897f7f80e7a087897f7f80
efa087897f7f80f7a087897f7f7f7f7e7e897fd77f848f7d787fdc7f848f7d787fe17f848f7d787fe67f848f7d787feb7f848f7d787ff07f848f7d787ff57f848f7d787ffa7f848f7d787fd77f848f7d787fd77f848f7d7880827e7e8e807fd187877f7f8087d187877f7f808fd187877f7f8097d187877f7f809fd187877f7f
80a7d187877f7f80a7d187877f7f80a7d187877f7f80a7d187877f7f80a7d187877f7f809fd187877f7f80afd187877f7f80b7d187877f7f80bfd187877f7f80c7d187877f7f7f827e7e837fdf978387827c7fe3978387827c7fe7978387827c7feb978387827c7f8280af85817f8f8f8f7f7f818f8f8f8f7f7f819f8f8f8f7f
7f81af8f8f8f7f7f81bf8f8f8f7f7f81cf8f8f8f7f7f7f8282b4867fa7bf888d7f7b7fa7bf888d7f7b7fa7bf888d7f7b7fb0bf878d807b7fb8bf8e8d7f7b7fc7bf878d7f7b7fcfbf878d7f7b7f8280b1837fd7bf878a7f7e7fdfbf878a7f7e7fe7bf878a7f7e7fefbf878a7f7e808280ae887fc7cd87897f7e7fc7cd87897f7e
7fc7cd87897f7e7fcfcd87897f7e7fd7cd8789807e7fdfcd8789817e7fe7cd8789817e7fefcd8789817e7ff7cd8789817e808280b3837fafb787877c897fb7b787877c897fbfb787877c897f7f8787877f7f7f827e7ed97fb7cf8f8f8b7e7fb7cf8f8f8b7d7fb7cf8f8f8b7d7fb7cf8f8f8b7c7fb7cf8f8f8b7c7fb7cf8f8f8b
7b7fb7cf8f8f8b7b7fb7cf8f8f8a7a7fb7cf8f8f8a7a7fb7cf8f8f8a797fb7cf8f8f89797fb7cf8f8f89797fb7cf8f8f88787fb7cf8f8f88787fb7cf8f8f87787fb7cf8f8f87777fb7cf8f8f86777fb7cf8f8f86777fb7cf8f8f85777fb7cf8f8f85777fb7cf8f8f84777fb7cf8f8f84777fb7cf8f8f83777fb7cf8f8f83777f
b7cf8f8f82777fb7cf8f8f82777fb7cf8f8f81777fb7cf8f8f81777fb7cf8f8f80777fb7cf8f8f80787fb7cf8f8f7f787fb7cf8f8f7f787fb7cf8f8f7e797fb7cf8f8f7e797fb7cf8f8f7d797fb7cf8f8f7d7a7fb7cf8f8f7d7a7fb7cf8f8f7c7b7fb7cf8f8f7c7b7fb7cf8f8f7c7c7fb7cf8f8f7c7c7fb7cf8f8f7c7d7fb7cf
8f8f7c7d7fb7cf8f8f7c7e7fb7cf8f8f7c7f7fb7cf8f8f7c7f7fb7cf8f8f7c807fb7cf8f8f7c807fb7cf8f8f7c817fb7cf8f8f7c817fb7cf8f8f7c827fb7cf8f8f7c827fb7cf8f8f7d837fb7cf8f8f7d837fb7cf8f8f7d847fb7cf8f8f7e847fb7cf8f8f7e847fb7cf8f8f7f857fb7cf8f8f7f857fb7cf8f8f80857fb7cf8f8f
80867fb7cf8f8f81867fb7cf8f8f81867fb7cf8f8f82867fb7cf8f8f82867fb7cf8f8f83867fb7cf8f8f83867fb7cf8f8f84867fb7cf8f8f84867fb7cf8f8f85867fb7cf8f8f85867fb7cf8f8f86867fb7cf8f8f86867fb7cf8f8f87867fb7cf8f8f87857fb7cf8f8f88857fb7cf8f8f88857fb7cf8f8f89847fb7cf8f8f8984
7fb7cf8f8f8a847fb7cf8f8f8a837fb7cf8f8f8a837fb7cf8f8f8b827fb7cf8f8f8b827fb7cf8f8f8b817fb7cf8f8f8b817fb7cf8f8f8b807fb7cf8f8f8b807fb7cf8f8f8b7f7fb7cf8f8f8c7f7f827e7ed97fafcf87879b807fafcf87879b7e7fafcf87879a7c7fafcf8787997a7fafcf878798787fafcf878797767fafcf87
8795757fafcf878794737fafcf878792727fafcf878790727fafcf87878e717fafcf87878c717fafcf87878a717fafcf878787717fafcf878786717fafcf878784727fafcf878782737fafcf878780747fafcf87877f757fafcf87877e777fafcf87877d787fafcf87877c7a7fafcf87877b7b7fafcf87877b7d7fafcf87877b
7f7fafcf87877b807fafcf87877b827fafcf87877c837fafcf87877d857fafcf87877e867fafcf87877f877fafcf878780887fafcf878781887fafcf878782897fafcf878783897fafcf878785897fafcf878786897fafcf878787897fafcf878788887fafcf878789877fafcf87878a877fafcf87878b867fafcf87878b857f
afcf87878b847fafcf87878c837fafcf87878b817fafcf87878b807fafcf87878b7f7fafcf87878a7e7fafcf8787897e7fafcf8787887d7fafcf8787877c7fafcf8787867c7fafcf8787857c7fafcf8787837c7fafcf8787827c7fafcf8787817d7fafcf8787807d7fafcf87877f7e7fafcf87877e7f7fafcf87877d807fafcf
87877c827fafcf87877b837fafcf87877b857fafcf87877b867fafcf87877b887fafcf87877b8a7fafcf87877c8b7fafcf87877d8d7fafcf87877e8e7fafcf87877f907fafcf878780917fafcf878782927fafcf878784937fafcf878786947fafcf878787947fafcf87878a947fafcf87878c947fafcf87878e947fafcf8787
90937fafcf878792937fafcf878794927fafcf878795907fafcf8787978f7fafcf8787988d7fafcf8787998b7fafcf87879a897fafcf87879b877fafcf87879b857fafcf87879c8380827e7e837fafb787878e897fef9787878a897ff79787878a897f7f8787877f7f7f8282b5837fc79783837e817fcb97838380817fc79b83
8380817fcb9b838380818e897fafb787878e897fef9787878a897fef9787878a897ff79787878a897ff79787878a897f7f8787877f7f7f7f8787877f7f7f8282b5877fc79783837e817fc79783837e817fcb97838380817fcb97838380817fc79b838380817fc79b838380817fcb9b838380817fcb9b83838081000000000000
__sfx__
010c0000221502c150001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000c00002c14022140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

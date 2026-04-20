pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--map editor
--inits/updates

-- project config
cfg_anim_cart="picocraft.p8"
cfg_export_cart="start_picocraft.p8"
cfg_pack_prefix="pack"

camx,camy,frm=0,0,0
--tmp var unit selected
sel,colsel=nil,0

-- tile infos
--0=green/grass
--1=brown/dirt
--2=blue/water
map_to_ovr={
 [0]=split"-1,-1,-1,-1",--0
 split"0,0,0,1",--1
 split"0,0,1,1",--2
 split"0,0,1,0",--3
 split"0,0,0,2",--4
 split"0,0,2,2",--5
 split"0,0,2,0",--6
 split"2,2,2,0",--7
 split"2,2,0,2",--8
 [16]=split"0,0,0,0",--16
 [17]=split"0,1,0,1",--17
 [18]=split"1,1,1,1",--18
 [19]=split"1,0,1,0",--19
 [20]=split"0,2,0,2",--20
 [21]=split"2,2,2,2",--21
 [22]=split"2,0,2,0",--22
 [23]=split"2,0,2,2",--23
 [24]=split"0,2,2,2",--24
 [33]=split"0,1,0,0",--33
 [34]=split"1,1,0,0",--34
 [35]=split"1,0,0,0",--35
 [36]=split"0,2,0,0",--36
 [37]=split"2,2,0,0",--37
 [38]=split"2,0,0,0",--38
 [39]=split"1,1,1,0",--39
 [40]=split"1,1,0,1",--40
 [41]=split"1,0,1,1",--41
 [42]=split"0,1,1,1" --42
}
--ovr_pal={[0]=3,4,12}
ovr_pal={[0]=11,9,13}
--element picker defs
objs_sel,unit_sel=
 {[0]={[0]=1,4},
  {[0]=2,6,5,8,3,7},
  {[0]=2,6,5,8,3,7,9},
 },
 {[0]={[0]=1,2,3,4},
  {[0]=1,2,3,4}
 }
yelpal=split"9,2,3,4,5,6,7,8,9,10,11,10,13,14,15"
function make_unit(plr,edef,x,y)
 return { 
  edef.id,x,y,--writable
  def=edef.id,--unit definition
  edef=edef,
  pos={x,y},--pos
  w=edef.w,h=edef.h,--dim from def
  cxoff=edef.w/2,cyoff=edef.h/2,
  mhp=edef.hp,--maxhealth point
  hp=edef.hp,--health point
  at=edef.at,--attack
  dm=edef.dm,--damage range
  de=edef.de,--defense
  wd=0,--wood
  gd=0,--gold
  st=1,--state
  t=0,
  plr=plr,
  draw=draw_unit
  }
end


function _init()
 --font 
 poke(0x5600,unpack(split"4,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,7,7,7,0,0,0,0,0,0,7,7,0,0,0,0,0,14,10,14,0,0,0,0,0,10,4,10,0,0,0,0,0,10,0,10,0,0,0,0,0,10,10,0,0,0,0,0,0,12,14,12,0,0,0,0,0,6,14,6,0,0,0,0,3,1,0,0,0,0,0,0,0,0,0,16,24,0,0,0,99,54,28,62,8,62,8,0,0,6,0,0,0,0,0,0,0,2,4,0,0,0,0,0,0,0,2,0,0,0,0,0,5,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,12,12,12,12,12,0,12,0,0,54,54,0,0,0,0,0,0,54,127,54,54,127,54,0,8,62,11,62,104,62,8,0,0,51,24,12,6,51,0,0,14,27,27,110,59,59,110,0,12,12,0,0,0,0,0,0,24,12,6,6,6,12,24,0,12,24,48,48,48,24,12,0,0,5,2,5,0,0,0,0,0,2,7,2,0,0,0,0,0,0,0,3,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,2,0,0,0,0,0,4,2,1,0,0,0,0,0,7,5,7,0,0,0,0,0,3,2,7,0,0,0,0,0,3,2,6,0,0,0,0,0,3,6,3,0,0,0,0,0,5,7,4,0,0,0,0,0,6,2,3,0,0,0,0,0,1,7,7,0,0,0,0,0,7,4,4,0,0,0,0,0,7,7,7,0,0,0,0,0,7,7,4,0,0,0,0,0,2,0,2,0,0,0,0,0,2,0,3,0,0,0,0,0,2,1,2,0,0,0,0,0,3,0,3,0,0,0,0,0,2,4,2,0,0,0,0,0,3,4,2,0,0,0,0,0,30,51,59,59,3,30,0,0,6,5,6,0,0,0,0,3,3,63,99,99,99,63,0,0,6,1,6,0,0,0,0,4,6,5,6,0,0,0,0,0,7,1,2,0,0,0,0,124,6,6,63,6,6,6,0,0,0,126,99,99,126,96,62,1,3,5,5,0,0,0,0,0,2,2,2,0,0,0,0,48,0,56,48,48,48,51,30,3,3,51,27,15,27,51,0,12,12,12,12,12,12,56,0,0,7,7,5,0,0,0,0,0,3,5,5,0,0,0,0,0,2,5,2,0,0,0,0,0,3,5,7,1,0,0,0,0,0,126,99,99,126,96,96,0,6,1,1,0,0,0,0,0,6,2,3,0,0,0,0,2,7,2,4,0,0,0,0,0,5,5,6,0,0,0,0,0,0,99,99,34,54,28,0,0,0,99,99,107,127,54,0,0,0,99,54,28,54,99,0,0,0,99,99,99,126,96,62,0,0,127,112,28,7,127,0,62,6,6,6,6,6,62,0,1,3,6,12,24,48,32,0,62,48,48,48,48,48,62,0,12,30,18,0,0,0,0,0,0,0,0,0,0,0,30,0,12,24,0,0,0,0,0,0,28,54,99,99,127,99,99,0,63,99,99,63,99,99,63,0,6,1,1,6,0,0,0,0,31,51,99,99,99,51,31,0,127,3,3,63,3,3,127,0,127,3,3,63,3,3,3,0,62,3,3,115,99,99,126,0,99,99,99,127,99,99,99,0,63,12,12,12,12,12,63,0,127,24,24,24,24,24,15,0,99,51,27,15,27,51,99,0,3,3,3,3,3,3,127,0,99,119,127,107,99,99,99,0,99,103,111,107,123,115,99,0,2,5,5,2,0,0,0,0,63,99,99,63,3,3,3,0,2,5,3,6,0,0,0,0,63,99,99,63,27,51,99,0,6,1,4,3,0,0,0,0,63,12,12,12,12,12,12,0,99,99,99,99,99,99,62,0,99,99,99,99,54,28,8,0,99,99,99,107,127,119,99,0,99,99,54,28,54,99,99,0,99,99,99,126,96,96,63,0,127,96,48,28,6,3,127,0,56,12,12,7,12,12,56,0,8,8,8,0,8,8,8,0,14,24,24,112,24,24,14,0,0,0,110,59,0,0,0,0,0,0,0,0,0,0,0,0,4,4,14,4,0,0,0,0,10,14,14,4,0,0,0,0,6,9,13,6,0,0,0,0,9,0,0,9,0,0,0,0,0,6,2,0,0,0,0,0,14,4,14,31,14,0,0,0,15,15,15,31,24,0,0,0,27,31,31,14,4,0,0,0,0,0,0,8,16,0,0,0,8,0,0,1,0,0,0,0,1,12,12,16,8,0,0,0,4,14,14,31,4,0,0,0,0,0,0,0,4,0,0,0,4,14,4,7,0,0,0,0,14,17,21,17,14,0,0,0,8,20,42,93,42,20,8,0,0,0,0,85,0,0,0,0,14,27,19,27,14,0,0,0,8,28,127,28,54,34,0,0,127,34,20,8,20,34,127,0,14,27,17,31,14,0,0,0,14,31,17,27,14,0,0,0,17,42,68,0,17,42,68,0,14,21,27,21,14,0,0,0,127,0,127,0,127,0,127,0,85,85,85,85,85,85,85,0"))
 --init ui
 msgvwr,
 propseditor,
 lvlselector=
  make_msgvwr(),
  make_propseditor(),
  make_lvlselector()
 ui_elements={
  msgvwr,
  propseditor,
  lvlselector}
 --
 darkpal,maptocolor={
  split"1,1,5,2,1,13,6,2,2,4,3,13,5,4,4",
  split"0,1,1,5,1,5,13,1,1,2,5,13,1,2,2",
  split"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
 },
 split"3,3,3,12,12,12,12,12,0,0,0,0,0,0, 0,3,3,4,3,12,12,12,12,12,0,0,0,0,0,0,0, 0,3,3,3,12,12,12,4,4,4,4",

 unpack_gfx()
 -- mouse support
 poke(0x5f2d, 0x01)
 --init definitions
 unitspr,objsdef,unitdef,menu=
  --unitspr
  p_tbl"{{nb=1,s=48},{nb=8,s=256},{nb=8,w=10,f={{},{},{},{},{ofx=-2},{ofx=-3},{ofx=-3},{},{},{}},s=288},{nb=8,s=49},{w=10,once=1,nb=10,s=272},{h=9,w=9,nb=4,s=298},{nb=1,s=269},{spy=1,nb=8,s=320},{ofy=-1,ofx=-1,s=560,h=10,spy=1,w=14,nb=6},{ofy=-5,ofx=-3,spy=3,s=336,h=19,once=1,w=12,nb=9},{nb=1,s=271},{w=10,nb=8,s=304},{w=16,ofx=-2,nb=4,s=544},{ofy=-7,ofx=-2,w=14,s=512,h=16,once=1,f={{},{},{},{},{},{ofx=0},{ofx=0},{ofx=0},{ofx=0}},nb=9},{nb=1,s=270},{spy=1,nb=8,s=328}}",
  --objsdef
  p_tbl"{{tw=2,poffx=2,h=16,w=16,yoff=8,th=3,s=71,yboff=1,mpalt=1,sts={{s=71},{tw=1,xoff=5,yoff=16,th=1,s=70}},cm={0,3,3},hp=200},{tw=2,poffx=3,h=16,w=16,yoff=8,th=3,poffy=-2,s=217,sts={{},{fn=o_die},{fn=b_wait,blur=1,s=217},{yoff=6,th=2,mpalt=4096,s=64},{yoff=6,th=2,mpalt=4096,s=66}},bt=30,cm={0,3,3},sm={2,2,0},gd=50,wd=10,hp=350},{tw=5,h=32,yoff=9,th=5,yboff=3,bt=120,sm={0,12,24,16,0},wd=150,sts={{fn=waitorder},{fn=o_die},{fn=b_wait,blur=1,s=180},{m={6,15,31,31,14},mpalt=4096,s=123},{m={6,31,31,31,14},mpalt=4096,s=118},{fn=o_prod}},w=32,s=180,m={7,15,15,15,15},cm={0,7,15,15,15},rlyp=1,gd=300,mnu=1,hp=1000},{tw=5,h=24,w=36,yoff=8,th=4,poffy=-10,s=203,m={30,31,31,31},cm={0,15,15,14},sts={{},{}},sm={24,16,16,16},hp=10000},{tw=5,h=32,yoff=12,th=6,poffy=-22,yboff=3,bt=40,sm={0,0,16,16,12,0},wd=70,sts={{fn=waitorder},{fn=o_die},{fn=b_wait,blur=1,s=96},{m={6,15,31,31,14},mpalt=4096,yoff=8,th=5,s=123},{m={6,31,31,31,14},mpalt=4096,yoff=8,th=5,s=118},{fn=o_prod}},w=32,s=96,m={6,15,15,15,15,6},cm={0,6,15,15,6,0},rlyp=1,gd=200,mnu=5,hp=1000},{tw=4,h=26,w=28,yoff=16,th=5,poffy=-18,s=57,sts={{},{fn=o_die},{fn=b_wait,blur=1,s=57},{m={3,3},mpalt=4096,yoff=16,th=2,s=64},{m={3,3},mpalt=4096,yoff=16,th=2,s=66}},m={6,7,15,15,7},bt=40,mpalt=1,cm={0,0,15,15,7},gd=120,wd=30,hp=800},{tw=4,poffx=-3,h=24,yoff=8,th=4,poffy=-12,yboff=1,bt=60,mpalt=129,wd=120,spalt=32639,sts={{},{fn=o_die},{fn=b_wait,blur=1,s=192},{tw=5,m={6,15,31,31,14},mpalt=4096,yoff=0,th=5,s=123},{tw=5,m={6,31,31,31,14},mpalt=4096,yoff=0,th=5,s=118},{fn=o_prod}},w=26,s=192,sm={12,12,8,8},m={7,15,15,7},gd=100,cm={0,7,7,7},rlyp=1,spal=5f080,mnu=6,hp=800},{tw=3,poffx=2,h=24,yoff=8,th=4,poffy=-12,bt=15,sm={0,6,6,2},wd=10,sts={{},{fn=o_die},{fn=b_wait,blur=1,s=68},{yoff=12,th=2,mpalt=4096,s=64},{yoff=12,th=2,mpalt=4096,s=66}},w=16,s=68,m={3,3,3,3},cm={0,3,3,3},gd=20,vrad=48,hp=250},{tw=3,poffx=2,h=24,yoff=8,th=4,poffy=-12,bt=15,sm={0,6,6,2},wd=10,sts={{},{fn=o_die},{fn=b_wait,blur=1,s=68},{yoff=12,th=2,mpalt=4096,s=64},{yoff=12,th=2,mpalt=4096,s=66}},w=16,s=68,m={3,3,3,3},cm={0,3,3,3},gd=20,vrad=48,hp=250}}",
  --unitdef
  p_tbl"{{vrad=24,h=8,ico=2,repair=16,sts={{fn=waitorder,a=1},{fn=u_die,a=5},{fn=walkto,a=2},{fn=fight,a=2},{a=2,fn=walkto,s=6},{fn=attack,a=3},{fn=gather,a=1},{a=2,fn=walkto,s=9},{a=3,fn=g_chop,s=10},{a=4,fn=g_return,s=7},{a=2,fn=walkto,s=12},{a=1,fn=g_wait,s=13},{a=0,fn=g_chop,s=10},{a=2,fn=walkto,s=15},{fn=u_build,a=6},{a=2,fn=walkto,s=17},{fn=u_repair,a=6}},mnu=2,fn=o_prod_unit,hp=25,w=8,de=0,fight=4,at=2,gather=7,gd=50,bt=300,id=1,fd=1},{dm=3,fight=4,mnu=7,vrad=32,ico=6,fn=o_prod_unit,hp=50,w=8,de=1,h=9,at=5,fd=2,gd=100,bt=540,id=2,sts={{fn=waitorder,a=7},{fn=u_die,a=10},{fn=walkto,a=8},{fn=fight,a=7},{a=8,fn=walkto,s=6},{fn=attack,a=9}}},{vrad=40,h=9,ico=20,wd=20,sts={{fn=waitorder,a=11},{fn=u_die,a=14},{fn=walkto,a=12},{fn=fight,a=11},{a=12,fn=walkto,s=6},{fn=attack,a=13}},mnu=7,fn=o_prod_unit,hp=100,w=8,de=0,fight=4,at=8,arad=32,gd=150,bt=600,id=3,fd=2},{vrad=32,h=10,ico=34,wd=5,sts={{fn=waitorder,a=15},{fn=u_die,a=5},{fn=walkto,a=16},{fn=fight,a=15},{a=16,fn=walkto,s=6},{fn=attack,a=3},{a=16,fn=walkto,s=8},{fn=heal,a=3}},mnu=7,heal=7,fn=o_prod_unit,hp=75,w=8,de=0,fight=4,at=2,arad=32,gd=120,bt=600,id=4,fd=2}}",
  --menu
  p_tbl"{{{ico=0,fn=sel_tool,tip=select},{fn=ter_tool,ico=1,tip=terrain},{fn=obj_tool,ico=2,tip=objects},{fn=unit_tool,ico=3,tip=units},{ico=9,fn=del_tool,tip=delete},{ico=13,fn=file_tool,tip=file menu}}}"
 --todo replace with good parsing
 loadanim()
 init_ovr_to_map()

 --load default level
 lvl=1
 --read compress map/elements
 load_lvl(lvl)
 --prepare tilemap
 --copy first 3 lines to spritesheet
 memcpy(0,32768,1536)
 smnu=1
 --editor ui tools
 objpicker,unitpicker=
  make_elementpicker(objs_sel),
  make_elementpicker(unit_sel)
 --init updfn
 sel_tool()
 addmsg("welcome to picocraft map editor")
end

function _update()
 --handle editor
 update_inputs()
 --handle ui
 for ui_elt in all(ui_elements) do
  ui_elt:update(mx,my,mb)
 end
 --reinit m_pressed
 pmb=mb
end

function update_inputs()
 --handle interactions
 mx,my,mb=
  stat(32),stat(33),stat(34)
 --make stuffs
 if(btn(⬅️) or mx>-8 and mx<6 and my<95) camx-=2
 if(btn(➡️) or mx>122 and mx<134 and my<106) camx+=2
 if(btn(⬆️) or my>-8 and my<6) camy-=2
 if(btn(⬇️) or my>125 and my<134 and mx>31 and mx<94) camy+=2
 
	--btn clic
	if (m_released(mb,0x01)) ibtn=nil
 if mx<31 and my>95 then
  --minimap
  if mb&0x01==0x01 then
   camx,camy=
    mid(0,mx-4+mmx,31)*8/mmres,
    mid(0,my-101+mmy,31)*8/mmres
  end
 elseif mx>93 and my>105 
  and m_pressed(mb,0x01) then
  ibtn=(mx-95)\11 --3 cols
   +(mx-95)\33*12 --stick on 3 column
   +(my-105)\12*3+1 --2 lines
  local mitem=menu[smnu][ibtn]
  if (mitem and mitem.fn) mitem.fn()
 end

 -- tooltip
 tooltip=nil
 if mx>93 and my>105 then
  local hbtn=(mx-95)\11
   +(mx-95)\33*12
   +(my-105)\12*3+1
  local mitem=menu[smnu][hbtn]
  if mitem then tooltip=mitem.tip end
 elseif drwhud==draw_filehud
  and mx>=55 and my>=108
  and mx<95 and my<128 then
  local fi=(mx-55)\10+(my-108)\10*4
  tooltip=file_tips[fi]
 end

 --clamp camera
	camx=mid(0,camx,(terw-16)*8) 
	camy=mid(0,camy,terh*8-106) 

 --tool input
	if (updfn) updfn()
	--loop on all elements
	disp_elts=init_disp_elts()
 for _objs in all(all_objs) do
 	add_disp_elts(_objs)
 end
 add_disp_elts(plrunits)
 add_disp_elts(cpuunits)
end

function init_disp_elts()
 local disp_elts={}
 for i=1,terh do
  disp_elts[i]={}
 end
 return disp_elts
end

function add_disp_elts(elts)
 for e in all(elts) do
  local y=e.pos[2]
  add(disp_elts[y\8+1],e)
 end
end

function sel_elt(mx,my)
 local sx,sy,sel=
  mx+camx,my+camy-7,nil
 for bank in all(disp_elts) do
  for e in all(bank) do
   local yoff=e.edef.yoff or 0
   local x,y,w,h=
    e.pos[1],e.pos[2]+yoff,
    e.w,e.h
   if x<=sx and sx<x+w 
    and y<=sy and sy<y+h then
    sel=e
   end
  end
 end
 return sel
end

-- handle mouse just pressed
function m_pressed(mb,n)
 return mb&n==n and pmb&n==0
end
function m_released(mb,n)
 return pmb and mb&n==0 and pmb&n==n
end

function add_units(_units,plr)
 local units={}
 for u in all(_units) do
  add(units,make_unit(
   plr,
   unitdef[u[1]],
   u[2]*8,
   u[3]*8))
 end
 return units
end

function delete_element(element)
 if (not element) return
 for _objs in all(all_objs) do
  if del(_objs,element) then
   updatecolmask(element,0)
  end
 end
 del(plrunits,element)
 del(cpuunits,element) 
end

-- undo system
undo_stk,redo_stk={},{}
function push_undo(delta)
 if #undo_stk>=10 then
  deli(undo_stk,1)
 end
 add(undo_stk,delta)
 redo_stk={}
end

function apply_delta(d)
 if d.t=="ter" then
  ter_ovr=d.ovr
  local nbw=terw+1
  for k,v in pairs(ter_ovr) do
   local mx=k%nbw
   local my=k\nbw
   paint_ter(mx,my,nbw,v)
  end
  refresh_colmap()
 elseif d.t=="add" then
  local e=d.raw or d.lst[d.idx]
  deli(d.lst,d.idx)
  if d.obj and e then
   updatecolmask(e,0)
  end
 elseif d.t=="del" then
  local e=d.raw
  add(d.lst,e,d.idx)
  if d.obj then
   prepare_obj(e,e.plr)
   updatecolmask(e,1)
  else
   -- reinsert unit directly, plr already in e
   e[2],e[3]=e.pos[1],e.pos[2]
  end
 elseif d.t=="mov" then
  local e=d.elt
  if e.obj then
   updatecolmask(e,0)
   e[2],e[3]=d.tx\8,d.ty\8
   e.pos={d.tx,d.ty}
   prepare_obj(e,e.plr)
   updatecolmask(e,1)
  else
   e[2],e[3]=d.tx,d.ty
   e.pos={d.tx,d.ty}
  end
 end
end

function invert_delta(d)
 if d.t=="ter" then
  -- swap current ter_ovr with snapshot
  local cur=copy_ter_ovr()
  apply_delta(d)
  d.ovr=cur
 elseif d.t=="add" then
  -- add becomes del
  d.t="del"
 elseif d.t=="del" then
  -- del becomes add
  d.t="add"
 elseif d.t=="mov" then
  -- swap ox/oy and tx/ty
  d.ox,d.tx=d.tx,d.ox
  d.oy,d.ty=d.ty,d.oy
  apply_delta(d)
  -- swap back for correct future use
  d.ox,d.tx=d.tx,d.ox
  d.oy,d.ty=d.ty,d.oy
 end
end

function do_undo()
 local d=deli(undo_stk,#undo_stk)
 if (not d) return
 -- save inverse for redo
 local cur=snapshot_for_redo(d)
 apply_delta(d)
 add(redo_stk,cur)
end

function do_redo()
 local d=deli(redo_stk,#redo_stk)
 if (not d) return
 local cur=snapshot_for_redo(d)
 apply_delta(d)
 add(undo_stk,cur)
end

-- build the inverse snapshot before applying
function snapshot_for_redo(d)
 if d.t=="ter" then
  return {t="ter",ovr=copy_ter_ovr()}
 elseif d.t=="add" then
  -- undo of add = del (capture raw before removal)
  return {t="del",lst=d.lst,idx=d.idx,
   raw=d.lst[d.idx],obj=d.obj}
 elseif d.t=="del" then
  -- undo of del = add (keep raw for re-deletion)
  return {t="add",lst=d.lst,idx=d.idx,
   obj=d.obj,raw=d.raw}
 elseif d.t=="mov" then
  -- undo of mov = mov with swapped pos
  return {t="mov",elt=d.elt,
   ox=d.nx,oy=d.ny,
   nx=d.ox,ny=d.oy}
 end
end

-- snapshot ter_ovr (shallow copy ok:
-- all values are numbers)
function copy_ter_ovr()
 local c={}
 for k,v in pairs(ter_ovr) do
  c[k]=v
 end
 return c
end

-- find which list owns an element
function find_lst(element)
 for _objs in all(all_objs) do
  for i,e in ipairs(_objs) do
   if e==element then
    return _objs,i
   end
  end
 end
 for i,e in ipairs(plrunits) do
  if e==element then
   return plrunits,i
  end
 end
 for i,e in ipairs(cpuunits) do
  if e==element then
   return cpuunits,i
  end
 end
 return nil,nil
end

function load_lvl(lvl)
 local cart=cfg_pack_prefix..lvl..".p8"
 --tile map
 reload(0x2000,0x2000,0x1000,cart)
 --map elements
 reload(0x5300,0x3200,768,cart)
 read_lvl(lvl)
 --structure data
 all_objs={objs,obj1,obj2}
 units={unit1,unit2}
 --init players
 refresh_players()
 --init collision mask
 local plr=nil
 for _objs in all(all_objs) do
  prepare_objs(_objs,plr)
  if plr then 
   plr=cpuplr
  else
   plr=curplr
  end
 end
 init_colmap()
 refresh_colmap()
 plrunits,cpuunits=
  add_units(units[1],curplr),
  add_units(units[2],cpuplr)
 dirty=false
 addmsg("compact width "..terw)
 --compact map width
 poke(0x5f57,terw)
 ter_ovr=init_ter_ovr()
end

function init_colmap()
 local res=max(terw,terh)
 colmask,mmres,mmx,mmy=
  {},32/res,
  (terw-res)/4,(terh-res)/4
end
function refresh_colmap()
 for i=0,terw*terh-1 do
  --get map tile,test for collision
  local n=@(0x2000+i%terw+i\terw*terw)
  colmask[i]=fget(n,0) and 1 or 0
 end
 -- objs
 for _objs in all(all_objs) do
  for o in all(_objs) do
   updatecolmask(o,1)
  end
 end
end


function  init_ovr_to_map()
 --autotiling help
 ovr_to_map={}
 for k,v in pairs(map_to_ovr) do
  local nk=v[1]+v[2]*3+v[3]*9
   +v[4]*27
  ovr_to_map[nk]=k
 end
end

function init_ter_ovr()
 local ter_ovr={}
 local nbw,nbh=terw+1,terh+1
 for i=0,nbw*nbh-1 do
  --read map n-1x-1y,n+1y,n+1x,n
  local x,y=i%nbw,i\nbw
  local tl,tr,bl,br=
   mget(x-1,y-1),
   mget(x,y-1),
   mget(x-1,y),
   mget(x,y)
  local res={
   map_to_ovr[tl][4],
   map_to_ovr[tr][3],
   map_to_ovr[bl][2],
   map_to_ovr[br][1]
  }
  local r=-1
  for i=4,1,-1 do
   local a=res[i]
   if r==-1 then
    r=a
   elseif a~=-1 and r~=a then
    r=-2
   end
  end
  -- apply remaining color
  if r>=0 then
   ter_ovr[i]=r
  end
 end
 return ter_ovr
end

function sel_tool()
 updfn,drwfn,drwhud,
  obj_blur,sel=
  upd_sel,draw_sel,nil,
  false,nil
end

function ter_tool()
 updfn,drwfn,drwhud,
  obj_blur,sel=
  upd_ter,draw_ter,draw_tercolpicker,
  true,nil
end

function obj_tool()
 updfn,drwfn,drwhud,
  obj_blur,sel=
  upd_objtool,draw_objtool,draw_objhud,
  false,nil
end

function unit_tool()
 updfn,drwfn,drwhud,
  obj_blur,sel=
  upd_unittool,draw_unittool,draw_unithud,
  false,nil
end

function del_tool()
 updfn,drwfn,drwhud,
  obj_blur=
  del_sel,nil,nil,
  false
end

function file_tool()
 updfn,drwfn,drwhud,
  obj_blur=
  upd_filetool,nil,draw_filehud,
  false
end

function prop_ok()
 --todo store players state
 propseditor.enable=false
 terw,terh,oterw=
  widths[propseditor.sizesellist.sel],
  heights[propseditor.sizesellist.sel],
  terw
 addmsg("width "..terw.." height "..terh)
 addmsg("remapping collision stuffs")
 --re-map width 32/64
 remap_map(oterw,terw)
 poke(0x5f57,terw)
 fill_emptymap()
 init_colmap()
 refresh_colmap()
 init_ovr_to_map()
 ter_ovr=init_ter_ovr()
 --update players
 local inp=propseditor.child_ui
 plrs={
  --idx,startx,starty,gold,wood
  {1,inp[1].val/10,inp[2].val/10},
  {2,inp[3].val/10,inp[4].val/10}
 }
 refresh_players()
end

function prop_cancel()
 sfx(0)
 --todo store players state
 propseditor.enable=false
end

function fill_emptymap()
 local nbw,nbh=terw+1,terh+1
 for j=0,nbh do
  for i=0,nbw do
   local k=i+j*nbw
   if ter_ovr[k]==nil then
    local col=rnd(100)>95 and 1 or 0
    if not paint_ter(i,j,nbw,col) then
     paint_ter(i,j,nbw,0)
    end
   end
  end
 end
end

function remap_map(owidth,nwidth)
 if (owidth==nwidth) return
 addmsg("ow "..owidth.." nw "..nwidth)
 if owidth<nwidth then
  --32 to 64 for ex
  local src=0x2000+0x1000\nwidth*owidth-owidth
  for dst=0x3000-nwidth,0x2000,-nwidth do
   if src~=dst then
    memcpy(dst,src,owidth)
    clearmem(src,owidth)
   end
   src-=owidth
  end
 else
  --64 to 32
  local dst=0x2000+nwidth
  for src=0x2000+owidth,0x3000-owidth,owidth do
   memcpy(dst,src,owidth)
   dst+=nwidth
  end
 end
end

function refresh_players()
 if plrs and #plrs>1 and #plrs[1]==3 then
  curplr,cpuplr=
   {idx=1,gold=plrs[1][2]*10,wood=plrs[1][3]*10},
   {idx=2,gold=plrs[2][2]*10,wood=plrs[2][3]*10}
 else
  curplr,cpuplr=
   {idx=1,gold=200,wood=100},
   {idx=2,gold=200,wood=100}
 end
end

-->8
--unpack gfx+vspr
function unpack_gfx()
 bank_loaded={}
 for i=1,4 do
  local addr=0x6000+i*0x2000
  local cart=cfg_pack_prefix..i..".p8"
  poke2(addr,0xfffe)
  reload(addr,0,0x2000,cart)
  bank_loaded[i-1]=peek2(addr)~=0xfffe
  if not bank_loaded[i-1] then
   memset(addr,0,0x2000)
   addmsg(cart.." not found")
  end
 end
end

--prepare objs
function prepare_objs(_objs,plr)
 for o in all(_objs) do
  prepare_obj(o,plr)
 end
 init_objsdef()
end

function prepare_obj(o,plr)
 local def=objsdef[o[1]]
 o.pos,o.obj,
 o.mhp,o.hp,o.st,o.t,
 o.draw,o.def,o.edef,
 o.cxoff,o.cyoff,o.plr,o.factq=
  {o[2]*8,o[3]*8},true,
  def.hp,def.hp,1,0,
  draw_obj,o[1],def,
  def.w\2,def.yoff+def.h\2,
  plr,{}

 o.w,o.h=def.w,def.h
end

function updatecolmask(o,v)
 loopcm(
  o.edef,
  function(i,j)
   colmask[
    o[2]+i+(o[3]+j)*terw]=v
  end
 )
end

--init objs masks
function init_objsdef()
 for def in all(objsdef) do
  for sts in all(def.sts) do
   --mask,shadowmask
   sts.sa,sts.ssa=
    initmasks(
     sts.s or def.s,
     sts.m or def.m,
     sts.sm or def.sm,
     sts.tw or def.tw,
     sts.th or def.th)
  end
 end
end
function initmasks(sp,ma,sm,tw,th) 
 local tbl,stbl={},{}
 for j=0,th-1 do
  local m=ma and ma[j+1] or 255
  local s=sm and sm[j+1] or 0
  for i=0,tw-1 do
   local val=sp+i+j*16
   applymask(m,i,val,tbl)
   applymask(s,i,val,stbl)
  end
 end
 return tbl,stbl
end
function applymask(m,i,v,tbl)
 if m>>i&1==0 then
  v=0
 end
 add(tbl,v)
end

-- virt sprite
function vspr(nspr,x,y,flipx,blur)
 --flipx=flipx or false
 --map spritesheet to highmem
 poke(0x5f54,nspr\256*32+128)
 if blur then
  poke(0x5f34,0x3)
  color(0x1300.5a5a)
 end
 spr(nspr%256,x,y,1,1,flipx)
 color(0x1300.0000)

 --restore scr spr mapping
 poke(0x5f54,0)
end

function vsspr(
  b,sx,sy,w,h,dx,dy,flipx)
 flipx=flipx or false

 poke(0x5f54,b*32+128)
 sspr(sx,sy,w,h,dx,dy,w,h,flipx)
 poke(0x5f54,0)
end

function getarridx(arr,e)
 for i,a in ipairs(arr) do
  if (a==e) return i
 end
 return -1
end


-- px9 compress (as str to clipboard)

-- x0,y0 where to read from
-- w,h   image width,height
-- dest  address to store
-- vget  read function (x,y)

function
    px9_comp(x0,y0,w,h,dest,vget)

    local dest0=dest
    local bit=1
    local byte=0

    local function vlist_val(l, val)
        -- find position and move
        -- to head of the list

--[ 2-3x faster than block below
        local v,i=l[1],1
        while v!=val do
            i+=1
            v,l[i]=l[i],v
        end
        l[1]=val
        return i
--]]

--[[ 8 tokens smaller than above
        for i,v in ipairs(l) do
            if v==val then
                add(l,deli(l,i),1)
                return i
            end
        end
--]]
    end

    local cache,cache_bits=0,0
    function putbit(bval)
     cache=cache<<1|bval
     cache_bits+=1
        if cache_bits==8 then
            poke(dest,cache)
            dest+=1
            cache,cache_bits=0,0
        end
    end

    function putval(val, bits)
        for i=bits-1,0,-1 do
            putbit(val>>i&1)
        end
    end

    function putnum(val)
        local bits = 0
        repeat
            bits += 1
            local mx=(1<<bits)-1
            local vv=min(val,mx)
            putval(vv,bits)
            val -= vv
        until vv<mx
    end


    -- first_used

    local el={}
    local found={}
    local highest=0
    for y=y0,y0+h-1 do
        for x=x0,x0+w-1 do
            c=vget(x,y)
            if not found[c] then
                found[c]=true
                add(el,c)
                highest=max(highest,c)
            end
        end
    end

    -- header

    local bits=1
    while highest >= 1<<bits do
        bits+=1
    end

    putnum(w-1)
    putnum(h-1)
    putnum(bits-1)
    putnum(#el-1)
    for i=1,#el do
        putval(el[i],bits)
    end


    -- data

    local pr={} -- predictions

    local dat={}

    for y=y0,y0+h-1 do
        for x=x0,x0+w-1 do
            local v=vget(x,y)

            local a=y>y0 and vget(x,y-1) or 0

            -- create vlist if needed
            local l=pr[a] or {unpack(el)}
            pr[a]=l

            -- add to vlist
            add(dat,vlist_val(l,v))
           
            -- and to running list
            vlist_val(el, v)
        end
    end

    -- write
    -- store bit-0 as runtime len
    -- start of each run

    local nopredict
    local pos=1

    while pos <= #dat do
        -- count length
        local pos0=pos

        if nopredict then
            while dat[pos]!=1 and pos<=#dat do
                pos+=1
            end
        else
            while dat[pos]==1 and pos<=#dat do
                pos+=1
            end
        end

        local splen = pos-pos0
        putnum(splen-1)

        if nopredict then
            -- values will all be >= 2
            while pos0 < pos do
                putnum(dat[pos0]-2)
                pos0+=1
            end
        end

        nopredict=not nopredict
    end

    if cache_bits>0 then
        -- flush
        poke(dest,cache<<8-cache_bits)
        dest+=1
    end

    return dest-dest0
end

-->8
-- drawing map and things
function _draw()
 cls()
 -- game mode
 camera(0,-7)
 draw_map()
 draw_all_elts()
 
 if (drwfn) drwfn()
 camera()
 draw_hud()
 for ui_el in all(ui_elements) do
  ui_el:draw()
 end
 --mouse
 palt(0x0001)--0 false,15 true
 spr(26,mx-1,my)  

 --?"▤"..stat(0),0,9,7
 --?"∧"..stat(1)
 --?"mx="..mx..",".."my="..my
-- ?"dirty "..(dirty and "true" or "false")
-- ?"camx="..camx..",".."camy="..camy
-- ?"all_objs[1] "..#all_objs[1]
-- ?"all_objs[2] "..#all_objs[2]
-- ?"all_objs[3] "..#all_objs[3]
-- ?"plrunits "..#plrunits
-- ?"cpuunits "..#cpuunits
 frm+=1
end

function draw_map()
 -- terrain
 palt(0, false)
 local celx,cely=
  camx/8,camy/8
 map(celx,cely,
     -(camx%8),-(camy%8),17,14)
end


function draw_all_elts()
 for bank in all(disp_elts) do
  for e in all(bank) do
   e:draw()
  end
 end
end

function draw_obj(o,blur)
 if (o.dis) return
 local def,sa=o.edef
 local state=def.sts[o.st]
 --handle shadows
 if o.shad then
  if def.spal then
   ?"\^!"..def.spal
  else
   pal()
  end
  palt(def.spalt or 0x7fff)
  sa=state.ssa
 else
  palt(state.mpalt or def.mpalt or 0x8001)
  sa=state.sa
 end
 --x offset,y offset
 local xoff,yoff,x,y,tw=
  state.xoff or 0,
  state.yoff or 0,
  o.pos[1]-camx,
  o.pos[2]-camy,
  state.tw or def.tw
-- pset(x,y,0)
 if o==sel then
  --highlight selection
  local oy,selcol=
   y+def.yoff,11
  if (sel.plr==curplr)selcol=12
  if (sel.plr==cpuplr)selcol=10
  rect(x-1,oy,x+o.w,oy+o.h,selcol)
 end
 --w,h actif state or def
 x+=xoff
 y+=yoff
-- pset(x+1,y,1)
 for i,v in ipairs(sa) do
  if v~=0 then
   local dx,dy=
    (i-1)%tw,(i-1)\tw
   vspr(v,
        x+dx*8, 
        y+dy*8,
        false,
        state.blur 
         or obj_blur
         or blur)
  end
 end
end

function draw_unit(u)
 local def,ti=u.edef,u.t\3+1
 local ianim=def.sts[u.st].a
 local anim=anims[ianim]
 if (not anim) return
   
 local flipx=false--u.dpos and u.dpos[1]<0
 draw_anim(
  u.pos,
  anim,
  ti,
  flipx,
  u)
end
function draw_anim(
  pos,anim,ti,flipx,u)
 --virtual sprite
 pal()
 palt(anim.transp)
 local x,y=
  pos[1]-camx,
  pos[2]-camy
 --highlight selection
-- if getarridx(sel,u)>=0 then
 if sel==u then
  local selcol=u.plr==curplr and 12 or 10
  rect(x-1,y-1,
       x+u.w-1,y+u.h-1,selcol)
 end
 if (u and u.plr~=curplr) pal(yelpal)
 
 local toff=anim.once
  and min(ti,anim.nbfrm)
  or ti%anim.nbfrm+1
  
 local s=anim[toff]--frame
 local ofx=flipx and u.w-s.w-s.ofx or s.ofx
 
 vsspr(s.b,s.x,s.y,
  s.w,s.h,
  x+ofx,y+s.ofy,
  flipx)

 pal()
 palt()
end
function draw_hud()
 rectfill(0,107,127,127,0)
 --bars
 rect(-1,95,32,128,5)
 rect(32,106,53,127)
 rect(53,106,95,128)
 --fill
 rectfill(0,96,31,106,0)--map
 rectfill(0,0,127,7)--top bar
 --empty actions
 for i=105,127,11 do
  rect(i,107,i,127,1)
  if (i>105) rect(96,i,127,i)
 end 
 for i=106,117,11 do
  rect(i,107,i,127,5)
  rect(96,i,127,i)
 end
 --header
 ?"\14\fa🐱\-b\f4⬇️\-b\f9░\f7 "..(curplr.gold),1,1
 ?"\14\f3⬅️\f4\-b😐\fb\-b♪\f7 "..(curplr.wood),28,1
 ?"\14\fa🐱\-b\f4⬇️\-b\f9░\f7 "..(cpuplr.gold),65,1
 ?"\14\f3⬅️\f4\-b😐\fb\-b♪\f7 "..(cpuplr.wood),92,1
 drawmnu(smnu)
 if (drwhud) drwhud()
 drawminimap()
 -- tooltip
 if tooltip then
  local tw=#tooltip*4+2
  rectfill(0,120,tw,127,0)
  ?tooltip,1,121,6
 end
end

function drawmnu(imnu)
 local mnu=menu[imnu]
 for i,v in pairs(mnu) do
  if ismnuact(v) then
   drawbtn(v.ico,i-1,v.flx or false,ibtn==i)
  end
 end
end
--s sprite nb, i grid position
function drawbtn(s,i,flx,press)
 if (not s) return
 local x0,y0=
   95+i%3*11,
   106+i\3*11
   
 local x1,y1=x0+1,y0+1

 if (press) pal(darkpal[1])
 drawspricon(s,x1,y1,flx)
 --upper left frame
 rectfill(x0,y0,x0,y0,6)
 rectfill(x1,y0,x0+9,y0,13)
 rectfill(x0,y1,x0,y0+9)
 pal()
end
function drawspricon(s,x,y,flx) 
 spr(48+s,x,y)
end
function ismnuact(mn)
 if (mn.vis) return mn.vis()
 return true
end
function drawicon(s,x,y,flx) 
 vsspr(1,s%14*9,90+s\14*9,
  9,9,x,y,flx)
end

function draw_objsel(obj)
 --draw collision mask
 fillp(░)--▒░
 bok=true
 local x,y=obj.pos[1],obj.pos[2]
 loopcm(
  bdef,
  function(i,j)
   local sx,sy=x+i*8-camx,y+j*8-camy
   local idx=postoidx({sx+camx,sy+camy})
   local col=
    colget(colmask,idx)
      and 8 or 11
   rectfill(sx,sy,sx+8,sy+8,col)
   bok=bok and col==11
  end
 ) 
 --draw blured obj
 draw_obj(obj,true)
end

function drawminimap()
 camera(mmx,mmy)
 for k2=0,1023 do
  local i,j=k2%32,k2\32
  local x,y=i\mmres,j\mmres
  local c=maptocolor[mget(x,y)],c
  if c then
   rectfill(i,j+96,i,j+96,c)
  end
 end
 --viewed area
 local ulx,uly=
  camx/8*mmres,camy/8*mmres+96
 rect(ulx,uly,
  ulx+16*mmres-1,uly+13*mmres,6)
 camera()
end
-->8
-- ui tools
--global const
local portraitbox=
 {x=32,y=105,w=21,h=22}
----------------
-- select tool
function upd_sel()
 --handle clic
 if m_pressed(mb,0x01) then
  --select unit
  sel=sel_elt(mx,my)
  if sel then
   drag_sel,omx,omy,opos,ocamx,ocamy=
    true,mx,my,sel.pos,camx,camy
   -- save position before drag
   sel_ox,sel_oy=sel.pos[1],sel.pos[2]
   if sel.obj then
    updatecolmask(sel,0)
   end
  end
 end
 if sel and drag_sel then
  local dx,dy=mx-omx,my-omy
  dx+=camx-ocamx
  dy+=camy-ocamy
  local pos={
   opos[1]+dx,
   opos[2]+dy,
  }
  if sel.obj then
   bdef=objsdef[sel[1]]
   sel.pos={
    mid(0,pos[1]\8*8,(terw-bdef.tw)*8),
    mid(0,pos[2]\8*8,(terh-bdef.th)*8)
   }   
  else
   sel.pos={
    mid(0,pos[1],terw*8-8),
    mid(0,pos[2],terh*8-16)
   }
   sel[2],sel[3]=
    sel.pos[1],
    sel.pos[2]
  end
 end 
 if m_released(mb,0x01) and sel then
  if omx~=mx or omy~=my then
   push_undo({
    t="mov",elt=sel,
    ox=sel_ox,oy=sel_oy,
    nx=sel.pos[1],ny=sel.pos[2]
   })
   dirty=true
  end
  drag_sel,omx,omy,opos=
   false
  if sel.obj then
   if bok then
    sel[2],sel[3]=
     sel.pos[1]\8,
     sel.pos[2]\8
   end
   prepare_obj(sel,sel.plr)
   updatecolmask(sel,1)
  end
 end
end
function draw_sel()
 if drag_sel and sel and sel.obj then
  draw_objsel(sel)
 end
end
----------------
-- delete tool
function del_sel()
 if m_pressed(mb,0x01) then
  local sel2=sel_elt(mx,my)
  if sel2 then
   local lst,idx=find_lst(sel2)
   if lst then
    push_undo({
     t="del",
     lst=lst,idx=idx,
     raw=sel2,
     obj=sel2.obj,
     plr=sel2.plr
    })
   end
   delete_element(sel2)
   dirty=true
  end
 end
end
----------------
-- terrain tool
function upd_ter()
 -- colpicker ?
 local pic=(mx-62)\8+(my-113)\8*16
 if mb&1==1 and pic>=0 and pic<=2 then
  colsel=pic
  return
 end
 -- clamp clic on map zone
 if (my>105) return
 -- snapshot before first stroke
 if m_pressed(mb,0x01) then
  ter_snap=copy_ter_ovr()
 end
 -- which
 if m_released(mb,0x01) then
  push_undo({t="ter",ovr=ter_snap})
  --store new map state
  refresh_colmap()
  dirty=true
 end
 local nbw=terw+1
 local mapx,mapy=
  mid(0,(mx-camx%8+camx+4)\8,nbw),
  mid(0,(my-camy%8+camy)\8,terh+1)
 -- draw to map
 if mb&1==1 then
  paint_ter(mapx,mapy,nbw,colsel)
 end
end
function paint_ter(mapx,mapy,nbw,col)
 --check if valid because
 --2 combo miss in tileset
 local k=mapx+mapy*nbw
 local oldv=ter_ovr[k]
 ter_ovr[k]=col
 local a,b,c,d=
  get_tile(mapx,mapy,nbw),
  get_tile(mapx-1,mapy,nbw),
  get_tile(mapx,mapy-1,nbw),
  get_tile(mapx-1,mapy-1,nbw)
 if not a or not b or not c or not d then
  ter_ovr[k]=oldv
  return false
 else
  mset(mapx,mapy,a)
  mset(mapx-1,mapy,b)
  mset(mapx,mapy-1,c)
  mset(mapx-1,mapy-1,d)
 end
 return true
end

function get_tile(mapx,mapy,nbw)
 local a,b,c,d=
  ter_ovr[mapx+mapy*nbw],
  ter_ovr[mapx+1+mapy*nbw],
  ter_ovr[mapx+mapy*nbw+nbw],
  ter_ovr[mapx+1+mapy*nbw+nbw]
 return ovr_to_map[(a or 0)
   +(b or 0)*3
   +(c or 0)*9
   +(d or 0)*27]
end

function draw_ter()
 --
 local nbw=terw+1
 local mapx,mapy=
  mid(0,(mx+4)\8,nbw),
  mid(0,my\8,terh+1)
 local x0,y0=
  mapx*8-4-camx%8,
  mapy*8-4-camy%8
 local x1,y1=x0+7,y0+7
 rect(x0-2,y0-2,x1+2,y1+2,0)
 rect(x0-1,y0-1,x1+1,y1+1,7)
end

function draw_tercolpicker()
 --map color picker
 rectfill(62,113,69,120,3)
 rectfill(70,113,77,120,4)
 rectfill(78,113,85,120,12)
 rect(62+colsel*8,113,
  69+colsel*8,120,7)
end

----------------
-- obj tools
local objtyp,objico,ibdef=
 0,
 {55,0,28,56,14,1,29,15,42},
 0
function make_elementpicker(arr)
 return {
  seltyp=0,selielt=0,
  iedef=arr[0][0],
  elements=arr,
  update=upd_eltpicker
 }
end
function upd_eltpicker(picker)
 local seltyp,selielt=
  picker.seltyp,picker.selielt
 if m_pressed(mb,0x01)
  and insidebox(mx,my,portraitbox) then
  seltyp=(seltyp+1)%(#(picker.elements)+1)
  selielt=min(selielt,#(picker.elements[seltyp]))
  refreshselobj=true
 end
 if m_pressed(mb,0x01) 
  and insidebox(mx,my,
   {x=56,y=107,w=36,h=20}) then
  local tmp=(mx-56)\9+(my-105)\10*4
  if tmp<=#picker.elements[seltyp]then
   selielt=tmp
   refreshselobj=true
  end
 end
 if refreshselobj then
  picker.iedef,refreshselobj=
   picker.elements[seltyp][selielt],
   false
 end
 picker.seltyp,picker.selielt=
  seltyp,selielt
end 

function upd_objtool()
 objpicker:update()
 if not selobj or objpicker.iedef~=ibdef then
  bdef,ibdef=
   objsdef[objpicker.iedef],
   objpicker.iedef
  selobj={ibdef,0,0}
  prepare_obj(selobj)
 end
 if bdef then
  curx,cury=
   mid(0,(mx-camx%8+camx)\8,terw-bdef.tw),
   mid(0,(my-camy%8+camy)\8,terh-bdef.th)
  selobj.pos={curx*8,cury*8}
 end
 if m_pressed(mb,0x01) and bdef 
  and my<105 and bok then
  local lst=objs
  if(objpicker.seltyp==1)lst=obj1
  if(objpicker.seltyp==2)lst=obj2
  newobj={ibdef,curx,cury}
  local plr=nil
  if(objpicker.seltyp==1)plr=curplr
  if(objpicker.seltyp==2)plr=cpuplr
  prepare_obj(newobj,plr)
  updatecolmask(newobj,1)
  add(lst,newobj)
  push_undo({
   t="add",lst=lst,
   idx=#lst,obj=true
  })
  dirty=true
 end
end
function draw_objtool()
 -- drawselection
 if selobj then
  draw_objsel(selobj)
 end
end
function draw_objhud()
 local objtyp,seliobj=
  objpicker.seltyp,
  objpicker.selielt
 --obj type picker
 spr(52+objtyp,39,112)
 --obj picker
 --vsspr b,sx,sy,w,h,dx,dy,flipx
 local x,y=56,107
 local els=objs_sel[objtyp]
 for i=0,#els do
  if objtyp==0 then
   spr(objico[objs_sel[objtyp][i]],
    x+i%4*9,y+i\4*9) 
  else
   drawicon(objico[objs_sel[objtyp][i]],
    x+i%4*9,y+i\4*9) 
  end
 end
 if seliobj then
  rect(x+(seliobj%4)*9,y+seliobj\4*9,
   x+9+(seliobj%4)*9,y+9+seliobj\4*9,7)
 end
end
  
----------------
-- units tools
local unittyp,iudef=0

function upd_unittool()
 unitpicker:update()
 if unitpicker.iedef~=iudef 
  or not selunit then
  udef,iudef=
   unitdef[unitpicker.iedef],
   unitpicker.iedef
  selunit=make_unit(nil,udef,0,0)
 end
 if udef then --todo sizemax
  curx,cury=
   mid(0,(mx+camx),terw*8-8),
   mid(0,(my+camy-8),terh*8-16)
 end
 if m_pressed(mb,0x01)
  and my<105 then
  --todo collision
  local plr=curplr
  local lst=plrunits
  if unitpicker.seltyp~=0 then
   plr=cpuplr
   lst=cpuunits
  end
  newunit=make_unit(
   plr,udef,curx,cury)
  add(lst,newunit)
  push_undo({
   t="add",lst=lst,
   idx=#lst,obj=false,
   plr=plr
  })
  dirty=true
 end
end

function draw_unittool()
 -- drawselection
 if selunit then
  --todo draw collision
--  bok=true
  selunit.pos={curx,cury}
  draw_unit(selunit)
 end
end

function draw_unithud()
 local seltyp,selielt=
  unitpicker.seltyp,
  unitpicker.selielt
 --sel type picker
 spr(53+seltyp,39,112)
 --sel picker
 local x,y=56,107
 local els=unit_sel[unittyp]
 for i=0,#els do
  drawicon(unitdef[unit_sel[unittyp][i]].ico,
   x+i%4*9,y+i\4*9) 
 end
 if selielt then
  rect(x+(selielt%4)*9,y+selielt\4*9,
   x+9+(selielt%4)*9,y+9+selielt\4*9,7)
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
function addmsg(msg)
 add(msgvwr.msgs,msg)
end
----------------
-- file tools
file_icons={[0]=58,59,60,64,66,67}
file_tips={[0]="load map","save map","export to game","map props","undo","redo"}

function upd_filetool()
 --on file icon click
 selifile=(mx-55)\10%4
  +(my-109)\8*4+(mx-55)\40*48
 if selifile and m_pressed(mb,0x01) then
  if selifile==0 then
   lvlselector.enable,
   propseditor.enable=
    true,false
   pmb=mb--cancelclick
  elseif selifile==1 then
   save_map()
  elseif selifile==2 then
   export()
  elseif selifile==3 then
   propseditor.enable,
   lvlselector.enable=
    true,false
   propseditor:refresh()
   pmb=mb--cancelclick
  elseif selifile==4 then
   do_undo()
  elseif selifile==5 then
   do_redo()
  end
 end
end

function draw_filehud()
 --sel picker
 local x,y=55,108
 for i=0,#file_icons do
  local xx,yy=x+i%4*10,y+i\4*10
  spr(file_icons[i],xx,yy) 
  if i==selifile then
   rect(xx,yy,xx+8,yy+8,1)
  end
 end
end
----------------
-- level selector
lvlselbox,maps=
 {x=40,y=40,w=48,h=40},
 split("map 1,map 2,map 3,map 4")
function make_lvlselector()
 return {
  enable=false,
  child_ui=make_selectlist(48,56,20,maps,lvlsel_click),
  update=update_lvlselector,
  draw=draw_lvlselector
 }
end
function update_lvlselector(lsel,mx,my,mb)
 if (not lsel.enable) return
 if (lsel.confirm) return
 lsel.child_ui:update()
 if m_pressed(mb,0x02) then
  lsel.enable=false
 end
 if m_pressed(mb,0x01) then
  if not insidebox(mx,my,lvlselbox) then
   lsel.enable=false
   del(ui_elements,lsel.confirm)
  end
 end
end
function lvlsel_click(sl,isel)
 local lsel=lvlselector
 lsel.sel=isel
 --confirm
 if dirty then
  lsel.confirm=make_confirm(lvlsel_loadlvl,lsel)
  add(ui_elements,lsel.confirm)
  pmb=mb--cancelclick
  return
 end
 lvlsel_loadlvl(lsel,true)
end
function lvlsel_loadlvl(lsel,ok)
 lsel.enable,lsel.confirm=
  false,nil
 if ok then
  lvl=lsel.sel
  load_lvl(lvl)
  addmsg("map "..lvl.." loaded")
  
 end
end
function draw_lvlselector(lsel)
 if (not lsel.enable) return
 rectfill(40,40,88,80,5)
 print("open map",48,42,6)
 lsel.child_ui:draw()
end
----------------
-- confirm
confirmbox={x=40,y=84,w=48,h=16}
function make_confirm(fn,arg)
 return {
  cb_fn=fn,
  cb_arg=arg,
  update=update_confirm,
  draw=draw_confirm
 }
end
function update_confirm(cf)
 cf.tmp=(mx-56)\8%2+(my-91)\8*2+(mx-56)\16*32
 if m_pressed(mb,0x01) then
  if cf.tmp\2==0 then
   --feedback
   cf.cb_fn(cf.cb_arg,cf.tmp==0)
   del(ui_elements,cf)
  end
  if not insidebox(mx,my,confirmbox) then
   cf.cb_fn(cf.cb_arg,false)
   del(ui_elements,cf)
  end
 end
end
function draw_confirm(cf)
 rectfill(40,84,88,100,5)
 print("confirm",51,86,6)
 spr(62,56,91)
 spr(63,64,91)
 if cf.tmp and cf.tmp\2==0 then
  rect(56+cf.tmp*8,91,64+cf.tmp*8,99,1)
 end
end
----------------
-- level props
propseditbox,map_sizes,widths,heights=
 {x=16,y=40,w=96,h=52},
 split("32x32,64x32,32x64,64x64"),
 --,"128x32","32x128"}
 split("32,64,32,64"),
 split("32,32,64,64")

function fromsize()
 for i=1,#widths do
  if terw==widths[i]
   and terh==heights[i] then
   return i
  end
 end
end
function propsrefresh(pe)
 pe.sizesellist.sel=fromsize()
 res={curplr.gold,curplr.wood,
  cpuplr.gold,cpuplr.wood}
 for i=1,4 do
  pe.child_ui[i].val=res[i]
 end
end
function make_propseditor()
 local sizesellist=
  make_selectlist(86,56,20,map_sizes)

 return {
  enable=false,
  update=update_propseditor,
  draw=draw_propseditor,
  sizesellist=sizesellist,
  refresh=propsrefresh,
  child_ui={
   make_inputnum(44,60,0,2500),
   make_inputnum(64,60,0,2500),
   make_inputnum(44,68,0,2500),
   make_inputnum(64,68,0,2500),
   sizesellist,
   make_sprbtn(62,40,80,prop_ok),
   make_sprbtn(63,50,80,prop_cancel) 
  }
 }
end
function update_propseditor(pe,mx,my,mb)
 if (not pe.enable) return
 if m_pressed(mb,0x01) then
  if not insidebox(mx,my,propseditbox) then
   pe.enable=false
  end
 end
 for c in all(pe.child_ui) do
  c:update()
 end
end
function draw_propseditor(pe)
 if (not pe.enable) return
 rectfill(16,40,112,92,5)
 print("map properties",36,42,6) 
 print("size",86,50)
 spr(56,47,50)
 spr(55,66,50)
 print("human",20,60)
 print("cpu",20,68)
 for c in all(pe.child_ui) do
  c:draw()
 end
end
function peclick(sl,isel)
 local pe=propseditor
 pe.isize=isel
end

----------------
-- ui elements
function make_sprbtn(n,x,y,onclk)
 return {
  x=x,y=y,
  nspr=n,
  draw=draw_sprbtn,
  update=update_sprbtn,
  onclick=onclk
 }
end
function draw_sprbtn(sb)
 --palt(0x8000)
 spr(sb.nspr,sb.x,sb.y)
end
function update_sprbtn(sb)
 local xc,yc=
  (mx-sb.x)\8,
  (my-sb.y)\8
 local sel=xc+yc*16
 if (sel~=0) return
 --mspr=9
 if m_pressed(mb,0x01) then
  sb:onclick()
 end
end

function make_inputnum(x,y,vmin,vmax)
 local input={
  x=x,
  y=y,
  val=val,
  vmin=vmin,vmax=vmax,
  update=update_inputnum,
  draw=draw_inputnum
 }
 return input
end
function update_inputnum(inp)
 if m_pressed(mb,0x01) then
  if insidebox(mx,my,{x=inp.x+15,y=inp.y-1,w=5,h=3}) then
   incval(inp,10)
  elseif insidebox(mx,my,{x=inp.x+15,y=inp.y+3,w=5,h=3}) then
   incval(inp,-10)
  end
 end
end
function draw_inputnum(inp)
 ?inp.val,inp.x,inp.y,0
 spr(65,inp.x+15,inp.y-1)
end
function incval(inp,inc)
 inp.val=mid(inp.vmin,inp.val+inc,inp.vmax)
end

function make_selectlist(x,y,w,values,onclk)
 return {
  x=x,y=y,w=w,sel=1,
  values=values,
  update=update_selectlist,
  draw=draw_selectlist,
  onclick=onclk
 }
end
function update_selectlist(sl)
 local x,y,w,nbvalues=
  sl.x,sl.y,sl.w,#(sl.values)
 local tmp=(mx-x)\w*16+(my-y)\6
 if m_pressed(mb,0x01) then
  if tmp and tmp\nbvalues==0 then
   sl.sel=tmp+1
   if (sl.onclick)sl:onclick(tmp+1)
  end
 end
 if tmp\nbvalues==0 then
  sl.hover=tmp+1
 end
end
function draw_selectlist(se)
 local x,y=se.x,se.y
 for k,v in pairs(se.values) do
  if k==se.hover or k==se.sel then
   local col=(k==se.hover and 1 or 6)
   rect(x-1,y-1,x+19,y+5,col)
  end
  ?v,x,y,0
  y+=6
 end
end

 
-->8
-- utils/undo ?
function insidebox(x,y,box)
 return x>=box.x
  and x<=box.x+box.w
  and y>=box.y
  and y<box.y+box.h
end
--
function loopcm(def,fn)
 local ma=def.cm
 for j=0,def.th-1 do
  for i=0,def.tw-1 do
   if ma[j+1]>>i&1~=0 then
    fn(i,j)
   end
  end
 end
end
function postoidx(pos)
 return pos[1]\8+pos[2]\8*terw
end
function colget(arr,i)
 --out of bound or collision
 return i<0 or i>#arr or arr[i]==1
end
-->8
--read/write game data
local obj_props,anim_props,frm_props=
 split"1,2,3",
 split"once,transp,sfrm,sfx,nbfrm",
 split"b,x,y,w,h,ofx,ofy"
 
 
function save_map()
 --check size 768 bytes max
 --write 768 0 before ?
 local size=
  #objs*3+1
  +#obj1*3+1
  +#obj2*3+1
  +#plrunits*3+1
  +#cpuunits*3+1
  +2--terrain width/height
 --addmsg("store elements size "..size)
 if size>768 then
  --add message wont fit !!
  addmsg("cant save")
  addmsg("maximum 768")
  sfx(3)
  return
 end
 save_addr=0x5300
 write_block(objs)
 write_block(obj1)
 write_block(obj2)
 --store units
 write_block(compactunits(plrunits))
 write_block(compactunits(cpuunits))
 write_byte(terw)
 write_byte(terh)
 write_block(plrs)
 --save map to packx.p8
 savecart=cfg_pack_prefix..lvl..".p8"
 if @0x5f57==128 then
  convert128to32()
 end
 cstore(0x2000,0x2000,0x1000,savecart)
 cstore(0x3200,0x5300,768,savecart)
 addmsg("map save to "..savecart)
 addmsg("written "..save_addr-0x5300)
 dirty=false
end
function convert128to32()
 local dst=0x2000
 for i=0x2000,0x2fff,128 do
  memcpy(dst,i,32)
  dst+=32
 end
 addmsg("convert to 32")
end
function export()
 --export map objs
 addmsg("exporting")
-- cstore(0,0x5300,768,cfg_anim_cart)
 --export maps to cfg_export_cart
 local off,expcart=
  0xd09,cfg_export_cart
 poke(0x1000,4)
 cstore(0x1000,0x1000,1,expcart)
 poke(0x5f57,128)
 for i=1,4 do
  --map
  local cart=cfg_pack_prefix..i..".p8"
  local len,headr=
   append_map(cart),
   0xcff+i*2
  poke(headr,len%256,len\256)
  cstore(headr,headr,2,expcart)
  cstore(off,0x4300,len,expcart)
  off+=len
  --elements
  reload(0x1000,0x3200,768,cart)
  cstore(0x1d00+i*768,0x1000,768,cfg_anim_cart)
 end
 poke(0x5f57,terw)
 sfx(2)
 addmsg("export ok")
 --restore current level map
 reload(0x2000,0x2000,0x1000,
  cfg_pack_prefix..lvl..".p8")
end
function append_map(cart)
 --load map
 reload(0x2000,0x2000,0x1000,cart)
 --compress and return length
 return px9_comp(
--  0,0,terw,terh,
  0,0,128,32,
  0x4300,mget)
end

function write_block(_arr)
 write_byte(#_arr)
 for e in all(_arr) do
  for i=1,#e do
   write_byte(e[i])
  end
 end
end

function write_byte(b)
 poke(save_addr,b)
 save_addr+=1
end

function compactunits(_arr)
 local res={}
 for e in all(_arr) do
  local e2={}
  add(res,e2)
  for i=1,#e do
   e2[i]=e[i]
   if i>1 then
    e2[i]\=8
   end
  end
 end
 return res
end
--load level
function read_lvl()
 read_addr,roff=0x5300,0
 objs,obj1,obj2=
  load_elt(),
  load_elt(),
  load_elt()
 --units
 unit1=load_elt()
 unit2=load_elt()
 terw,terh=read_byte(),read_byte()
 addmsg("terw "..terw.." terh "..terh)
 --players
 plrs=load_elt()
end

function load_elt()
 local _elts={}
 for i=1,read_byte() do
  add(_elts,loadblk(obj_props))
 end
 return _elts
end

function read_byte()
 local val=@read_addr-roff
 read_addr+=1
 return val
end
function loadblk(keys)
 local blk={}
 for v in all(keys) do
  blk[v]=read_byte()
 end
 return blk
end

--load anim
function loadanim()
 reload(0x800,0x800,1024,cfg_anim_cart)
 --init read addr,here map memory
 read_addr,roff=0x800,127
 --nb anims
 anims={}
 for i=1,read_byte() do
  local newanim=loadblk(anim_props)
  newanim.once=newanim.once==1
  newanim.transp=0x8000>>>newanim.transp
  add(anims,newanim)
  for j=1,newanim.nbfrm do
   add(newanim,loadblk(frm_props))
  end
 end
 reload(0x800,0x800,1024)
end


function clearmem(addr,len)
 for i=addr,addr+len-1 do
  poke(i,0)
 end
end

-->8
--str/tbl parser
function p_num(str,pos)
 local k,pos,val=nxt_delim(str,pos)
 return tonum(val),pos
end
function p_str(str,pos)
 local k,pos,val=nxt_delim(str,pos)
 return val,pos
end
function p_fun(str,pos)
 local val,pos=p_str(str,pos)
 return _ENV[val],pos
end
function nxt_delim(str,pos,val)
 val=val or ""
 local c=sub(str,pos,pos)
 if (c==',' or c=='=' or c=='{' or c=='}') return c,pos,val
 return nxt_delim(str,pos+1,val..c)
end

function p_tbl(str,pos)
 pos=pos or 1
 local first=sub(str,pos,pos)
 if first=='{' then
  local obj={}--new obj
  pos+=1
  while true do
   if sub(str,pos,pos)=="{" then
    res,pos=p_tbl(str,pos)
    add(obj,res)
   else
    tk,pos,val=nxt_delim(str,pos)
    if tk=="=" then
--     ?"key "..val
     k,val,pos=val,parsers[val](str,pos+1)
     obj[k]=val
    else
     add(obj,val)
    end
   end
   --then...
   local nxt=sub(str,pos,pos)
   if (nxt=="}") return obj,pos+1
   if (nxt==',') pos+=1
  end
 end 
end

parsdefs,parsers=
 split("id,p_num,flx,p_num,ico,p_num,prm,p_num,vis,p_fun,fn,p_fun,s,p_num,w,p_num,h,p_num,tw,p_num,th,p_num,nb,p_num,once,p_num,ofx,p_num,ofy,p_num,spy,p_num,spal,p_str,spalt,p_num,mpalt,p_num,blur,p_num,poffx,p_num,poffy,p_num,fd,p_num,at,p_num,dm,p_num,de,p_num,gd,p_num,wd,p_num,bt,p_num,hp,p_num,a,p_num,yboff,p_num,xoff,p_num,yoff,p_num,vrad,p_num,arad,p_num,mnu,p_num,cm,p_tbl,m,p_tbl,sm,p_tbl,f,p_tbl,rlyp,p_num,gather,p_num,repair,p_num,fight,p_num,heal,p_num,sts,p_tbl,mhp,p_tbl,ma,p_num,tip,p_str"),{}

for i=1,#parsdefs,2 do
 parsers[parsdefs[i]]=
  _ENV[parsdefs[i+1]] 
end
__gfx__
00000000333333333333333333333333333333333333333333333333ccccccccccccccccffff7ffff0000000000f0000f0000f0000f0000f0000f0000f0000f0
00000000333333333333333333333333333333333333333333333333ccccccccccccccccfffc7cfff00000000911009110091100911009110091100911009110
00700700333333333333333333333333333333131333331311333333ccccccccccccccccffcfffcff000000004c1094c1094c1004c1004c1004c1004c1004c10
00077000333333111333331311133333333331111131311111133333ccccccc33cccccccfcfffffcf0000000094c19c4c19c4c19c4c1094c1094c1094c1094c1
00077000333313445131315544513333333311111111111111113333ccccc3333333cccc77ff7ff77000000009c4909c499cc499cc499cc4909c4909c4909c49
00700700333355444444444444453333333311111111111111133333cccc333333333cccfcfffffcf000000009cc409c9109c919ccc49ccc409cc409cc409cc4
000000003333344444444444444333333333311cc111111cc1113333cccc1133333333ccffcfffcff000000009cc909c9109c919cc919ccc99ccc909cc909cc9
00000000333354444444444444453333333333cccc1111cccc113333cccc1333333311ccfffc7cfff000000009cc909cc909c9109c919cc919ccc909cc909cc9
33333333333544444444444444451333333331ccccccccccccc33333cccc3333333331ccffff7ffffd65ffff09cc909cc909cc909c9109c919ccc99ccc999cc9
33333333333544444444444444453333333333cccccccccccc333333cccc1333333111cc00000000f056511f09cc909cc909cc909c9109c919cc919ccc99ccc9
33333333333344444444444444433333333331cccccccccccc133333cccc1131131111cc00000000ff0d77df09cc909cc909cc909cc909c9109c9109cc909cc9
33333333333334444444444444433333333311cccccccccccc333333cccc1111111133cc00000000ff0d66df019c9019c9019c9019c9019c9019910199101999
33333333333314444444444444413333333111cccccccccccc133333ccc333111113333c00000000f66d77710019900199001990019900199001910019100191
33333333333334444444444444451333333311cccccccccccc113333ccc133111111331c00000000f001d6610001900019000190001900019000190001900019
33333333333314444444444444443333333331cccccccccccc111333cccc11cccccc11cc00000000fff0d66d0001000010000100001000010000100001000010
33333333333154444444444444441333333333cccccccccccc111333cccccccccccccccc00000000fff015510001000010000100001000010000100001000010
00000000333144444444444444445533333331ccccccccccccc13333444444444444444444444533333544440000000000000000000000000000000000000000
00000000333544444444444444445333333311ccccccccccccc33333444444444444444444444333333544440000000000000000000000000000000005555500
00000000333544444444444444441333333313cccc33c3ccccc13333444444444444444444444553315444440000000000000000000000000000000005666650
000000003333544444434344444133333333333cc333333ccc113333444444444444444444444441554444440000000000000000000000000000000005655650
00000000333333535533333553533333333333333333333333333333444444443444444444444444444444440000000000000000000000000000000005666650
00000000333333333333333333333333333333333333333333333333444444353334444444444444444444444999999999999999999999400000000005655650
00000000333333333333333333333333333333333333333333333333444445333334444444444444444444449000000000000000000000900000000005666650
00000000333333333333333333333333333333333333333333333333444443333333444444444444444444444999999999999999999999400000000005555550
00000000000000000000000000000000003000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000000
06000000000005000c0000c000c00700003300000000000000000000000033000000000000005000005555000555550000500050055555550000000008200028
0660000000005550ccc00ccc0c56070003330000cccd0cc0aa999a0a000333000004aa400055555005dddd000565565005605555056666650000003b02820282
0666000000055555575555750051070003333000c0cd0c0ca0909a0a00033330000a99a00555555505d555550565565005650050056ddd65000003b300282820
066660000055555054577545ccc6570033333300cccd0cc0a0999a0a00333333000a9aa00056565005d566650566665005650000056ddd650b303b3000028200
066666000f55550057544575c6c5466033333300c00d0c0caa900aaa003333330004aa40005656500556665005666650056666650566666503b3b30000282820
066660000ff5500057544575c6c66000004400a9c00ddc0c0090000000004400000000000056565000555550055555500055555000566665003b300002820282
0660000003ff000055555555ccc0600000440a9a0000000000000000000044000000000000555550000000000000000000000000000555550003000008200028
000000000dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555500dddd00000050000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05666650dddd00000555550000555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05655650000000000050005005000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05666650dddd00000000005005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05655650dddd00000000550000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
056666500dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000001010101010000000000000000000000010101010100000000000000000000000101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
012a131010100102020310101010101010101010101010101010101010101112000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a27231010012a12122902031010101010101010101010101010101010102122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
27231010012a1212122722231010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2310101021281212272310101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010210022231010101010101010101010100102020310101010100405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010100000101010101010101010100102022a12121310101010041815000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101000000102031010101010101112121212121310101010141515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010000012290310101010101112121212121310101004181515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010110012122903101010101112121227222310101024081515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010111200121213101010102122222223101010001010242525000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010010203212812001213101010101010101010101000000202031010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010012a12290321281200231010101010101010101000002a1212131010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
101010101112121213101112001010101010101010100000012a121212131010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050621222222231021222310101010101010100000101112121227231010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151706101010101010101010001010101010001010101112122723101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2525081517050610101010101010100010101000001010102122222310101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010242508151610101010101010101010100010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101014151610101010101010100010001010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1001020324081706101010101010101000101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011122903141516101010101010100010001010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011121213240817061010101001000202020202020310101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011121229031415161010101000121212121200122903101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011121227231415161010100011121212121212001213101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1021222223102425261010001011121212121212120023101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010100000101021222228121212121300101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010001010040506101021222222222310001010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101001020200020310141517061010101010101010100010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101011000012122903141515170506101010101010101000101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101000121212121213240815151516101010101010101010001010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010100021281212121213102408151517061010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0203101010212812272223100418151515161010101010101010101010100102000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1213101010102122231010101415151515161010101010101010101010101112000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000800001d05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800002205000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0000130501f0502b0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00002b0501f050130500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

;
;  $Id:$
;
; This script will visualise the flow of particles around one or more
; solid objects.  
;
;  Author: Nils Erland L. Haugen
;
FUNCTION CIRCLE_, xcenter, ycenter, radius
points = (2 * !PI / 99.0) * FINDGEN(100)
x = xcenter + radius * COS(points )
y = ycenter + radius * SIN(points )
RETURN, TRANSPOSE([[x],[y]])
END
;
pro pc_visualize_particles,png=png,removed=removed, savefile=savefile,xmin=xmin,$
                           xmax=xmax,ymin=ymin,ymax=ymax,tmin=tmin,tmax=tmax,$
                           w=w,trace=trace,velofield=velofield
;
device,decompose=0
loadct,5
;
; Set defaults
;
default,writepng,0
default,removed,0
default,savefile,1
default,tmin,-1e37
default,tmax,1e37
default,w,0.03
default,trace,0
default,velofield,0
;
; Read dimensions and namelists
;
pc_read_dim,obj=procdim
pc_read_param, object=param
pc_read_pvar,obj=objpvar,/solid_object,irmv=irmv,theta_arr=theta_arr,savefile=savefile
pc_read_pstalk,obj=obj
dims=size(obj.xp)
npar=dims[1]
print,'npar=',npar
;
; Set some auxillary variables
;
nx=procdim.nx
ny=procdim.ny
dims=size(obj.xp)
n_parts=dims(1)
n_steps=dims(2)
print,'param.coord_system=',param.coord_system
if (param.coord_system eq 'cylindric') then begin
    radius=param.xyz0[0]
    xpos=0.0
    ypos=0.0
    default,xmax,param.xyz1[0]
    default,xmin,-xmax
    default,ymax, xmax
    default,ymin,-xmax
endif else begin
    radius=param.cylinder_radius[0]
    xpos=param.cylinder_xpos[0]
    ypos=param.cylinder_ypos[0]
    default,xmax,param.xyz1[0]
    default,xmin,param.xyz0[0]
    default,ymax,param.xyz1[1]
    default,ymin,param.xyz0[1]
endelse
print,'xmin=',xmin
print,'xmax=',xmax
print,'ymin=',ymin
print,'ymax=',ymax
;
; Find positions of removed particles (to be used later for plotting them).
;
if (removed eq 1) then begin
    removed_pos=objpvar.xx(irmv,*)
    skin=nx
    collision_radius=sqrt((removed_pos(*,0)-xpos)^2+(removed_pos(*,1)-ypos)^2)
    solid_colls=where(collision_radius lt radius+1e-3)
endif
;
; Find where (in radians) the particles hit the surface of the cylinder as a
; function of time
;
theta_=theta_arr[*,0]
time_=theta_arr[*,1]
here=where(theta_ ne 0)
print,here
if (here[0] ne -1) then begin
    WINDOW,4,XSIZE=128*2,YSIZE=256*2
    theta=theta_[here]
    timereal=time_[here]
    time=timereal-min(timereal)
    dims=size(theta)
    ind=indgen(dims[1])
    !x.range=[0,max(ind)]
    !x.range=[min(time),max(time)]
    !y.range=[min(theta),max(theta)]
    plot,time,theta,ps=2,ytit='!4h!6',xtit='time'
    print,'The first particle hit the surface at t=',min(timereal)
    print,'The last particle hit the surface at t =',max(timereal)
    if (savefile) then begin
       save,time,theta,filename='./data/theta.sav'
    endif
endif else begin
    print,'No particles has hit the cylinder surface!'
endelse
print,'The final time of the simulation is  t =',objpvar.t
;
; Set window size
;
xr=xmax-xmin
yr=ymax-ymin
WINDOW,3,XSIZE=1024*xr/yr*1.6,YSIZE=1024
!x.range=[xmin,xmax]
!y.range=[ymin,ymax]
;
; Show results
;
for i=0,n_steps-1 do begin
   ;
   ; Check if we want to plot for this time
   ;
   if ((obj.t[i] gt tmin) and (obj.t[i] lt tmax)) then begin
      titlestring='t='+str(obj.t[i])
      if (param.coord_system eq 'cylindric') then begin
         xp=obj.xp(*,i)*cos(obj.yp(*,i))
         yp=obj.xp(*,i)*sin(obj.yp(*,i))
         plot,xp,yp,psym=sym(1),symsize=1,/iso,title=titlestring
      endif else begin
         plot,obj.xp(*,i),obj.yp(*,i),psym=sym(1),symsize=1,/iso,title=titlestring
      endelse
      POLYFILL, CIRCLE_(xpos, ypos, radius),color=122
      ;
      ; Do we want to write png files or to show results on screen
      ;
      if writepng eq 1 then begin
         istr2 = strtrim(string(i,'(I20.4)'),2) ;(only up to 9999 frames)
         file='img_'+istr2+'.png'
         write_png,file,tvrd()
      endif else begin
         wait,w
      endelse
   endif
end
;
; Do we want to show the trace of the particles?
;
ddt=2e-4
if (trace) then begin
   for ipar=0,npar-1 do begin
      oplot,obj.xp(ipar,*),obj.yp(ipar,*),ps=3
      ARROW, obj.xp(ipar,*), obj.yp(ipar,*),$
             obj.xp(ipar,*)+obj.ux(ipar,*)*ddt, $
             obj.yp(ipar,*)+obj.uy(ipar,*)*ddt, $
             /data,col=122,HSIZE=4
   end 
end
;
; Do we want to overplot the velocity field?
;
if (velofield) then begin
   pc_read_var,obj=objvar
   pc_read_dim,obj=objdim
   l1=objdim.l1
   l2=objdim.l2
   m1=objdim.m1
   m2=objdim.m2
   n1=objdim.n1
   velovect,reform(objvar.uu(l1:l2,m1:m2,n1,0)),$
            reform(objvar.uu(l1:l2,m1:m2,n1,1)),$
            objvar.x(l1:l2),objvar.y(m1:m2),/overplot
endif
;
; Plot the removed particles as blue dots
;
if (removed eq 1) then begin
    oplot,removed_pos(solid_colls,0),removed_pos(solid_colls,1),col=45,ps=sym(1)
endif
;
; Write png files if required
;
if writepng eq 1 then begin
    istr2 = strtrim(string(i+1,'(I20.4)'),2) ;(only up to 9999 frames)
    file='img_'+istr2+'.png'
    write_png,file,tvrd()
endif
;
END

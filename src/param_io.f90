! $Id$
!
!  IO of init and run parameters. Subroutines here are `at the end of the
!  food chain', i.e. depend on all physics modules plus possibly others.
!  Using this module is also a compact way of referring to all physics
!  modules at once.
!
module Param_IO
!
  use Cdata
  use Cparam
  use Chemistry
  use Chiral
  use Cosmicray
  use CosmicrayFlux
  use Density
  use Dustdensity
  use Dustvelocity
  use Entropy
  use EquationOfState
  use Forcing
  use General
  use Gravity
  use Hydro
  use InitialCondition
  use Interstellar
  use Magnetic
  use Lorenz_gauge
  use Messages
  use NeutralDensity
  use NeutralVelocity
  use NSCBC
  use Particles_main
  use Poisson
  use Pscalar
  use Radiation
  use Selfgravity
  use Shear
  use Shock
  use Solid_Cells
  use Signal_handling
  use Special
  use Sub
  use Testfield
  use Testflow
  use TestPerturb
  use Testscalar
  use Timeavg
  use Viscosity
!
  implicit none
!
  private
!
  public :: get_datadir, get_snapdir
  public :: read_startpars, print_startpars
  public :: read_runpars,   print_runpars
  public :: rparam, wparam, wparam2, write_pencil_info
!
! The following fixes namelist problems withi MIPSpro 7.3.1.3m
! under IRIX -- at least for the moment
!
  character (len=labellen) :: mips_is_buggy='system'
!AB/15-Mar-07: the lcylindrical is kept to produce a warning: outdated
  logical :: lcylindrical
!
  namelist /init_pars/ &
      cvsid, ip, xyz0, xyz1, Lxyz, lperi, lshift_origin, coord_system, &
      lequidist, coeff_grid, zeta_grid0, grid_func, xyz_star, lwrite_ic, &
      lnowrite, luniform_z_mesh_aspect_ratio, unit_system, unit_length, &
      unit_velocity, unit_density, unit_temperature, unit_magnetic, c_light, &
      G_Newton, hbar, random_gen, seed0, nfilter, lserial_io, der2_type, &
      lread_oldsnap, lread_oldsnap_nomag, lread_oldsnap_nopscalar, &
      lread_oldsnap_notestfield, lread_aux, lwrite_aux, &
      pretend_lnTT, lprocz_slowest, &
      lcopysnapshots_exp, bcx, bcy, bcz, r_int, r_ext, r_ref, rsmooth, &
      r_int_border, r_ext_border, mu0, force_lower_bound, force_upper_bound, &
      tstart, fbcx1, fbcx2, fbcy1, fbcy2, fbcz1, fbcz2, fbcz1_1, fbcz1_2, &
      fbcz2_1, fbcz2_2, fbcx1_2, fbcx2_2, xyz_step, xi_step_frac, &
      xi_step_width, niter_poisson, lcylindrical, lcylinder_in_a_box, &
      lsphere_in_a_box, llocal_iso, init_loops, lwrite_2d, &
      lcylindrical_gravity, border_frac_x, border_frac_y, border_frac_z, &
      luse_latitude, lshift_datacube_x, lfargo_advection, yequator, lequatory, &
      lequatorz, zequator, lav_smallx, xav_max 
!
  namelist /run_pars/ &
      cvsid, ip, nt, it1, it1d, dt, cdt, ddt, cdtv, cdtv2, cdtv3, cdts, cdtr, &
      cdtc, isave, itorder, dsnap, d2davg, dvid, dtmin, dspec, tmax, iwig, &
      awig, ialive, max_walltime, dtmax, ldt_paronly, vel_spec, mag_spec, &
      uxj_spec, vec_spec, ou_spec, ab_spec, ub_spec, vel_phispec, mag_phispec, &
      uxj_phispec, vec_phispec, ou_phispec, ab_phispec, EP_spec, ro_spec, &
      TT_spec, ss_spec, cc_spec, cr_spec, isaveglobal, lr_spec, r2u_spec, &
      r3u_spec, rhocc_pdf, cc_pdf, lncc_pdf, gcc_pdf, lngcc_pdf, kinflow, &
      eps_kinflow, omega_kinflow, ampl_kinflow, lkinflow_as_aux, &
      ampl_kinflow_x, ampl_kinflow_y, ampl_kinflow_z, kx_kinflow, ky_kinflow, &
      kz_kinflow, dtphase_kinflow, kinflow_ck_Balpha, kinflow_ck_ell, &
      random_gen, der2_type, lrmwig_rho, lrmwig_full, lrmwig_xyaverage, &
      ltime_integrals, lnowrite, noghost_for_isave, lwrite_yaverages, &
      lwrite_zaverages, lwrite_phiaverages, test_nonblocking, &
      lread_oldsnap_nomag, lread_oldsnap_nopscalar, lread_oldsnap_notestfield, &
      lread_aux, comment_char, ix, iy, iz, iz2, iz3, iz4, slice_position, &
      zbot_slice, ztop_slice, bcx, bcy, bcz, r_int, r_ext, r_int_border, &
      r_ext_border, lfreeze_varsquare, lfreeze_varint, lfreeze_varext, &
      xfreeze_square, yfreeze_square, rfreeze_int, rfreeze_ext, wfreeze, &
      wfreeze_int, wfreeze_ext, wborder, wborder_int, wborder_ext, tborder, &
      fshift_int, fshift_ext, fbcx1, fbcx2, fbcy1, fbcy2, fbcz1, fbcz2, &
      fbcx1_2, fbcx2_2, fbcz1_1, fbcz1_2, fbcz2_1, fbcz2_2, Udrift_bc, &
      ttransient, tavg, idx_tavg, lserial_io, nr_directions, lsfu, lsfb, &
      lsfz1, lsfz2, lsfflux, lpdfu, lpdfb, lpdfz1, lpdfz2, oned, lwrite_aux, &
      onedall, pretend_lnTT, old_cdtv, lmaxadvec_sum, save_lastsnap, &
      lwrite_dvar, force_lower_bound, force_upper_bound, twod, border_frac_x, &
      border_frac_y, border_frac_z, lpoint, mpoint, npoint, lpoint2, mpoint2, &
      npoint2, lcylinder_in_a_box, lsphere_in_a_box, ipencil_swap, &
      lpencil_requested_swap, lpencil_diagnos_swap, lpencil_check, &
      lpencil_check_small, lrandom_f_pencil_check, lpencil_check_diagnos_opti, &
      lpencil_init, penc0, lwrite_2d, lbidiagonal_derij, lisotropic_advection, &
      crash_file_dtmin_factor, niter_poisson, lADI, ltestperturb, eps_rkf, &
      eps_stiff, timestep_scaling, lequatory, lequatorz, zequator, &
      lini_t_eq_zero, lav_smallx, xav_max, ldt_paronly, lweno_transport
!
  contains
!***********************************************************************
    subroutine get_datadir(dir)
!
!  Overwrite datadir from datadir.in, if that exists.
!
!   2-oct-02/wolf: coded
!  25-oct-02/axel: default is taken from cdata.f90 where it's defined
!
      use Mpicomm
!
      character (len=*) :: dir
      logical :: exist
!
!  Let root processor check for existence of datadir.in.
!
      if (lroot) then
        inquire(FILE='datadir.in',EXIST=exist)
        if (exist) then
          open(1,FILE='datadir.in',FORM='formatted')
          read(1,'(A)') dir
          close(1)
        endif
      endif
!
!  Tell other processors whether we need to communicate dir (i.e. datadir).
!
      call mpibcast_logical(exist, 1)
!
!  Let root processor communicate dir (i.e. datadir) to all other processors.
!
      if (exist) call mpibcast_char(dir, len(dir))
!
    endsubroutine get_datadir
!***********************************************************************
    subroutine get_snapdir(dir)
!
!  Read directory_snap from data/directory_snap, if that exists
!  wd: I think we should unify these into a subroutine
!      `overwrite_string_from_file(dir,file,label[optional])'
!
!   2-nov-02/axel: adapted from get_datadir
!
      character (len=*) :: dir
      character (len=120) :: tdir
      character (len=10) :: a_format
      logical :: exist
!
!  check for existence of `data/directory_snap'
!
      inquire(FILE=trim(datadir)//'/directory_snap',EXIST=exist)
      if (exist) then
        open(1,FILE=trim(datadir)//'/directory_snap',FORM='formatted')
! NB: the following does not work under IRIX (silently misses reading of
! run parameters):
!        read(1,'(a)') dir
! ..so we do it like this:
        a_format = '(a)'
        read(1,a_format) tdir
        close(1)
        if (len(trim(tdir)) .gt. 0) call parse_shell(tdir,dir)
      endif
      if (lroot.and.ip<20) print*,'get_snapdir: dir=',trim(dir)
!
    endsubroutine get_snapdir
!***********************************************************************
    subroutine read_startpars(print,file)
!
!  read input parameters (done by each processor)
!
!   6-jul-02/axel: in case of error, print sample namelist
!  21-oct-03/tony: moved sample namelist stuff to a separate procedure
!
      integer :: ierr
      logical, optional :: print,file
      character (len=30) :: label='[none]'
!
!  set default to shearing sheet if lshear=.true. (even when Sshear==0.)
!
      if (lshear) bcx(:)='she'
!
! find out if we should open and close the file everytime
! to fix the SGI reading problem
      inquire(FILE='SGIFIX',EXIST=lsgifix)
!
!  open namelist file
!
      open(1,FILE='start.in',FORM='formatted',STATUS='old')
!
!  read through all items that *may* be present
!  in the various modules
!
      label='init_pars'
      read(1,NML=init_pars                 ,ERR=99, IOSTAT=ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_initial_condition_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('initial_condition_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_eos_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('eos_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_hydro_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('hydro_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_density_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('density_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_forcing_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('forcing_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_gravity_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('grav_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_selfgravity_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('selfgrav_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_poisson_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('poisson_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_entropy_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('entropy_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_magnetic_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('magnetic_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_lorenz_gauge_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('lorenz_gauge_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_testscalar_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('testscalar_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_testfield_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('testfield_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_testflow_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('testflow_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_radiation_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('radiation_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_pscalar_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('pscalar_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_chiral_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('chiral_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_chemistry_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('chemistry_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_signal_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('signal_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_dustvelocity_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('dustvelocity_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_dustdensity_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('dustdensity_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_neutralvelocity_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('neutralvelocity_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_neutraldensity_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('neutraldensity_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_cosmicray_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('cosmicray_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_cosmicrayflux_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('cosmicrayflux_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_interstellar_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('interstellar_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_shear_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('shear_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_testperturb_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('testperturb_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_viscosity_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('viscosity_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_special_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('special_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_shock_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('shock_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_solid_cells_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('solid_cells_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call read_NSCBC_init_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('NSCBC_init_pars',ierr)
!
      call sgi_fix(lsgifix,1,'start.in')
      call particles_read_startpars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_startpars('particles_init_pars_wrap',ierr)
!
      ! no input parameters for viscosity
      label='[none]'
      close(1)
!
!  Print cvs id from first line.
!
      if (lroot) call svn_id(cvsid)
!
!  Give online feedback if called with the PRINT optional argument.
!  Note: Some compiler's [like Compaq's] code crashes with the more
!  compact `if (present(print) .and. print)'.
!
      if (present(print)) then
        if (print) then
          call print_startpars()
        endif
      endif
!
!  Write parameters to log file.
!
      if (present(file)) then
        if (file) then
          call print_startpars(FILE=trim(datadir)//'/params.log')
        endif
      endif
!
!  Parse boundary conditions; compound conditions of the form `a:s' allow
!  to have different variables at the lower and upper boundaries.
!
      call parse_bc(bcx,bcx1,bcx2)
      call parse_bc(bcy,bcy1,bcy2)
      call parse_bc(bcz,bcz1,bcz2)
!
      if (lroot.and.ip<14) then
        print*, 'bcx1,bcx2= ', bcx1," : ",bcx2
        print*, 'bcy1,bcy2= ', bcy1," : ",bcy2
        print*, 'bcz1,bcz2= ', bcz1," : ",bcz2
        print*, 'lperi= ', lperi
      endif
!
      call check_consistency_of_lperi('read_startpars')
!
!  Produce a warning when somebody still sets lcylindrical.
!
      if (lcylindrical) then
        if (lroot) then
          print*
          print*,'read_startpars: lcylindrical=T is now outdated'
          print*,'use instead: lcylinder_in_a_box=T'
          print*,'This renaming became necessary with the development of'
          print*,'cylindrical coordinates which led to very similar names'
          print*,'(coord_system="cylindrical_coords")'
          print*
        endif
        call fatal_error('read_startpars','')
      endif
!
!  In case of i/o error: print sample input list.
!
      return
!
99  call sample_startpars(label,ierr)
!
    endsubroutine read_startpars
!***********************************************************************
    subroutine sample_startpars(label,iostat)
!
      character (len=*), optional :: label
      integer, optional :: iostat
!
      if (lroot) then
        print*
        print*,'-----BEGIN sample namelist ------'
                                print*,'&init_pars                 /'
        if (linitial_condition) print*,'&initial_condition_pars    /'
        if (leos              ) print*,'&eos_init_pars             /'
        if (lhydro            ) print*,'&hydro_init_pars           /'
        if (ldensity          ) print*,'&density_init_pars         /'
        if (lgrav             ) print*,'&grav_init_pars            /'
        if (lselfgravity      ) print*,'&selfgrav_init_pars        /'
        if (lpoisson          ) print*,'&poisson_init_pars         /'
        if (lentropy          ) print*,'&entropy_init_pars         /'
        if (ltemperature      ) print*,'&entropy_init_pars         /'
        if (lmagnetic         ) print*,'&magnetic_init_pars        /'
        if (llorenz_gauge     ) print*,'&lorenz_gauge_init_pars        /'
        if (ltestscalar       ) print*,'&testscalar_init_pars      /'
        if (ltestfield        ) print*,'&testfield_init_pars       /'
        if (ltestflow         ) print*,'&testflow_init_pars        /'
        if (lradiation        ) print*,'&radiation_init_pars       /'
        if (lpscalar          ) print*,'&pscalar_init_pars         /'
        if (lchiral           ) print*,'&chiral_init_pars          /'
        if (lchemistry        ) print*,'&chemistry_init_pars       /'
        if (lsignal           ) print*,'&signal_init_pars          /'
        if (ldustvelocity     ) print*,'&dustvelocity_init_pars    /'
        if (ldustdensity      ) print*,'&dustdensity_init_pars     /'
        if (lneutralvelocity  ) print*,'&neutralvelocity_init_pars /'
        if (lneutraldensity   ) print*,'&neutraldensity_init_pars  /'
        if (lcosmicray        ) print*,'&cosmicray_init_pars       /'
        if (lcosmicrayflux    ) print*,'&cosmicrayflux_init_pars   /'
        if (linterstellar     ) print*,'&interstellar_init_pars    /'
        if (lshear            ) print*,'&shear_init_pars           /'
        if (ltestperturb      ) print*,'&testperturb_init_pars     /'
        if (lspecial          ) print*,'&special_init_pars         /'
        if (lsolid_cells      ) print*,'&solid_cells_init_pars     /'
        if (lnscbc            ) print*,'&NSCBC_init_pars           /'
        if (lparticles        ) print*,'&particles_init_pars_wrap  /'
        print*,'------END sample namelist -------'
        print*
        if (present(label))  print*, 'Found error in input namelist "' // trim(label)
        if (present(iostat)) print*, 'iostat = ', iostat
        if (present(iostat).or.present(label)) &
                           print*,  '-- use sample above.'
      endif
!
      call fatal_error('','')
!
    endsubroutine sample_startpars
!***********************************************************************
    subroutine print_startpars(file)
!
!  Print input parameters.
!
!  4-oct02/wolf: adapted
!
      character (len=*), optional :: file
      character (len=datelen) :: date
      integer :: unit=6         ! default unit is 6=stdout
!
      if (lroot) then
        if (present(file)) then
          unit = 1
          call date_time_string(date)
          open(unit,FILE=file)
          write(unit,*) &
               '! -------------------------------------------------------------'
          write(unit,'(A,A)') ' ! ', 'Initializing'
          write(unit,'(A,A)') ' ! Date: ', trim(date)
          write(unit,*) '! t=', t
        endif
!
        write(unit,NML=init_pars          )
!
        call write_initial_condition_pars(unit)
        call write_eos_init_pars(unit)
        call write_hydro_init_pars(unit)
        call write_density_init_pars(unit)
        call write_forcing_init_pars(unit)
        call write_gravity_init_pars(unit)
        call write_selfgravity_init_pars(unit)
        call write_poisson_init_pars(unit)
        call write_entropy_init_pars(unit)
        call write_magnetic_init_pars(unit)
        call write_lorenz_gauge_init_pars(unit)
        call write_testscalar_init_pars(unit)
        call write_testfield_init_pars(unit)
        call write_testflow_init_pars(unit)
        call write_radiation_init_pars(unit)
        call write_pscalar_init_pars(unit)
        call write_chiral_init_pars(unit)
        call write_chemistry_init_pars(unit)
        call write_signal_init_pars(unit)
        call write_dustvelocity_init_pars(unit)
        call write_dustdensity_init_pars(unit)
        call write_neutralvelocity_init_pars(unit)
        call write_neutraldensity_init_pars(unit)
        call write_cosmicray_init_pars(unit)
        call write_cosmicrayflux_init_pars(unit)
        call write_interstellar_init_pars(unit)
        call write_shear_init_pars(unit)
        call write_testperturb_init_pars(unit)
        call write_viscosity_init_pars(unit)
        call write_special_init_pars(unit)
        call write_shock_init_pars(unit)
        call write_solid_cells_init_pars(unit)
        call write_NSCBC_init_pars(unit)
        call particles_wparam(unit)
!
        if (present(file)) then
          close(unit)
        endif
      endif
!
    endsubroutine print_startpars
!***********************************************************************
    subroutine read_runpars(print,file,annotation)
!
!  Read input parameters.
!
!  14-sep-01/axel: inserted from run.f90
!  31-may-02/wolf: renamed from cread to read_runpars
!   6-jul-02/axel: in case of error, print sample namelist
!  21-oct-03/tony: moved sample namelist stuff to a separate procedure
!
      use Sub, only: parse_bc
      use Dustvelocity, only: copy_bcs_dust
      use Slices, only: setup_slices
!
      integer :: ierr
      logical, optional :: print,file
      character (len=*), optional :: annotation
      character (len=30) :: label='[none]'
!
!  Reset some parameters, in particular those where we play tricks with
!  `impossible' values
!
!  set default to shearing sheet if lshear=.true. (even when Sshear==0.)
!
      if (lshear) bcx(:)='she'
!
!  Find out if we should open and close the file everytime
!  to fix the SGI reading problem.
!
      inquire(FILE='SGIFIX',EXIST=lsgifix)
!
!  Open namelist file.
!
      open(1,FILE='run.in',FORM='formatted',STATUS='old')
!
!  Read through all items that *may* be present in the various modules.
!  AB: at some point the sgi_fix stuff should probably be removed (see sgi bug)
!
      label='run_pars'
                         read(1,NML=run_pars              ,ERR=99, IOSTAT=ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_eos_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('eos_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_hydro_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('hydro_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_density_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('density_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_forcing_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('forcing_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_gravity_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('grav_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_selfgravity_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('selfgrav_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_poisson_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('poisson_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_entropy_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('entropy_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_magnetic_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('magnetic_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_lorenz_gauge_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('lorenz_gauge_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_testscalar_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('testscalar_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_testfield_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('testfield_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_testflow_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('testflow_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_radiation_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('radiation_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_pscalar_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('pscalar_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_chiral_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('chiral_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_chemistry_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('chemistry_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_dustvelocity_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('dustvelocity_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_dustdensity_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('dustdensity_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_neutralvelocity_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('neutralvelocity_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_neutraldensity_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('neutraldensity_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_cosmicray_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('cosmicray_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_cosmicrayflux_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('cosmicrayflux_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_interstellar_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('interstellar_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_shear_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('shear_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_testperturb_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('testperturb_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_viscosity_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('viscosity_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_special_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('special_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_shock_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('shock_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_solid_cells_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('solid_cells_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call read_NSCBC_run_pars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('NSCBC_run_pars',ierr)
!
      call sgi_fix(lsgifix,1,'run.in')
      call particles_read_runpars(1,IOSTAT=ierr)
      if (ierr/=0) call sample_runpars('particles_run_pars_wrap',ierr)
!
      label='[none]'
      close(1)
!
!  Copy boundary conditions on first dust species to all others.
!
      call copy_bcs_dust
!
!  Print cvs id from first line.
!
      if (lroot) call svn_id(cvsid)
!
!  Set debug logical (easier to use than the combination of ip and lroot).
!
      ldebug=lroot.and.(ip<7)
      if (lroot) print*,'ldebug,ip=',ldebug,ip
!
!  Give online feedback if called with the PRINT optional argument.
!  Note: Some compiler's [like Compaq's] code crashes with the more
!  compact `if (present(print) .and. print)'.
!
      if (present(print)) then
        if (print) then
          call print_runpars()
        endif
      endif
!
!  Write parameters to log file.
!  [No longer used, since at the time when read_runpars() is called, t
!  is not known yet]
!
      if (present(file)) then
        if (file) then
          if (present(annotation)) then
            call print_runpars(FILE=trim(datadir)//'/params.log', &
                               ANNOTATION=annotation)
          else
            call print_runpars(FILE=trim(datadir)//'/params.log')
          endif
        endif
      endif
!
!  Parse boundary conditions; compound conditions of the form `a:s' allow
!  to have different variables at the lower and upper boundaries.
!
      call parse_bc(bcx,bcx1,bcx2)
      call parse_bc(bcy,bcy1,bcy2)
      call parse_bc(bcz,bcz1,bcz2)
!
      if (lroot.and.ip<14) then
        print*, 'bcx1,bcx2= ', bcx1," : ",bcx2
        print*, 'bcy1,bcy2= ', bcy1," : ",bcy2
        print*, 'bcz1,bcz2= ', bcz1," : ",bcz2
      endif
!
      call check_consistency_of_lperi('read_runpars')
!
!  In case of i/o error: print sample input list.
!
      return
!
99    call sample_runpars(label,ierr)
!
    endsubroutine read_runpars
!***********************************************************************
    subroutine sample_runpars(label,iostat)
!
      character (len=*), optional :: label
      integer, optional :: iostat
!
      if (lroot) then
        print*
        print*,'-----BEGIN sample namelist ------'
                              print*,'&run_pars                 /'
        if (leos            ) print*,'&eos_run_pars             /'
        if (lhydro          ) print*,'&hydro_run_pars           /'
        if (ldensity        ) print*,'&density_run_pars         /'
        if (lforcing        ) print*,'&forcing_run_pars         /'
        if (lgrav           ) print*,'&grav_run_pars            /'
        if (lselfgravity    ) print*,'&selfgrav_run_pars        /'
        if (lpoisson        ) print*,'&poisson_run_pars         /'
        if (lentropy        ) print*,'&entropy_run_pars         /'
        if (ltemperature    ) print*,'&entropy_run_pars         /'
        if (lmagnetic       ) print*,'&magnetic_run_pars        /'
        if (llorenz_gauge   ) print*,'&lorenz_gauge_run_pars    /'
        if (ltestscalar     ) print*,'&testscalar_run_pars      /'
        if (ltestfield      ) print*,'&testfield_run_pars       /'
        if (ltestflow       ) print*,'&testflow_run_pars        /'
        if (lradiation      ) print*,'&radiation_run_pars       /'
        if (lpscalar        ) print*,'&pscalar_run_pars         /'
        if (lchiral         ) print*,'&chiral_run_pars          /'
        if (lchemistry      ) print*,'&chemistry_run_pars       /'
        if (ldustvelocity   ) print*,'&dustvelocity_run_pars    /'
        if (ldustdensity    ) print*,'&dustdensity_run_pars     /'
        if (lneutralvelocity) print*,'&neutralvelocity_run_pars /'
        if (lneutraldensity ) print*,'&neutraldensity_run_pars  /'
        if (lcosmicray      ) print*,'&cosmicray_run_pars       /'
        if (lcosmicrayflux  ) print*,'&cosmicrayflux_run_pars   /'
        if (linterstellar   ) print*,'&interstellar_run_pars    /'
        if (lshear          ) print*,'&shear_run_pars           /'
        if (ltestperturb    ) print*,'&testperturb_run_pars     /'
        if (lviscosity      ) print*,'&viscosity_run_pars       /'
        if (lspecial        ) print*,'&special_run_pars         /'
        if (lshock          ) print*,'&shock_run_pars           /'
        if (lsolid_cells    ) print*,'&solid_cells_run_pars     /'
        if (lnscbc          ) print*,'&NSCBC_run_pars           /'
        if (lparticles      ) print*,'&particles_run_pars_wrap  /'
        print*,'------END sample namelist -------'
        print*
        if (present(label))  print*, 'Found error in input namelist "' // trim(label)
        if (present(iostat)) print*, 'iostat = ', iostat
        if (present(iostat).or.present(label)) &
                           print*,  '-- use sample above.'
      endif
!
      call fatal_error('sample_runpars','')
!
    endsubroutine sample_runpars
!***********************************************************************
    subroutine sgi_fix(lfix,lun,file)
!
      logical :: lfix
      integer :: lun
      character (LEN=*) :: file
!
      if (lfix) then
        close (lun)
        open(lun, FILE=file,FORM='formatted')
      endif
!
    endsubroutine sgi_fix
!***********************************************************************
    subroutine print_runpars(file,annotation)
!
!  Print input parameters.
!
!  14-sep-01/axel: inserted from run.f90
!  31-may-02/wolf: renamed from cprint to print_runpars
!   4-oct-02/wolf: added log file stuff
!
      character (len=*), optional :: file,annotation
      integer :: unit=6         ! default unit is 6=stdout
      character (len=linelen) :: line
      character (len=datelen) :: date
!
      if (lroot) then
        line = read_line_from_file('RELOAD') ! get first line from file RELOAD
        if ((line == '') .and. present(annotation)) then
          line = trim(annotation)
        endif
        if (present(file)) then
          unit = 1
          call date_time_string(date)
          open(unit,FILE=file,position='append')
          write(unit,*) &
               '! -------------------------------------------------------------'
!
!  Add comment from `RELOAD' and time.
!
          write(unit,'(A,A)') ' ! ', trim(line)
          write(unit,'(A,A)') ' ! Date: ', trim(date)
          write(unit,*) '! t=', t
        endif
!
        write(unit,NML=run_pars             )
!
        call write_eos_run_pars(unit)
        call write_hydro_run_pars(unit)
        call write_forcing_run_pars(unit)
        call write_gravity_run_pars(unit)
        call write_selfgravity_run_pars(unit)
        call write_poisson_run_pars(unit)
        call write_entropy_run_pars(unit)
        call write_magnetic_run_pars(unit)
        call write_lorenz_gauge_run_pars(unit)
        call write_testscalar_run_pars(unit)
        call write_testfield_run_pars(unit)
        call write_testflow_run_pars(unit)
        call write_radiation_run_pars(unit)
        call write_pscalar_run_pars(unit)
        call write_chiral_run_pars(unit)
        call write_chemistry_run_pars(unit)
        call write_dustvelocity_run_pars(unit)
        call write_dustdensity_run_pars(unit)
        call write_neutralvelocity_run_pars(unit)
        call write_neutraldensity_run_pars(unit)
        call write_cosmicray_run_pars(unit)
        call write_cosmicrayflux_run_pars(unit)
        call write_interstellar_run_pars(unit)
        call write_shear_run_pars(unit)
        call write_testperturb_run_pars(unit)
        call write_viscosity_run_pars(unit)
        call write_special_run_pars(unit)
        call write_shock_run_pars(unit)
        call write_solid_cells_run_pars(unit)
        call write_NSCBC_run_pars(unit)
        call particles_wparam2(unit)
!
        if (present(file)) then
          close(unit)
        endif
!
      endif
!
    endsubroutine print_runpars
!***********************************************************************
    subroutine check_consistency_of_lperi(label)
!
!  Check consistency of lperi.
!
!  18-jul-03/axel: coded
!
      character (len=*) :: label
      logical :: lwarning=.true.
      integer :: j
!
!  Identifier.
!
      if (lroot.and.ip<5) print*,'check_consistency_of_lperi: called from ',label
!
!  Make the warnings less dramatic looking, if we are only in start
!  and exit this routine altogether if, in addition, ip > 13.
!
      if (label=='read_startpars'.and.ip>13) return
      if (label=='read_startpars') lwarning=.false.
!
!  Check x direction.
!
      j=1
      if (any(bcx(1:nvar)=='p'.or. bcx(1:nvar)=='she').and..not.lperi(j).or.&
         any(bcx(1:nvar)/='p'.and.bcx(1:nvar)/='she').and.lperi(j)) &
           call warning_lperi(lwarning,bcx(1:nvar),lperi,j)
!
!  Check y direction.
!
      j=2
      if (any(bcy(1:nvar)=='p').and..not.lperi(j).or.&
         any(bcy(1:nvar)/='p').and.lperi(j)) &
           call warning_lperi(lwarning,bcy(1:nvar),lperi,j)
!
!  Check z direction.
!
      j=3
      if (any(bcz(1:nvar)=='p').and..not.lperi(j).or.&
         any(bcz(1:nvar)/='p').and.lperi(j)) &
           call warning_lperi(lwarning,bcz(1:nvar),lperi,j)
!
!  Print final warning.
!  Make the warnings less dramatic looking, if we are only in start.
!
      if (lroot .and. (.not. lwarning)) then
        if (label=='read_startpars') then
          print*,'[bad BCs in start.in only affects post-processing' &
               //' of start data, not the run]'
        else
          print*,'check_consistency_of_lperi(run.in): you better stop and check!'
          print*,'------------------------------------------------------'
          print*
        endif
      endif
!
    endsubroutine check_consistency_of_lperi
!***********************************************************************
    subroutine warning_lperi(lwarning,bc,lperi,j)
!
!  Print consistency warning of lperi.
!
!  18-jul-03/axel: coded
!
      character (len=*), dimension(mvar) :: bc
      logical, dimension(3) :: lperi
      logical :: lwarning
      integer :: j
!
      if (lroot) then
        if (lwarning) then
          print*
          print*,'------------------------------------------------------'
          print*,'W A R N I N G'
          lwarning=.false.
        else
          print*
        endif
!
        print*,'warning_lperi: inconsistency, j=', j, ', lperi(j)=',lperi(j)
        print*,'bc=',bc
        print*,"any(bc=='p'.or. bc=='she'), .not.lperi(j) = ", &
          any(bc=='p'.or. bc=='she'), .not.lperi(j)
        print*, "any(bcx/='p'.and.bcx/='she'), lperi(j) = ", &
          any(bc=='p'.or. bc=='she'), .not.lperi(j)
      endif
!
    endsubroutine warning_lperi
!***********************************************************************
    subroutine wparam ()
!
!  Write startup parameters
!
!  21-jan-02/wolf: coded
!
      logical :: lhydro         = lhydro_var
      logical :: ldensity       = ldensity_var
      logical :: lentropy       = lentropy_var
      logical :: lshock         = lshock_var
      logical :: lmagnetic      = lmagnetic_var
      logical :: llorenz_gauge  = llorenz_gauge_var
      logical :: ldustvelocity  = ldustvelocity_var
      logical :: ldustdensity   = ldustdensity_var
      logical :: ltestscalar    = ltestscalar_var
      logical :: ltestfield     = ltestfield_var
      logical :: ltestflow      = ltestflow_var
      logical :: linterstellar  = linterstellar_var
      logical :: lcosmicray     = lcosmicray_var
      logical :: lcosmicrayflux = lcosmicrayflux_var
!
      namelist /lphysics/ &
          lhydro,ldensity,lentropy,lmagnetic, llorenz_gauge, &
          ltestscalar,ltestfield,ltestflow, &
          lpscalar,lradiation,ldustvelocity,ldustdensity, &
          lforcing,lgravz,lgravr,lshear,ltestperturb,linterstellar,lcosmicray, &
          lcosmicrayflux, &
          lshock,lradiation_fld, &
          leos_ionization,leos_fixed_ionization,lvisc_hyper,lchiral, &
          leos,leos_temperature_ionization,lneutralvelocity,lneutraldensity
!
!  Write the param.nml file only from root processor.
!  However, for pacx-MPI (grid-style computations across different platforms)
!  we'd need this on each site separately (not done yet).
!  (In that case we'd need to identify separate master-like processors
!  one at each site.)
!
      if (lroot) then
        open(1,FILE=trim(datadir)//'/param.nml',DELIM='apostrophe', &
               STATUS='unknown')
!
!  Write init_pars.
!
        write(1,NML=init_pars)
!
!  Write each namelist separately.
!
        call write_eos_init_pars(1)
        call write_hydro_init_pars(1)
        call write_density_init_pars(1)
        call write_forcing_init_pars(1)
        call write_gravity_init_pars(1)
        call write_selfgravity_init_pars(1)
        call write_poisson_init_pars(1)
        call write_entropy_init_pars(1)
        call write_magnetic_init_pars(1)
        call write_lorenz_gauge_init_pars(1)
        call write_testscalar_init_pars(1)
        call write_testfield_init_pars(1)
        call write_testflow_init_pars(1)
        call write_radiation_init_pars(1)
        call write_pscalar_init_pars(1)
        call write_chiral_init_pars(1)
        call write_chemistry_init_pars(1)
        call write_signal_init_pars(1)
        call write_dustvelocity_init_pars(1)
        call write_dustdensity_init_pars(1)
        call write_neutralvelocity_init_pars(1)
        call write_neutraldensity_init_pars(1)
        call write_cosmicray_init_pars(1)
        call write_cosmicrayflux_init_pars(1)
        call write_interstellar_init_pars(1)
        call write_shear_init_pars(1)
        call write_testperturb_init_pars(1)
        call write_viscosity_init_pars(1)
        call write_special_init_pars(1)
        call write_shock_init_pars(1)
        call write_solid_cells_init_pars(1)
        call write_NSCBC_init_pars(1)
        call write_initial_condition_pars(1)
        call particles_wparam(1)
        ! The following parameters need to be communicated to IDL
        write(1,NML=lphysics              )
        close(1)
      endif
!
      call keep_compiler_quiet(lhydro)
      call keep_compiler_quiet(ldensity)
      call keep_compiler_quiet(lentropy)
      call keep_compiler_quiet(lmagnetic)
      call keep_compiler_quiet(ltestscalar,ltestfield,ltestflow)
      call keep_compiler_quiet(lpscalar,lradiation,lcosmicray,lcosmicrayflux)
      call keep_compiler_quiet(linterstellar,lshock)
      call keep_compiler_quiet(ldustdensity,ldustvelocity)
      call keep_compiler_quiet(llorenz_gauge)
!
    endsubroutine wparam
!***********************************************************************
    subroutine rparam ()
!
!  Read startup parameters.
!
!  21-jan-02/wolf: coded
!
      open(1,FILE=trim(datadir)//'/param.nml')
      read(1,NML=init_pars)
      call read_eos_init_pars(1)
      call read_hydro_init_pars(1)
      call read_density_init_pars(1)
      call read_forcing_init_pars(1)
      call read_gravity_init_pars(1)
      call read_selfgravity_init_pars(1)
      call read_poisson_init_pars(1)
      call read_entropy_init_pars(1)
      call read_magnetic_init_pars(1)
      call read_testscalar_init_pars(1)
      call read_testfield_init_pars(1)
      call read_testflow_init_pars(1)
      call read_radiation_init_pars(1)
      call read_pscalar_init_pars(1)
      call read_chiral_init_pars(1)
      call read_chemistry_init_pars(1)
      call read_signal_init_pars(1)
      call read_dustvelocity_init_pars(1)
      call read_dustdensity_init_pars(1)
      call read_neutralvelocity_init_pars(1)
      call read_neutraldensity_init_pars(1)
      call read_cosmicray_init_pars(1)
      call read_cosmicrayflux_init_pars(1)
      call read_interstellar_init_pars(1)
      call read_shear_init_pars(1)
      call read_testperturb_init_pars(1)
      call read_viscosity_init_pars(1)
      call read_special_init_pars(1)
      call read_shock_init_pars(1)
      call read_solid_cells_init_pars(1)
      call read_NSCBC_init_pars(1)
      call read_initial_condition_pars(1)
      call particles_rparam(1)
      close(1)
!
      if (lroot.and.ip<14) then
        print*, "rho0,gamma=", rho0,gamma
      endif
!
    endsubroutine rparam
!***********************************************************************
    subroutine wparam2 ()
!
!  Write runtime parameters for IDL.
!
!  21-jan-02/wolf: coded
!
      if (lroot) then
        open(1,FILE=trim(datadir)//'/param2.nml',DELIM='apostrophe')
        write(1,NML=run_pars)
        call write_eos_run_pars(1)
        call write_hydro_run_pars(1)
        call write_density_run_pars(1)
        call write_forcing_run_pars(1)
        call write_gravity_run_pars(1)
        call write_selfgravity_run_pars(1)
        call write_poisson_run_pars(1)
        call write_entropy_run_pars(1)
        call write_magnetic_run_pars(1)
        call write_testscalar_run_pars(1)
        call write_testfield_run_pars(1)
        call write_testflow_run_pars(1)
        call write_radiation_run_pars(1)
        call write_pscalar_run_pars(1)
        call write_chiral_run_pars(1)
        call write_chemistry_run_pars(1)
        call write_dustvelocity_run_pars(1)
        call write_dustdensity_run_pars(1)
        call write_neutralvelocity_run_pars(1)
        call write_neutraldensity_run_pars(1)
        call write_cosmicray_run_pars(1)
        call write_cosmicrayflux_run_pars(1)
        call write_interstellar_run_pars(1)
        call write_shear_run_pars(1)
        call write_testperturb_run_pars(1)
        call write_viscosity_run_pars(1)
        call write_special_run_pars(1)
        call write_shock_run_pars(1)
        call write_solid_cells_run_pars(1)
        call write_NSCBC_run_pars(1)
        call particles_wparam2(1)
        close(1)
      endif
!
    endsubroutine wparam2
!***********************************************************************
    subroutine write_pencil_info()
!
!  Write information about requested and diagnostic pencils.
!  Do this only when on root processor.
!
     integer :: i
!
     if (lroot) then
       open(1,FILE=trim(datadir)//'/pencils.list')
       write(1,*) 'Pencils requested:'
       do i=1,npencils
         if (lpenc_requested(i)) write(1,*) i, pencil_names(i)
       enddo
       write(1,*) ''
       write(1,*) 'Pencils requested for diagnostics:'
       do i=1,npencils
         if (lpenc_diagnos(i)) write(1,*) i, pencil_names(i)
       enddo
       write(1,*) ''
       write(1,*) 'Pencils requested for 2-D diagnostics:'
       do i=1,npencils
         if (lpenc_diagnos2d(i)) write(1,*) i, pencil_names(i)
       enddo
       write(1,*) ''
       write(1,*) 'Pencils requested video output'
       do i=1,npencils
         if (lpenc_video(i)) write(1,*) i, pencil_names(i)
       enddo
       print*, 'write_pencil_info: pencil information written to the file pencils.list'
       close(1)
     endif
!
   endsubroutine write_pencil_info
!***********************************************************************
endmodule Param_IO


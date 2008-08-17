;
;  $Id: pc_particles_to_ascii.pro,v 1.2 2008-08-17 10:25:30 ajohan Exp $
;
;  Output particles positions in ascii file.
;
;  Author: Anders Johansen
;
pro pc_particles_to_ascii, xxp, filename=filename, npar=npar, $
    lwrite_tauf=lwrite_tauf, datadir=datadir
;
;  Default values.
;
default, filename, './particles.dat'
default, npar, n_elements(xxp[*,0])
default, lwrite_tauf, 0
default, datadir, './data'
;
;  Read friction time from parameter files.
;
if (lwrite_tauf) then begin
  pc_read_param, obj=par, datadir=datadir, /quiet
  pc_read_pdim, obj=pdim, datadir=datadir, /quiet
  if (max(par.tausp_species) eq 0.0) then begin
;
;  Single friction time.
;
    ipar_fence_species=0
  endif else begin
;
;  Multiple friction times.
;
    npar_species=n_elements(par.tausp_species)
    npar_per_species=pdim.npar/npar_species
    ipar_fence_species=lonarr(npar_species)
    ipar_fence_species[0]=npar_per_species-1
    for jspec=1,npar_species-1 do begin
      ipar_fence_species[jspec]=ipar_fence_species[jspec-1]+npar_per_species
    endfor
  endelse
endif
;
;  Open file for writing.
;
close, 1
openw, 1, filename
;
;  Loop over particles.
;
for ipar=0L,npar-1 do begin
  if (lwrite_tauf) then begin
    if (max(par.tausp_species) eq 0.0) then begin
      tauf=par.tausp
    endif else begin
      ispec=0
      while (ipar gt ipar_fence_species[ispec]) do begin
        ispec=ispec+1
      endwhile
      tauf=par.tausp_species[ispec]
    endelse
    printf, 1, xxp[ipar,*], tauf, format='(4f9.4)'
  endif else begin
    printf, 1, xxp[ipar,*], format='(3f9.4)'
  endelse
endfor
;
;  Close file.
;
close, 1
;
end

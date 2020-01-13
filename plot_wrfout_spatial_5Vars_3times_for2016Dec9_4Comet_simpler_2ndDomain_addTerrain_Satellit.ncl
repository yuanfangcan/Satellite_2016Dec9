;;; developed by Xiao-Ming Hu on Jan 12, 2020
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;XCO2_Dec89 = addfile("/oasis/scratch/comet/xhu2/temp_project/Run/CO2_and_otherGHG/WRFV3.9.1.1/China/wrfchem3.9.1.1_R2_China2NE_10mb_Hil3ReShrubRES_addOce_restoreDF_ODIAC_CT2017.2016010100/extract_netCDF_Fortran_xhu/simulated_XCO2_domainWide_Fortran_Dec89.nc","r")
XCO2_Dec89 = addfile("/oasis/scratch/comet/xhu2/temp_project/Run/CO2_and_otherGHG/WRFV3.9.1.1/China/wrfchem3.9.1.1_R2_China2Shanghai_10mb_Hil3ReShrubRES_addOce_restoreDF_ODIAC_CT2017.2016010100/extract_netCDF_Fortran_xhu/simulated_XCO2_domainWide_Fortran_Dec89_d02.nc","r")
;hourselect = (/10, 15, 20/)
;hourselect = (/12, 17, 22/)
hourselect = (/12, 20, 32/)
hourselectX = hourselect/2 


layer = 0
do idomain =  2,2 ;  3, 3
  WRFchemJun = addfile("/oasis/projects/nsf/uok114/hujun/wrfout_d0"+idomain+"_2016-12-06_12:00:00.nc","r")
  WRFchemJunEmiss = addfile("/oasis/projects/nsf/uok114/hujun/wrfchemi_00z_d0"+idomain+".nc","r")
;  Emiss_CO2 = addfile("/oasis/projects/nsf/uok114/xhu2/Codes/WRFV3.9.1/WRFV3_kpp_config66_NETCDF4_HiltonParameter/test/em_real/wrfchemi_d0"+idomain+"_valueFromODIAC_China12month_2016_Shanghai.nc","r")
  Emiss_CO2 = addfile("/oasis/scratch/comet/xhu2/temp_project/Run/CO2_and_otherGHG/WRFV3.9.1.1/China/wrfchem3.9.1.1_R2_China2Shanghai_10mb_Hil3ReShrubRES_addOce_restoreDF_ODIAC_CT2017.2016010100/wrfchemi_d0"+idomain+".nc","r")

  files = systemfunc ("ls wrfout_d0"+idomain+"_2016-12-08_12*:00 wrfout_d0"+idomain+"_2016-12-08_20*:00 wrfout_d0"+idomain+"_2016-12-09_08*:00")

;  plot = new(15,graphic)
;  figurename = "wrfout_d0"+idomain+"_3VarsOverlayObs_0"; with Terrain 
   NO2_origSwath = True
  if (NO2_origSwath) then 
   figurename = "wrfout_d0"+idomain+"_3VarsOverlayObs_7"; for SatelliteData 
  else 
   figurename = "wrfout_d0"+idomain+"_3VarsOverlayObs_6"; for SatelliteData 
  end if 
  if (idomain.eq.2) then 
;   figurename = "wrfout_d0"+idomain+"_3VarsOverlayObs_1"; thetae1000 m  (/10, 15, 20/)
    XCO2_2ndDomain = False 
   if (XCO2_2ndDomain) then 
    figurename = "wrfout_d0"+idomain+"_3VarsOverlayObs_2"; add CO2 ; full domain 
   else 
     figurename = "wrfout_d0"+idomain+"_3VarsOverlayObs_3"; using 2nddomainXCO2 
   end if 
  end if 
   wks_type = "png"
   wks_type@wkWidth = 1450
   wks_type@wkHeight = 1450

  wks = gsn_open_wks(wks_type ,figurename)           ; ps,pdf,x11,ncgm,eps
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; select color map
 cmap = gsn_retrieve_colormap(wks)
do icorlor = 2,4
 cmap(icorlor,:) = cmap(0,:)
end do
  gsn_define_colormap(wks,cmap) ; select color map
  file_target = files(0) 
  f     = addfile(file_target+".nc","r")

  vars  = (/"AOD","XCO2","CO","NO2"/) 

 do ivar= 0,dimsizes(vars)-1  ; obs LT, sim UTC  4 hours difference
  print("working on ivar "+vars(ivar))
  fmap  = f 
  Times_char = f->Times
   Times_char(0,13) = Times_char(0,4) 
   Times_char(0,16) = Times_char(0,4) 

  ua  = wrf_user_getvar(f,"ua",0)   ; u on mass points
  va  = wrf_user_getvar(f,"va",0)   ; v on mass points 
    thetae = wrf_user_getvar(f,"eth",0)      ;
    height = wrf_user_getvar(f,"height",0)
    thetae_1000wrf = wrf_interp_3d_z(thetae, height, 1000.)
    ua_1000wrf = wrf_interp_3d_z(ua, height, 1000.)
    va_1000wrf = wrf_interp_3d_z(va, height, 1000.)

  v     = va(layer,:,:) 
  u     = ua(layer,:,:)

      gsres               = True
      gsres@gsMarkerIndex = 16          ; circle at first
      gsres@gsMarkerThicknessF = 1
      gsres@gsMarkerSizeF = 0.01
;      gsres@gsMarkerColor      = "black"
  tres       =  True
  tres@txFontHeightF = 0.0152005
  tres@txBackgroundFillColor = "White" 


  res                       = True             ; plot mods desired
  res@cnFillMode = "RasterFill"
  res@mpDataBaseVersion  = "Ncarg4_1"
  res@mpDataSetName      = "Earth..4"
  res@mpDataBaseVersion     = "MediumRes"  ; Medium resolution database
  res@mpOutlineBoundarySets = "AllBoundaries"
  res@mpGeophysicalLineThicknessF = 3.0 ; 1.5          ; thickness of outlines
  res@mpProvincialLineThicknessF  = 2.
  res@mpProvincialLineColor = "black"
 res@mpGeophysicalLineThicknessF = 3.0
 res@mpNationalLineThicknessF = 3.0
 res@mpGeophysicalLineColor = "Black"; (/22/)
 res@mpNationalLineThicknessF = 3.0
 res@mpNationalLineColor = res@mpGeophysicalLineColor

  res@tmYRMajorOutwardLengthF = 0
  res@tmYLMajorOutwardLengthF = 0
  res@tmXBMajorOutwardLengthF = 0
  res@tmXBMinorOutwardLengthF = 0

   if (ivar.eq.1) then 
    res@tmYLLabelsOn = True 
   else 
    res@tmYLLabelsOn = False 
   end if 
   if (ivar.eq.2) then 
    res@lbLabelBarOn = True 
   else 
    res@lbLabelBarOn = False
   end if 
    res@vpXF             = 0.0511+0.4535512*(ivar-1)

  res@vpHeightF             = 0.3820
  res@vpWidthF              = 0.45
;  res@lbOrientation   = "vertical"
  res@lbLabelFontHeightF = 0.012
  res@tmXBLabelFontHeightF = 0.0102
  res@tmYLLabelFontHeightF = 0.0102
  res@gsnStringFontHeightF = 0.0105
  res@gsnFrame  = False
  res@gsnDraw   = False 
;  res@gsnMaximize = True
;  res@gsnPaperOrientation   = "portrait"
  res@gsnSpreadColors       = True             ; use full range of colormap
  res@cnFillOn              = True             ; color plot desired
  res@cnLinesOn             = False            ; turn off contour lines
  res@cnLineLabelsOn        = False            ; turn off contour labels

  res@lbLabelStride         =2 
;  res@lbLabelAutoStride = True ;
  res@tmYLLabelStride = 2
  res@tmXBLabelStride = 2

  WRF_map_c(fmap, res, 0)                   ; reads info from file
  res@mpOutlineBoundarySets = "AllBoundaries"
   res@vcRefAnnoOn = False ; True 
   res@vcLabelFontHeightF  = 0.0182
   res@vcRefAnnoFontHeightF = 0.02112
   res@vcRefMagnitudeF          = 8.             ; define vector ref mag
   res@vcRefLengthF             = 0.045          ; define length of vec ref
   res@vcRefAnnoOrthogonalPosF  = -.985            ; move ref vector
   res@vcRefAnnoParallelPosF  = 0.985            ; move ref vector
   res@vcMinDistanceF           = 0.06            ; larger means sparser
   res@vcLineArrowHeadMaxSizeF  = 0.0175          ; default: 0.05 (LineArrow), 0.012 (CurlyVector) 
   res@vcGlyphStyle             = "CurlyVector"   ; default: "LineArrow"  
   res@gsnScalarContour      = True               ; contours desired    

  res@tfDoNDCOverlay       = True     

  res@pmTickMarkDisplayMode = "Always"         ; turn on tickmarks
 res@tmXTOn = False            ; turn off top   labels 
 res@tmYROn = False            ; turn off right labels

  res@cnInfoLabelOn       = False ; True

  res@lbTitleOn        =  True                ; turn on title
;  res@lbTitleString    = "   ~C~  ~C~~V10~K"   ; "O~B~3, ~N~ppbv"             ; title string

  res@lbTitlePosition  = "right";"Top"              ; title position
  res@lbTitleFontHeightF= .012                ; make title smaller
  res@lbTitleDirection = "Across"             ; title direction
;  res@lbTopMarginF = 0.3
;  res@lbBottomMarginF = 0.13
  res@lbTitleOffsetF = 0.0
  res@lbTitleJust = "CenterCenter"


  res@cnInfoLabelOrthogonalPosF = -0.04
  res@cnInfoLabelString   = "Min= $ZMN$ Max= $ZMX$"

  res@lbLabelFontHeightF = 0.012
; do iplot = 0 , 4 ; add sst, acctually TSK 
 do iplot = 0 ,0 ; 2 ;  4 ; add sst, acctually TSK 
  res@cnLevelSelectionMode  = "ManualLevels"

  if (iplot.eq.0) then 
 TIMEWRF=WRFchemJun->Times(hourselect(0)+36,:12)  
  print("working on WRF time "+TIMEWRF)
   CST_hr = mod(stringtoint(chartostring(Times_char(0, 11:12)))+24+8, 24)
   res@gsnRightString = "" ; chartostring(fmap->Times(0,:12)) + "UTC "  +CST_hr +"LT"
   res@tmXBLabelsOn = False
   U10     = f->U10(0,:,:)
   V10     = f->V10(0,:,:)
     HGT     = f->HGT(0,:,:)
   if (ivar.eq.2) then
     x = Emiss_CO2->E_CO2(0,0,:,:) 
     x = (/x/1000./)
     res@lbTitleString    = "E_CO2 ~C~ m s~S~-1" 
;    res@cnMaxLevelValF        = 20 
;    res@cnMinLevelValF       = 2 
;    res@cnLevelSpacingF   =  2. 
   else 
;  res@cnMaxLevelValF        = 50 
;  res@cnMinLevelValF       = 15 
;  res@cnLevelSpacingF   =  5. 
   res@cnMaxLevelValF        =1. 
   res@cnMinLevelValF       = 0.3 
   res@cnLevelSpacingF   =  .1 
     x = WRFchemJunEmiss->E_NO(0,0,:,:) 
     res@lbTitleString    = "E_NO ~C~ m s~S~-1" 
   end if 
  end if 

  if (iplot.eq.9990) then 
  res@cnMaxLevelValF        = 6 
  res@cnMinLevelValF       = 4 
  res@cnLevelSpacingF   =  0.2 
 TIMEWRF=WRFchemJun->Times(hourselect(ivar)+36,:12)  
  print("working on WRF time "+TIMEWRF)
   CST_hr = mod(stringtoint(chartostring(Times_char(0, 11:12)))+24+8, 24)
   res@gsnRightString = chartostring(fmap->Times(0,:12)) + "UTC "  +CST_hr +"LT"
   res@tmXBLabelsOn = False
   U10     = f->U10(0,:,:)
   V10     = f->V10(0,:,:)
   HGT     = f->HGT(0,:,:)
   x = U10
   x = (/sqrt(U10^2+V10^2)/)
;   res@lbTitleString    = "WSP ~C~ m s~S~-1" 
  end if 
  if (iplot.eq.1) then 
  res@cnMaxLevelValF        = 140 
  res@cnMinLevelValF       = 20 
  res@cnLevelSpacingF   =  20 
   res@tmXBLabelsOn = False
  res@gsnRightString    = "" ;  string_xhu_show 
   U10     = f->U10(0,:,:)
   V10     = f->V10(0,:,:)
;   x = U10
;   x = (/sqrt(U10^2+V10^2)/)
; x=WRFchemJun->PM2_5_DRY(hourselect(ivar)+36,0,:,:)  
;   res@lbTitleString    = "PM~B~2.5~N~ ~C~~F33~m~F~g m~S~-3" 
  res@cnMaxLevelValF        = 120 
  res@cnMinLevelValF       = 20 
  res@cnLevelSpacingF   =  20 
 x=WRFchemJun->no(hourselect(ivar)+36,0,:,:)  
 x=(/x*1000/)
    res@cnLevelSelectionMode  = "ExplicitLevels"
   res@cnLevels= (/2, 5, 10, 20, 40,70,100, 200/)
   res@lbTitleString    = "NO~C~ppbv" 
  end if 

  if (iplot.eq.9991) then 
  res@cnMaxLevelValF        = 80 
  res@cnMinLevelValF       = 66 
  res@cnLevelSpacingF   =  2. 
  res@gsnRightString    = "" ;  string_xhu_show 
   x  = wrf_user_getvar(f,"rh2",0)   ; v on mass points
   res@lbTitleString    = "RH~C~ "+x@units 
  end if 
  if (iplot.eq.4) then 
   res@vcRefAnnoOn = False 
   res@gsnLeftString =  "" ; chartostring(fmap->Times)
  res@cnMaxLevelValF        = 10 
  res@cnMinLevelValF       = 2 
  res@cnLevelSpacingF   =  1. 
  res@gsnRightString    = "" ;  string_xhu_show 
   x  = f->T2(0,:,:)
   x = x-273.15
   res@lbTitleString    = "T2~C~~S~o~N~C" 

  layer = 0
  x= f->CO2_BIO(0,layer,:,:) + f->CO2_ANT(0,layer,:,:) - f->CO2_BCK(0,layer,:,:)
     res@lbTitleString    = "CO~B~2~N~~C~ppmv"
  res@cnMinLevelValF       = 408 ;
  res@cnMaxLevelValF        = 440 ; 2016 scale


  end if 

  if (iplot.eq.2) then 
  res@cnMaxLevelValF        = 10 
  res@cnMinLevelValF       = 1 
  res@cnLevelSpacingF   =  1. 
  res@gsnRightString    = "" ;  string_xhu_show 
  res@gsnLeftString =  "" ; chartostring(fmap->Times)
;   res@lbTitleString    = "  K~B~H~N~~C~m~S~2~N~s~S~-1~N~"
;   x  = f->EXCH_H(0,1,:,:) 
;  printVarSummary(x)
;  printVarSummary(XCO2_Dec89->XCO2)
   x= XCO2_Dec89->XCO2(hourselectX(ivar),:,:)
   res@tmXBLabelsOn = True 
  res@lbTitleString    = "XCO~B~2~N~~C~ppmv"
  res@cnMinLevelValF       = 404 ;
  res@cnMaxLevelValF        = 412 ; 2016 scale

  end if 

  if (iplot.eq.9990) then 
   res@tmXBLabelsOn = False ; True 
   res@cnMaxLevelValF        =294 
  res@cnMinLevelValF       = 285 
  res@cnLevelSpacingF   =  1.   
   x  = thetae_1000wrf 
  res@lbTitleString    = " ~F5~q~F~~B~e~N~~C~ K"
   res@gsnLeftString = "" 
  end if 

  res@vpYF              =0.98-(0.3820+0.0051)*iplot
  res@lbLabelStride = 2
  dim_var = dimsizes(x)
  lat2d  = f->XLAT(0,:,:)
  long2d = f->XLONG(0,:,:)
  
  res@tfDoNDCOverlay       =False ;   True
  if (idomain.eq.2) then
   res@mpRightCornerLonF =123.75 
   res@mpRightCornerLatF =33.09025
   res@mpLeftCornerLonF =113.201 
;  res@mpLeftCornerLatF =30.001
  else 
   res@mpRightCornerLonF =130.5
;   res@mpRightCornerLatF =39
   res@mpRightCornerLatF =37.5
   res@mpLeftCornerLonF =110.001
;   res@mpLeftCornerLatF =30.001
   res@mpLeftCornerLatF =28.001
  end if 
  x@lon2d = long2d
  x@lat2d = lat2d
  HGT@lon2d = long2d
  HGT@lat2d = lat2d
  u@lon2d = long2d
  u@lat2d = lat2d
  v@lon2d = long2d
  v@lat2d = lat2d
  ua_1000wrf@lon2d = long2d
  ua_1000wrf@lat2d = lat2d
  va_1000wrf@lon2d = long2d
  va_1000wrf@lat2d = lat2d

;  plot(iplot+5*ivar)                 = gsn_csm_vector_scalar_map(wks,ua_1000wrf,va_1000wrf,x,res)
  if(iplot.gt.0) then 
   plot                 = gsn_csm_vector_scalar_map(wks,u,v,x,res)
    if (ivar.gt.0) then 
     draw(plot)
    end if 
  else 
  res_ter                       = True             ; plot mods desired
  res_ter@vpHeightF             = 0.3820
  res_ter@vpWidthF              = 0.45
  res_ter@vpXF             = 0.0511+0.4535512*(mod(ivar,2))
  res_ter@vpYF              =0.98-(0.45555)*(ivar/2)
  res_ter@lbLabelFontHeightF = 0.012
  res_ter@tmXBLabelFontHeightF = 0.0102
  res_ter@tmYLLabelFontHeightF = 0.0102

  res_ter@gsnFrame              = False
  res_ter@gsnDraw               = False

  res_ter@cnFillOn              = True             ; color plot desired
  res_ter@cnFillPalette         = "gsltod"         ; Select grayscale colormap
  res_ter@cnLinesOn             = False            ; turn off contour lines
  res_ter@cnLineLabelsOn        = False            ; turn off contour labels
  res_ter@cnFillMode            = "RasterFill"
  res_ter@cnFillOpacityF        = 1.
  res_ter@lbLabelBarOn          = False
  res_ter@gsnRightString        =  ""

  res_ter = wrf_map_resources(fmap, res_ter)      ; set map resources to match those on WRF file
     
  res_ter@tfDoNDCOverlay        = False ; True
  res_ter@mpRightCornerLonF = res@mpRightCornerLonF; =123.5 
  res_ter@mpRightCornerLatF = res@mpRightCornerLatF; =34.05
  res_ter@mpLeftCornerLonF  = res@mpLeftCornerLonF ;=112.001 
  res_ter@mpLeftCornerLatF  = res@mpLeftCornerLatF ;=112.001 

  res_ter@mpOutlineBoundarySets = "AllBoundaries"
  res_ter@mpDataSetName         = "Earth..4"      ; Gives us provincial boundaries
  res_ter@mpGeophysicalLineThicknessF = 1.5       ; thickness of map outlines
  res_ter@mpProvincialLineThicknessF  = 2.
  res_ter@mpGeophysicalLineThicknessF = 3.0
  res_ter@mpNationalLineThicknessF = 3.0
  res_ter@mpProvincialLineColor       = "black" 
  res_ter@mpNationalLineColor       = "black" 
  res_ter@mpGeophysicalLineColor       = "black" 

  res_ter@pmTickMarkDisplayMode = "Always"         ; turn on nicer tickmarks
  res_ter@tmYLLabelStride       = 2                ; label every other tickmark
  res_ter@tmXBLabelStride       = 2
   if (mod(ivar,2).eq.1) then 
    res_ter@tmYLLabelsOn = False 
   else 
    res_ter@tmYLLabelsOn = True 
   end if 

;---Point the tickmarks inward
  res_ter@tmYRMajorOutwardLengthF = 0
  res_ter@tmYLMajorOutwardLengthF = 0
  res_ter@tmXBMajorOutwardLengthF = 0
  res_ter@tmXBMinorOutwardLengthF = 0
  res_ter@tmXTOn                  = True 
  res_ter@tmYROn                  = True 
  res_ter@tmYRLabelsOn            = False
  res_ter@tmXTLabelsOn            = False
  res_ter@cnLevelSelectionMode = "ManualLevels"
  res_ter@cnMaxLevelValF       = 500 
  res_ter@cnMinLevelValF       = 50 
  res_ter@cnLevelSpacingF      = 50 
  res_ter@gsnLeftString        =  ""

;---Set resources for rain total contour plot
  res_tot                       = True
  res_tot@lbLabelStride         =2 
   if (mod(ivar,2).eq.1) then ; did not take effecty 
    res_tot@tmYLLabelsOn = False 
   else 
    res_tot@tmYLLabelsOn = True 
   end if 
  res_tot@lbOrientation   = "horizontal"; "vertical"
  res_tot@lbLabelFontHeightF = 0.012
  res_tot@lbTitleOn        =  True                ; turn on title
  res_tot@lbTitlePosition  = "right";"Top"              ; title position
  res_tot@lbTitleFontHeightF= .012                ; make title smaller
  res_tot@lbTitleDirection = "Across"             ; title direction
  res_tot@lbTopMarginF = -0.0513
  res_tot@lbBottomMarginF = 0.0513
  res_tot@lbLeftMarginF = 0.30513
  res_tot@lbRightMarginF = 0.30513
  res_tot@lbTitleOffsetF = 0.0002
  res_tot@lbTitleJust = "CenterCenter"

  res_tot@gsnStringFontHeightF = res@gsnStringFontHeightF; = 0.0105
  res_tot@tmXBLabelFontHeightF = 0.0102
  res_tot@tmYLLabelFontHeightF = 0.0102
  res_tot@gsnFrame              = False
  res_tot@gsnDraw               = False
  res_tot@vpHeightF             = 0.3820
  res_tot@vpWidthF              = 0.45
  res_tot@vpXF             = 0.0511+0.4535512*(mod(ivar,2))
  res_tot@vpYF              =0.98-(0.45555)*(ivar/2)

  cmap     := read_colormap_file("BlAqGrYeOrReVi200")
  cmap(0,:) = (/0,0,0,0/)    ; make first color fully transparent

  res_tot@cnFillOn             = True
  res_tot@cnFillPalette        = cmap
  res_tot@cnLinesOn            = False            ; turn off contour lines
  res_tot@cnLineLabelsOn       = False            ; turn off contour labels
  res_tot@cnFillOpacityF       = 1.               ; .85 
 
  res_tot@tfDoNDCOverlay        = False ;True
  res_tot@mpRightCornerLonF = res@mpRightCornerLonF; =123.5 
  res_tot@mpRightCornerLatF = res@mpRightCornerLatF; =34.05
  res_tot@mpLeftCornerLonF  = res@mpLeftCornerLonF ;=112.001 
  res_tot@mpLeftCornerLatF  = res@mpLeftCornerLatF ;=112.001 

  res_tot@cnLevelSelectionMode = "ManualLevels"
  res_tot@cnMaxLevelValF       = res@cnMaxLevelValF 
  res_tot@cnMinLevelValF       = res@cnMinLevelValF 
  res_tot@cnLevelSpacingF      =  res@cnLevelSpacingF 

  res_tot@pmLabelBarHeightF    = 0.08        ; Make labelbar less thick
  res_tot@pmLabelBarOrthogonalPosF = -0.008

  res_tot@cnInfoLabelOn        = False; True
  res_tot@cnInfoLabelString    = "Min= $ZMN$ Max= $ZMX$"
  res_tot@cnInfoLabelOrthogonalPosF = -0.104        ; move info label into plot

  res_tot@tiMainFont           = "Helvetica-bold"
  res_tot@tiMainFontHeightF    = 0.018
  res_tot@gsnRightString       = res@gsnRightString ; "" ; "RAIN, mm" 
  res_tot@gsnLeftString        =  ""
   if (ivar.eq.2) then
;    res_tot@lbTitleString    = "WSP ~C~ m s~S~-1" 
     res_tot@lbTitleString    = "E_CO2 ~C~kmol km~S~-2~N~ hr~S~-1~N~" 
   else 
     x = WRFchemJunEmiss->E_NO(0,0,:,:) 
;     res_tot@lbTitleString    = "E_NO ~C~mol km~S~-2~N~ hr~S~-1~N~" 
   end if 

      plot_terrain = gsn_csm_contour_map(wks,HGT,res_ter)

   SatelliteNC = False 
    if (ivar.eq.2) then 
      res_tot@cnFillMode           = "RasterFill"
      res_tot@cnMaxLevelValF        =.7 
      res_tot@cnMinLevelValF       = 0.3 
      res_tot@cnLevelSpacingF   =  .05 

     if (NO2_origSwath) then 
         ncol = 400 
         NO2 = readAsciiTable("Satellite_2016Dec9/NPP/NO2_1.txt", ncol, "float", 0)
         NO2_LAT = readAsciiTable("Satellite_2016Dec9/NPP/NO2_LAT_1.txt", ncol, "float", 0)
         NO2_LON = readAsciiTable("Satellite_2016Dec9/NPP/NO2_LON_1.txt", ncol, "float", 0)
        NO2(:,331:) = (/NO2@_FillValue/)
        res_tot@lbTitleString    = "NO~B~2~N~~C~DU"
       res_tot@cnFillMode           = "AreaFill"
      else 
         ncol = 31
         NO2 = readAsciiTable("Satellite_2016Dec9/NPP/NO2.txt", ncol, "float", 0)
         NO2_LAT = readAsciiTable("Satellite_2016Dec9/NPP/NO2_LAT.txt", ncol, "float", 0)
         NO2_LON = readAsciiTable("Satellite_2016Dec9/NPP/NO2_LON.txt", ncol, "float", 0)
         res_tot@lbTitleString    = "NO2~C~DU"
       end if 
        NO2@lat2d = NO2_LAT
        NO2@lon2d = NO2_LON 
       plot_raintot = gsn_csm_contour(wks,NO2,res_tot)
      
   end if  

     if (ivar.eq.3) then 
       res_tot@cnFillMode           = "AreaFill"
       res_tot@cnMaxLevelValF    = 1.5 ; for AIRS CO after *1e7
       res_tot@cnMinLevelValF    = 1.3
       res_tot@cnLevelSpacingF   =  .025
         ncol = 34
         CO = readAsciiTable("Satellite_2016Dec9/AIRS/CO.txt", ncol, "float", 0)
         CO_LAT = readAsciiTable("Satellite_2016Dec9/AIRS/CO_LAT.txt", ncol, "float", 0)
         CO_LON = readAsciiTable("Satellite_2016Dec9/AIRS/CO_LON.txt", ncol, "float", 0)
        res_tot@lbTitleString    = "CO~C~e-7"
        CO = (/CO*1e7/)
        CO@lat2d = CO_LAT
        CO@lon2d = CO_LON 
       plot_raintot = gsn_csm_contour(wks,CO,res_tot)
    end if  
   
   if (ivar.eq.1) then 
;       data_array = readAsciiTable("/nsftor/xhu/ACT-America/OCO/OCO2_9_LITE_LEVEL2/2016/OCO-2_9_LITE_LEVEL2_extracted_2016only.nc_2sMean.txt", 4, "double", 1)
     print("reading OCO-2")
       data_array = readAsciiTable("OCO-2_9_LITE_LEVEL2_extracted_2016only.nc_2sMean.txt", 4, "double", 1)
     print("finish reading OCO-2")
       date_str =       tostring(tolong(data_array(:,0)))
      print("prepare OCO2 time string")
;       date     =       tochar(tostring(tolong(data_array(:,0))))
       latitude_good  = data_array(:,2)
       longitude_good = data_array(:,3)
       xco2_good      = data_array(:,1)

     print("reading WRF XCO2")
      iday_dec9 = 344-1
   if (XCO2_2ndDomain) then 
      fXCO2 = addfile("extract_netCDF_Fortran_xhu/simulated_XCO2_domainWide_Fortran_06UTC_d0"+idomain+".nc","r")
     print("finish reading WRF XCO2")
      XCO2 = fXCO2->XCO2(iday_dec9,:,:)
      XCO2@lon2d = long2d
      XCO2@lat2d = lat2d
      res_tot@cnFillMode           = "RasterFill"
    else 
      fXCO2 = addfile("extract_netCDF_Fortran_xhu/simulated_XCO2_domainWide_Fortran_06UTC_d01.nc","r")
      res_tot@cnFillMode           = "AreaFill"
     print("finish reading WRF XCO2")
      fd01 = addfile("wrfinput_d01.nc","r")
      XCO2 = fXCO2->XCO2(iday_dec9,:,:)
      XCO2@lon2d = fd01->XLONG(0,:,:) 
      XCO2@lat2d = fd01->XLAT(0,:,:) 
    end if 
      Times_char_XCO2 = fXCO2->timeUTC

    CST_hr = mod(stringtoint(chartostring(Times_char_XCO2(iday_dec9,11:12)))+8+24, 24)
   str_to_find = "2016"+chartostring(Times_char_XCO2(iday_dec9,5:6)) + chartostring(Times_char_XCO2(iday_dec9,8:9))
   print("looking for "+str_to_find)
   ii = str_match_ind(date_str,str_to_find)
      lat  = latitude_good(ii)
      lon  = longitude_good(ii)
      xco2 = xco2_good(ii)
      res_tot@cnMaxLevelValF        = 413.
      res_tot@cnMinLevelValF       = 405. 
      res_tot@cnLevelSpacingF   =  1. 
      res_tot@lbTitleString    = "XCO~B~2~N~~C~ppmv"
       plot_raintot = gsn_csm_contour(wks,XCO2,res_tot)
      levels = ispan(405,413,1)
  getvalues plot_raintot@contour
;    "cnLevels" : levels
;    "cnFillColors" : colors
;    "cnFillPalette" : colors ; Attempt to reference attribute (contour) which is undefined
  end getvalues
  num_distinct_markers = dimsizes(levels)+1        ; number of distinct markers
  dims=dimsizes(xco2) 
  lat_new = new((/num_distinct_markers,dims/),double,-999)
  lon_new = new((/num_distinct_markers,dims/),double,-999)
  do j = 0, num_distinct_markers-1
    if (j.eq.0) then
      indexes = ind(xco2.lt.levels(0))
    end if
    if (j.eq.num_distinct_markers-1) then
      indexes = ind(xco2.ge.max(levels))
;     print("color "+j+" indexes="+indexes)
    end if
    if (j.gt.0.and.j.lt.num_distinct_markers-1) then
      indexes = ind(xco2.ge.levels(j-1).and.xco2.lt.levels(j))
    end if

    if (.not.any(ismissing(indexes))) then 
      npts_range = dimsizes(indexes)   ; # of points in this range.
      lat_new(j,0:npts_range-1) = lat(indexes)
      lon_new(j,0:npts_range-1) = lon(indexes)
     if (j.eq.0) then
     print("color "+j+"npts_range="+npts_range)
     end if
    end if
    delete(indexes)            ; Necessary b/c "indexes" may be a different
                               ; size next time.
    end do ; j = 0, num_distinct_markers-1

   end if 

   if (ivar.eq.0) then 
       res_tot@cnFillMode           = "RasterFill"
      if (SatelliteNC) then 
        fsat = addfile("Satellite_data_Dec9Case_fromLan2020Jan.nc","r")
        AOD = fsat->AOD(::3,:)
        AOD_LAT = fsat->AOD_LAT(::3,:)
        AOD_LON = fsat->AOD_LON(::3,:)
       else 
         ncol = 301 
         AOD = readAsciiTable("Satellite_2016Dec9/MODIS/AOD.txt", ncol, "float", 0)
         AOD_LAT = readAsciiTable("Satellite_2016Dec9/MODIS/AOD_LAT.txt", ncol, "float", 0)
         AOD_LON = readAsciiTable("Satellite_2016Dec9/MODIS/AOD_LON.txt", ncol, "float", 0)
       end if ; SatelliteNC 
        res_tot@lbTitleString    = "AOD"
        AOD@lat2d = AOD_LAT
        AOD@lon2d = AOD_LON 
       plot_raintot = gsn_csm_contour(wks,AOD,res_tot)
     end if ; ivar.eq.2  


     overlay(plot_terrain, plot_raintot)
     draw(plot_terrain)

  if (ivar.eq.1) then 
  gsres               = True
;  gsres@gsMarkerIndex = 4          ; circle at first
  gsres@gsMarkerIndex = 16          ; circle at first
  
  do j = 0, num_distinct_markers-1
    if (.not.ismissing(lat_new(j,0)))
      gsres@gsMarkerThicknessF = 1
      gsres@gsMarkerIndex = 16          ; Use filled dots for markers.
;      gsres@gsMarkerSizeF = 0.012
      gsres@gsMarkerSizeF = 0.014
      gsres@gsMarkerColor      = cmap(1,:); "white"
      gsn_polymarker(wks,plot_terrain,lon_new(j,:),lat_new(j,:),gsres)
      gsres@gsMarkerSizeF = 0.011
      gsres@gsMarkerColor      = cmap((200/(413-405))*j,:);colors(j)
      gsn_polymarker(wks,plot_terrain,lon_new(j,:),lat_new(j,:),gsres)
    end if
   end do
  end if ;   if (ivar.eq.1) then
 

  end if  ;  where is if ?  
    res@cnLevelSelectionMode  = "ManualLevels"
  abc_show = (/"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o"/)
;  gsn_text(wks,plot,abc_show(iplot+5*ivar),-101.0,33.2,tres)

;481130069 +32.819952 -96.860082        DALLAS HINTON
      gsres               = True
      gsres@gsMarkerThicknessF = 1
      gsres@gsMarkerSizeF = 0.015
;      gsres@gsMarkerColor      = "black"
      gsres@gsMarkerIndex = 13          ; circle at first

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  draw(plot(iplot+ivar*3))
  end do ; iplot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   end do ; ivar
  frame(wks)

;  system("convert -density 300 -resize 1500x1500 -trim  "+figurename+".eps /nsftor/xhu/public_html/CO2_and_otherGHG/WRFV3.9.1.1/YSU/wrfchem_junhu.2016010100_Dec9/"+figurename+".png")
;  system("mv  "+figurename+".png /nsftor/xhu/public_html/CO2_and_otherGHG/WRFV3.9.1.1/YSU/wrfchem_junhu.2016010100_Dec9/"+figurename+".eps")

 print("finish plotting "+figurename+".eps")
 delete(u)
 delete(v)
 delete(ua)
 delete(va)
 delete(files)
end do ; idomain
end
;        if (any(isnan_ieee(AOD))) then 
;          AOD@_FillValue = -999. ; or whatever value you want to use 
;          replace_ieeenan (AOD, AOD@_FillValue, 0) 
;        end if 
;        system("rm debug.nc")
;        fdebug = addfile("debug.nc","c")
;        fdebug->AOD_LAT = AOD_LAT(::3,:)
;        fdebug->AOD_LON = AOD_LON(::3,:)

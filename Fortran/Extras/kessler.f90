!-----------------------------------------------------------------------
!
!  Version:  2.0
!
!  Date:  January 22nd, 2015
!
!  Change log:
!  v2 - Added sub-cycling of rain sedimentation so as not to violate
!       CFL condition.
!
!  The KESSLER subroutine implements the Kessler (1969) microphysics
!  parameterization as described by Soong and Ogura (1973) and Klemp
!  and Wilhelmson (1978, KW). KESSLER is called at the end of each
!  time step and makes the final adjustments to the potential
!  temperature and moisture variables due to microphysical processes
!  occurring during that time step. KESSLER is called once for each
!  vertical column of grid cells. Increments are computed and added
!  into the respective variables. The Kessler scheme contains three
!  moisture categories: water vapor, cloud water (liquid water that
!  moves with the flow), and rain water (liquid water that falls
!  relative to the surrounding air). There  are no ice categories.
!  Variables in the column are ordered from the surface to the top.
!
!  SUBROUTINE KESSLER(theta, qv, qc, qr, rho, pk, dt, z, nz, rainnc)
!
!  Input variables:
!     theta  - potential temperature (K)
!     qv     - water vapor mixing ratio (gm/gm)
!     qc     - cloud water mixing ratio (gm/gm)
!     qr     - rain  water mixing ratio (gm/gm)
!     rho    - dry air density (not mean state as in KW) (kg/m^3)
!     pk     - Exner function  (not mean state as in KW) (p/p0)**(R/cp)
!     dt     - time step (s)
!     z      - heights of thermodynamic levels in the grid column (m)
!     nz     - number of thermodynamic levels in the column
!     precl  - Precipitation rate (m_water/s)
!
! Output variables:
!     Increments are added into t, qv, qc, qr, and rainnc which are
!     returned to the routine from which KESSLER was called. To obtain
!     the total precip qt, after calling the KESSLER routine, compute:
!
!       qt = sum over surface grid cells of (rainnc * cell area)  (kg)
!       [here, the conversion to kg uses (10^3 kg/m^3)*(10^-3 m/mm) = 1]
!
!
!  Authors: Paul Ullrich
!           University of California, Davis
!           Email: paullrich@ucdavis.edu
!
!           Based on a code by Joseph Klemp
!           (National Center for Atmospheric Research)
!
!  Reference:
!
!    Klemp, J. B., W. C. Skamarock, W. C., and S.-H. Park, 2015:
!    Idealized Global Nonhydrostatic Atmospheric Test Cases on a Reduced
!    Radius Sphere. Journal of Advances in Modeling Earth Systems. 
!    doi:10.1002/2015MS000435
!
!=======================================================================

SUBROUTINE KESSLER(theta, qv, qc, qr, rho, pk, dt, z, nz, precl)

  use machine  , only : kind_phys

  IMPLICIT NONE


  !------------------------------------------------
  !   Input / output parameters
  !------------------------------------------------

  INTEGER, INTENT(IN) :: nz ! Number of thermodynamic levels in the column

  REAL(kind=kind_phys), DIMENSION(nz), INTENT(INOUT) :: &
            theta   ,     & ! Potential temperature (K)
            qv      ,     & ! Water vapor mixing ratio (gm/gm)
            qc      ,     & ! Cloud water mixing ratio (gm/gm)
            qr              ! Rain  water mixing ratio (gm/gm)

  REAL(kind=kind_phys), DIMENSION(nz), INTENT(IN) :: &
            rho             ! Dry air density (not mean state as in KW) (kg/m^3)

  REAL(kind=kind_phys), INTENT(OUT) :: &
            precl          ! Precipitation rate (m_water / s)

  REAL(kind=kind_phys), DIMENSION(nz), INTENT(IN) :: &
            z       ,     & ! Heights of thermo. levels in the grid column (m)
            pk              ! Exner function (p/p0)**(R/cp)

  REAL(kind=kind_phys), INTENT(IN) :: & 
            dt              ! Time step (s)


  !------------------------------------------------
  !   Local variables
  !------------------------------------------------
  REAL(kind=kind_phys), DIMENSION(nz) :: r, rhalf, velqr, sed, pc

  REAL(kind=kind_phys) :: f5, f2x, xk, ern, qrprod, prod, qvs, psl, rhoqr, dt_max, dt0

  INTEGER :: k, rainsplit, nt

  !------------------------------------------------
  !   Begin calculation
  !------------------------------------------------
  f2x = 17.27d0
  f5 = 237.3d0 * f2x * 2500000.d0 / 1003.d0
  xk = .2875d0      !  kappa (r/cp)
  psl    = 1000.d0  !  pressure at sea level (mb)
  rhoqr  = 1000.d0  !  density of liquid water (kg/m^3)

  do k=1,nz
    r(k)     = 0.001d0*rho(k)
    rhalf(k) = sqrt(rho(1)/rho(k))
    pc(k)    = 3.8d0/(pk(k)**(1.0d0/xk)*psl)

    ! Liquid water terminal velocity (m/s) following KW eq. 2.15
    velqr(k)  = 36.34d0*(qr(k)*r(k))**0.1364d0*rhalf(k)
  end do

  ! Maximum time step size in accordance with CFL condition
  if (dt .le. 0.d0) then
    write(*,*) 'kessler.f90 called with nonpositive dt'
    stop
  end if

  dt_max = dt
  do k=1,nz-1
    if (velqr(k) .ne. 0.d0) then
      dt_max = min(dt_max, 0.8d0*(z(k+1)-z(k))/velqr(k))
    end if
  end do

  ! Number of subcycles
  rainsplit = ceiling(dt / dt_max)
  dt0 = dt / real(rainsplit, kind_phys)

  ! Subcycle through rain process
  precl = 0.d0

  do nt=1,rainsplit

    ! Precipitation rate (m/s)
    precl = precl + rho(1) * qr(1) * velqr(1) / rhoqr

    ! Sedimentation term using upstream differencing
    do k=1,nz-1
      sed(k) = dt0*(r(k+1)*qr(k+1)*velqr(k+1)-r(k)*qr(k)*velqr(k))/(r(k)*(z(k+1)-z(k)))
    end do
    sed(nz)  = -dt0*qr(nz)*velqr(nz)/(0.5d0*(z(nz)-z(nz-1)))

    ! Adjustment terms
    do k=1,nz

      ! Autoconversion and accretion rates following KW eq. 2.13a,b
!TAJO      qrprod = qc(k) - (qc(k)-dt0*amax1(0.0010d0*(qc(k)-0.0010d0),0.0d0))/(1.0d0+dt0*2.20d0*qr(k)**0.8750d0)
!TAJO      qc(k) = amax1(qc(k)-qrprod,0.0d0)
!TAJO      qr(k) = amax1(qr(k)+qrprod+sed(k),0.0d0)
      qrprod = qc(k) - (qc(k)-dt0*max(0.0010d0*(qc(k)-0.0010d0),0.0d0))/(1.0d0+dt0*2.20d0*qr(k)**0.8750d0)
      qc(k) = max(qc(k)-qrprod,0.0d0)
      qr(k) = max(qr(k)+qrprod+sed(k),0.0d0)

      ! Saturation vapor mixing ratio (gm/gm) following KW eq. 2.11
      qvs = pc(k)*exp(f2x*(pk(k)*theta(k)-273.0d0)   &
             /(pk(k)*theta(k)- 36.0d0))
      prod = (qv(k)-qvs)/(1.d0+qvs*f5/(pk(k)*theta(k)-36.d0)**2)

      ! Evaporation rate following KW eq. 2.14a,b
!TAJO      ern = amin1(dt0*(((1.60d0+124.90d0*(r(k)*qr(k))**.2046d0)  &
!TAJO            *(r(k)*qr(k))**0.525d0)/(2550000d0*pc(k)            &
!TAJO            /(3.8d0 *qvs)+540000))*(dim(qvs,qv(k))         &
!TAJO            /(r(k)*qvs)),amax1(-prod-qc(k),0.0d0),qr(k))
      ern = min(dt0*(((1.60d0+124.90d0*(r(k)*qr(k))**.2046d0)  &
            *(r(k)*qr(k))**0.525d0)/(2550000d0*pc(k)            &
            /(3.8d0 *qvs)+540000))*(dim(qvs,qv(k))         &
            /(r(k)*qvs)),max(-prod-qc(k),0.0d0),qr(k))

      ! Saturation adjustment following KW eq. 3.10
!TAJO      theta(k)= theta(k) + 2500000d0/(1003.d0*pk(k))*(amax1( prod,-qc(k))-ern)
!TAJO      qv(k) = amax1(qv(k)-max(prod,-qc(k))+ern,0.d0)
!TAJO      qc(k) = qc(k)+max(prod,-qc(k))
      theta(k)= theta(k) + 2500000d0/(1003.d0*pk(k))*(max( prod,-qc(k))-ern)
      qv(k) = max(qv(k)-max(prod,-qc(k))+ern,0.d0)
      qc(k) = qc(k)+max(prod,-qc(k))
      qr(k) = qr(k)-ern
    end do

    ! Recalculate liquid water terminal velocity
    if (nt .ne. rainsplit) then
      do k=1,nz
        velqr(k)  = 36.34d0*(qr(k)*r(k))**0.1364d0*rhalf(k)
      end do
    end if
  end do
!TAJO  precl = precl / dble(rainsplit)
  precl = precl / real(rainsplit, kind_phys)

END SUBROUTINE KESSLER

!=======================================================================


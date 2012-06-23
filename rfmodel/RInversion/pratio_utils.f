c
c     Utilities for Poisson's Ratio Vp/Vs conversions
c
      real function vpovs_to_pr(vpovs)
      real vpovs
        vpovs_to_pr = (vpovs*vpovs - 2 )/(2*(vpovs*vpovs-1))
      return
      end
c
      real function pr_to_vpovs(pr)
      real pr
        pr_to_vpovs = sqrt( (2*(1-pr))/(1-2*pr) )
      return
      end


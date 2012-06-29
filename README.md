# Masters Thesis

Hey this is everything to do with my Masters thesis including documentation, presentations, scripts and of course the code. Since I have not started the paper yet I have not come up with a catchy title, but give me a few more months and I'll get there.

## Processing Chain

1.  Filter Event Directories

    Function SortEventDirs.m selects only those directories
    which have just numbers as their name. This should
    leave out directories with names such as 'test'.

2.  Convert sac file format, filter bad picks

    Function ConvertTraces uses the function readsac.m to
    read in sac data, some quality checking/filtering occurs.

3.  Window with Taper and fourier transform signal.

    p data is windowed with a tukey taper and passed through
    the fft algorithm into `wft` with fft'd s trace vectors
    going into `vft`.

4.  Bin by p value (build pIndex)

    Right now an logical index array is created. Each line in the
    array is associated with a pbin, and it's columns are the
    zeros and ones which select the appropriate trace that corrisponds
    to this bin.

5.  Impulse Response: Stack and Deconvolve

    The sorted fourier transformed signals are sent into simdecf.m
    to be deconvolved into what should be something like a greens
    function. These are saved in `rft` which is passed through the
    inverse fourier transform to recover `rec`.

6.  Filter Impulse Response, aquire data tps

    Filter with bandpass filter `(0.04, 1)` hz and use filtered response to select `tps` as
    max values within a certain range (here from 3ish to 5ish seconds).

7.  IRLS Newtons Method to find regression Tps

    Newtons method for non-linear regression with three variables.
    Linear solution solving with IRLS solver (homemade but tested and working).
    IRLS solver to downweight high residuals, to get a pseudo L1 solution.
    Solution is an L1-like non-linear regression fit for the tps data.

8.  Curvelet Denoising. Can I even use this?

9.  Grid and Line Search

    With the `tps` found above solve the `tpps` and `tpss` ratios for each
    `Vp` and `R` in a range of choices. Use the `tpps` and `tpss` times to index
    into receiver functions, and sum and average all the values in the range
    of reciever functions for this Vp and R. This is Gridded out and the
    maximum is selected. The best `Vp` and `R` are then used to find `H` in a
    line search. These are plotted over the reviever functions.

### Still to Complete
- Migrate some more matlab code to Python. Keep chewing up the proc chain.

### Tuning, testing
- Need to make the error estimates more transparent.
- Figure out what to do with Curvelet denoising. It has potential.
- Reproduce results using cross-validation, and similar azimuth station data.
- Use synthetic and data with known P velocity to test model.

### Change Log
#### June 27th 2012
- I missed like a billion updates. Ugh. Documentation is a bitch.
- Moved freetran func from a matlab -> python script and included it in the pre-processing.
- Anyway developed a whole litter of python scripts for pre-processing new data.
- developed a seismogram picker program using Matplotlib which I prefer to matlab.
- Refactored some of the overArching dataDriver -> database stuff in Matlab.
    - The only data from specific runs that is saved is:
        - Data necessary for standard plots.
        - Paramaters required to regenerate the data.

#### February 19th 2012
- Using -v6 .mat files to avoid compression and speed up saves and loads.
- Processed all stations from Micheals server
- Collected in Database. Database is loaded into memory for each addition
- Have many bad results, various reasons. Notes have been made for each station entry.

#### February 17th 2012
- Built database structure and tools for adding new station data and removing data.
- Changed several data types in functions
- Reworked error message system.
- Removed unnecessary steps and info in functions and drivers.

#### February 16th 2012
- Refactored Code
- Created meta-program DataDriver which now runs ProcessTraces and attempts to collect error messages on failure.
- DataDriver collects all results into a db structure saved as database.mat.
- db has each entry as station name plus a prefix, so we can have multiple vversions of each station, as to try out different parameters.

#### December 20th 2011
- Finished IRLS Newton Solver
- Encapsulate Newton Solver in a Function.
- Tried a few filters, need to try more.
- Using similar plots to Paper. - compares well.
- Added step 9) Grid Search.

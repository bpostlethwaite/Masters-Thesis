Masters Thesis Code
===================

Processing Chain
----------------

1.  Filter Event Directories

    Function SortEventDirs.m selects only those directories
    which have just numbers as their name. This should 
    leave out directories with names such as 'test'.

2.  Convert sac file format, filter bad picks

    Function ConvertTraces uses the function readsac.m to
    read in sac data. This data is then sent to freetran
    to rotate the coordinates from r and z into p and s.
    header file infor is saved into cell array 'header' and
    slowness p values are sent to vector 'pslows'

3.  Window with Taper and fourier transform signal.

    p data is windowed with a tukey taper and passed through 
    the fft algorithm into 'wft' with fft'd s trace vectors 
    going into 'vft'.

4.  Bin by p value (build pIndex)

    Right now an logical index array is created. Each line in the
    array is associated with a pbin, and it's columns are the 
    zeros and ones which select the appropriate trace that corrisponds
    to this bin.

5.  Impulse Response: Stack and Deconvolve

    The sorted fourier transformed signals are sent into simdecf.m
    to be deconvolved into what should be something like a greens
    function. These are saved in 'rft' which is passed through the
    inverse fourier transform to recover 'Rtrace'.

6.  Filter Impulse Response, aquire data tps

    Filter with bandpass filter [0.01 1]hz and use filtered response to select tps as
    max values within a certain range (here from 3ish to 5ish seconds).

7.  IRLS Newtons Method to find regression Tps

    Newtons method for non-linear regression with three variables.
    Linear solution solving with IRLS solver (homemade but tested and working).
    IRLS solver to downweight high residuals, to get a pseudo L1 solution.
    Solution is an L1-like non-linear regression fit for the tps data.

8.  Grid and Line Search

    With the Tps found above, solve the tpps and tpss ratios for each
    Vp and R in a range of choices. Use the tpps and tpss times to index
    into receiver functions, and sum and average all the values in the range
    of reciever functions for this Vp and R. This is Gridded out and the
    maximum is selected. The best Vp and R are then used to find H in a 
    line search. These are plotted over the reviever functions.

### Still to Complete
*   Keep track of which traces are removed, and for what reason [Complete]
*   Build in some feature that modifies the tps window we do the automatic picks.
This has an impact on the convergence of the Newton Iterations.
*   Re-order the datastructure so name is on top, etc.
### Tuning, testing
*   Associate particular event and station with bad event.
*   Run testing on pbin logical index array [COMPLETE].
*   Filter out and flag poorly picked traces [COMPLETE].
*   Test different filters, compare outcome. 
*   Reproduce results using cross-validation, and similar azimuth station data.
*   Eigenvalues of Hessian
    
### Change Log
#### February 17th 2012
*   Built database structure and tools for adding new station data and removing data.
*   Changed several data types in functions
*   Reworked error message system.
*   Removed unnecessary steps and info in functions and drivers.

#### February 16th 2012
*   Refactored Code
    * Created meta-program DataDriver which now runs ProcessTraces and attempts to collect error messages on failure.
    * DataDriver collects all results into a db structure saved as database.mat.
    * db has each entry as station name plus a prefix, so we can have multiple vversions of each station, as to try out different parameters.
#### December 20th 2011
*   Finished IRLS Newton Solver
*   Encapsulate Newton Solver in a Function.
*   Tried a few filters, need to try more.
*   Using similar plots to Paper. - compares well.
*   Added step 9) Grid Search.



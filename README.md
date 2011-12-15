Masters Thesis Code
===================

Processing Chain
----------------

1.  Select Station folder to be processed
2.  Filter Event Directories

    Function SortEventDirs.m selects only those directories
    which have just numbers as their name. This should 
    leave out directories with names such as 'test'.

3.  Convert sac file format, filter bad picks

    Function ConvertTraces uses the function readsac.m to
    read in sac data. This data is then sent to freetran
    to rotate the coordinates from r and z into p and s.
    header file infor is saved into cell array 'header' and
    slowness p values are sent to vector 'pslows'

4.  Bin by p value (build pIndex)

    Right now an logical index array is created. Each line in the
    array is associated with a pbin, and it's columns are the 
    zeros and ones which select the appropriate trace that corrisponds
    to this bin.

5.  Window with Taper and fourier transform signal.

    p data is windowed with a tukey taper and passed through 
    the fft algorithm into 'wft' with fft'd s trace vectors 
    going into 'vft'.

6.  Impulse Response: Stack and Deconvolve

    The sorted fourier transformed signals are sent into simdecf.m
    to be deconvolved into what should be something like a greens
    function. These are saved in 'rft' which is passed through the
    inverse fourier transform to recover 'Rtrace'.

7.  Filter Impulse Response, aquire tps

    Filter with lowpass filter and use filtered response to select tps as
    max values within a certain range (here from 3ish to 5ish seconds).

8.  Newtons Method to find prelim alpha, beta and H

    Need to implement an L1 solver for the linear equation step. Right now
    it is biased to extreme values and coming out with complex numbers.

### Tuning and Testing
*   Run testing on pbin logical index array [COMPLETE].
*   Filter out and flag poorly picked traces [COMPLETE].
*   Streamline workflow.
*   Build Newton solver, figure out where tps is.
*   Move on to next stage in project.
    
### Change Log
*   Changed function names
*   Working on Newton solver.
*   Added function pbinIndexer and tested it on known data
*   Tried a few filters
*   Began implementing newtons method.

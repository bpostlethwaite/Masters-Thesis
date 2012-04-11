#!/bin/python3
# saclink.py combs through the given root folder for station folders and their sub event folders
# Within each event folder it looks for the specific event/station sac file name and creates a symlink
# with a generic name pointing to it. If the Links are already present for the given directory this is logged,
# if there are no files meeting the regex requirements, this is also logged. All successful links created are
# also logged. The logging will be broken into several files for ease of use.

import os, os.path, re, subprocess, pickle

sh = subprocess.Popen

def SeiSpider(files,p1,p2,p3):
    """ Searches through directories and looks for station data matches
    specifically it looks for the long form orignal data, as well as
    looking for the general named form symlinks. For each given 
    Directory it returns a set and a dictionary, the dictionary has
    keys corrisponding to the component of the time series, while the
    value is the filename of the target file. The set holds the names
    of the returned general name matches. """
    
    # match1 is a dictionary so we could be sure about the component names
    # and sorting them, in order to apply the right symlink to them
    match1 = {}
    match2  = set()
    match3  = set()
    fnames = files
    # Hand SeiSpider a bunch of filenames
    for f in fnames:
        try:
            m1 = p1.match(f)
            for comp in m1.groups():
                if comp:                # Create a dictionary with components R,T,V as keys, and filenames as values
                    match1[comp] = m1.group(0)
        except AttributeError:
            pass
        
        try:
            m2 = p2.match(f)
            match2.add(m2.group(0))
        except AttributeError:
            pass

        try:
            m3 = p3.match(f)
            match3.add(m3.group(0))
        except AttributeError:
            pass


    return (match1, match2, match3)
        
def SeisLinks(d,targetfiles,linknames):
    """ Creates symlinks in given directory d to the targetfiles dictionary
    with linknames in dictionary linknames. These dictionaries must have
    crossreferenced key names so the values are used in the linking process"""

    for k in targetfiles.keys():
        sh('ln -s {} {}'.format(os.path.join(d,targetfiles[k]),
                                  os.path.join(d,linknames[k])),shell=True)
 

def RunScan(root,file1=None,file2=None,ignore=None,Linker=None,matcher=None): 
    """ This runs the scan and performs actions on found files.
    It tries to make sure that the found files are in the event folders
    any function can be used for the processing that follows
    the arguement / output API. It ignores folders listed in set ignore"""
    
    linked = finished = needproc = problems = 0
        
    for (thisDir,dirsHere,filesHere) in os.walk(root):
        (path,DIR) = os.path.split(thisDir)
        if ignore and DIR in ignore:                   # If an ignore list/set specified use it and check if Dir is in it
            pass                                       # If it is skip it
        else:
            if matcher:
                match1,match2,match3 = matcher(filesHere,p1,p2,p3)
                if (len(match1.keys()) == 3) and (len(match2) != 3):    # If 3 rotated components but not all linked to gen named symlinks
                    if Linker:                           # Run the symlinker if supplied
                        Linker(thisDir,match1,linknames)
                    linked += 1                                        # Increment Linked
                elif len(match2) == 3:                             # If General named links are present, we are good
                    finished += 1
                elif len(match3) == 3 and len(match2) != 3:      # If we have UNrotated components, and no general named symlinks
                    needproc += 1
                    if file1:
                        file1.write(thisDir+"\n")
                else:                                          # All other cases
                    print(thisDir)
                    print(filesHere)
                    problems += 1
                    if file2:
                        file2.write(thisDir+"\n")
    
    return linked,finished,needproc,problems




if __name__ == '__main__':

    root = '/media/TerraS/CNSN'
    station = set(os.listdir(root))
    linknames = {'R':'STACK_R.sac','T':'STACK_T.sac','Z':'STACK_Z.sac'}


    # Match Criteria
    p1 = re.compile(r'.*(?:BH(R).SAC$|BH(T).SAC$|BH(Z).SAC$)')
    p2 = re.compile(r'(STACK_R.sac)|(STACK_T.sac)|(STACK_Z.sac)')
    p3 = re.compile(r'.*(?:BH(E).SAC$|BH(N).SAC$|BH(Z).SAC$)')
    
    probFile = open((os.path.join(root,"probs")),'w')
    procFile = open((os.path.join(root,"needprocs")),'w')
    
    # Check for root dir existence
    if os.path.isdir(root):
        print("root is found")
    else:
        print("root not found")
        exit()


    L,F,R,P = RunScan(root,file1=procFile,file2=probFile,ignore=station,matcher=SeiSpider)


    print("Linkables:  " + str(L))
    print("Finished:  " + str(F))
    print("To be Processed:  " + str(R))
    print("Problem Directories:  " + str(P))


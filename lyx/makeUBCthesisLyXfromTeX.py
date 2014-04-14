#!/usr/bin/python

# This script automates the creation of a UBC Thesis Sample file in LyX,
# using the LaTeX version. This means using tex2lyx to do the initial
# conversion, and then fixing bugs, and then maybe making it look nicer
# as well.
# 2010 July 16: CPBL: first version

# For safety, still call it ubcsamplelyx.lyx, so that exports from
# this don't automatically get named the same thing as the original
# .tex file...

import os
import re
import errno

'''
# These are the commands I run: Michael
rm -r convertToLyx
export TEX2LYX=/Applications/LyX.app/Contents/MacOS/tex2lyx
export LYX=/Applications/LyX.app/Contents/MacOS/lyx
export DIFF=ediff
python makeUBCthesisLyXfromTeX.py
'''
TEX2LYX = os.environ.get('TEX2LYX', 'tex2lyx')
LYX = os.environ.get('LYX', 'lyx')
DIFF = os.environ.get('DIFF', 'meld')
PDFLATEX = os.environ.get('PDFLATEX', 'pdflatex')
EPSTOPDF = os.environ.get('EPSTOPDF', 'epstopdf')

UBCSAMPLE_TEX = '../../ubcsample.tex'

def do_sys(cmd):
    r"""Execute the command and print it."""
    print(cmd)
    os.system(cmd)

def preprocess_tex(text):
    r"""Return preprocessed .tex file to make it easier for the lyx
    converter.

    Parameters
    ----------
    text : String representing the original latex file.
    """
    # Remove preamble and ignore as this will end up in preambl
    start = text.find(r"\begin{document}")
    preamble = text[:start]

    # Add comments package
    ind = preamble.find(r"\usepackage")
    preamble = "\n".join([preamble[:ind],
                          r"\usepackage{comment}", "",
                          preamble[ind:]])
    
    text = text[start:]

    # Match solid blocks of comments that start as "%%% ".  We add a *
    # so we can convert these to Notes later.
    prog = re.compile(r"((^%%% .*\n)+)",
                      flags=re.MULTILINE)
    res = []
    while True:
        # For each block...
        match = prog.search(text)
        if match is None:
            res.append(text)
            break
        res.append(text[:match.start()])
        lines = match.expand(r"\1").splitlines()
        comment = "\n".join(
            [r"\begin{comment}*"] +        # Add \begin{comment}
            [line[4:] for line in lines] + # Remove leading "%%% "
            [r"\end{comment}", "", ""])    # Add \end{comment} + \n\n 
        res.append(comment)
        text = text[match.end():]
        
    text = "".join(res)

    # Match solid blocks of comments that start as "%% "
    prog = re.compile(r"((^%% .*\n)+)",
                      flags=re.MULTILINE)
    res = []
    while True:
        # For each block...
        match = prog.search(text)
        if match is None:
            res.append(text)
            break
        res.append(text[:match.start()])
        lines = match.expand(r"\1").splitlines()
        comment = "\n".join(
            [r"\begin{comment}"] +         # Add \begin{comment}
            [line[3:] for line in lines] + # Remove leading "%% "
            [r"\end{comment}", "", ""])    # Add \end{comment} + \n\n 
        res.append(comment)
        text = text[match.end():]
        
    text = "".join(res)

    # Now match remaining "%% "comments.
    text = re.sub(r"%% (.*)", 
                  r"\\begin{comment}\1\\end{comment}\n",
                  text)
    return "\n".join([preamble, text])
 
def process_lyx(lyx_file):
    r"""Return processed .lyx file.

    Parameters
    ----------
    lyx_file : String representing the file from tex2lyx.
    """
    new = lyx_file

    # Don't know why it does this...
    # It does not: this is in the sample class.  This is the preferred
    # format I believe.
    #new = new.replace(
    #    r'\submitdate{\monthname\ \number\year}',
    #    r'\submitdate{\today}')

    new = new.replace(r'listof{{}',
                      r'listof{')

    # Convert Comments to Notes if they have a *
    new = re.sub(
        r"\\begin_inset\s*Note Comment\s*status open\s*" +
        r"\\begin_layout (.*)\s*\*",
        "\n".join([r"\\begin_inset Note Note",
                   r"status open",
                   r"\\begin_layout \1",
                   r""]),
        new)

    # Close Comments
    new = re.sub(
        r"(\\begin_inset\s*Note Comment\s*status) open(\s*" +
        r"\\begin_layout .*\s*)",
        r"\1 collapsed\2",
        new)
     
    # We don't need to open these any more b/c we have notes for the
    # important stuff.
    new = re.sub(r"inset ERT(\s*)status open", 
                 r"inset ERT\1status collapsed", 
                 new)

    # Insert a comment at the beginning of the file, instructing user
    # to check out the preamble:
    new = re.sub(
        r"\\begin_body\s*\\begin_layout Standard\s*",
        r"""
\\begin_body

\\begin_layout Standard
\\begin_inset Note Note
status open

\\begin_layout Plain Layout
In order to set various aspects of your front matter and thesis 
options, look under Document->Settings->LaTeX Preamble.
\\end_layout

\end_inset""", new)

    import pdb;pdb.set_trace()
    # Add maketitle...
    ind = re.search(r"\\end_layout\s*\\begin_layout\s*Abstract", 
                    new).start()
    new = "\n".join(
        [new[:ind],
         r"\begin_inset ERT",
         r"status collapsed",
         r"",
         r"\begin_layout Plain Layout",
         r"",
         r"\backslash",
         r"maketitle",
         r"",
         r"\end_layout",
         r"",
         r"\end_inset",
         r"",
         new[ind:]
         ])
        

    replacements = []
    replacements.extend([
        
    # WTF the two attempts at dealing with listof bug so far have failed. Try again:
            [r"""\backslash
    listof{
    \end_layout

    \end_inset


    \begin_inset ERT
    status open

    \begin_layout Standard

    {}
    \end_layout

    \end_inset

    Program
    \begin_inset ERT
    status open

    \begin_layout Standard

    }
    \end_layout
    """,r"""\backslash
    listof{Program}{List of Programs}
    \end_layout
    """],

            # Kill the entire abstract!? Yes, kill the entire !@$#? abstract.
    [r"""\begin_layout Abstract

    The 
    \family typewriter
    genthesis.cls
    \family default
     LaTeX class file and accompanying documents, such as this sample thesis, are distributed in the hope that it will be useful but without any warranty (without even the implied warranty of fitness for a particular purpose). For a description of this file's purpose, and instructions on its use, see below.
    \end_layout

    \begin_layout Abstract

    These files are distributed under the GPL which should be included here in the future. Please let the author know of any changes or improvements that should be made.
    \end_layout

    \begin_layout Abstract

    Michael Forbes. mforbes@physics.ubc.ca 
    \end_layout""",'']
        ])


    for aa,bb in replacements:
        new = new.replace(aa,bb)
        #assert bb in rawlyx # Just for debugging.

    return new

def mkdir(path):
    r"Robust mkdir"
    try:
        os.mkdir(path)
    except OSError as exc: # Python >2.5
        if exc.errno == errno.EEXIST:
            pass
        else: raise

def symlink(path, dest=None):
    r"Robust symlink to the current directory"
    if dest is None:
        dest = os.path.basename(path)
    elif dest[-1] == "/":
        dest = dest + os.path.basename(path)

    try:
        os.symlink(path, dest)
    except OSError as exc: # Python >2.5
        if exc.errno == errno.EEXIST:
            pass
        else: raise

if __name__ == '__main__':
    #import pdb;pdb.set_trace()

    #do_sys('cp /home/cpbl/web/latex/ubcthesislyx/hg/ubcthesis/lyx/ubcsamplelyx.lyx ./tmp_MasterHandmadeSample.lyx')
    #do_sys('cp /home/cpbl/web/latex/ubcthesislyx/hg/ubcthesis/ubcsample.tex ./tmp_RawUBCsample.tex')
#do_sys('cp handmade-ubcsamplelyx.lyx ./tmp_MasterHandmadeSample.lyx')

    # We build everything in a new directory convertToLyX.  We also
    # set this up as the "userdir" with a "layouts" subdirectory so
    # that we can specify this to tex2lyx and lyx.
    mkdir('convertToLyX')
    os.chdir('convertToLyx')
    symlink('../../sample.bib')
    symlink('../../ubcthesis.cls')
    symlink('../../genthesis.cls')
    symlink('../../fig.eps')

    mkdir('layouts')
    os.chdir('layouts')
    symlink('../../ubcthesis.layout')
    os.chdir('..')

    # Make a "syntax file" for tex2lyx. This might help it barf less on
    # things like listof ??? See manpage for tex2lyx
    f = open("tmp_cpblSyntax_tex2lyx",'wt')
    f.write("""
    \listof{}{}
    """)
    f.close()

    f = open(UBCSAMPLE_TEX, 'rt')
    text = f.read()
    f.close()

    f = open("00_ubcsample.tex", 'wt')
    f.write(text)
    f.close()
    
    text = preprocess_tex(text)

    f = open("01_ubcsample.tex", 'wt')
    f.write(text)
    f.close()

    #do_sys('tex2lyx -f -userdir '+os.getcwd()+' -c ubcthesis.layout -s "tmp_cpblSyntax_tex2lyx"  tmp_RawUBCsample.tex')
    do_sys(TEX2LYX +
           ' -userdir .' +
           ' -f -s tmp_cpblSyntax_tex2lyx' +
           ' 01_ubcsample.tex 02_ubcsample.lyx')

    f = open('02_ubcsample.lyx', 'rt')
    text = f.read()
    f.close()

    text = process_lyx(text)
    f = open('03_ubcsample_tex2lyx.lyx', 'wt')
    f.write(text)
    f.close()

    # Open and save from lyx as this performs some conversions
    do_sys(LYX + ' -userdir . 03_ubcsample_tex2lyx.lyx' +
           ' -x "command-sequence buffer-write-as' +
           ' 04_ubcsample_tex2lyx2lyx.lyx;' +
           ' lyx-quit;"')

    do_sys(LYX + ' -userdir . -e latex 04_ubcsample_tex2lyx2lyx.lyx')
    # Can't seem to provide a way to force lyx to save the output in a
    # named file.
    os.rename('04_ubcsample_tex2lyx2lyx.tex',
              '05_ubcsample_tex2lyx2lyx2tex.tex')

    f = open('05_ubcsample_tex2lyx2lyx2tex.tex')
    text = f.read()
    f.close()

    # This causes problems with the comments package.
    text = text.replace(r'\usepackage{verbatim}', '')

    f = open('06_ubcsample.tex','wt')
    f.write(text)
    f.close()

    do_sys(EPSTOPDF + ' fig.eps')
    do_sys(PDFLATEX + ' 06_ubcsample.tex')
    do_sys(PDFLATEX + ' 06_ubcsample.tex')
    do_sys(LYX + ' -userdir . -e pdf ../ubcsamplelyx.lyx')
    do_sys(LYX + ' -userdir . -e pdf 04_ubcsample_tex2lyx2lyx.lyx')

    # Compare with previous version
    do_sys(DIFF + ' 04_ubcsample_tex2lyx2lyx.lyx ../ubcsamplelyx.lyx &')

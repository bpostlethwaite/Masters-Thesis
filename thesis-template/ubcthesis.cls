%%
%% This is file `ubcthesis.cls',
%% generated with the docstrip utility.
%%
%% The original source files were:
%%
%% ubcthesis.dtx  (with options: `ubcthesis')
%% 
%% This file was generated from the ubcthesis package.
%% --------------------------------------------------------------
%% 
%% Copyright (C) 2001
%% Michael McNeil Forbes
%% mforbes@alum.mit.edu
%% 
%% This file may be distributed and/or modified under the
%% conditions of the LaTeX Project Public License, either version 1.2
%% of this license or (at your option) any later version.
%% The latest version of this license is in
%%    http://www.latex-project.org/lppl.txt
%% and version 1.2 or later is part of all distributions of LaTeX
%% version 1999/12/01 or later.
%% 
%% This program consists of the files ubcthesis.dtx, ubcthesis.ins, and
%% the sample figures fig.eps and fig.fig.
%% 
%% This file may only be distributed together with a copy of this
%% program. You may, however, distribute this program without generated
%% files such as this one.
%% 

\NeedsTeXFormat{LaTeX2e}[1995/12/01]
\ProvidesClass{ubcthesis}[2012/04/07 v1.70 ^^J
 University of British Columbia Thesis Class]
\PassOptionsToClass{11pt}{genthesis}%
\PassOptionsToClass{pagenumBR}{genthesis}%
\PassOptionsToClass{nochapternotereset}{genthesis}%
\PassOptionsToClass{nobibnum}{genthesis}%
\PassOptionsToClass{appendicestoc}{genthesis}%
\PassOptionsToClass{appendixpage}{genthesis}%
\DeclareOption*{%
  \PassOptionsToClass{\CurrentOption}{genthesis}%
}
\ProcessOptions*\relax
\LoadClass{genthesis}
\copyrightnotice{}
\renewcommand{\titlefont}{\huge \bfseries}
\renewcommand{\subtitlefont}{\Large \bfseries}
\newlength{\@logocopywidth}
\newlength{\@logocopyheight}
\newlength{\@logowidth}
\newcommand\@logo{\hbox{
    \iflogo
    \includegraphics*[height=\@logocopyheight]{\@logofile}
    \fi}}
\newcommand\@logocopybare{\vbox{%
    \@condupper{@upperinstitution}{\@institution}\par%
    (\@institutionaddress)\par%
    \@submitdate\par%
    \@copyrighttext}}
\newcommand\@logocopy{\vbox{
    \hbox to\@logocopywidth{%
      \hfil\@condupper{@upperinstitution}{\@institution}\hfil}
    \vspace{1.5ex}
    \hbox to\@logocopywidth{\hfil(\@institutionaddress)\hfil}
    \vspace{1.5ex}
    \hbox to\@logocopywidth{\hfil\@submitdate\hfil}
    \vspace{1.5ex}
    \hbox to\@logocopywidth{%
      \hfil\@copyrighttext\hfil}}}
\renewcommand{\titlepage}{
  \null\vfil
  \begin{center}%
    {\titlefont \@condupper{@uppertitle}{\@title}\par}%
    \vspace{1em}%
    \if@subtitle
      {\subtitlefont \@condupper{@uppersubtitle}{\@subtitle}\par}%
      \vspace{1em}%
    \fi
    by \par%
    \vspace{1em}%
    {\authorfont%
      \@condupper{@upperauthor}{\@author}\par%
    }%
    \if@empty\@previousdegrees\else\vfil\fi%
    \if@empty\@previousdegrees\else\@previousdegrees\fi%
    \vfil
    A THESIS SUBMITTED IN PARTIAL FULFILLMENT OF\par%
    THE REQUIREMENTS FOR THE DEGREE OF\par%
    \vspace{1em}
    {\degreetitlefont\@condupper{@upperdegreetitle}{\@degreetitle}\par}%
    \vspace{1em}
    in \par%
    \vspace{1em}
    {\facultyfont \@condupper{@upperfaculty}{\@faculty}\par}%
    \vspace{1em}
    (\@program)\par%
    \vspace{1em plus 1fil minus 0.5em}%
    \setbox0=\@logocopybare
    \setlength{\@logocopywidth}{\wd0}
    \settoheight{\@logocopyheight}{\@logocopy}
    \settowidth{\@logowidth}{\@logo}
    \centerline{\hbox{%
        \hfill\@logo\@logocopy\hspace{\@logowidth}}}
    \if@empty\@copyrightnotice\else\vfil\@copyrightnotice\fi
  \end{center}
  \vfil\null
}
\@AtStartOfAbstract{%
  \if@twoside\else
    \setcounter{page}{2}
  \fi
}
  \@AfterTitlepage{\global\let\ps@empty\ps@plain}
\endinput
%%
%% End of file `ubcthesis.cls'.

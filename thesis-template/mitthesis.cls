%%
%% This is file `mitthesis.cls',
%% generated with the docstrip utility.
%%
%% The original source files were:
%%
%% ubcthesis.dtx  (with options: `mitthesis')
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
\ProvidesClass{mitthesis}[2012/04/07 v1.70 ^^J
 Massachusetts Institute of Technology Thesis Class]
\LoadClassWithOptions{genthesis}
\ProcessOptions
\providecommand*{\MIT}{MASSACHUSETTS INSTITUTE OF TECHNOLOGY}
\providecommand*{\Mit}{Massachusetts Institute of Technology}
\providecommand*{\prevdegrees}[1]{\previousdegrees{#1}}
\providecommand*{\thesisdate}[1]{\date{#1}}
\providecommand*{\chairman}[2]{\departmentchair{#1}\departmentchairtitle{#2}}
\newcommand{\@abstractsupervisor}{}
\providecommand*{\supervisor}[2]{%
  \addsignature{Certified by}{#1 \\ #2 \\ Thesis Supervisor}
  \@addto{@abstractsupervisor}{Thesis Supervisor: #1\par%
    Title: #2\par}
}
\newcommand*{\and}{\degreeword{degrees} \par and \par}
\newcommand*{\departmentchair}[1]{\gdef\@departmentchair{#1}}
\providecommand*{\@departmentchair}{%
  \ClassWarning{mitthesis}{No \noexpand\departmentchair given}}
\newcommand*{\departmentchairtitle}[1]{\gdef\@departmentchairtitle{#1}}
\providecommand*{\@departmentchairtitle}{%
  \ClassWarning{mitthesis}{No \noexpand\departmentchairtitle given}}
\newcommand*{\degreeword}[1]{\gdef\@degreeword{#1}}
\providecommand*{\@degreeword}{%
  \ClassWarning{mitthesis}{No \noexpand\degreeword given}}
\AtBeginDocument{
  \degreeword{degree}
  \institution{Massachusetts Institute of Technology}
  \institutionaddress{Cambridge, Massachusetts, USA}
  \copyrighttext{\copyright\ \@author, \@copyrightyear. All rights reserved.}
  \copyrightnotice{%
    The author hereby grants to MIT permission to reproduce\\*
    and to distribute publicly paper and electronic\\*
    copies of this thesis document in whole or in part.}
  \addsignature[l]{Signature of Author}{\@department\\*
    \@submitdate}
  \supervisor{\@advisor}{\@advisortitle}
  \addsignature[l]{Accepted by}{\@departmentchair\\*
    \@departmentchairtitle}
}
\renewcommand{\titlepage}{
  \begin{center}
    {\titlefont\@condupper{@uppertitle}{\@title}\par}%
    \vspace{1em minus 1em}
  \if@subtitle%
    {\subtitlefont\@condupper{@uppersubtitle}{\@subtitle}\par}%
    \vspace{1em plus 1fil minus 1em}%
  \fi
  by\par%
  \vspace{1em plus 1fil minus 0.5em}%
  {\authorfont
    \@condupper{@upperauthor}{\@author}\par%
  }%
  \vspace{1em plus 1fil minus 0.5em}%
  \if@empty\@previousdegrees\else\vfil\fi%
  \if@empty\@previousdegrees\else\@previousdegrees\fi%
  \if@empty\@previousdegrees\else\vspace{1em plus 1fil minus 0.5em}\fi%
  \@condupper{@uppertitletext}{Submitted to the \@department}\par%
  \@condupper{@uppertitletext}{in partial fulfillment of the
    requirements for the \@degreeword\ of}\par%
  \vspace{1em plus 1fil minus 0.5em}%
  \@condupper{@upperdegreetitle}{\@degreetitle}\par%
  \vspace{1em plus 1fil minus 0.5em}%
  \@condupper{@uppertitletext}{at the}\par%
  \vspace{1em plus 1fil minus 0.5em}%
  \@condupper{@upperinstitution}{\@institution}\par%
  \vspace{1em plus 1fil minus 0.5em}%
  \@degreedate\par%
  \vspace{1em plus 1fil}%
  \@copyrighttext\par%
  \vspace{1em plus 1fil}%
  \@copyrightnotice\par%
  \vspace{1em plus 1fil}%
  \UBCT@signatures\par%
  \end{center}
}
\renewenvironment{abstract}{
  \clearp@ge
  \@startonecolumn
  \begin{center}
    \thispagestyle{empty}
    {\titlefont
      \@condupper{@uppertitle}{\@title}%
      \par}%
    \vspace{1em minus 1em}
    \if@subtitle%
    {\subtitlefont%
      \@condupper{@uppersubtitle}{\@subtitle}%
      \par%
    }%
    \vspace{1em plus 0.5fil minus 1em}%
    \fi
    by\par%
    \vspace{1em plus 0.5fil minus 0.5em}%
    {\authorfont
      \@condupper{@upperauthor}{\@author}\par%
    }%
    \vspace{1em plus 0.5fil minus 0.5em}%
    Submitted to the \@department\par%
    on \@date, in partial fulfillment of the\par%
    requirements for the \@degreeword\ of\par%
    \@degreetitle\par
    \vspace{1em plus 0.5fil minus 0.5em}%
  \end{center}
  {
    \def\@tempname{\@toupper{\abstractname}}
    \section*{\@tempname}
    \@mkboth{\@tempname}{\@tempname}
    \addcontentsline{toc}{chapter}{\@fmttocentry{\abstractname}}
  }
}
{
  \par%
  \vspace{1em}
  \vfil
  \setlength{\parindent}{0pt}
  \@abstractsupervisor
  \vspace{0pt plus 2fil}
  \clearpage
  \@endonecolumn
}
\endinput
%%
%% End of file `mitthesis.cls'.

%%
%% This is file `genthesis.cls',
%% generated with the docstrip utility.
%%
%% The original source files were:
%%
%% ubcthesis.dtx  (with options: `genthesis')
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
\ProvidesClass{genthesis}[2012/04/07 v1.70 ^^J
 University of British Columbia Thesis Class]
\global\let\and\@undefined
\newcommand\@ptsize{}
\newif\if@restonecol
\newif\if@chaptertocdots \@chaptertocdotstrue
\newcommand{\@addto}[2]{
  \expandafter\let\expandafter\old\csname#1\endcsname
  \toks1=\expandafter{\old}
  \toks2=\expandafter{#2}
  \expandafter\xdef\csname#1\endcsname{\the\toks1 \the\toks2 }
}
\newcount\hours
\newcount\minutes
\def\SetTime{\hours=\time
        \global\divide\hours by 60
        \minutes=\hours
        \multiply\minutes by 60
        \advance\minutes by-\time
        \global\multiply\minutes by-1 }
\def\now{\number\hours:\ifnum\minutes<10 0\fi\number\minutes}
\newcommand\@toupper[1]{\if@upper\MakeUppercase{#1}\else{#1}\fi}
\newcommand\@toctoupper[1]{\if@tocupper\MakeUppercase{#1}\else{#1}\fi}
\newcommand{\@condupper}[2]{%
  \csname if#1\endcsname{\MakeUppercase{#2}}\else{{#2}}\fi}
\newcommand{\tst}[1]{\if#1{True}\else{False}\fi}
\newcommand\@toctoitalic[1]{\if@tocitalic {\textit{#1}} \else {#1} \fi}
\newlength{\UBCT@oldtextwidth}
\newlength{\UBCT@oldtextheight}
\newlength{\UBCT@oldoddsidemargin}
\newlength{\UBCT@oldevensidemargin}
\newlength{\UBCT@oldtopmargin}
\newlength{\UBCT@oldtopskip}
\newlength{\UBCT@old@colht}
\newlength{\UBCT@old@colroom}
\newlength{\UBCT@oldvsize}
\newlength{\UBCT@oldcolumnwidth}
\newlength{\UBCT@oldhsize}
\newlength{\UBCT@oldlinewidth}
\newlength{\UBCT@oldparindent}
\newlength{\UBCT@oldmarginparsep}
\newlength{\UBCT@oldmarginparwidth}
\providecommand*{\@startonecolumn}{
  \global\setlength{\UBCT@oldtextwidth}{\textwidth}
  \global\setlength{\UBCT@oldtextheight}{\textheight}
  \global\setlength{\UBCT@oldoddsidemargin}{\oddsidemargin}
  \global\setlength{\UBCT@oldevensidemargin}{\evensidemargin}
  \global\setlength{\UBCT@oldtopmargin}{\topmargin}
  \global\setlength{\UBCT@oldtopskip}{\topskip}
  \global\setlength{\UBCT@old@colht}{\@colht}
  \global\setlength{\UBCT@old@colroom}{\@colroom}
  \global\setlength{\UBCT@oldvsize}{\vsize}
  \global\setlength{\UBCT@oldcolumnwidth}{\columnwidth}
  \global\setlength{\UBCT@oldhsize}{\hsize}
  \global\setlength{\UBCT@oldlinewidth}{\linewidth}
  \global\setlength{\UBCT@oldparindent}{\parindent}
  \global\setlength{\UBCT@oldmarginparsep}{\marginparsep}
  \global\setlength{\UBCT@oldmarginparwidth}{\marginparwidth}
  \global\let\UBCT@oldbaselinestretch=\baselinestretch

  \if@twocolumn
    \@restonecoltrue

    \setlength\@tempdima{\paperwidth}
    \addtolength\@tempdima{-2in}
    \ifcase\@ptsize\relax
      \setlength\@tempdimb{345\p@}
    \or
      \setlength\@tempdimb{360\p@}
    \or
      \setlength\@tempdimb{390\p@}
    \fi
    \ifdim\@tempdima>\@tempdimb\relax
      \global\setlength\textwidth{\@tempdimb}
    \else
      \global\setlength\textwidth{\@tempdima}
    \fi
    \global\@settopoint\textwidth
    \global\setlength\linewidth{\textwidth}
    \global\setlength\marginparsep{7\p@}

    \ifcase\@ptsize\relax
      \global\setlength\parindent{15\p@}
    \or
      \global\setlength\parindent{17\p@}
    \or
      \global\setlength\parindent{1.5em}
    \fi

    \if@twoside
      \setlength\@tempdima        {\paperwidth}
      \addtolength\@tempdima      {-\textwidth}
      \global\setlength\oddsidemargin {.4\@tempdima}
      \addtolength\oddsidemargin  {-1in}
      \global\setlength\marginparwidth   {.6\@tempdima}
      \global\addtolength\marginparwidth {-\marginparsep}
      \global\addtolength\marginparwidth {-0.4in}
    \else
      \setlength\@tempdima        {\paperwidth}
      \addtolength\@tempdima      {-\textwidth}
      \global\setlength\oddsidemargin    {.5\@tempdima}
      \global\addtolength\oddsidemargin  {-1in}
      \global\setlength\marginparwidth   {.5\@tempdima}
      \global\addtolength\marginparwidth {-\marginparsep}
      \global\addtolength\marginparwidth {-0.4in}
      \global\addtolength\marginparwidth {-.4in}
    \fi
    \ifdim \marginparwidth >2in
      \global\setlength\marginparwidth{2in}
    \fi
    \global\@settopoint\oddsidemargin
    \global\@settopoint\marginparwidth

    \global\setlength\evensidemargin  {\paperwidth}
    \global\addtolength\evensidemargin{-2in}
    \global\addtolength\evensidemargin{-\textwidth}
    \global\addtolength\evensidemargin{-\oddsidemargin}

    \global\@settopoint\evensidemargin
    \onecolumn
  \else
    \@restonecolfalse
  \fi
}
\providecommand*{\@endonecolumn}{
  \global\setlength{\textwidth}{\UBCT@oldtextwidth}
  \global\setlength{\textheight}{\UBCT@oldtextheight}
  \global\setlength{\oddsidemargin}{\UBCT@oldoddsidemargin}
  \global\setlength{\evensidemargin}{\UBCT@oldevensidemargin}
  \global\setlength{\topmargin}{\UBCT@oldtopmargin}
  \global\setlength{\topskip}{\UBCT@oldtopskip}
  \global\setlength{\@colht}{\UBCT@old@colht}
  \global\setlength{\@colroom}{\UBCT@old@colroom}
  \global\setlength{\vsize}{\UBCT@oldvsize}
  \global\setlength{\columnwidth}{\UBCT@oldcolumnwidth}
  \global\setlength{\hsize}{\UBCT@oldhsize}
  \global\setlength{\linewidth}{\UBCT@oldlinewidth}
  \global\setlength{\parindent}{\UBCT@oldparindent}
  \global\setlength{\marginparsep}{\UBCT@oldmarginparsep}
  \global\setlength{\marginparwidth}{\UBCT@oldmarginparwidth}
  \global\let\baselinestretch=\UBCT@oldbaselinestretch
  \if@restonecol
    \twocolumn
  \fi}
\newif\if@openright
\newif\if@openrightblank
\newif\if@mainmatter \@mainmattertrue
\def\if@empty#1#2\else#3\fi{%
  \def\UBCT@tempa{}\ifx\UBCT@tempa#1#2\else#3\fi}
\providecommand*{\monthname}[1][\month]{%
  \newcount\@orgargctr
  \@orgargctr=#1\relax
  \ifcase\@orgargctr
    \PackageError{genthesis}{Invalid Month number \the\@orgargctr}
    {Month numbers should go from 1 (January) to 12 (December)}%
  \or January%
  \or February%
  \or March%
  \or April%
  \or May%
  \or June%
  \or July%
  \or August%
  \or September%
  \or October%
  \or November%
  \or December%
  \else \PackageError{genthesis}{Invalid Month number \the\@orgargctr}
        {Month numbers should go from 1 (January) to 12 (December)}%
  \fi%
} %\monthname
\newif\if@subtitle \@subtitlefalse
\newcommand*{\subtitle}[1]{\@subtitletrue \gdef\@subtitle{#1}}
\newcommand*{\institution}[1]{\gdef\@institution{#1}}
\providecommand*{\@institution}{%
  \ClassWarning{genthesis}{No \noexpand\institution given}}
\newcommand*{\institutionaddress}[1]{\gdef\@institutionaddress{#1}}
\providecommand*{\@institutionaddress}{%
  \ClassWarning{genthesis}{No \noexpand\institutionaddress given}}
\newcommand*{\degreetitle}[1]{\gdef\@degreetitle{#1}}
\providecommand*{\@degreetitle}{%
  \ClassWarning{genthesis}{No \noexpand\degreetitle given}}
\newcommand*{\degreedate}[1]{\gdef\@degreedate{#1}}
\providecommand*{\@degreedate}{%
  \ClassWarning{genthesis}{No \noexpand\degreedate given}}
\newcommand*{\department}[1]{\gdef\@department{#1}}
\providecommand*{\@department}{%
  \ClassWarning{genthesis}{No \noexpand\department given}}
\newcommand*{\program}[1]{\gdef\@program{#1}}
\providecommand*{\@program}{%
  \ClassWarning{genthesis}{No \noexpand\program given}}
\newcommand*{\faculty}[1]{\gdef\@faculty{#1}}
\providecommand*{\@faculty}{%
  \ClassWarning{genthesis}{No \noexpand\faculty given}}
\newcommand*{\advisor}[1]{\gdef\@advisor{#1}}
\providecommand*{\@advisor}{%
  \ClassWarning{genthesis}{No \noexpand\advisor given}}
\newcommand*{\advisortitle}[1]{\gdef\@advisortitle{#1}}
\providecommand*{\@advisortitle}{%
  \ClassWarning{genthesis}{No \noexpand\advisortitle given}}
\newcommand*{\copyrighttext}[1]{\gdef\@copyrighttext{#1}}
\providecommand*{\@copyrighttext}{%
  \ClassWarning{genthesis}{No \noexpand\copyrighttext given}}
\newcommand*{\copyrightnotice}[1]{\gdef\@copyrightnotice{#1}}
\providecommand*{\@copyrightnotice}{%
  \ClassWarning{genthesis}{No \noexpand\copyrightnotice given}}
\institution{The University of British Columbia}
\institutionaddress{Vancouver}
\department{Department of Physics and Astronomy}
\program{in Physics}
\faculty{The Faculty of Graduate Studies}
\copyrighttext{\copyright\ \@author\ \@copyrightyear}
\copyrightnotice{All rights reserved.  This work may not be\\
  reproduced in whole or in part, by photocopy\\
  or other means, without permission of the author.}
\newcommand*{\numberofsignatures}[1]{\gdef\@numberofsignatures{#1}}
\numberofsignatures{4}
\newcommand*{\copyrightyear}[1]{\gdef\@copyrightyear{#1}}
\newcommand*{\submitdate}[1]{\gdef\@submitdate{#1}}
\copyrightyear{\number\year}
\submitdate{\today}
\newcommand{\UBCT@signatures}

\newcommand{\@signature}[3]{
  \vspace*{0.75in minus 0.5in}
  \if#1l#2\else\fi\dotfill\if#1r#2\else\fi\\*
  { \if#1l\raggedleft\fi%
    \if#1r\raggedright\fi%
    \if#1c\centering\fi%
    #3\par%
  }
}
\newcommand{\signature}[3][l]{\@signature{#1}{#2}{#3}}
\newcommand{\addsignature}[3][l]{
  \@addto{UBCT@signatures}{\@signature{#1}{#2}{#3}\par}
}
\iffalse
  \setbox\UBCT@abstractsignatures\vbox
  {\unvbox\UBCT@abstractsignatures \vskip\baselineskip
    \def\baselinestretch{1}\@normalsize
    \par\noindent #4: #2 \\ Title: #3}}

\newbox\UBCT@signatures
\newbox\UBCT@abstractsignatures

\fi

\newcommand\@previousdegrees{}
\newcommand\previousdegree[1]{
  \@addto{@previousdegrees}{#1\par}
}
\newcommand\titlepagefont{\normalsize}
\newcommand\titlefont{}
\newcommand\subtitlefont{\titlefont}
\newcommand\authorfont{\titlepagefont}
\newcommand\degreetitlefont{\titlepagefont}
\newcommand\facultyfont{\titlepagefont}
\newcommand\institutionfont{\titlepagefont}
\newcommand\abstractfont{}
\newcommand\partfont{}
\newcommand\partnamefont{}
\newcommand\chapterfont{}
\newcommand\chaptertitlefont{}
\newcommand\chapterauthorfont{}
\newcommand\sectionfont{}
\newcommand\subsectionfont{}
\newcommand\subsubsectionfont{}
\newcommand\paragraphfont{}
\newcommand\subparagraphfont{}
\newcommand\translatorfont{}
\newcommand\theoremheaderfont{}
\newcommand\theorembodyfont{}
\newcommand\itemfont{}
\newcommand\examplefont{}
\newcommand\headingstextfont{}
\newcommand\pagenumberfont{}
\newcommand\captionheaderfont{}
\newcommand\captionbodyfont{}
\newcommand\figurefont{}
\newcommand\tablefont{}
\newcommand\indexsize{}
\newcommand\bibsize{}
\newlength{\partbetweenskip}
\newlength{\chapterbeforeskip}
\newlength{\chapterbetweenskip}
\newlength{\chapterafterskip}
\newlength{\sectionindent}
\newlength{\sectionbeforeskip}
\newlength{\sectionafterskip}
\newlength{\subsectionindent}
\newlength{\subsectionbeforeskip}
\newlength{\subsectionafterskip}
\newlength{\subsubsectionindent}
\newlength{\subsubsectionbeforeskip}
\newlength{\subsubsectionafterskip}
\newlength{\paragraphindent}
\newlength{\paragraphbeforeskip}
\newlength{\paragraphafterskip}
\newlength{\subparagraphindent}
\newlength{\subparagraphbeforeskip}
\newlength{\subparagraphafterskip}
\newcommand{\lofindent}{1.5em}
\newcommand{\lotindent}{1.5em}
\newcommand{\loflabelwidth}{2.3em}
\newcommand{\lotlabelwidth}{2.3em}
\DeclareOption{a4paper}
   {\setlength\paperheight {297mm}%
    \setlength\paperwidth  {210mm}}
\DeclareOption{a5paper}
   {\setlength\paperheight {210mm}%
    \setlength\paperwidth  {148mm}}
\DeclareOption{b5paper}
   {\setlength\paperheight {250mm}%
    \setlength\paperwidth  {176mm}}
\DeclareOption{letterpaper}
   {\setlength\paperheight {11in}%
    \setlength\paperwidth  {8.5in}}
\DeclareOption{legalpaper}
   {\setlength\paperheight {14in}%
    \setlength\paperwidth  {8.5in}}
\DeclareOption{executivepaper}
   {\setlength\paperheight {10.5in}%
    \setlength\paperwidth  {7.25in}}
\DeclareOption{landscape}
   {\setlength\@tempdima   {\paperheight}%
    \setlength\paperheight {\paperwidth}%
    \setlength\paperwidth  {\@tempdima}}
\DeclareOption{10pt}{\renewcommand\@ptsize{0}}
\DeclareOption{11pt}{\renewcommand\@ptsize{1}}
\DeclareOption{12pt}{\renewcommand\@ptsize{2}}
\DeclareOption{oneside}{\@twosidefalse \@mparswitchfalse}
\DeclareOption{twoside}{\@twosidetrue  \@mparswitchtrue}
\newcommand{\@pagesnumberstyle}{2}
\DeclareOption{pagenumBC}{\renewcommand{\@pagesnumberstyle}{0}}
\DeclareOption{pagenumBR}{\renewcommand{\@pagesnumberstyle}{1}}
\DeclareOption{pagenumTR}{\renewcommand{\@pagesnumberstyle}{2}}
\newif\if@final \@finaltrue
\DeclareOption{draft}{\setlength\overfullrule{5pt}\@finalfalse \SetTime}
\DeclareOption{final}{\setlength\overfullrule{0pt}\@finaltrue}
\newif\if@committee \@committeefalse
\DeclareOption{committee}{\@committeetrue}
\DeclareOption{openright}{\@openrighttrue\@openrightblankfalse}
\DeclareOption{openrightblank}{\@openrighttrue\@openrightblanktrue}
\DeclareOption{openany}{\@openrightfalse\@openrightblankfalse}
\DeclareOption{onecolumn}{\@twocolumnfalse}
\DeclareOption{twocolumn}{\@twocolumntrue}
\newif\if@runningheaders \@runningheaderstrue
\DeclareOption{runningheaders}{\@runningheaderstrue}
\DeclareOption{norunningheaders}{\@runningheadersfalse}
\newif\if@centerheadline \@centerheadlinetrue
\DeclareOption{centerheadline}{\@centerheadlinetrue}
\DeclareOption{nocenterheadline}{\@centerheadlinefalse}
\newif\if@headline \@headlinetrue
\DeclareOption{headline}{\@headlinetrue}
\DeclareOption{noheadline}{\@headlinefalse}

\newif\if@starmark \@starmarktrue
\DeclareOption{starmark}{\@starmarktrue}
\DeclareOption{nostarmark}{\@starmarkfalse}
\DeclareOption{leqno}{\input{leqno.clo}}
\DeclareOption{fleqn}{\input{fleqn.clo}}
\newif\if@uppertitle \@uppertitlefalse
\DeclareOption{uppertitle}{\@uppertitletrue\@uppersubtitletrue}
\DeclareOption{nouppertitle}{\@uppertitlefalse\@uppersubtitlefalse}
\newif\if@uppersubtitle \@uppersubtitlefalse
\DeclareOption{uppersubtitle}{\@uppersubtitletrue}
\DeclareOption{nouppersubtitle}{\@uppersubtitlefalse}
\newif\if@upperauthor \@upperauthorfalse
\DeclareOption{upperauthor}{\@upperauthortrue}
\DeclareOption{noupperauthor}{\@upperauthorfalse}
\newif\if@upperdegreetitle \@upperdegreetitletrue
\DeclareOption{upperdegreetitle}{\@upperdegreetitletrue}
\DeclareOption{noupperdegreetitle}{\@upperdegreetitlefalse}
\newif\if@uppertitletext \@uppertitletexttrue
\DeclareOption{uppertitletext}{\@uppertitletexttrue}
\DeclareOption{nouppertitletext}{\@uppertitletextfalse}
\newif\if@upperfaculty \@upperfacultyfalse
\DeclareOption{upperfaculty}{\@upperfacultytrue}
\DeclareOption{noupperfaculty}{\@upperfacultyfalse}
\newif\if@upperdepartment \@upperdepartmentfalse
\DeclareOption{upperdepartment}{\@upperdepartmenttrue}
\DeclareOption{noupperdepartment}{\@upperdepartmentfalse}
\newif\if@upperprogram \@upperprogramfalse
\DeclareOption{upperprogram}{\@upperprogramtrue}
\DeclareOption{noupperprogram}{\@upperprogramfalse}
\newif\if@upperinstitution \@upperinstitutiontrue
\DeclareOption{upperinstitution}{\@upperinstitutiontrue}
\DeclareOption{noupperinstitution}{\@upperinstitutionfalse}
\DeclareOption{phd}{
  \degreetitle{Doctor of Philosophy}
  \numberofsignatures{4}
}
\DeclareOption{msc}{
  \degreetitle{Master of Science}
  \numberofsignatures{2}
}
\DeclareOption{masc}{
  \degreetitle{Master of Applied Science}
  \numberofsignatures{2}
}
\DeclareOption{ma}{
  \degreetitle{Master of Arts}
  \numberofsignatures{2}
}
\DeclareOption{meng}{
  \degreetitle{Master of Engineering}%
  \numberofsignatures{2}
  }
\newif\iflogo\logofalse
\DeclareOption{logo}{\logotrue}
\DeclareOption{nologo}{\logofalse}
\newif\if@chapterheads \@chapterheadstrue
\DeclareOption{chapterheads}{\@chapterheadstrue}
\DeclareOption{nochapterheads}{\@chapterheadsfalse}
\newif\if@headcount \@headcounttrue
\newif\if@partheads \@partheadstrue
\DeclareOption{partheads}{\@partheadstrue}
\DeclareOption{nopartheads}{\@partheadsfalse}
\newif\if@headcount \@headcounttrue
\DeclareOption{headcount}{\@headcounttrue}
\DeclareOption{noheadcount}{\@headcountfalse}
\newif\if@upper \@upperfalse
\DeclareOption{upper}{\@uppertrue}
\DeclareOption{noupper}{\@upperfalse}
\newif\if@tocitalic \@tocitalicfalse
\DeclareOption{tocitalic}{\@tocitalictrue}
\DeclareOption{notocitalic}{\@tocitalicfalse}
\newif\if@tocupper \@tocupperfalse
\DeclareOption{tocupper}{\@tocuppertrue}
\DeclareOption{notocupper}{\@tocupperfalse}
\newcommand\@headingalignment{\raggedright}
\DeclareOption{leftheads}{\renewcommand\@headingalignment{\raggedleft}}
\DeclareOption{centerheads}{\renewcommand\@headingalignment{\centering}}
\DeclareOption{rightheads}{\renewcommand\@headingalignment{\raggedright}}
\newif\if@hangingcaptions \@hangingcaptionsfalse
\DeclareOption{hangingcaptions}{\@hangingcaptionstrue}
\DeclareOption{nohangingcaptions}{\@hangingcaptionsfalse}

\newif\if@chapternotereset \@chapternoteresettrue
\DeclareOption{chapternotereset}{\@chapternoteresettrue}
\DeclareOption{nochapternotereset}{\@chapternoteresetfalse}

\newif\if@bibnum \@bibnumtrue
\DeclareOption{bibnum}{\@bibnumtrue}
\DeclareOption{nobibnum}{\@bibnumfalse}
\newif\if@sectionbib \@sectionbibfalse
\DeclareOption{sectionbib}{\@sectionbibtrue}
\newif\if@appendixpart \@appendixpartfalse
\DeclareOption{appendixpart}{\@appendixparttrue}
\DeclareOption{noappendixpart}{\@appendixpartfalse}
\newif\if@appendixpage \@appendixpagetrue
\DeclareOption{appendixpage}{\@appendixpagetrue}
\DeclareOption{noappendixpage}{\@appendixpagefalse}
\newif\if@appendicestoc \@appendicestoctrue
\DeclareOption{appendicestoc}{\@appendicestoctrue}
\DeclareOption{noappendicestoc}{\@appendicestocfalse}
\DeclareOption{openbib}{%
  \AtEndOfPackage{%
   \renewcommand\@openbib@code{%
      \advance\leftmargin\bibindent
      \itemindent -\bibindent
      \listparindent \itemindent
      \parsep \z@
      }%
   \renewcommand\newblock{\par}}%
}
\newif\if@crosshair \@crosshairfalse
\DeclareOption{nocrosshair}{\@crosshairfalse}
\DeclareOption{crosshair}{\@crosshairtrue}
\DeclareOption{defaultfonts}{
    \renewcommand\titlepagefont{\normalsize}
    \renewcommand\titlefont{\Large \bfseries}
    \renewcommand\subtitlefont{\large \bfseries}
    \renewcommand\institutionfont{\slshape}
    \renewcommand\abstractfont{\large\slshape}
    \renewcommand\partfont{\huge \bfseries}
    \renewcommand\partnamefont{\Huge \bfseries}
    \renewcommand\chapterfont{\huge\bfseries}
    \renewcommand\chaptertitlefont{\Huge\bfseries}
    \renewcommand\chapterauthorfont{\large}
    \renewcommand\sectionfont{\Large\bfseries}
    \renewcommand\subsectionfont{\large\bfseries}
    \renewcommand\subsubsectionfont{\normalsize\bfseries}
    \renewcommand\paragraphfont{\normalsize\bfseries}
    \renewcommand\subparagraphfont{\normalsize\bfseries}
    \renewcommand\translatorfont{}
    \renewcommand\theoremheaderfont{\upshape}
    \renewcommand\theorembodyfont{}
    \renewcommand\itemfont{\slshape}
    \renewcommand\examplefont{}
    \renewcommand\headingstextfont{\slshape}
    \renewcommand\pagenumberfont{}
    \renewcommand\captionheaderfont{}
    \renewcommand\captionbodyfont{}
    \renewcommand\figurefont{}
    \renewcommand\tablefont{}
    \setlength{\partbetweenskip}{20pt}
    \setlength{\chapterbeforeskip}{30pt}
    \setlength{\chapterbetweenskip}{20pt}
    \setlength{\chapterafterskip}{30pt}
    \renewcommand\sectionindent{\z@}
    \renewcommand\sectionbeforeskip{-3.5ex \@plus -1ex \@minus -.2ex}
    \renewcommand\sectionafterskip{2.3ex \@plus.2ex}
    \renewcommand\subsectionindent{\z@}
    \renewcommand\subsectionbeforeskip{-3.25ex \@plus -1ex \@minus -.2ex}
    \renewcommand\subsectionafterskip{1.5ex \@plus.2ex}
    \renewcommand\subsubsectionindent{\z@}
    \renewcommand\subsubsectionbeforeskip{-3.25ex\@plus -1ex \@minus -.2ex}
    \renewcommand\subsubsectionafterskip{1.5ex \@plus .2ex}
    \renewcommand\paragraphindent{\z@}
    \renewcommand\paragraphbeforeskip{3.25ex \@plus1ex \@minus.2ex}
    \renewcommand\paragraphafterskip{-1em}
    \renewcommand\subparagraphindent{\parindent}
    \renewcommand\subparagraphbeforeskip{3.25ex \@plus1ex \@minus .2ex}
    \renewcommand\subparagraphafterskip{-1em}
}
\DeclareOption{slanted}{
    \renewcommand\titlefont{\LARGE}
    \renewcommand\abstractfont{\large\slshape}
    \renewcommand\subtitlefont{\large}
    \renewcommand\authorfont{}
    \renewcommand\degreetitlefont{\large}
    \renewcommand\partfont{\Large}
    \renewcommand\chapterfont{\large}
    \renewcommand\chaptertitlefont{\large}
    \renewcommand\chapterauthorfont{\large}
    \renewcommand\sectionfont{\large\slshape}
    \renewcommand\subsectionfont{\slshape}
    \renewcommand\subsubsectionfont{\slshape}
    \renewcommand\paragraphfont{\slshape}
    \renewcommand\subparagraphfont{\slshape}
    \renewcommand\institutionfont{\slshape}
    \renewcommand\translatorfont{}
    \renewcommand\theoremheaderfont{\upshape}
    \renewcommand\theorembodyfont{}
    \renewcommand\itemfont{\slshape}
    \renewcommand\examplefont{}
    \renewcommand\headingstextfont{\small\slshape}
    \renewcommand\pagenumberfont{\small}
    \renewcommand\captionheaderfont{\slshape\small}
    \renewcommand\captionbodyfont{\small}
    \renewcommand\figurefont{}
    \renewcommand\tablefont{}
    \setlength{\partbetweenskip}{20pt}
    \setlength{\chapterbeforeskip}{30pt}
    \setlength{\chapterbetweenskip}{20pt}
    \setlength{\chapterafterskip}{30pt}
    \renewcommand\sectionindent{\z@}
    \renewcommand\sectionbeforeskip{-3.5ex \@plus -1ex \@minus -.2ex}
    \renewcommand\sectionafterskip{2.3ex \@plus.2ex}
    \renewcommand\subsectionindent{\z@}
    \renewcommand\subsectionbeforeskip{-3.25ex \@plus -1ex \@minus -.2ex}
    \renewcommand\subsectionafterskip{1.5ex \@plus.2ex}
    \renewcommand\subsubsectionindent{\z@}
    \renewcommand\subsubsectionbeforeskip{-3.25ex\@plus -1ex \@minus -.2ex}
    \renewcommand\subsubsectionafterskip{1.5ex \@plus .2ex}
    \renewcommand\paragraphindent{\z@}
    \renewcommand\paragraphbeforeskip{3.25ex \@plus1ex \@minus.2ex}
    \renewcommand\paragraphafterskip{-1em}
    \renewcommand\subparagraphindent{\parindent}
    \renewcommand\subparagraphbeforeskip{3.25ex \@plus1ex \@minus .2ex}
    \renewcommand\subparagraphafterskip{-1em}
}
\DeclareOption{bold}{%
    \renewcommand\titlefont{\LARGE\bfseries}
    \renewcommand\subtitlefont{\large\bfseries}
    \renewcommand\abstractfont{\Large\bfseries}
    \renewcommand\authorfont{}
    \renewcommand\degreetitlefont{\large\bfseries}
    \renewcommand\partfont{\LARGE\bfseries}
    \renewcommand\chapterfont{\LARGE\bfseries}
    \renewcommand\chaptertitlefont{\LARGE\bfseries}
    \renewcommand\chapterauthorfont{\large}
    \renewcommand\sectionfont{\Large\bfseries}
    \renewcommand\subsectionfont{\large\bfseries}
    \renewcommand\subsubsectionfont{\bfseries}
    \renewcommand\paragraphfont{\bfseries}
    \renewcommand\subparagraphfont{\bfseries}
    \renewcommand\translatorfont{}
    \renewcommand\institutionfont{\slshape}
    \renewcommand\theoremheaderfont{\bfseries}
    \renewcommand\theorembodyfont{\itshape}
    \renewcommand\itemfont{\bfseries}
    \renewcommand\examplefont{}
    \renewcommand\headingstextfont{\small\bfseries}
    \renewcommand\pagenumberfont{\small}
    \renewcommand\captionheaderfont{\bfseries}
    \renewcommand\captionbodyfont{}
    \renewcommand\figurefont{}
    \renewcommand\tablefont{}
    \setlength{\partbetweenskip}{20pt}
    \setlength{\chapterbeforeskip}{30pt}
    \setlength{\chapterbetweenskip}{20pt}
    \setlength{\chapterafterskip}{30pt}
    \renewcommand\sectionindent{\z@}
    \renewcommand\sectionbeforeskip{-3.5ex \@plus -1ex \@minus -.2ex}
    \renewcommand\sectionafterskip{2.3ex \@plus.2ex}
    \renewcommand\subsectionindent{\z@}
    \renewcommand\subsectionbeforeskip{-3.25ex \@plus -1ex \@minus -.2ex}
    \renewcommand\subsectionafterskip{1.5ex \@plus.2ex}
    \renewcommand\subsubsectionindent{\z@}
    \renewcommand\subsubsectionbeforeskip{-3.25ex\@plus -1ex \@minus -.2ex}
    \renewcommand\subsubsectionafterskip{1.5ex \@plus .2ex}
    \renewcommand\paragraphindent{\z@}
    \renewcommand\paragraphbeforeskip{3.25ex \@plus1ex \@minus.2ex}
    \renewcommand\paragraphafterskip{-1em}
    \renewcommand\subparagraphindent{\parindent}
    \renewcommand\subparagraphbeforeskip{3.25ex \@plus1ex \@minus .2ex}
    \renewcommand\subparagraphafterskip{-1em}
}
\DeclareOption{sfbold}{%
    \renewcommand\titlefont{\LARGE\sffamily\bfseries}
    \renewcommand\abstractfont{\large\sffamily\bfseries}
    \renewcommand\subtitlefont{\large\sffamily}
    \renewcommand\authorfont{\Large\sffamily\slshape}
    \renewcommand\degreetitlefont{\large\sffamily}
    \renewcommand\partfont{\LARGE\sffamily\bfseries}
    \renewcommand\chapterfont{\LARGE\sffamily\bfseries}
    \renewcommand\chaptertitlefont{\LARGE\sffamily\bfseries}
    \renewcommand\chapterauthorfont{\Large\sffamily\bfseries}
    \renewcommand\sectionfont{\large\sffamily\bfseries}
    \renewcommand\subsectionfont{\large\sffamily\bfseries}
    \renewcommand\subsubsectionfont{\sffamily\bfseries}
    \renewcommand\paragraphfont{\sffamily\bfseries}
    \renewcommand\subparagraphfont{\sffamily}
    \renewcommand\translatorfont{}
    \renewcommand\institutionfont{\sffamily}
    \renewcommand\theoremheaderfont{\sffamily}
    \renewcommand\theorembodyfont{}
    \renewcommand\itemfont{\sffamily}
    \renewcommand\examplefont{}
    \renewcommand\headingstextfont{\small\sffamily}
    \renewcommand\pagenumberfont{\small\rmfamily}
    \renewcommand\captionheaderfont{\sffamily}
    \renewcommand\captionbodyfont{}
    \renewcommand\figurefont{}
    \renewcommand\tablefont{}
    \setlength{\partbetweenskip}{20pt}
    \setlength{\chapterbeforeskip}{30pt}
    \setlength{\chapterbetweenskip}{20pt}
    \setlength{\chapterafterskip}{30pt}
    \renewcommand\sectionindent{\z@}
    \renewcommand\sectionbeforeskip{-3.5ex \@plus -1ex \@minus -.2ex}
    \renewcommand\sectionafterskip{2.3ex \@plus.2ex}
    \renewcommand\subsectionindent{\z@}
    \renewcommand\subsectionbeforeskip{-3.25ex \@plus -1ex \@minus -.2ex}
    \renewcommand\subsectionafterskip{1.5ex \@plus.2ex}
    \renewcommand\subsubsectionindent{\z@}
    \renewcommand\subsubsectionbeforeskip{-3.25ex\@plus -1ex \@minus -.2ex}
    \renewcommand\subsubsectionafterskip{1.5ex \@plus .2ex}
    \renewcommand\paragraphindent{\z@}
    \renewcommand\paragraphbeforeskip{3.25ex \@plus1ex \@minus.2ex}
    \renewcommand\paragraphafterskip{-1em}
    \renewcommand\subparagraphindent{\parindent}
    \renewcommand\subparagraphbeforeskip{3.25ex \@plus1ex \@minus .2ex}
    \renewcommand\subparagraphafterskip{-1em}
}
\ExecuteOptions{%
  letterpaper,%
  10pt,%
  twoside,%
  onecolumn,%
  final,%
  openright,%
  noupper,%
  defaultfonts,%
  pagenumTR,%
  chapternotereset,%
  nobibnum,%
  nologo}
\ProcessOptions*\relax
\input{bk1\@ptsize.clo}
\iflogo\RequirePackage{graphics}\fi
\setlength\lineskip{1\p@}
\setlength\normallineskip{1\p@}
\renewcommand\baselinestretch{}
\setlength\parskip{0\p@ \@plus \p@}
\@lowpenalty   51
\@medpenalty  151
\@highpenalty 301
\setcounter{topnumber}{2}
\renewcommand\topfraction{.7}
\setcounter{bottomnumber}{1}
\renewcommand\bottomfraction{.3}
\setcounter{totalnumber}{3}
\renewcommand\textfraction{.2}
\renewcommand\floatpagefraction{.5}
\setcounter{dbltopnumber}{2}
\renewcommand\dbltopfraction{.7}
\renewcommand\dblfloatpagefraction{.5}
\newlength{\headlinespace}
\setlength{\headlinespace}{5pt}
\newcommand{\v@strut}{{\headingstextfont \vphantom{y}}}
\if@twoside
  \def\ps@plain{%
    \ifcase\@pagesnumberstyle\relax % Page number Bottom Center
      \def\@oddfoot{\hfil{\pagenumberfont\thepage}\hfil}%
      \let\@evenfoot\@oddfoot%
      \let\@oddhead\@empty%
      \let\@evenhead\@empty%
    \or                             % Page number Bottom Outside
      \def\@oddfoot{\hfil{\pagenumberfont\thepage}}%
      \def\@evenfoot{{\pagenumberfont\thepage}\hfil}%
      \let\@oddhead\@empty%
      \let\@evenhead\@empty%
    \else                           % Page number Top Outside
      \let\@oddfoot\@empty%
      \let\@evenfoot\@empty%
      \def\@oddhead{\hfil{\pagenumberfont\thepage}}%
      \def\@evenhead{{\pagenumberfont\thepage}\hfil}%
    \fi
  }%
\else
  \def\ps@plain{%
    \ifcase\@pagesnumberstyle\relax % Page number Bottom Center
      \def\@oddfoot{\hfil{\pagenumberfont\thepage}\hfil}%
      \let\@oddhead\@empty%
    \or                             % Page number Bottom Outside
      \def\@oddfoot{\hfil{\pagenumberfont\thepage}}%
      \let\@oddhead\@empty%
    \else                           % Page number Top Outside
      \let\@oddfoot\@empty%
      \def\@oddhead{\hfil{\pagenumberfont\thepage}}%
    \fi
  }%
\fi
\if@twoside
  \def\ps@headings{%
    \def\@evenhead{%
      \parbox{\textwidth}{%
        \makebox[\textwidth]{%
          \hfill{\headingstextfont\leftmark}%
          \if@centerheadline\hfill\fi%
          \v@strut%
        }%
        \if@headline\vspace{\headlinespace}\hrule\fi%
      }%
    }%
    \def\@oddhead{%
      \parbox{\textwidth}{%
        \makebox[\textwidth]{%
          \if@centerheadline\hfill\fi%
          {\headingstextfont\rightmark}\hfill\v@strut%
        }%
        \if@headline\vspace{\headlinespace}\hrule\fi%
      }%
    }%
    \ifcase\@pagesnumberstyle\relax % Page number Bottom Center
      \def\@oddfoot{\hfil{\pagenumberfont\thepage}\hfil}%
      \let\@evenfoot\@oddfoot%
    \or                             % Page number Bottom Outside
      \def\@oddfoot{\hfil{\pagenumberfont\thepage}}%
      \def\@evenfoot{{\pagenumberfont\thepage}\hfil}%
    \else                           % Page number Top Outside
      \let\@oddfoot\@empty%
      \let\@evenfoot\@empty%
      \def\@evenhead{%
        \parbox{\textwidth}{%
          \makebox[\textwidth]{%
            {\pagenumberfont\thepage}\hfill{\headingstextfont\leftmark}%
            \if@centerheadline\hfill\fi%
            \v@strut%
          }%
          \if@headline\vspace{\headlinespace}\hrule\fi%
        }%
      }%
      \def\@oddhead{%
        \parbox{\textwidth}{%
          \makebox[\textwidth]{%
            \if@centerheadline\hfill\fi%
            {\headingstextfont\rightmark}\hfill%
            {\pagenumberfont\thepage}\v@strut%
          }%
          \if@headline\vspace{\headlinespace}\hrule\fi%
        }%
      }%
    \fi
      \let\@mkboth\markboth
     \renewcommand*\chaptermark[1]{%
       \markboth{%
         \ifnum \c@secnumdepth >\m@ne
           \if@mainmatter       % Only include Chapter # in mainmatter
             \@toupper{\@chapapp}\
             \if@headcount
               \thechapter. \ %
             \fi
           \fi
         \fi
         \@toupper{##1}}{}}%
     \renewcommand*\sectionmark[1]{%
       \markright{%
         \ifnum \c@secnumdepth >\z@
           \if@headcount
             \thesection. \ %
           \fi
         \fi
         \@toupper{##1}}}
     \renewcommand*\chapterstarmark[1]{\markboth{\@toupper{##1}}{}}
     \renewcommand*\sectionstarmark[1]{\markright{\@toupper{##1}}}
   }%
\else % oneside
  \def\ps@headings{%
    \def\@oddhead{%
      \parbox{\textwidth}{%
        \makebox[\textwidth]{%
          \if@centerheadline\hfill\fi%
          {\headingstextfont\rightmark}\hfill\v@strut%
        }%
        \if@headline\vspace{\headlinespace}\hrule\fi%
      }%
    }%
    \ifcase\@pagesnumberstyle\relax % Page number Bottom Center
      \def\@oddfoot{\hfil{\pagenumberfont\thepage}\hfil}%
    \or                             % Page number Bottom Right
      \def\@oddfoot{\hfil{\pagenumberfont\thepage}}%
    \else                           % Page number Top Right
      \let\@oddfoot\@empty%
      \def\@oddhead{%
        \parbox{\textwidth}{%
          \makebox[\textwidth]{%
            \if@centerheadline\hfill\fi%
            {\headingstextfont\rightmark}\hfill%
            {\pagenumberfont\thepage}\v@strut%
          }%
          \if@headline\vspace{\headlinespace}\hrule\fi%
        }%
      }%
    \fi
    \let\@mkboth\markboth
     \renewcommand*\chaptermark[1]{%
       \markright{
         \ifnum \c@secnumdepth >\m@ne
           \if@mainmatter
             \@toupper{\@chapapp}\
             \if@headcount
               \thechapter. \ %
             \fi
           \fi
         \fi
         \@toupper{##1}}}%
     \renewcommand*\sectionmark[1]{%
       \markright{%
         \ifnum \c@secnumdepth >\z@
           \if@headcount
             \thesection. \ %
           \fi
         \fi
         \@toupper{##1}}}%
     \renewcommand*\chapterstarmark[1]{\markright{\@toupper{##1}}}
     \renewcommand*\sectionstarmark[1]{\markright{\@toupper{##1}}}
   }%
\fi
\if@twoside
  \def\ps@draft{%
    \def\@evenhead{%
      \parbox{\textwidth}{%
        \makebox[\textwidth]{%
          \hfill%
          {\headingstextfont\draftname: ``\jobname''}%
          {\pagenumberfont --- \today\ \now}%
          \if@centerheadline\hfill\fi%
          \v@strut%
        }%
        \if@headline\vspace{\headlinespace}\hrule\fi%
      }%
    }%
    \def\@oddhead{%
      \parbox{\textwidth}{%
        \makebox[\textwidth]{%
          \if@centerheadline\hfill\fi%
          {\pagenumberfont\today\ \now\ ---}%
          {\headingstextfont\draftname: ``\jobname''}%
          \hfill\v@strut%
        }%
        \if@headline\vspace{\headlinespace}\hrule\fi%
      }%
    }%
    \ifcase\@pagesnumberstyle\relax % Page number Bottom Center
      \def\@oddfoot{\hfil{\pagenumberfont\thepage}\hfil}%
      \let\@evenfoot\@oddfoot%
    \or                             % Page number Bottom Outside
      \def\@oddfoot{\hfil{\pagenumberfont\thepage}}%
      \def\@evenfoot{{\pagenumberfont\thepage}\hfil}%
    \else                           % Page number Top Outside
      \let\@oddfoot\@empty%
      \let\@evenfoot\@empty%
      \def\@evenhead{%
        \parbox{\textwidth}{%
          \makebox[\textwidth]{%
            {\pagenumberfont\thepage}\hfill%
            {\headingstextfont\draftname: ``\jobname''}%
            {\pagenumberfont --- \today\ \now}%
            \if@centerheadline\hfill\fi%
            \v@strut%
          }%
          \if@headline\vspace{\headlinespace}\hrule\fi%
        }%
      }%
      \def\@oddhead{%
        \parbox{\textwidth}{%
          \makebox[\textwidth]{%
            \if@centerheadline\hfill\fi%
            {\pagenumberfont\today\ \now\ ---}%
            {\headingstextfont\draftname: ``\jobname''}%
            \hfill%
            {\pagenumberfont\thepage}\v@strut%
          }%
          \if@headline\vspace{\headlinespace}\hrule\fi%
        }%
      }%
    \fi
    \let\@mkboth\@gobbletwo
    \let\chaptermark\@gobble
    \let\sectionmark\@gobble
    \let\chapterstarmark\@gobble
    \let\sectionstarmark\@gobble
  }%
\else % oneside
  \def\ps@draft{%
    \def\@oddhead{%
      \parbox{\textwidth}{%
        \makebox[\textwidth]{%
          \if@centerheadline\hfill\fi%
          {\pagenumberfont\today\ \now\ ---}%
          {\headingstextfont\draftname: ``\jobname''}%
          \hfill\v@strut%
        }%
        \if@headline\vspace{\headlinespace}\hrule\fi%
      }%
    }%
    \ifcase\@pagesnumberstyle\relax % Page number Bottom Center
      \def\@oddfoot{\hfil{\pagenumberfont\thepage}\hfil}%
    \or                             % Page number Bottom Outside
      \def\@oddfoot{\hfil{\pagenumberfont\thepage}}%
    \else                           % Page number Top Outside
      \let\@oddfoot\@empty%
      \def\@oddhead{%
        \parbox{\textwidth}{%
          \makebox[\textwidth]{%
            \if@centerheadline\hfill\fi%
            {\pagenumberfont\today\ \now\ ---}%
            {\headingstextfont\draftname: ``\jobname''}%
            \hfill%
            {\pagenumberfont\thepage}\v@strut%
          }%
          \if@headline\vspace{\headlinespace}\hrule\fi%
        }%
      }%
    \fi
    \let\@mkboth\@gobbletwo
    \let\chaptermark\@gobble
    \let\sectionmark\@gobble
    \let\chapterstarmark\@gobble
    \let\sectionstarmark\@gobble
  }%
\fi
\if@crosshair
  \def\clap#1{\hbox to 0pt{\hss#1\hss}}
  \newdimen\@crosshairrule
  \@crosshairrule=.24pt
  \def\@crosshairs{\vbox to
     0pt{\hsize=0pt\baselineskip=0pt\lineskip=0pt \vss \clap{\vrule
        height .125in width \@crosshairrule depth 0pt} \clap{\vrule
        width .25in height \@crosshairrule depth 0pt} \clap{\vrule
        height .125in width \@crosshairrule depth 0pt} \vss}}
  \def\ps@clear{%
    \let\@oddfoot\@empty\let\@evenfoot\@empty
    \def\@oddhead{\hfil\raise\headheight\@crosshairs}
    \let\@evenhead\@oddhead}
\fi
\def\ps@myheadings{%
  \let\@oddfoot\@empty\let\@evenfoot\@empty
  \def\@evenhead{%
    \parbox{\textwidth}{%
      \makebox[\textwidth]{%
        {\pagenumberfont\thepage}\hfil{\headingstextfont\leftmark}%
        \v@strut%
        \if@centerheadline\hfil\fi
      }%
    \if@headline
      \vspace{\headlinespace}%
      \hrule%
    \fi}%
  }%
  \def\@oddhead{%
    \parbox{\textwidth}{%
      \makebox[\textwidth]{%
        \if@centerheadline\hfil\fi%
        {\headingstextfont\rightmark}\v@strut\hfil{\pagenumberfont\thepage}%
      }%
      \if@headline
        \vspace{\headlinespace}%
        \hrule%
      \fi}%
    }%
  \let\@mkboth\@gobbletwo
  \let\chaptermark\@gobble
  \let\sectionmark\@gobble
  \let\chapterstarmark\@gobble
  \let\sectionstarmark\@gobble
  }
\newif\if@suppressblankpage \@suppressblankpagefalse

\newcommand{\blankpage}{%
  \clearpage\thispagestyle{empty}\hbox{}\newpage
  \@suppressblankpagetrue
}
\newcommand{\blankdoublepage}{
  \blankpage\thispagestyle{empty}\cleardoublepage
}
\newcommand{\clearp@ge}{%
  \if@twoside
    \if@openright
      \if@openrightblank
        \if@suppressblankpage
          \cleardoublepage       % Just in case
        \else
          \blankdoublepage
        \fi%
      \else
        \cleardoublepage
      \fi%
    \else
      \clearpage
    \fi%
  \else
    \clearpage
  \fi%
  \@suppressblankpagefalse
}

\newcommand{\@starttitlepagehook}{}
\newcommand{\@AtStartOfTitlepage}{\g@addto@macro\@starttitlepagehook}
\newcommand{\@aftertitlepagehook}{}
\newcommand{\@AfterTitlepage}{\g@addto@macro\@aftertitlepagehook}
\newcommand{\@startabstracthook}{}
\newcommand{\@AtStartOfAbstract}{\g@addto@macro\@startabstracthook}
\newlength{\titlemarginleft}
\newlength{\titlemarginright}
\newlength{\titlemargintop}
\newlength{\titlemarginbottom}

\setlength{\titlemarginleft}{1.5in}
\setlength{\titlemarginright}{1.5in}
\setlength{\titlemargintop}{1.5in}
\setlength{\titlemarginbottom}{1.5in}
\newcommand*{\signatures}[1]{
  \count0=0
  \loop\ifnum\count0<#1 \advance\count0 by 1
  { \begin{minipage}{4in}
      \par
      \vspace{.25in}
      \hbox to 4in{\dotfill}
    \end{minipage}}
  \endgraf\repeat
  }
\def\@logofile{\@latex@warning@no@line{No \noexpand\logofile\ given}}
\newcommand*{\logofile}[1]{\gdef\@logofile{#1}}
\newcommand\maketitle{
  {\pagestyle{empty}\cleardoublepage}
  \thispagestyle{empty}
  \@startonecolumn
  \setlength{\parindent}{0pt}
  \setlength{\textwidth}{\paperwidth}
  \addtolength{\textwidth}{-\titlemarginleft}
  \addtolength{\textwidth}{-\titlemarginright}
  \setlength{\oddsidemargin}{\titlemarginleft}
  \addtolength{\oddsidemargin}{-1.0in}
  \setlength{\evensidemargin}{\oddsidemargin}
  \if@twoside
    \setlength\@tempdima        {\paperwidth}
    \addtolength\@tempdima      {-\textwidth}
    \addtolength\oddsidemargin  {-.1\@tempdima}
    \addtolength\evensidemargin  {.1\@tempdima}
  \fi

  \setlength{\textheight}{\paperheight}
  \addtolength{\textheight}{-\titlemargintop}
  \addtolength{\textheight}{-\titlemarginbottom}

  \setlength{\topmargin}{\titlemargintop}
  \addtolength{\topmargin}{-1.0in}
  \addtolength{\topmargin}{-\headheight}
  \addtolength{\topmargin}{-\headsep}
  \setlength{\@colht}{\textheight}%
  \setlength{\@colroom}{\textheight}%
  \setlength{\vsize}{\textheight}%
  \setlength{\columnwidth}{\textwidth}%
  \setlength{\hsize}{\columnwidth}%
  \setlength{\linewidth}{\hsize}%
  \renewcommand{\baselinestretch}{1}
  \titlepagefont
  \@starttitlepagehook
  {% Local scope for error calculations.
    \setbox0=\vbox to\textheight{\vspace{0pt plus 1filll}\par%
      \titlepage\par%
      \vspace{0pt plus 1filll}}
    \settoheight{\dimen0}{\copy0}
    \settodepth{\dimen1}{\box0}
    \addtolength{\dimen0}{\dimen1}
    \setlength{\dimen1}{\dimen0}
    \addtolength{\dimen0}{-\textheight}
    \addtolength{\dimen1}{-\paperheight}
    \ifdim0pt<\dimen0
      \ClassWarning{genthesis}
      {Overfull titlepage by \the\dimen0 }
    \fi
    \ifdim0pt<\dimen1
      \ClassError{genthesis}
      {Titlepage larger than paper by \the\dimen1 !!}
    \fi
  }
  \vbox to \textheight{%
    \vspace{0pt plus 1fil minus \titlemargintop}\par%
    \titlepage\par%
    \vspace{0pt plus 1fil minus \titlemarginbottom}%
  }
  \clearpage
  \@endonecolumn
  \@aftertitlepagehook
  \normalfont
  \normalsize
  \setcounter{footnote}{0}%
  \global\let\thanks\relax
  \global\let\maketitle\relax
  \global\let\@thanks\@empty
\global\let\title\relax \global\let\author\relax
\global\let\date\relax
}
\@AtStartOfTitlepage{\setcounter{page}\@ne}
\providecommand{\titlepage}{
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
    \@condupper{@upperinstitution}{\@institution}\par%
    \vspace{1em minus 0.5em}%
    (\@institutionaddress)\par%
    \vspace{1em minus 0.5em}%
    \@submitdate\par%
    \vspace{1em minus 0.5em}%
    \@copyrighttext\par%
    \vspace{1em minus 0.5em}%
    \if@empty\@copyrightnotice\else\vfil\@copyrightnotice\fi
    \vspace{1em plus 1fil}%
    \UBCT@signatures\par%
  \end{center}
  \vfil\null
}

\newcommand{\ubcauthorizationform}{
  {\pagestyle{empty}\cleardoublepage}
  \@startonecolumn
  \edef\@tempbaselinestretch{\baselinestretch}
  \renewcommand{\baselinestretch}{1}
  \selectfont
  In presenting this thesis in partial fulfillment of the requirements
  for an advanced degree at the University of British Columbia, I
  agree that the Library shall make it freely available for reference
  and study. I further agree that permission for extensive copying of
  this thesis for scholarly purposes may be granted by the head of my
  department or by his or her representatives. It is understood that
  copying or publication of this thesis for financial gain shall not
  be allowed without my written permission.

  \vfil
  \begin{flushright}
    (Signature) \rule{2in}{0.5pt}
  \end{flushright}
  \vfil

  \noindent
  \@department

  \vspace{2em}
  \noindent
  \@institution\par
  \@institutionaddress

  \vspace{2em}
  \noindent
  Date \rule{2in}{0.5pt}

  % The authorization form should not count as a page, but this will
  % be taken care of in the abstract.

  \clearpage
  \@endonecolumn
  \edef\baselinestretch{\@tempbaselinestretch}
  \global\let\thanks\relax
  \selectfont
}
\newcommand{\authorizationform}{\ubcauthorizationform}
\newcommand*\chaptermark[1]{}
\newcommand*\chapterstarmark[1]{}
\newcommand*\sectionstarmark[1]{}
\newcommand*\subsectionstarmark[1]{}
\newcommand*\subsubsectionstarmark[1]{}
\newcommand*\paragraphstarmark[1]{}
\newcommand*\subparagraphstarmark[1]{}
\setcounter{secnumdepth}{2}
\newcounter{@oldsecnumdepth}
\setcounter{@oldsecnumdepth}{\value{secnumdepth}}
\newcounter {part}
\newcounter {chapter}
\newcounter {section}[chapter]
\newcounter {subsection}[section]
\newcounter {subsubsection}[subsection]
\newcounter {paragraph}[subsubsection]
\newcounter {subparagraph}[paragraph]
\renewcommand{\thepart}{\@Roman\c@part}
\renewcommand\thechapter {\@arabic\c@chapter}
\renewcommand\thesection {\thechapter.\@arabic\c@section}
\renewcommand\thesubsection   {\thesection.\@arabic\c@subsection}
\renewcommand\thesubsubsection{\thesubsection.\@arabic\c@subsubsection}
\renewcommand\theparagraph    {\thesubsubsection.\@arabic\c@paragraph}
\renewcommand\thesubparagraph {\theparagraph.\@arabic\c@subparagraph}
\newcommand\@fmttocentry[1]{\@toctoupper{#1}}
\newcommand\@fmttocpart[1]{\@toctoitalic{\large \bfseries #1}}
\newcommand\@fmttocpartpage[1]{\normalfont \normalcolor #1}
\newcommand\@fmttocchapter[1]{\@toctoitalic{\bfseries #1}}
\newcommand\@fmttocchapterpage[1]{\normalfont \normalcolor #1}
\newcommand\@fmttocsection[1]{\@toctoitalic{#1}}
\newcommand\@fmttocsectionpage[1]{\normalfont \normalcolor #1}
\newcommand\@fmttocsubsection[1]{\@toctoitalic{#1}}
\newcommand\@fmttocsubsectionpage[1]{\normalfont \normalcolor #1}
\newcommand\@fmttocsubsubsection[1]{\@toctoitalic{#1}}
\newcommand\@fmttocsubsubsectionpage[1]{\normalfont \normalcolor #1}
\newcommand\@fmttocparagraph[1]{\@toctoitalic{#1}}
\newcommand\@fmttocparagraphpage[1]{\normalfont \normalcolor #1}
\newcommand\@fmttocsubparagraph[1]{\@toctoitalic{#1}}
\newcommand\@fmttocsubparagraphpage[1]{\normalfont \normalcolor #1}
\newcommand\@chapapp{\chaptername}
\newcommand\frontmatter{%
  \@mainmatterfalse
  \setcounter{@oldsecnumdepth}{\value{secnumdepth}}
  \setcounter{secnumdepth}{-3}
  \pagenumbering{roman}}
\newcommand\mainmatter{%
  \@mainmattertrue
  \setcounter{secnumdepth}{\value{@oldsecnumdepth}}
  \if@twoside
    \blankdoublepage
  \else
    \cleardoublepage
  \fi%
  \pagenumbering{arabic}}
\newcommand\backmatter{\@mainmatterfalse}
\newcommand\part{%
  \clearp@ge
  \thispagestyle{plain}%
  \if@twocolumn
    \onecolumn
    \@tempswatrue
  \else
    \@tempswafalse
  \fi
  \null\vfil
  \secdef\@part\@spart}
\def\@part[#1]#2{%
  \ifnum \c@secnumdepth >-2\relax
    \refstepcounter{part}%
    \addcontentsline{toc}{part}%
                    {\thepart\hspace{1em}\@fmttocentry{#1}}%
  \else
    \addcontentsline{toc}{part}{\@fmttocentry{#1}}%
  \fi
  \markboth{}{}%
  {\centering
    \interlinepenalty \@M
    \normalfont
    \if@partheads
      \ifnum \c@secnumdepth >-2\relax
        {\partnamefont\@toupper{\partname}\nobreakspace\thepart\par}
        \vspace{\partbetweenskip}
      \fi
    \fi
    {\partnamefont #2\par}%
  }%
  \@endpart
}
\def\@spart#1{%
  {\centering
    \interlinepenalty \@M
    \normalfont
    {\partnamefont #1\par}%
  }%
  \@endpart}
\def\@endpart{\vfil\newpage
  \if@twoside
    \if@openright
      \null
      \thispagestyle{empty}%
      \newpage
    \fi
  \fi
  \if@tempswa
    \twocolumn
  \fi}
\newcommand\chapter{%
  \clearp@ge
  \thispagestyle{plain}%
  \global\@topnum\z@
  \@afterindentfalse
  \secdef\@chapter\@schapter}
\def\@chapter[#1]#2{
  \ifnum \c@secnumdepth >\m@ne
    \if@mainmatter
      \refstepcounter{chapter}%
      \typeout{\@chapapp\space\thechapter.}%
      \addcontentsline{toc}{chapter}%
                      {\protect\numberline{\thechapter}%
                        \@fmttocentry{#1}}%
    \else
      \addcontentsline{toc}{chapter}{\@fmttocentry{#1}}
    \fi
  \else
    \addcontentsline{toc}{chapter}{\@fmttocentry{#1}}
  \fi
  \chaptermark{#1}%
  \addtocontents{lof}{\protect\addvspace{10\p@}}%
  \addtocontents{lot}{\protect\addvspace{10\p@}}%
  \@ifundefined{float@addtolists}%
               {\relax}%
               {\float@addtolists{\protect\addvspace{10\p@}}}%
  \if@twocolumn
    \@topnewpage[\vspace*{\chapterbeforeskip}%
                 \@makechapterhead{#2}]%
  \else
    \@makechapterhead{#2}%
    \@afterheading
  \fi}
\AtBeginDocument{
  \@ifundefined{float@listhead}%
               {\relax}%
               {\renewcommand{\float@listhead}[1]{%
                   \chapter[#1]{#1}}}
} %\AtBeginDocument
\def\@makechapterhead#1{%
  \setlength{\@tempdima}{\chapterbeforeskip}
  \if@chapterheads
    \if@mainmatter
      \addtolength{\@tempdima}{-\chapterbetweenskip}
      \settoheight{\@tempdimb}{\chapterfont \@toupper{\@chapapp}
                               \if@headcount\space\thechapter\fi } % b := H
      \if@committee %
         \addtolength{\@tempdimb}{\committeespacing\@tempdimb}  % b := H(C+1)
         \setlength{\@tempdimb}{0.5\@tempdimb}
         \settodepth{\@tempdimc}{\chapterfont \@toupper{\@chapapp}
                                 \if@headcount\space\thechapter\fi }  % c := FUDGE FACTOR
         \addtolength{\@tempdimc}{-\committeespacing\@tempdimc} % c := F(1-C)
         \setlength{\@tempdimc}{-\@tempdimc} % c := F(C-1)
         \addtolength{\@tempdimb}{\@tempdimc} % b := H(C+1)/2 + F(C-1)
      \fi
      \addtolength{\@tempdima}{-\@tempdimb}
    \fi
  \fi
  \vspace*{\@tempdima}%
  {\parindent \z@
    \@headingalignment \normalfont
    \interlinepenalty\@M
    \ifnum \c@secnumdepth >\m@ne
      \if@chapterheads
        \if@mainmatter
          {\chapterfont%
            \@toupper{\@chapapp}%
            \if@headcount\space\thechapter\fi
          }%
          \par\nobreak
          \vspace{\chapterbetweenskip}
        \fi
      \fi
    \fi
  \interlinepenalty\@M
    {\chaptertitlefont %
      \if@mainmatter
        \if@chapterheads\else
          \if@headcount
            \thechapter.\space%
          \fi
        \fi
      \fi
      \@toupper{#1}%
    \par\nobreak}
    \vspace*{\chapterafterskip}%
  }
}
\def\@schapter#1{%
  \if@starmark\chapterstarmark{#1}\fi
  \if@twocolumn
    \@topnewpage[\@makeschapterhead{#1}]%
  \else
    \@makeschapterhead{#1}%
    \@afterheading
  \fi}
\def\@makeschapterhead#1{%
  \vspace*{\chapterbeforeskip}%
  {\parindent \z@
    \@headingalignment
    \normalfont
    \interlinepenalty\@M
    {\chaptertitlefont \@toupper{#1}%
    \par\nobreak}
    \vspace*{\chapterafterskip}%
  }
}
\newcommand*{\section}{\@suppressblankpagefalse%
  \secdef\@section\@ssection}%
\newcommand*{\@section}[2][]{%
  \@startsection {section}{1}{\sectionindent}%
                 {\sectionbeforeskip}%
                 {\sectionafterskip}%
                 {\@headingalignment\normalfont\sectionfont}%
                 [\@fmttocentry{#1}]%
                 {#2}}
\newcommand*{\@ssection}[1]{%
  \@startsection{section}{1}{\sectionindent}%
                {\sectionbeforeskip}%
                {\sectionafterskip}%
                {\@headingalignment\normalfont\sectionfont}*%
                {#1}%
  \if@starmark\sectionstarmark{#1}\fi}
\newcommand*{\subsection}{\@suppressblankpagefalse%
  \secdef\@subsection\@ssubsection}%
\newcommand*{\@subsection}[2][]{%
  \@startsection {subsection}{2}{\subsectionindent}%
                 {\subsectionbeforeskip}%
                 {\subsectionafterskip}%
                 {\@headingalignment\normalfont\subsectionfont}%
                 [\@fmttocentry{#1}]%
                 {#2}}
\newcommand*{\@ssubsection}[1]{%
  \@startsection{subsection}{2}{\subsectionindent}%
                {\subsectionbeforeskip}%
                {\subsectionafterskip}%
                {\@headingalignment\normalfont\subsectionfont}*%
                {#1}%
  \if@starmark\subsectionstarmark{#1}\fi}
\newcommand*{\subsubsection}{\@suppressblankpagefalse%
  \secdef\@subsubsection\@ssubsubsection}%
\newcommand*{\@subsubsection}[2][]{%
  \@startsection {subsubsection}{3}{\subsubsectionindent}%
                 {\subsubsectionbeforeskip}%
                 {\subsubsectionafterskip}%
                 {\@headingalignment\normalfont\subsubsectionfont}%
                 [\@fmttocentry{#1}]%
                 {#2}}
\newcommand*{\@ssubsubsection}[1]{%
  \@startsection{subsubsection}{3}{\subsubsectionindent}%
                {\subsubsectionbeforeskip}%
                {\subsubsectionafterskip}%
                {\@headingalignment\normalfont\subsubsectionfont}*%
                {#1}%
  \if@starmark\subsectionstarmark{#1}\fi}
\newcommand*{\paragraph}{\@suppressblankpagefalse%
  \secdef\@paragraph\@sparagraph}%
\newcommand*{\@paragraph}[2][]{%
  \@startsection {paragraph}{4}{\paragraphindent}%
                 {\paragraphbeforeskip}%
                 {\paragraphafterskip}%
                 {\@headingalignment\normalfont\paragraphfont}%
                 [\@fmttocentry{#1}]%
                 {#2}}
\newcommand*{\@sparagraph}[1]{%
  \@startsection{paragraph}{4}{\paragraphindent}%
                {\paragraphbeforeskip}%
                {\paragraphafterskip}%
                {\@headingalignment\normalfont\paragraphfont}*%
                {#1}%
  \if@starmark\paragraphstarmark{#1}\fi}
\newcommand*{\subparagraph}{\@suppressblankpagefalse%
  \secdef\@subparagraph\@ssubparagraph}%
\newcommand*{\@subparagraph}[2][]{%
  \@startsection {subparagraph}{5}{\subparagraphindent}%
                 {\subparagraphbeforeskip}%
                 {\subparagraphafterskip}%
                 {\@headingalignment\normalfont\subparagraphfont}%
                 [\@fmttocentry{#1}]%
                 {#2}}
\newcommand*{\@ssubparagraph}[1]{%
  \@startsection{subparagraph}{5}{\subparagraphindent}%
                {\subparagraphbeforeskip}%
                {\subparagraphafterskip}%
                {\@headingalignment\normalfont\subparagraphfont}*%
                {#1}%
  \if@starmark\subparagraphstarmark{#1}\fi}
\if@twocolumn
  \setlength\leftmargini  {2em}
\else
  \setlength\leftmargini  {2.5em}
\fi
\leftmargin  \leftmargini
\setlength\leftmarginii  {2.2em}
\setlength\leftmarginiii {1.87em}
\setlength\leftmarginiv  {1.7em}
\if@twocolumn
  \setlength\leftmarginv  {.5em}
  \setlength\leftmarginvi {.5em}
\else
  \setlength\leftmarginv  {1em}
  \setlength\leftmarginvi {1em}
\fi
\setlength  \labelsep  {.5em}
\setlength  \labelwidth{\leftmargini}
\addtolength\labelwidth{-\labelsep}
\@beginparpenalty -\@lowpenalty
\@endparpenalty   -\@lowpenalty
\@itempenalty     -\@lowpenalty
\renewcommand\theenumi{\@arabic\c@enumi}
\renewcommand\theenumii{\@alph\c@enumii}
\renewcommand\theenumiii{\@roman\c@enumiii}
\renewcommand\theenumiv{\@Alph\c@enumiv}
\newcommand\labelenumi{\theenumi.}
\newcommand\labelenumii{(\theenumii)}
\newcommand\labelenumiii{\theenumiii.}
\newcommand\labelenumiv{\theenumiv.}
\renewcommand\p@enumii{\theenumi}
\renewcommand\p@enumiii{\theenumi(\theenumii)}
\renewcommand\p@enumiv{\p@enumiii\theenumiii}
\newcommand\labelitemi{\textbullet}
\newcommand\labelitemii{\normalfont\bfseries \textendash}
\newcommand\labelitemiii{\textasteriskcentered}
\newcommand\labelitemiv{\textperiodcentered}
\newenvironment{description}
{\list{}{\labelwidth\z@ \itemindent-\leftmargin
    \let\makelabel\descriptionlabel}}
{\endlist}
\newcommand*\descriptionlabel[1]{\hspace\labelsep
  \normalfont\bfseries #1}
\newenvironment{abstract}{%
  \@startonecolumn
  \@startabstracthook
    \chapter{\abstractname}
}
{\clearpage\@endonecolumn}
\newenvironment{verse}
               {\let\\\@centercr
                \list{}{\itemsep      \z@
                        \itemindent   -1.5em%
                        \listparindent\itemindent
                        \rightmargin  \leftmargin
                        \advance\leftmargin 1.5em}%
                \item\relax}
               {\endlist}
\newenvironment{quotation}
               {\list{}{\listparindent 1.5em%
                        \itemindent    \listparindent
                        \rightmargin   \leftmargin
                        \parsep        \z@ \@plus\p@}%
                \item\relax}
               {\endlist}
\newenvironment{quote}
               {\list{}{\rightmargin\leftmargin}%
                \item\relax}
               {\endlist}
\newcommand{\appendix}{\par
  \setcounter{chapter}{0}%
  \setcounter{section}{0}%
  \if@appendixpart{%
    \part{\appendicesname}%
  }\else{%
    \if@appendicestoc{%
      \addtocontents{toc}{\protect\contentsline%
        {part}{\@fmttocentry{\appendicesname}}{}{}}%
    }\fi
    \if@appendixpage{
      \pagestyle{empty}\cleardoublepage
    }\fi
  }\fi
  \gdef\@chapapp{\appendixname}%
  \gdef\thechapter{\@Alph\c@chapter}}
\setlength\arraycolsep{5\p@}
\setlength\tabcolsep{6\p@}
\setlength\arrayrulewidth{.4\p@}
\setlength\doublerulesep{2\p@}
\setlength\tabbingsep{\labelsep}
\skip\@mpfootins = \skip\footins
\setlength\fboxsep{3\p@}
\setlength\fboxrule{.4\p@}
\@addtoreset {equation}{chapter}
\renewcommand\theequation
  {\ifnum \c@chapter>\z@ \thechapter.\fi \@arabic\c@equation}
\newcounter{figure}[chapter]
\renewcommand \thefigure
     {\ifnum \c@chapter>\z@ \thechapter.\fi \@arabic\c@figure}
\def\fps@figure{tbp}
\def\ftype@figure{1}
\def\ext@figure{lof}
\def\fnum@figure{{\figurefont\figurename\nobreakspace\thefigure}}
\newenvironment{figure}
               {\@float{figure}}
               {\end@float}
\newenvironment{figure*}
               {\@dblfloat{figure}}
               {\end@dblfloat}
\newcounter{table}[chapter]
\renewcommand \thetable
     {\ifnum \c@chapter>\z@ \thechapter.\fi \@arabic\c@table}
\def\fps@table{tbp}
\def\ftype@table{2}
\def\ext@table{lot}
\def\fnum@table{{\tablefont\tablename\nobreakspace\thetable}}
\newenvironment{table}
               {\@float{table}}
               {\end@float}
\newenvironment{table*}
               {\@dblfloat{table}}
               {\end@dblfloat}
\newlength\abovecaptionskip
\newlength\belowcaptionskip
\setlength\abovecaptionskip{10\p@}
\setlength\belowcaptionskip{0\p@}
\long\def\@makecaption#1#2{%
  \vskip\abovecaptionskip
  \sbox\@tempboxa{{\captionheaderfont #1:} {\captionbodyfont #2}}%
  \ifdim \wd\@tempboxa >\hsize
    \if@hangingcaptions
      \@hangfrom{\captionheaderfont #1: }{\captionbodyfont #2\par}%
    \else
      {\captionheaderfont #1: }{\captionbodyfont #2\par}%
    \fi
  \else
    \global \@minipagefalse
    \hb@xt@\hsize{\hfil\box\@tempboxa\hfil}%
  \fi
  \vskip\belowcaptionskip}
\DeclareOldFontCommand{\rm}{\normalfont\rmfamily}{\mathrm}
\DeclareOldFontCommand{\sf}{\normalfont\sffamily}{\mathsf}
\DeclareOldFontCommand{\tt}{\normalfont\ttfamily}{\mathtt}
\DeclareOldFontCommand{\bf}{\normalfont\bfseries}{\mathbf}
\DeclareOldFontCommand{\it}{\normalfont\itshape}{\mathit}
\DeclareOldFontCommand{\sl}{\normalfont\slshape}{\@nomath\sl}
\DeclareOldFontCommand{\sc}{\normalfont\scshape}{\@nomath\sc}
\DeclareRobustCommand*\cal{\@fontswitch\relax\mathcal}
\DeclareRobustCommand*\mit{\@fontswitch\relax\mathnormal}
\newcommand\@pnumwidth{1.55em}
\newcommand\@tocrmarg{2.55em}
\newcommand\@dotsep{4.5}
\setcounter{tocdepth}{2}
\newcommand{\tableofcontents}{%
    \if@twocolumn
      \@restonecoltrue\onecolumn
    \else
      \@restonecolfalse
    \fi
    \chapter{\contentsname}
    \@starttoc{toc}%
    \if@restonecol\twocolumn\fi
    }
\newcommand*\l@part[2]{%
  \ifnum \c@tocdepth >-2\relax
    \addpenalty{-\@highpenalty}%
    \addvspace{2.25em \@plus\p@}%
    \setlength\@tempdima{3em}%
    \begingroup
      \parindent \z@ \rightskip \@pnumwidth
      \parfillskip -\@pnumwidth
      {\leavevmode
       \@fmttocpart{#1}\hfil \hb@xt@\@pnumwidth{%
         \hss \@fmttocpartpage{#2}}}\par
       \nobreak
         \global\@nobreaktrue
         \everypar{\global\@nobreakfalse\everypar{}}%
    \endgroup
  \fi}
\newcommand*\l@chapter[2]{%
  \ifnum \c@tocdepth >\m@ne
    \addpenalty{-\@highpenalty}%
    \vskip 1.0em \@plus\p@
    \setlength\@tempdima{1.5em}%
    \begingroup
      \parindent \z@ \rightskip \@pnumwidth
      \parfillskip -\@pnumwidth
      \leavevmode
      \advance\leftskip\@tempdima
      \hskip -\leftskip
      {\@fmttocchapter{#1}}\nobreak%
       \if@chaptertocdots
         \leaders\hbox{$\m@th%
           \mkern \@dotsep mu\hbox{.}\mkern \@dotsep%
           mu$}\hfil
       \else
         \hfil
       \fi
      \hb@xt@\@pnumwidth{\hfil \@fmttocchapterpage{#2}}\par%
      \penalty\@highpenalty
    \endgroup
  \fi}
\newcommand*\l@section[2]{%
  \@dottedtocline{1}{1.5em}{2.3em}%
                 {\@fmttocsection{#1}}%
                 {\@fmttocsectionpage{#2}}%
}
\newcommand*\l@subsection[2]{%
  \@dottedtocline{2}{3.8em}{3.2em}{\@fmttocsubsection{#1}}%
                                  {\@fmttocsubsectionpage{#2}}}
\newcommand*\l@subsubsection[2]{%
  \@dottedtocline{3}{7.0em}{4.1em}{\@fmttocsubsubsection{#1}}%
                                  {\@fmttocsubsubsectionpage{#2}}}
\newcommand*\l@paragraph[2]{%
  \@dottedtocline{4}{10em}{5em}{\@fmttocparagraph{#1}}%
                               {\@fmttocparagraphpage{#2}}}
\newcommand*\l@subparagraph[2]{%
  \@dottedtocline{5}{12em}{6em}{\@fmttocsubparagraph{#1}}%
                               {\@fmttocsubparagraphpage{#2}}}
\newcommand\listoffigures{%
    \if@twocolumn
      \@restonecoltrue\onecolumn
    \else
      \@restonecolfalse
    \fi
    \chapter{\listfigurename}%
    \@starttoc{lof}%
    \if@restonecol\twocolumn\fi
    }
\newcommand*\l@figure{\@dottedtocline{1}{\lofindent}{\loflabelwidth}}
\newcommand\listoftables{%
    \if@twocolumn
      \@restonecoltrue\onecolumn
    \else
      \@restonecolfalse
    \fi
    \chapter{\listtablename}%
    \@starttoc{lot}%
    \if@restonecol\twocolumn\fi
    }
\newcommand*\l@table{\@dottedtocline{1}{\lotindent}{\lotlabelwidth}}
\newdimen\bibindent
\setlength\bibindent{1.5em}
\providecommand\bibsection{}
\newenvironment{thebibliography}[1]{
  \bibsection
  \list{\@biblabel{\@arabic\c@enumiv}}%
  {\settowidth\labelwidth{\@biblabel{#1}}%
    \leftmargin\labelwidth
    \advance\leftmargin\labelsep
    \@openbib@code
    \usecounter{enumiv}%
    \let\p@enumiv\@empty
    \renewcommand\theenumiv{\@arabic\c@enumiv}}%
  \sloppy
  \clubpenalty4000
  \@clubpenalty \clubpenalty
  \widowpenalty4000%
  \sfcode`\.\@m}
{\def\@noitemerr
  {\@latex@warning{Empty `thebibliography' environment}}%
  \endlist}
\AtBeginDocument{
  \renewcommand\bibsection{
    \if@sectionbib
      \if@bibnum
        \section{\bibname}%
      \else
        \section*{\bibname}%
        \sectionstarmark{\bibname}%
        \addcontentsline{toc}{section}{\@fmttocentry{\bibname}}%
      \fi%
    \else
      \if@bibnum
        \chapter{\bibname}%
      \else
        \chapter*{\bibname}%
        \chapterstarmark{\bibname}%
        \addcontentsline{toc}{chapter}{\@fmttocentry{\bibname}}%
      \fi%
    \fi%
  }
} % AtBeginDocument
\newcommand\newblock{\hskip .11em\@plus.33em\@minus.07em}
\let\@openbib@code\@empty
\newenvironment{theindex}
               {\if@twocolumn
                  \@restonecolfalse
                \else
                  \@restonecoltrue
                \fi
                \columnseprule \z@
                \columnsep 35\p@
                \clearp@ge
                \settoheight{\@tempdimb}{\chapterfont \@toupper{\indexname}} % b = H
                \if@committee %
                  \setlength{\@tempdimc}{\@tempdimb} % c := H
                  \addtolength{\@tempdimc}{\committeespacing\@tempdimc}  % c := H(C+1)
                  \setlength{\@tempdimc}{0.5\@tempdimc} % c := H(C+1)/2
                  \addtolength{\@tempdimb}{-\committeespacing\@tempdimb} % b := H(1-C)
                  \setlength{\@tempdimb}{-\@tempdimb} % b := H(C-1)
                  \addtolength{\@tempdimb}{\@tempdimc} % b := H(C+1)/2 + H(C-1)
                \fi
                \addtolength{\@tempdimb}{0.5\@tempdimb}
                \phantomsection
                \twocolumn[\vspace*{\@tempdimb}%
                           \@makeschapterhead{\@toupper{\indexname}}]%
                \@mkboth{\@toupper{\indexname}}{\@toupper{\indexname}}%
                \addcontentsline{toc}{chapter}{\@fmttocentry{\indexname}}%
                \thispagestyle{plain}\parindent\z@
                \parskip\z@ \@plus .3\p@\relax
                \let\item\@idxitem}
               {\if@restonecol\onecolumn\else\clearpage\fi}
\newcommand\@idxitem{\par\hangindent 40\p@}
\newcommand\subitem{\@idxitem \hspace*{20\p@}}
\newcommand\subsubitem{\@idxitem \hspace*{30\p@}}
\newcommand\indexspace{\par \vskip 10\p@ \@plus5\p@ \@minus3\p@\relax}
\renewcommand\footnoterule{%
  \kern-3\p@
  \hrule\@width.4\columnwidth
  \kern2.6\p@}
\if@chapternotereset%
  \@addtoreset{footnote}{chapter}%
\fi%
\newcommand\@makefntext[1]{%
    \parindent 1em%
    \noindent
    \hb@xt@1.8em{\hss\@makefnmark}#1}
\newcommand*\contentsname{Table of Contents}
\newcommand*\listfigurename{List of Figures}
\newcommand*\listtablename{List of Tables}
\AtBeginDocument{
  \@ifpackageloaded{babel}{
    \addto\captionsenglish{%
      \renewcommand*\contentsname{Table of Contents}
      \renewcommand*\listfigurename{List of Figures}
      \renewcommand*\listtablename{List of Tables}
    }
  }{}
}
\newcommand\bibname{Bibliography}
\newcommand\indexname{Index}
\newcommand\figurename{Figure}
\newcommand\tablename{Table}
\newcommand\partname{Part}
\newcommand\chaptername{Chapter}
\newcommand\appendixname{Appendix}
\newcommand\appendicesname{Appendices}
\newcommand\abstractname{Abstract}
\newcommand\draftname{Preliminary Draft}
\def\today{\ifcase\month\or
  January\or February\or March\or April\or May\or June\or
  July\or August\or September\or October\or November\or December\fi
  \space\number\day, \number\year}
\setlength\columnsep{10\p@}
\setlength\columnseprule{0\p@}
\if@final
  \if@runningheaders
    \pagestyle{headings}
  \else
    \pagestyle{plain}
  \fi
\else % draft
  \pagestyle{draft}
  \let\ps@plain\ps@draft
\fi
\pagenumbering{arabic}
\if@twoside
\else
  \raggedbottom
\fi
\if@twocolumn
  \twocolumn
  \sloppy
  \flushbottom
\else
  \onecolumn
\fi
\newcommand{\committeespacing}{1.5}
\AtBeginDocument{
  \if@committee%
    \renewcommand\baselinestretch{\committeespacing}%
  \fi%
}%
\endinput
%%
%% End of file `genthesis.cls'.

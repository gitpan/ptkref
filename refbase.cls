%% refbase.cls -- standard document class for Perl Reference Guide
%%
%% RCS Status      : $Id: refbase.cls,v 5.10 1995/12/24 15:03:07 jv Exp $
%% Author          : Johan Vromans
%% Created On      : Wed Jul  3 13:58:33 1991
%% Last Modified By: Johan Vromans
%% Last Modified On: Sun Dec 24 16:01:35 1995
%% Update Count    : 89
%% Status          : OK
%%
%%%%%%%%%%%%%%%% Copyright %%%%%%%%%%%%%%%%
%
% The Perl Reference Guide and its associated files are 
%
% Copyright 1989, 1995 Johan Vromans.
%
% They may be used and reproduced under the terms of the
% GNU Public Licence. A copy of this licence should have 
% been included in your Perl source kit.
%
%%%%%%%%%%%%%%%% Usage %%%%%%%%%%%%%%%%
%
% Usage:
%
%    \documentclass[epsf]{refbase}
%
%%%%%%%%%%%%%%%% Start of code %%%%%%%%%%%%%%%%
%
\NeedsTeXFormat{LaTeX2e}[1994/12/01]
\ProvidesClass{refbase}
              [1995/11/20 $Revision: 5.10 $
 Document class for Perl Reference Guide]
%\def\tkrev{4.2}
\def\tkrev{402.003}
\def\PRGfmtname{Perl Reference Guide}
\def\PRGfmtversion{$Revision: 5.10 $}
\everyjob{\typeout{Document class \PRGfmtname\space\PRGfmtversion}}
\everyjob{\typeout{for Perl \perlrev.}}
\def\refrev{\tkrev.\revision}
\everyjob{\typeout{Reference Guide revision is \refrev.}}
%
% epsf.sty must be loaded before psfonts.
\DeclareOption{epsf}
   {\input{epsf.sty}}           % dvips
%\ExecuteOptions{...}
\ProcessOptions
%
%%%%%%%%%%%%%%%% Other Styles %%%%%%%%%%%%%%%%
%
\LoadClass[11pt,twoside]{article}       % standard LaTeX
%
%%%%%%%%%%%%%%%% Selection of Fonts %%%%%%%%%%%%%%%%
%
\let\makeuppage=\relax
\def\makeupspace#1{\relax}
%
\typeout{Configuring for PostScript fonts}
\RequirePackage{times}
\def\largesl{%
    \sffamily\bfseries\itshape\fontsize{12}{14}\selectfont}
\def\LARGEsl{%
    \sffamily\bfseries\itshape\fontsize{17}{22}\selectfont}
\def\smallsf{%
    \sffamily\mdseries\upshape\fontsize{10}{10}\selectfont}
\def\smallbf{%
    \sffamily\bfseries\upshape\fontsize{10}{10}\selectfont}
\def\ttbf{%
    \ttfamily\bfseries\upshape\fontsize{11}{12}\selectfont}

% In the final version, some explicit \newpages and space are needed. 
\let\makeuppage=\newpage
\def\makeupspace#1{\vspace{#1}}
%
%%%%%%%%%%%%%%%% Private Settings %%%%%%%%%%%%%%%%
%
\topmargin -1.55cm              % for dvips 5.47
\headheight 0.7cm
\headsep 0.4cm
\footskip 1.0cm
\textheight 25.4cm              % for dvips 5.47
\textwidth 12.8cm
\oddsidemargin 3cm              % for dvips 5.47
\evensidemargin 3cm             % for dvips 5.47
\frenchspacing
%
%%%%%%%%%%%%%%%% Headers/Footers %%%%%%%%%%%%%%%%
%
\newlength{\tw}\setlength{\tw}{\textwidth}\addtolength{\tw}{-2pt}
\def\@refhead#1{%
    \vbox{\makebox[\textwidth][#1]{\largesl{Perl/Tk Reference Guide}}
          \rule[-0.1cm]{\textwidth}{0.5pt}}}
\def\@reffoot#1{%
    \vbox{\rule[-0.6cm]{\textwidth}{0.5pt}
          \makebox[\textwidth][#1]{\largesl\thepage}}}
%
\def\@oddhead{\@refhead{r}}
\def\@evenhead{\@refhead{l}}
\def\@oddfoot{\@reffoot{r}}
\def\@evenfoot{\@reffoot{l}}
%
%%%%%%%%%%%%%%%% Paragraphs %%%%%%%%%%%%%%%%
%
\parindent 0pt                  % align to left margin
\setlength{\baselineskip}{12pt} % inter-line spacing
\parskip 2pt plus 1pt           % half-line spacing between paragraphs
\setlength{\smallskipamount}{\parskip} % half-line
\setlength{\medskipamount}{2\parskip} % single line
\setlength{\bigskipamount}{3\parskip} % one-and-a-half line
\setlength{\topsep}{0pt plus 1pt} % for lists and tabbing
\setlength{\partopsep}{0pt plus 1pt} % for lists and tabbing
\setlength{\itemsep}{0pt plus 1pt} % for lists and tabbing
%
\raggedright                    % no adjustment
\let\maybenewpage\relax
%
%%%%%%%%%%%%%%%% Sections and such %%%%%%%%%%%%%%%%
%
% Note: zero is a 'hot' value. approximate with 0.1pt
\def\pr@section{
        \@startsection{section}{1}{0.1pt}
                       {4mm}{0.1pt}{\normalsize}}
%
\renewcommand{\section}[1]{
        \maybenewpage
        \addtocounter{section}{1}
        \pr@section*{\vbox{{\LARGEsl \thesection. #1}
                          {\rule[0.3cm]{\textwidth}{0.25pt}}}}
        \addcontentsline{toc}{section}%
                {\protect\numberline{\thesection}#1}
        \typeout{\thesection. #1}
}
\newcommand{\unnumbered}[1]{
        \maybenewpage
        \pr@section*{{\vbox{{\LARGEsl {#1}}
                     {\rule[0.3cm]{\textwidth}{0.25pt}}}}}}
\renewcommand{\tableofcontents}{\@starttoc{toc}}
\renewcommand{\l@section}{\@dottedtocline{1}{\z@}{2.3em}}
\renewcommand{\@dottedtocline}[5]{
  \vskip \z@ \@plus.2\p@
  {\interlinepenalty\@M \leavevmode\@tempdima #3\relax
   \hbox to 105mm {{#4}\leaders\hbox{$\m@th \mkern \@dotsep mu.\mkern \@dotsep
       mu$}\hfill \hbox to\@pnumwidth{\hfil #5}}}}
\renewcommand{\numberline}[1]{\hbox to\@tempdima{\hfil#1.~~}}
%
%%%%%%%%%%%%%%%% Macros %%%%%%%%%%%%%%%%
%
\chardef\other=12
%
% |lit| is used to represent literal things.
% Representation is a fixed font.
{\catcode`\|=\active
\gdef|{\leavevmode%
\begingroup\catcode`\\=\other\catcode`\{=\other%
\catcode`\}=\other\catcode`\$=\other\catcode`\&=\other%
\catcode`\#=\other\catcode`\~=\other%
\catcode`\_=\other\catcode`\^=\other\catcode`\<=\other%
\catcode`\[=\other%
\obeyspaces\obeylines%
\let|=\endgroup\escapechar`\|\catcode`\%=\other\ttbf}}
\catcode`\|=\active

% <var> is used for variable things. 
% Representation is 10pt sans-serif uppercased.
\catcode`\<=\active
\def<{\leavevmode\italicizerest}
% \def\italicizerest#1>{{\smallsf\uppercase{#1}}}
\def\italicizerest#1>{{\it{#1}}}

% LaTeX active and 'hot' characters
\def\|{\leavevmode\hbox{\ttbf\char`\|}}
\def\<{\leavevmode\hbox{\ttbf\char`\<}}
\def\>{\leavevmode\hbox{\ttbf\char`\>}}
\def\^{\leavevmode\hbox{\ttbf\char`\^}}
\def\${\leavevmode\hbox{\ttbf\char`\$}}
\def\%{\leavevmode\hbox{\ttbf\char`\%}}
\def\&{\leavevmode\hbox{\ttbf\char`\&}}
\def\{{\leavevmode\hbox{\ttbf\char`\{}}
\def\}{\leavevmode\hbox{\ttbf\char`\}}}
\def\_{\leavevmode\hbox{\ttbf\char`\_}}

\newcommand{\lt}{\leavevmode\hbox{\ttbf\char`\<}}
\newcommand{\gt}{\leavevmode\hbox{\ttbf\char`\>}}

% Keywords
% Representation is 10pt sans-serif bold.
\def\kwd#1{{\smallbf #1}}

% Definitions
\def\oEXPR{<expr>\dag}
\def\true{{\bf true}}
\def\false{{\bf false}}

%%%%%%%%%%%%%%%% Enumerations %%%%%%%%%%%%%%%%
%
% Usage:
%
%  \begin{enum}{width}
%  \Xi{Blah} blah blah...
%  \Xi{Blah} bla ...
%  ...
%  \end{enum}
%
\newlength{\@xli}
\newlength{\@xlj}
\def\enum#1{
        \list{}{
          \setlength{\topsep}{0pt plus 1pt}
          \setlength{\partopsep}{0pt plus 1pt}
          \setlength{\itemsep}{0pt plus 1pt}
          \setlength{\parsep}{\parskip}
          \setlength{\itemindent}{0pt}
          \setlength{\labelsep}{5pt}
          \setlength{\labelwidth}{#1}
          \setlength{\leftmargin}{\labelwidth}
          \addtolength{\labelwidth}{-\labelsep}
          \setlength{\@xli}{\labelwidth}
          \def\makelabel##1{##1\hss}}}

% List element that overflows if it is too wide
\def\Xi#1{
        \settowidth{\@xlj}{#1}
        \item[{#1}]
        \ifnum\@xlj>\@xli
                \strut\newline
        \fi}
% List element that does not overflow if it is too wide
\def\Xj#1{\item[{#1}]}

\let\endenum=\endlist

%%%%%%%%%%%%%%%% Emacs support %%%%%%%%%%%%%%%%
%
% Local Variables:
% eval:(auto-fill-mode 0)
% eval:(headers)
% eval:(setq comment-start "% ")
% eval:(setq comment-start-skip "% +")
% End:

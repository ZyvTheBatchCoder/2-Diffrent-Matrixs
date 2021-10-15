@Echo Off & CD "%~dp0"

::: / Variable used in calling this script from the Self created resizing Batch.    
    Set "AlignFile=%~dpnx0"
::: \

::: / Creates variable /AE = Ascii-27 escape code.
::: - http://www.dostips.com/forum/viewtopic.php?t=1733
::: - https://stackoverflow.com/a/34923514/12343998
:::
::: - /AE can be used  with and without DelayedExpansion.
    Setlocal
    For /F "tokens=2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
        Endlocal
        Set "/AE=%%a"
    )
::: \

::: / Set environment state for Macro Definitions
    Setlocal DisableDelayedExpansion

    (Set LF=^


    %= Above Empty lines Required =%)

    Set ^"\n=^^^%LF%%LF%^%LF%%LF%^^"


::: / Color Macro Variables
::: - Macro used to print the "%%H"th character (Passed with randomly set Char variable as the 2nd Arg) from the defined Character Set
::: - At Y;X Position (Arg 1, %%G) in Color %%H
    Set @PrintMapped=for /L %%n in (1 1 2) do if %%n==2 (%\n%
        For /F "tokens=1,2,3,4 delims=, " %%G in ("!argv!") do (%\n%
            Echo(%/AE%[%%GH!%%I!!CharacterSet:~%%H,%%J!!Off!^&^&Endlocal%\n%
        ) %\n%
    ) ELSE setlocal enableDelayedExpansion ^& set argv=, 
::: -
::: - Macro used to print content of Variable passed with 2nd Arg (%%H)
::: - At Y;X Position (%%G) in Color %%H
    Set @Menu=for /L %%n in (1 1 2) do if %%n==2 (%\n%
        For /F "tokens=1,2,3 delims=, " %%G in ("!argv!") do (%\n%
            Echo(%/AE%[%%GH!%%I!!%%H!!Off!^&^&Endlocal%\n%
        ) %\n%
    ) ELSE setlocal enableDelayedExpansion ^& set argv=, 
::: \ End Macro Definitions

::: / Assigns ANSI color code values to each color, then builds an Array containing those color values to be accessed using random number.
    Setlocal EnableDelayedExpansion
    Set /A Red=31,Green=32,Yellow=33,Blue=34,Purple=35,Cyan=36,White=37,Grey=90,Pink=91,Beige=93,Aqua=94,Magenta=95,Teal=96,Off=0,CI#=0
    For %%A in (Red,Yellow,Pink,Beige,Grey,Purple,Green,Cyan,White,Aqua,Magenta,Blue,Teal,Off) do (
        Set "%%A=%/AE%[!%%A!m"
        Set /A "CI#+=1"
        Set "C#[!CI#!]=%%A"
    )
::: \

::: / Define character Set to be used. Accessed using Random number and Substring Modification to extract the character at that mapped position
    Set "CharacterSet=1qA{Z2W<sX[3EDC@4R}FV^5TG&BYHn7]UJM8-IK9OL0Ppo_iu>ytre$wQ\aSdf/gh~jkl+mN|bvc#xz"
::: \

::: / Identifies when the program has been called by the resizung batch it creates and goes to label passed by call
    If Not "%~3"=="" (
        Set "Console_Hieght=%~1"
        Set "Console_Width=%~2"
        Set "AlignFile=%~4"
        Goto :%~3
    ) Else (Goto :main)
::: \


::: / Subroutine to process output of wmic command into usable variables  for screen dimensions (resolution)

    :ChangeConsole <Lines> <Columns> <Label to Resume From> <If a 4th parameter is Defined, Aligns screen at top left>
::: - Get screen Dimensions
    For /f "delims=" %%# in  ('"wmic path Win32_VideoController  get CurrentHorizontalResolution,CurrentVerticalResolution /format:value"') do (
        Set "%%#">nul
    )
::: -  Calculation of X axis relative to screen resolution and console size

    Set /A CentreX= ( ( CurrentHorizontalResolution / 2 ) - ( %~2 * 4 ) ) + 8

::: - Sub Optimal calculation of Y axis relative to screen resolution and console size
    For /L %%A in (10,10,%1) DO Set /A VertMod+=1
    Set /A CentreY= ( CurrentVerticalResolution / 4 ) - ( %~1 * Vertmod )
    For /L %%B in (1,1,%VertMod%) do Set /A CentreY+= ( VertMod * 2 )

::: - Optional 4th parameter can be used to align console at top left of screen instead of screen centre
    If Not "%~4"=="" (Set /A CentreY=0,CentreX=-8)

    Set "Console_Width=%~2"

::: - Creates a batch file to reopen the main script using Call with parameters to define properties for console change and the label to resume from.
        (
        Echo.@Mode Con: lines=%~1 cols=%~2
        Echo.@Title Rainbow Matrix by Zyv
        Echo.@Call "%AlignFile%" "%~1" "%~2" "%~3" "%AlignFile%" 
        )>"%temp%\ChangeConsole.bat"

::: - .Vbs script creation and launch to reopen batch with new console settings, with aid of above batch script
        (
        Echo.Set objWMIService = GetObject^("winmgmts:\\.\root\cimv2"^)
        Echo.Set objConfig = objWMIService.Get^("Win32_ProcessStartup"^)
        Echo.objConfig.SpawnInstance_
        Echo.objConfig.X = %CentreX%
        Echo.objConfig.Y = %CentreY%
        Echo.Set objNewProcess = objWMIService.Get^("Win32_Process"^)
        Echo.intReturn = objNewProcess.Create^("%temp%\ChangeConsole.bat", Null, objConfig, intProcessID^)
        )>"%temp%\Consolepos.vbs"

::: - Starts the companion batch script to Change Console properties, ends the parent.
    Start "" "%temp%\Consolepos.vbs" & Exit

:main

    Call :ChangeConsole 45 170 Matrix top

::: / Display Elements  
:Matrix
Setlocal enableDelayedExpansion

::: - Numbers higher than actual console hieght cause the the console to scroll. the higher the number, the smoother the scroll
::: - and the less dense the characters on screen will be.
    Set /A Console_Hieght=(Console_Hieght * 5) / 4
::: - Menu Selection
    Set "Opt1=(W)aterfall %cyan%Matrix"
    Set "Opt2=(C)haos     %red%M%yellow%a%green%t%blue%r%purple%i%magenta%x"
    Set "Opt3=%red%(%pink%R%magenta%)%purple%a%blue%i%aqua%n%cyan%b%green%o%yellow%w %red%painting"
    Set "Opt4=(F)laming %yellow%Matrix"
    %@Menu% 1;1 Opt1 blue
    %@Menu% 2;1 Opt2 magenta
    %@Menu% 3;1 Opt3 aqua
    %@Menu% 4;1 Opt4 red
    Choice /N /C WCRF /M ""
    CLS & Goto :loop%Errorlevel%

:loop1
TITLE Flow Matrix By Paxton
:1loop
    For /L %%A in (1,1,125) do (
%= lower for loop end value equals faster transition, higher equals slower. Result of nCI color variable not being expanded with new value during for loop =%
        Set /A Xpos=!random! %%!Console_Width! + 1,Ypos=!random! %%!Console_Hieght! + 1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%3 + 1
        %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[%nCI%]! !CharCount!
    )
Goto :1loop

:loop2
TITLE Chaos Matrix By Zyv
:2loop
    For /L %%A in (1,1,5000) do ( 
        Set /A Xpos=!random! %%!Console_Width! + 1,Ypos=!random! %%!Console_Hieght! + 1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%3 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[%%B]! !CharCount!
    )
Goto :2loop

:loop3
TITLE Rainbow painter By Zyv
    Set /A Console_Hieght=((Console_Hieght / 5) * 4) - 4
:3loop
    Set /A Xpos=!random! %%!Console_Width! + 1,Ypos=!random! %%!Console_Hieght! + 1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%3 + 1
    For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[%%B]! !CharCount!
Goto :3loop

:loop4
TITLE Flaming Matrix By Zyv
:4loop
    For /L %%A in (1,1,200000) do ( 
        Set /A Xpos=!random! %%!Console_Width! + 1,Ypos=!random! %%!Console_Hieght! + 1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%5 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[2]! !CharCount!
        Set /A Xpos-=1,Ypos+=1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%6 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[1]! !CharCount!
        Set /A Xpos=!random! %%!Console_Width! + 1,Ypos=!random! %%!Console_Hieght! + 1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%5 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[2]! !CharCount!
        Set /A Xpos-=1,Ypos+=1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%6 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[1]! !CharCount!
        Set /A Xpos=!random! %%!Console_Width! + 1,Ypos=!random! %%!Console_Hieght! + 1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%5 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[2]! !CharCount!
        Set /A Xpos+=1,Ypos+=1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%6 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[1]! !CharCount!
        Set /A Xpos=!random! %%!Console_Width! + 1,Ypos=!random! %%!Console_Hieght! + 1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%5 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[2]! !CharCount!
        Set /A Xpos+=1,Ypos-=1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%6 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[1]! !CharCount!
        Set /A Xpos=!random! %%!Console_Width! + 1,Ypos=!random! %%!Console_Hieght! + 1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%5 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[2]! !CharCount!
        Set /A Xpos-=1,Ypos-=1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%6 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[1]! !CharCount!
    )
Goto :4loop
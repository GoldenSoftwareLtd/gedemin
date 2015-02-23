TurboPower Async Professional


Table of contents

1.  Introduction
2.  Package names
3.  Installation
4.  Version history
4.1   Release 4.06

==============================================


1. Introduction

Async Professional is a comprehensive communications toolkit for
Borland Delphi, C++Builder, & ActiveX environments. It provides direct
access to serial ports, TAPI, and the Microsoft Speech API. It
supports faxing, terminal emulation, VOIP, & more.

This is a source-only release of TurboPower Async Professional (APRO).
It includes designtime and runtime packages for Delphi 3 through 7 and
C++Builder 3 through 6.

For help files and a PDF manual, please see the tpapro_docs package on
SourceForge (http://sourceforge.net/projects/tpapro).

==============================================

2. Package names


TurboPower APRO package names have the following form:

  ANNNMKVV.*
   |  |||
   |  ||+------ VV  VCL version (30=Delphi 3, 40=Delphi 4, 70=Delphi 7)
   |  |+------- K   Kind of package (R=runtime, D=designtime)
   |  +-------- M   Product-specific modifier (typically underscore, V = VCL, C = CLX)
   +----------- NNN Product version number (e.g., 406=version 4.06)


For example, the APRO designtime package files for Delphi 7 have the
filename A406_D70.*.

The runtime package contains the core functionality of the product and
is not installed into the IDE. The designtime package references the
runtime package, registers the components, and contains property
editors used in the IDE.

==============================================

3. Installation


To install TurboPower APRO into your IDE, take the following steps:

  1. Unzip the release files into a directory (e.g., d:\apro).

  2. Start Delphi or C++Builder.

  3. Add the source subdirectory (e.g., d:\apro\source) to the IDE's
     library path.

  4. Open & compile the runtime package specific to the IDE being
     used.

  5. Open & install the designtime package specific to the IDE being
     used. The IDE should notify you the components have been
     installed.

==============================================

4. Version history


4.1 Release 4.06

  Please note that the following issue #s are from Bugzilla. These
  bugs were not exported to SourceForge.


 Enhancements
 ------------

 1880 - Multiple instances
 3580 - Error handling
 3623 - TAPI Hold and transfer capabilities
 3756 - enh: Add ability to force YModem to 128 byte blocks
 3981 - Add OnProcessChar commands for cursor on/off
 4064 - RAS - Add support for programatic phonebook additions
 4065 - RAS - Add support to retrieve connection statistics

 Bugs fixed
 ----------

 1350 - TInAddr conflicts with other components
 3217 - Once connected to an invalid ftp site, can't connect again.
 3373 - YModem locks files
 3515 - Need update the status when setting DTR and RTS.
 3548 - Cannot enter hex values in state conditions
 3646 - When switching modes, exception thrown in AdFax checkport procedure.
 3688 - TAdModem.BPSRate property not updated
 3702 - TApdSendFax, fpPageOK not used for class1
 3861 - Invalid modem attributes in XML files
 3866 - State machine - Mem leak upon deactivating
 3867 - States - StartString and EndString do not escape strings
 3879 - Fax - Class 1.0 implementation omission
 3887 - Data packet - AV on destroy
 3888 - Assign/AssignFile overloads causing problems
 3927 - TAdModem AV when destroyed
 3941 - State machine accesses port after closing
 3980 - OnProcessChar Command ecAnswerBack does not work.
 3982 - Support for Siemens S35i (PDU Mode?)
 4004 - Dialing using tone/pulse with TAdModem.
 4010 - AV even though ftp://ftp.turbopower.com/pub/apro/updates/APROFixes.htm#3887 was applied.
 4016 - FConnectFired may have broken DoDisconnect.
 4050 - Request for read only properties to indicate if scroll bars in use.
 4055 - TAdModem - incorrect exception if modemcap folder not found
 4056 - TApdModemStatusDialog - Cancel button doesn't work
 4057 - TAdModem - AV if port not opened
 4062 - Data packet - AV on destroy revisited
 4066 - Invalid Scroll Regions cause AV
 4067 - Provide manual adjustment of character cell sizes in terminal
 4068 - TAdTerminalEmulator.teProcessCommand can AV with no terminal
 4071 - RAS - Missing some consts
 4082 - AV On destroy when turning off mouseselect
 4096 - TAdModem - incompatible with user's OnTriggerXxx
 4121 - OnTapiFail getting called twice for one failure.
 4132 - Fonts changing works incorrectly with VT100
 4159 - AdModem - SetDevConfig not forcing initialization
 4177 - TApdFaxConverter - idShell conversion may leave reg/ini keys
 4186 - TApdSendFax - Class1 error handling
 4192 - TApdWinsockPort - DeviceName in log incorrect

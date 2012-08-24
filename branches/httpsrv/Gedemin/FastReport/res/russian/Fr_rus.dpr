
{******************************************}
{                                          }
{             FastReport v2.4              }
{              Resource DLL                }
{                                          }
{ Copyright (c) 1998-2000 by Tzyganenko A. }
{                                          }
{******************************************}

{
  Now FastReport can use several languages in one project. By default, it
  works with resources that are linked into .exe file. If you need
  multi-language support in your project, make several language DLLs
  (each about 50Kb) and switch to particular language by this code:

  uses FR_Class;

  frLocale.LoadDll('FR_Eng.dll'); // load english resources
  ...
  frLocale.UnloadDll; // unload resource DLL and use default .exe resources

  To make the DLL, run mkdll.bat file in this folder, or makeall.bat file
  in the RES folder to make DLLs for all languages.
}

library FR_Rus;


{$R FR_Lng1.RES}
{$R FR_Lng2.RES}
{$R FR_Lng3.RES}
{$R FR_Lng4.RES}
{$R FR_DBop.RES}
{$R FR_Desgn.RES}


begin
end.
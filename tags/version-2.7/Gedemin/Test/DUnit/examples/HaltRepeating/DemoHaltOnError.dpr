{ $Id: DemoHaltOnError.dpr,v 1.1 2006/07/19 02:54:36 judc Exp $ }
{: DUnit: An XTreme testing framework for Delphi programs.
   @author  The DUnit Group.
   @version $Revision: 1.1 $
}
(*
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code is DUnit.
 *
 * The Initial Developers of the Original Code are Kent Beck, Erich Gamma,
 * and Juancarlo A�ez.
 * Portions created The Initial Developers are Copyright (C) 1999-2000.
 * Portions created by The DUnit Group are Copyright (C) 2000-2003.
 * All rights reserved.
 *
 * Contributor(s):
 * Kent Beck <kentbeck@csi.com>
 * Erich Gamma <Erich_Gamma@oti.com>
 * Juanco A�ez <juanco@users.sourceforge.net>
 * Chris Morris <chrismo@users.sourceforge.net>
 * Jeff Moore <JeffMoore@users.sourceforge.net>
 * Uberto Barbini <uberto@usa.net>
 * Kris Golko <neuromancer@users.sourceforge.net>
 * The DUnit group at SourceForge <http://dunit.sourceforge.net>
 *
 *)

{$IFDEF LINUX}
{$DEFINE DUNIT_CLX}
{$ENDIF}

{ Define DUNIT_CLX for project to use D6+ CLX }

program DemoHaltOnError;

uses
{$IFDEF FASTMM}
  {$IFNDEF VER180}
    {$IFNDEF CLR}
      FastMM4,
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
  SysUtils,
  TestFramework,
  TestExtensions,
{$IFDEF DUNIT_CLX}
  QForms,
  QGUITestRunner,
{$ELSE}
  Forms,
  GUITestRunner,
{$ENDIF}
  DemoHaltRepeatingOnError in 'DemoHaltRepeatingOnError.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'DUnit Tests';
  TGUITestRunner.RunRegisteredTests;
end.


{ $Id: ListTest.dpr,v 1.9 2002/10/02 23:53:41 neuromancer Exp $ }
{: DUnit: An XTreme testing framework for Delphi programs.
   @author  The DUnit Group.
   @version $Revision: 1.9 $
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
 * The Initial Developer of the Original Code are Serge Beaumont,
 * Jeff Moore and Chris Houghten.
 * Portions created The Initial Developers are Copyright (C) 2000.
 * Portions created by The DUnit Group are Copyright (C) 2000.
 * All rights reserved.
 *
 * Contributor(s):
 * Jeff Moore <JeffMoore@users.sourceforge.net>
 * Chris Houghten <choughte@users.sourceforge.net>
 * Serge Beaumont <beaumose@users.sourceforge.net>
 * Kris Golko <neuromancer@users.sourceforge.net>
 * The DUnit group at SourceForge <http://dunit.sourceforge.net>
 *)

{$IFDEF LINUX}
{$DEFINE DUNIT_CLX}
{$ENDIF}
program ListTest;

uses
  TestFramework,
{$IFDEF DUNIT_CLX}
  QGUITestRunner,
{$ELSE}
  GUITestRunner,
{$ENDIF}
  TListTestCase in 'TListTestCase.pas';

{$R *.res}

begin
  TGUITestRunner.runRegisteredTests;
end.

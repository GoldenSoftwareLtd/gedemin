..:: TToolbar 2000 Skin+ & Patch for Toolbar 2000 Components ::..
          ..:: (C) Haralabos Michael 2001-2002 ::..

Homepage - http://www.flatstyle2k.net/tbskin/
Newsgroup - news://news.jrsoftware.org/jrsoftware.toolbar2000.thirdparty

--
 - What is it ? -
--

TTBSkin+ is a component which allowing current users of Toolbar 2000 
Components (By Jordan Russell http://www.jrsoftware.org/) to use additional "Skins". 
It also includes a couple enhacements like "Vertical Docked Captions" or 
"Non Overlapping Popups" and also the ability to create "Fully Customizable Colorsets".

--
 - Supports -
--

Skins:
1) tbsDisabled (Default toolbar 2000, disables Patch code)
2) tbsOfficeXP (Office XP Style)
3) tbsWindowsXP (Windows XP Style)
4) tbsNativeXP (Windows XP Native Support)

ColorSets:
1) tbcOfficeXP (Office XP Colorset, with run-time scheme support)
1) tbcWindowsXP (Windows XP Colorset, with run-time scheme support)
1) tbcCustom (Your own Custom Colorset)

ColorSet Colors:
1) cFace (Toolbar color when it's a Menubar)
2) cPopup (The background color of the TTBPopup/Sublink)
3) cBorder (The color of the popup borders)
4) cToolbar (Toolbar color when it's not a Menubar)
5) cDragHandle (The color of the "Drag Handle")
6) cImageList (Background color of the Imagelist gutter)
7) cImgListShadow (Imagelist Image Shadow when the item is selected)
8) cSelBar (Selection color of the item when it's on a toolbar)
9) cSelBarBorder (Selection border color the item when it's on a toolbar)
10) cSelItem (Selection color of the item when it's on a Sublink or TTBPopup)
11) cSelItemBorder, (Selection border color of the item when it's on a Sublink or TTBPopup)
12) cSelPushed (Selection color of the item when it's pushed/clicked)
13) cSelPushedBorder (Selection border color of the item when it's pushed/clicked)
14) cSeparator (The color of the Separator)
15) cChecked (The color of a Checked Item)
16) cCheckedOver (Color of a "Checked" Item when the mouse is over it)
17) cDockBorderTitle (Floating Dock outer border color)
18) cDockBorderIn (Floating Dock inner border color)
19) cDockBorderOut (Floating Dock outer border color)
20) tcGradStart (The starting gradient color)
21) tcGradEnd (The ending gradient color)
22) cPopupGradStart (The starting gradient color of the popup background)
23) cPopupGradEnd (The ending gradient color of the popup background)
24) cImgGradStart (The starting gradient color of the Images background)
25) cImgGradEnd (The ending gradient color of the Images background)

Options:
1) tboPopupOverlap (Controlling if the TTBPopup/Sublink will overlap along anotherTTBPopup/Sublink)
2) tboShadow (Enables OfficeXP like Shadows for Popups & SubLinks)
3) tboDockedCaptions (Enabling this will replace the "Drag" of a Vertical Toolbar with the "Caption" of the toolbar)
4) tboMenuTBColor (Sets the Menu Toolbars Color to use the "tcToolbar" color instead of BtnFace. -Only OfficeXP Skin-)
5) tboGradSelItem (Draw the selected items of the popup with gradient)
   (tcGradStart and tcGrandEnd for custom Gradient in Color property)
6) tboBlendedImages (Blends the imagelist with the toolbar color/background)

property IsDefaultSkin:
If "IsDefaultSkin" is True then all the toolbars/popups etc
that they don't have any Skin Component assigned (through
the "Skin" Property) will use the settings assigned to that 
Skin Component.

Gradient:
1) tbgTopBottom (Draws the Item Gradient bar from Top(Start Color) To Bottom(End Color))
1) tbgLeftRight (Draws the Item Gradient bar from Left(Start Color) To Right(End Color))

ImgBackStyle: 
1) tbimsDefault (The default images background style of the selected Skin)
2) tbimsGradVert (Draws the images background in gradient vertical)
3) tbimsGradHorz (Draws the images background in gradient horizontal)

PopupStyle: 
1) tbpsDefault (The default popup style of the selected Skin)
2) tbpsGradVert (Draws the popup background in gradient vertical)
3) tbpsGradHorz (Draws the popup background in gradient horizontal)

ShadowStyle:
1) sOfficeXP (Emulates the OfficeXP Shadows)
2) sWindowsXP (Emulates the WindowsXP Shadows)

Misc:
1) CaptionFont is the font which it will be displayed on the Caption
   bars of an Undocked toolbar or a Docked Toolbar(when tboDockedCaptions is setted)
2) ParentFont will reset the CaptionFont

--
 - Installation -
--

Copy all the files into you TB2k\Source folder.
Then open an MS-Dos Prompt window and go into TB2k\Source folder and
To install the patch execute "dopatch.bat"

After installing the Patch you must re-compile the Toolbar 2000 
package in order to add TTBSkin into your delphi component pallete.

Step Installation:
1) Get/Download Toolbar 2000 & TBSkin+
2) Unpack Toolbar 2000
3) Unpack TBSkin+ into Toolbar's 2000 Source Folder
4) Execute "DoPatch.bat"
5) Then install the Toolbar 2000 packages

Warning: Do not PATCH over the PATCH! 
(That means there isn't a method for upgrade
 a already patched version, you must do it from
 the beggining)

--
 - Uninstallation -
--

(The easiest way is to have a copy of the TB2k\Source folder)

To uninstall the patch execute the "unpatch.bat".
After installing the Patch you must re-compile the Toolbar 2000 
package in order to remove TTBSkin into your delphi component pallete.

--
 - Contributors - 
--

- See inside TBSkinPlus.Pas source -

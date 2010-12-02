kbmMemTable / kbmMemTable Pro v. 5.52 (Feb. 25 2007)
=========================================================================
An inmemory temporary table.

Copyright 1999-2007 Kim Bo Madsen/Components4Developers
All rights reserved.

BEFORE USING THIS COMPONENT, YOU ARE REQUESTED TO READ ALL OF THIS TEXT
DOCUMENT AND SPECIALLY TO NOTICE AND ACCEPT THE DISCLAIMER.

LICENSE AGREEMENT
PLEASE NOTE THAT THE LICENSE AGREEMENT HAS CHANGED!!! 25. Jul. 2003

You are allowed to use this component in any application for free.
You are NOT allowed to claim that you have created this component or to
copy its code into your own component and claim that it was your idea/code.

-----------------------------------------------------------------------------------
IM OFFERING THIS FOR FREE FOR YOUR CONVINIENCE, BUT
YOU ARE REQUIRED TO SEND AN E-MAIL ABOUT WHAT PROJECT THIS COMPONENT (OR DERIVED VERSIONS)
IS USED FOR !
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
PLEASE NOTE THE FOLLOWING CHANGES TO THE LICENSE AGREEMENT:
1. Aug. 2003
Parts of the package which constitute kbmMemTable Pro is not open source nor freware.
These parts may not be disclosed to any 3rdparty without prior written agreement with
Components4Developers.
Discussion in public fora about the algorithms used in those parts is not permitted.
Each unit which is under that part of the license agreement have it specifically
written in the top of the unit file as part of its own specific license agreement.

25. Jul. 2003
You are allowed to use this component in any application for free.
You are not allowed to use the knowledge gained from this component or any code
from it for creating applications or developer tools directly competing with any
C4D tool unless specifically approved in writing by C4D.
If you choose to make developer tools containing this component you are required to
acknowledge that visually in the application/tool/library f.ex. in the About box,
or in the beginning of the central documentation for the application/tool/library.
The acknowledgement must contain a link or reference to www.components4developers.com
You dont need to state my name in your end user application, unless its covered under
the previous phrase, although it would be appreciated if you do.
-----------------------------------------------------------------------------------

If you find bugs or alter the component, please DONT just send the corrected/new
code out on the internet, but instead send it to me, so I can put it into the
official version. You will be acredited if you do so.

DISCLAIMER
By using this component or parts theirof you are accepting the full
responsibility of the use. You are understanding that the author cant be
made responsible in any way for any problems occuring using this component.
You also recognize the author as the creator of this component and agrees
not to claim otherwize!

Please forward corrected versions (source code ONLY!), comments,
and emails saying you are using it for this or that project to:
           kbm@components4developers.com

Latest version can be found at:
           http://www.components4developers.com

To use it, some fields has to be defined, either programmatically by
setting up fielddefs, or by double-clicking kbmMemTable icon on the
form.
  - Rightclick to get menu.
  - Choose New field.
  - Specify field name and type + optionally size (only for strings).
  - Make sure that fieldtype is Data.
  - Add more optional data, calculated or lookup fields if needed.
The field definitions will be stored on the form automatically if created
this way.

Use it like any other TTable. E.g.: Open, Add records, Read records, Close.
Remember that when the close is issued, all records are forgotten, unless
you have manually saved them, or defined a persistent file.

Please see the comments in the start of the component source for what’s
new in this release.

//=============================================================================

Support:
   - Look for new versions at:
        http://www.components4developers.com

   - Check the newsgroups at:
        news://news.components4developers.com

   - Join the memory table community by sending an empty e-mail to:
	memtable-subscribe@onelist.com or use a browser to go to 
        http://www.yahoogroups.com/group/memtable

   - Leave the memory table community by sending an empty e-mail to:
	memtable-unsubscribe@yahoogroups.com

   - For more information about the list, please look at: http://www.Yahoogroups.com/group/memtable


Documentation:
   Please check out the demo projects, and read the comments in the top of the sourcefile.
   Purchase a help file at www.components4developers.com

History:
   Please look in top of the sourcefile, or check the history.txt file.

Contributors:
   Claude Rieth from Computer Team sarl (clrieth@team.lu)
   Wagner ADP (wagner@cads-informatica.com.br)
   Charlie McKeegan from Task Software Limited (charlie@task.co.uk)
   James Baile (James@orchiddata.demon.co.uk)
   Travis Diamond (tdiamond@airmail.net)
   Claudio Driussi (c.driussi@popmail.iol.it)
   Andrius Adamonis (andrius@prototechnika.lt)
   Pascalis Bochoridis from SATO S.A Greece (pbohor@sato.gr}
   Thomas Bogenrieder (tbogenrieder@wuerzburg.netsurf.de)
   Paulo Conzon (paolo.conzon@smc.it)
   Arséne von Wyss (arsene@vonwyss.ch)
   Raymond J. Schappe (rschappe@isthmus-ts.com)
   Bruno Depero (bdepero@usa.net)
   Denis Tsyplakov (den@vrn.sterling.ru)
   Jason Wharton (jwharton@ibobjects.com)
   Paul Moorcroft (pmoor@netspace.net.au)
   Jirí Hostinský (tes@pce.cz)
   Roberto Jimenez (mroberto@jaca.cetuc.puc-rio.br)
   Azuer (blue@nexmil.net)
   Lars Søndergaard (ls@lunatronic.dk)
   Dirk Carstensen (D.Carstensen@FH-Wolfenbuettel.DE)
   I. M. M. Vatopediou (monh@vatopedi.thessal.singular.gr)
   Kanca (kanca@ibm.net)
   Fernando (tolentino@atalaia.com.br)
   Albert Research (albertrs@redestb.es)
   John Knipper (knipjo@altavista.net)
   Vasil (vasils@ru.ru)
   Javier Tari Agullo (jtari@cyber.es)
   Roman Olexa (systech@ba.telecom.sk)
   Sorin Pohontu (spohontu@assist.cccis.ro)
   Edison Mera Menéndez (edmera@yahoo.com)
   Dick Boogaers (d.boogaers@css.nl)
   Stas Antonov (hcat@hypersoft.ru)
   Francisco Reyes (francisco@natserv.com)
   Roman Krejci (info@rksolution.cz)
   Mike Cariotoglou (Mike@singular.gr)
   Reinhard Kalinke (R_Kalinke@compuserve.com)
   Cosmin (cosmin@lycosmail.com)
   M.H. Avegaart (avegaart@mccomm.nl)
   Csehi Andras (acsehi@qsoft.hu)
   Chris G. Royle (cgr@dialabed.co.za)
   Thomas Everth (everth@wave.co.nz)
   Eduardo Costa e Silva (SoftAplic) (eduardo@softaplic.com.br)
   Lester Caine (lester@lsces.globalnet.co.uk)
   Milleder Markus (QI/LSR-Wi) (Markus.Milleder@tenovis.com)
   Wilfried Mestdagh (wilfried_sonal@compuserve.com)
   Jason Mills (jmills@sync-link.com)
   Speets, RCJ (ramon.speets@corusgroup.com)
   Vladimir (grumbler@ekonomik.com.ua)
   Andrew Leiper (Andy@ietgroup.com)
   Yuri Tolsky (ut@tario.net)
   Michael Bonner (michaelbonner@earthlink.net)
   Markus Landwehr (leisys.entwicklung@leisys.de)
   Jeffrey Jones (jonesjeffrey@home.com)
   Hans (hans@hoogstraat.ca)
   Hans-Dieter Karl (hdk@hdkarl.com)
   

You can be added to the list of contributors if you contribute significant code containing enhancements
which will be included in a version of kbmMemTable. You can also be added to this list of other
reasons, like giving an extraordinary good support to other members of the memtable community.

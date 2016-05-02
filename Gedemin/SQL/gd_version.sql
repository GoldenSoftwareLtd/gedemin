
CREATE TABLE fin_versioninfo
(
  id            dintkey,
  versionstring dversionstring,
  releasedate   ddate NOT NULL,
  comment       dtext254
);

ALTER TABLE fin_versioninfo ADD CONSTRAINT fin_pk_versioninfo_id
  PRIMARY KEY (id);

COMMIT;

GRANT SELECT ON fin_versioninfo TO startuser;

COMMIT;

SET TERM ^ ;

CREATE PROCEDURE fin_p_ver_getdbversion
  RETURNS (ID INTEGER, VersionString VARCHAR(20),
    ReleaseDate DATE, Comment VARCHAR(255) CHARACTER SET WIN1251)
AS
BEGIN
  SELECT id, versionstring, releasedate, comment
  FROM fin_versioninfo
  WHERE id = (SELECT MAX(id) FROM fin_versioninfo)
  INTO :ID, :VersionString, :ReleaseDate, :Comment;
END
^

SET TERM ; ^

COMMIT;

GRANT EXECUTE ON PROCEDURE fin_p_ver_getdbversion TO startuser;

COMMIT;

INSERT INTO fin_versioninfo
  VALUES (1, '0000.0000.0001.0000', '01.02.1999', 'Начало...');

INSERT INTO fin_versioninfo
  VALUES (2, '0000.0000.0001.0001', '07.02.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (3, '0000.0000.0001.0002', '08.02.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (4, '0000.0000.0001.0003', '11.02.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (5, '0000.0000.0001.0004', '18.02.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (6, '0000.0000.0001.0005', '27.02.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (7, '0000.0000.0001.0006', '03.03.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (8, '0000.0000.0001.0007', '22.04.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (9, '0000.0000.0001.0008', '23.07.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (10, '0000.0000.0001.0009', '30.07.1999', 'Phone tables added');

INSERT INTO fin_versioninfo
  VALUES (11, '0000.0000.0001.0010', '03.08.1999', 'Icon tables added');

INSERT INTO fin_versioninfo
  VALUES (12, '0000.0001.0000.0001', '19.06.2000', 'Gedemin started');

INSERT INTO fin_versioninfo
  VALUES (13, '0000.0001.0000.0002', '24.06.2000', 'Andreik added ON DELETE clause to FOREIGN KEY defenitions');

INSERT INTO fin_versioninfo
  VALUES (14, '0000.0001.0000.0003', '27.06.2000', '...');

INSERT INTO fin_versioninfo
  VALUES (15, '0000.0001.0000.0004', '10.07.2000', 'Audit levels added by Andreik');

INSERT INTO fin_versioninfo
  VALUES (16, '0000.0001.0000.0005', '03.08.2000', 'Першы кандыдат да выпуску адраснай кнiгi');

INSERT INTO fin_versioninfo
  VALUES (17, '0000.0001.0000.0006', '08.08.2000', 'Другi кандыдат да выпуску адраснай кнiгi');

INSERT INTO fin_versioninfo
  VALUES (18, '0000.0001.0000.0007', '09.08.2000', 'Views added');

INSERT INTO fin_versioninfo
  VALUES (19, '0000.0001.0000.0008', '15.08.2000', 'Functions (macros) added');

INSERT INTO fin_versioninfo
  VALUES (20, '0000.0001.0000.0009', '17.08.2000', 'Payment order added');

INSERT INTO fin_versioninfo
  VALUES (21, '0000.0001.0000.0010', '18.08.2000', 'New version');

INSERT INTO fin_versioninfo
  VALUES (22, '0000.0001.0000.0011', '20.08.2000', 'Generators names changed');

INSERT INTO fin_versioninfo
  VALUES (23, '0000.0001.0000.0012', '27.08.2000', 'Next release');

INSERT INTO fin_versioninfo
  VALUES (24, '0000.0001.0000.0014', '28.08.2000', 'Order by added in gd_p_getfolderelement');

INSERT INTO fin_versioninfo
  VALUES (25, '0000.0001.0000.0015', '31.08.2000', 'Some bug base fields added');

INSERT INTO fin_versioninfo
  VALUES (26, '0000.0001.0000.0016', '08.09.2000', 'Interval trees implemented');

INSERT INTO fin_versioninfo
  VALUES (27, '0000.0001.0000.0017', '14.09.2000', 'Desktops implemented');

INSERT INTO fin_versioninfo
  VALUES (28, '0000.0001.0000.0018', '18.09.2000', 'Goods added');

INSERT INTO fin_versioninfo
  VALUES (29, '0000.0001.0000.0019', '28.09.2000', '...');

INSERT INTO fin_versioninfo
  VALUES (30, '0000.0001.0000.0020', '22.10.2000', 'Filters added');

INSERT INTO fin_versioninfo
  VALUES (31, '0000.0001.0000.0021', '26.10.2000', 'First launch of new phone!!!');

INSERT INTO fin_versioninfo
  VALUES (32, '0000.0001.0000.0022', '14.11.2000', 'Berioza 2');

INSERT INTO fin_versioninfo
  VALUES (33, '0000.0001.0000.0023', '30.11.2000', 'Berioza 3');

INSERT INTO fin_versioninfo
  VALUES (34, '0000.0001.0000.0024', '04.12.2000', 'Bank statements to Berioza');

INSERT INTO fin_versioninfo
  VALUES (35, '0000.0001.0000.0025', '27.12.2000', 'Big clean up!');

INSERT INTO fin_versioninfo
  VALUES (36, '0000.0001.0000.0026', '12.02.2001', 'My birthday :)');

INSERT INTO fin_versioninfo
  VALUES (37, '0000.0001.0000.0027', '11.03.2001', 'Bankstatement fields added. Upgrade is mandatory.');

INSERT INTO fin_versioninfo
  VALUES (38, '0000.0001.0000.0028', '24.04.2001', 'Cattle tables added.');

INSERT INTO fin_versioninfo
  VALUES (39, '0000.0001.0000.0029', '10.11.2001', 'New operations');

INSERT INTO fin_versioninfo
  VALUES (40, '0000.0001.0000.0030', '12.02.2002', 'My birthday again :(');

INSERT INTO fin_versioninfo
  VALUES (41, '0000.0001.0000.0031', '08.07.2002', 'Triggers for system tables added');

INSERT INTO fin_versioninfo
  VALUES (42, '0000.0001.0000.0032', '08.11.2002', 'GD_JOURNAL has got its final state');

INSERT INTO fin_versioninfo
  VALUES (43, '0000.0001.0000.0033', '13.01.2003', 'ST_SETTINGSTATE for installer was added');

INSERT INTO fin_versioninfo
  VALUES (44, '0000.0001.0000.0034', '04.02.2003', 'Support financial report (add tables gd_tax..)');

INSERT INTO fin_versioninfo
  VALUES (45, '0000.0001.0000.0035', '23.04.2003', 'WG_POSITION added');

INSERT INTO fin_versioninfo
  VALUES (46, '0000.0001.0000.0036', '08.06.2003', 'employee becomes a children to department');

INSERT INTO fin_versioninfo
  VALUES (47, '0000.0001.0000.0045', '18.08.2003', 'Changed domain DGOLDQUANTITY');

INSERT INTO fin_versioninfo
  VALUES (48, '0000.0001.0000.0046', '22.08.2003', 'Changed trigger INV_AU_MOVEMENT ');

INSERT INTO fin_versioninfo
  VALUES (49, '0000.0001.0000.0047', '03.09.2003', 'Added fields into AT_SETTING');

INSERT INTO fin_versioninfo
  VALUES (50, '0000.0001.0000.0048', '20.09.2003', 'Computed indice added');

INSERT INTO fin_versioninfo
  VALUES (51, '0000.0001.0000.0049', '22.09.2003', 'Additional fields into gd_company added');

INSERT INTO fin_versioninfo
  VALUES (52, '0000.0001.0000.0052', '10.10.2003', 'Block');

INSERT INTO fin_versioninfo
  VALUES (53, '0000.0001.0000.0061', '09.12.2003', 'Additional fields into inv_balanceoption added');

INSERT INTO fin_versioninfo
  VALUES (54, '0000.0001.0000.0062', '19.12.2003', 'DataType field into gd_const added');

INSERT INTO fin_versioninfo
  VALUES (55, '0000.0001.0000.0063', '07.01.2004', 'Some triggers removed');

INSERT INTO fin_versioninfo
  VALUES (56, '0000.0001.0000.0064', '12.01.2004', 'Column RATE was added in BN_BANKSTATEMENT');

INSERT INTO fin_versioninfo
  VALUES (57, '0000.0001.0000.0066', '12.01.2004', 'Column ACCOUNTKEY was added in BN_BANKSTATEMENTLINE');

INSERT INTO fin_versioninfo
  VALUES (58, '0000.0001.0000.0068', '18.01.2004', 'Column FIXLENGTH was added in GD_LASTNUMBER');

INSERT INTO fin_versioninfo
  VALUES (59, '0000.0001.0000.0085', '17.06.2004', 'New general ledger');

INSERT INTO fin_versioninfo
  VALUES (60, '0000.0001.0000.0086', '28.06.2004', 'FIX gd_taxtype');

INSERT INTO fin_versioninfo
  VALUES (61, '0000.0001.0000.0087', '28.07.2004', 'Add EQ');

INSERT INTO fin_versioninfo
  VALUES (62, '0000.0001.0000.0090', '08.12.2004', 'Fix inv_price');

INSERT INTO fin_versioninfo
  VALUES (63, '0000.0001.0000.0091', '10.02.2005', 'Modify block triggers');

INSERT INTO fin_versioninfo
  VALUES (64, '0000.0001.0000.0092', '01.03.2005', 'Sync triggers procedures changed');

INSERT INTO fin_versioninfo
  VALUES (65, '0000.0001.0000.0093', '22.03.2005', 'Fixed some errors');

INSERT INTO fin_versioninfo
  VALUES (66, '0000.0001.0000.0094', '22.03.2005', 'Fixed some errors');

INSERT INTO fin_versioninfo
  VALUES (67, '0000.0001.0000.0095', '22.03.2005', 'Fixed some errors');

INSERT INTO fin_versioninfo
  VALUES (68, '0000.0001.0000.0096', '12.04.2005', 'Fixed some errors');

INSERT INTO fin_versioninfo
  VALUES (69, '0000.0001.0000.0097', '10.10.2005', 'Minor changes');

INSERT INTO fin_versioninfo
  VALUES (70, '0000.0001.0000.0098', '10.01.2006', 'Minor changes');

INSERT INTO fin_versioninfo
  VALUES (71, '0000.0001.0000.0099', '15.03.2006', 'Tables for SQL monitor added');

INSERT INTO fin_versioninfo
  VALUES (72, '0000.0001.0000.0100', '17.03.2006', 'Type of description field of goodgroup has been changed');

INSERT INTO fin_versioninfo
  VALUES (73, '0000.0001.0000.0101', '17.04.2006', 'Bankbranch field added');

INSERT INTO fin_versioninfo
  VALUES (74, '0000.0001.0000.0102', '04.05.2006', 'Bankbranch field added to bankstatement');

INSERT INTO fin_versioninfo
  VALUES (75, '0000.0001.0000.0103', '30.05.2006', 'Employee branch added into Explorer');

INSERT INTO fin_versioninfo
  VALUES (76, '0000.0001.0000.0104', '18.09.2006', 'Ability to exclude some document types from block period added');

INSERT INTO fin_versioninfo
  VALUES (77, '0000.0001.0000.0105', '31.07.2006', 'Add fields from AC_RECORD into AC_ENTRY');

INSERT INTO fin_versioninfo
  VALUES (78, '0000.0001.0000.0106', '15.09.2006', 'Change StoredProc AC_CIRCULATIONLIST');

INSERT INTO fin_versioninfo
  VALUES (79, '0000.0001.0000.0107', '27.10.2006', 'Исправлена процедура AC_ACCOUNTEXSALDO');

INSERT INTO fin_versioninfo
  VALUES (80, '0000.0001.0000.0108', '09.11.2006', 'Возвращены изменения триггеров - параметр ROWCOUNT - возрващал неверное значение');

INSERT INTO fin_versioninfo
  VALUES (81, '0000.0001.0000.0109', '12.11.2006', 'Добавлена процедура INV_GETCARDMOVEMENT для ускорения вывода остатков на дату');

INSERT INTO fin_versioninfo
  VALUES (82, '0000.0001.0000.0110', '24.11.2006', 'Пересчитываем складские остатки после восстановления складских триггеров');

INSERT INTO fin_versioninfo
  VALUES (84, '0000.0001.0000.0112', '03.01.2007', 'Fixed triggers for FireBird 2.0');

INSERT INTO fin_versioninfo
  VALUES (85, '0000.0001.0000.0113', '20.01.2007', 'Stripped security descriptors from rp_reportgroup');

INSERT INTO fin_versioninfo
  VALUES (86, '0000.0001.0000.0114', '22.01.2007', 'surname field of gd_people became not null');

INSERT INTO fin_versioninfo
  VALUES (87, '0000.0001.0000.0115', '24.01.2007', 'Fixed block and GD_AU_DOCUMENT triggers');

INSERT INTO fin_versioninfo
  VALUES (88, '0000.0001.0000.0116', '28.01.2007', 'Some internal changes');

INSERT INTO fin_versioninfo
  VALUES (89, '0000.0001.0000.0117', '31.01.2007', 'Some internal changes');

INSERT INTO fin_versioninfo
  VALUES (90, '0000.0001.0000.0118', '04.02.2007', 'Some internal changes');

INSERT INTO fin_versioninfo
  VALUES (91, '0000.0001.0000.0119', '26.02.2007', 'Some internal changes');

INSERT INTO fin_versioninfo
  VALUES (92, '0000.0001.0000.0120', '22.04.2007', 'GD_P_GETRUID changed');

INSERT INTO fin_versioninfo
  VALUES (93, '0000.0001.0000.0121', '02.05.2007', 'RUID changed');

INSERT INTO fin_versioninfo
  VALUES (94, '0000.0001.0000.0122', '07.05.2007', 'Some internal changes');

INSERT INTO fin_versioninfo
  VALUES (95, '0000.0001.0000.0123', '30.06.2007', 'Add generators');

INSERT INTO fin_versioninfo
  VALUES (96, '0000.0001.0000.0124', '3.08.2007', 'Add barcode indices');

INSERT INTO fin_versioninfo
  VALUES (97, '0000.0001.0000.0125', '4.10.2007', 'Add check constraints');

INSERT INTO fin_versioninfo
  VALUES (98, '0000.0001.0000.0126', '22.10.2007', 'GD_AU_DOCUMENT');

INSERT INTO fin_versioninfo
  VALUES (100, '0000.0001.0000.0127', '16.01.2008', 'inv_balanceoption');

INSERT INTO fin_versioninfo
  VALUES (101, '0000.0001.0000.0128', '10.06.2008', 'FastReport4');

/*
INSERT INTO fin_versioninfo
  VALUES (102, '0000.0001.0000.0134', '09.07.2008', 'Добавлены RPL таблицы');

INSERT INTO fin_versioninfo
  VALUES (103, '0000.0001.0000.0135', '15.10.2008', 'Добавлен расчет сальдо по проводкам');

INSERT INTO fin_versioninfo
  VALUES (104, '0000.0001.0000.0136', '19.12.2008', 'Добавлено поле OKULP в таблицу GD_COMPANYCODE');

INSERT INTO fin_versioninfo
  VALUES (105, '0000.0001.0000.0137', '12.01.2009', 'Добавлено поле ISINTERNAL в таблицу AC_TRANSACTION для определения внутренних проводок');

INSERT INTO fin_versioninfo
  VALUES (106, '0000.0001.0000.0138', '25.04.2009', 'Проставлены пропущенные гранты');
*/

INSERT INTO fin_versioninfo
  VALUES (107, '0000.0001.0000.0139', '07.09.2009', 'GD_SQL_HISTORY table added and other changes');

INSERT INTO fin_versioninfo
  VALUES (108, '0000.0001.0000.0140', '09.07.2008', 'Добавлены RPL таблицы');

INSERT INTO fin_versioninfo
  VALUES (109, '0000.0001.0000.0141', '15.10.2008', 'Добавлен расчет сальдо по проводкам');

INSERT INTO fin_versioninfo
  VALUES (110, '0000.0001.0000.0142', '19.12.2008', 'Добавлено поле OKULP в таблицу GD_COMPANYCODE');

INSERT INTO fin_versioninfo
  VALUES (111, '0000.0001.0000.0143', '12.01.2009', 'Добавлено поле ISINTERNAL в таблицу AC_TRANSACTION для определения внутренних проводок');

INSERT INTO fin_versioninfo
  VALUES (112, '0000.0001.0000.0144', '25.04.2009', 'Проставлены пропущенные гранты');


INSERT INTO fin_versioninfo
  VALUES (114, '0000.0001.0000.0145', '25.09.2009', 'Storage being converted into new data structures');
  
INSERT INTO fin_versioninfo
  VALUES (115, '0000.0001.0000.0146', '08.03.2010', 'Editorkey and editiondate fields were added to storage table');

INSERT INTO fin_versioninfo
  VALUES (116, '0000.0001.0000.0147', '26.04.2010', 'Storage tree is not a lb-rb tree any more');
  
INSERT INTO fin_versioninfo 
  VALUES (117, '0000.0001.0000.0148', '27.04.2010', 'Добавлен индекс на ac_entry_balance.accountkey');

INSERT INTO fin_versioninfo 
  VALUES (118, '0000.0001.0000.0149', '22.05.2010', 'Make all LB indices non unique');

INSERT INTO fin_versioninfo 
  VALUES (119, '0000.0001.0000.0150', '06.06.2010', 'Add FK manager metadata');

INSERT INTO fin_versioninfo
  VALUES (120, '0000.0001.0000.0151', '22.06.2010', 'Added locking into LBRB tree');

INSERT INTO fin_versioninfo
  VALUES (121, '0000.0001.0000.0152', '26.07.2010', 'Added DEFAULT 0 to boolean domains');

INSERT INTO fin_versioninfo
  VALUES (122, '0000.0001.0000.0153', '12.08.2010', 'IsCheckNumber now allows 4 possible values');

INSERT INTO fin_versioninfo
  VALUES (123, '0000.0001.0000.0154', '23.08.2010', 'Correct rp_x_reportgroup_lrn index');

INSERT INTO fin_versioninfo
  VALUES (124, '0000.0001.0000.0155', '23.08.2010', 'Correct rp_x_reportgroup_lrn index #2');

INSERT INTO fin_versioninfo
  VALUES (125, '0000.0001.0000.0156', '30.09.2010', 'Strategy for LB-RB tree widening has been changed');

INSERT INTO fin_versioninfo
  VALUES (126, '0000.0001.0000.0157', '05.11.2010', 'Relation field BN_BANKSTATEMENTLINE.COMMENT has been extended');

INSERT INTO fin_versioninfo
  VALUES (127, '0000.0001.0000.0158', '08.11.2010', 'Replacing references to xdeStart, xdeFinish components across macros');

INSERT INTO fin_versioninfo
  VALUES (128, '0000.0001.0000.0159', '16.11.2010', 'Replacing references to xdeStart, xdeFinish components across macros #2');

INSERT INTO fin_versioninfo
  VALUES (129, '0000.0001.0000.0160', '17.11.2010', 'Fixed field constraint_uq_count in GD_REF_CONSTRAINTS');

INSERT INTO fin_versioninfo
  VALUES (130, '0000.0001.0000.0161', '19.11.2010', 'Change gd_user_storage trigger');

INSERT INTO fin_versioninfo
  VALUES (131, '0000.0001.0000.0162', '24.03.2011', 'Check to GD_RUID table added.');

INSERT INTO fin_versioninfo
  VALUES (132, '0000.0001.0000.0163', '28.03.2011', 'Modify GD_P_GETRUID procedure.');

INSERT INTO fin_versioninfo
  VALUES (133, '0000.0001.0000.0164', '02.04.2011', 'Check for GD_RUID table modified.');

INSERT INTO fin_versioninfo
  VALUES (134, '0000.0001.0000.0165', '10.05.2011', 'Delete lbrb tree elements from at_settingpos.');

INSERT INTO fin_versioninfo
  VALUES (135, '0000.0001.0000.0166', '11.05.2011', 'Refined triggers for AC_ENTRY, AC_RECORD.');

INSERT INTO fin_versioninfo
  VALUES (136, '0000.0001.0000.0167', '12.01.2012', 'Add field modalpreview to the table rp_reportlist.');

INSERT INTO fin_versioninfo
  VALUES (137, '0000.0001.0000.0168', '17.01.2012', 'ALTER DOMAIN USR$FA_CORRECTCOEFF.');

INSERT INTO fin_versioninfo
  VALUES (138, '0000.0001.0000.0169', '07.03.2012', 'Add runonlogin field to evt_macroslist table.');

INSERT INTO fin_versioninfo
  VALUES (139, '0000.0001.0000.0170', '09.03.2012', 'Add runonlogin field to evt_macroslist table. Part #2.');

INSERT INTO fin_versioninfo
  VALUES (140, '0000.0001.0000.0171', '14.03.2012', 'Trigger AC_AIU_ACCOUNT_CHECKALIAS added.');

INSERT INTO fin_versioninfo
  VALUES (141, '0000.0001.0000.0172', '14.03.2012', 'Trigger AC_AIU_ACCOUNT_CHECKALIAS added. Part #2.');

INSERT INTO fin_versioninfo
  VALUES (142, '0000.0001.0000.0173', '04.04.2012', 'Trigger GD_AU_DOCUMENTTYPE_MOVEMENT added.');

INSERT INTO fin_versioninfo
  VALUES (143, '0000.0001.0000.0174', '04.04.2012', 'Some minor changes.');

INSERT INTO fin_versioninfo
  VALUES (144, '0000.0001.0000.0175', '04.04.2012', 'Protect system good groups.');

INSERT INTO fin_versioninfo
  VALUES (145, '0000.0001.0000.0176', '05.04.2012', 'Issue 2764.');

INSERT INTO fin_versioninfo
  VALUES (146, '0000.0001.0000.0177', '11.04.2012', 'Delete system triggers of prime tables from at_settingpos.');

INSERT INTO fin_versioninfo
  VALUES (147, '0000.0001.0000.0178', '16.04.2012', 'Delete system metadada of simple tables from at_settingpos.');

INSERT INTO fin_versioninfo
  VALUES (148, '0000.0001.0000.0179', '16.04.2012', 'Delete system triggers of prime tables from at_settingpos. #2');

INSERT INTO fin_versioninfo
  VALUES (149, '0000.0001.0000.0180', '16.04.2012', 'Delete system metadada of simple tables from at_settingpos. #2');

INSERT INTO fin_versioninfo
  VALUES (150, '0000.0001.0000.0181', '16.04.2012', 'Delete system triggers of tabletotable tables from at_settingpos.');

INSERT INTO fin_versioninfo
  VALUES (151, '0000.0001.0000.0182', '16.04.2012', 'Delete system metadada of tree tables from at_settingpos.');

INSERT INTO fin_versioninfo
  VALUES (152, '0000.0001.0000.0183', '20.04.2012', 'Contractorkey field added to the bn_statementline table.');

INSERT INTO fin_versioninfo
  VALUES (153, '0000.0001.0000.0184', '25.04.2012', 'Delete BI5, BU5 triggers.');

INSERT INTO fin_versioninfo
  VALUES (154, '0000.0001.0000.0185', '23.05.2012', 'Delete system metadada of set type from at_settingpos.');

INSERT INTO fin_versioninfo
  VALUES (155, '0000.0001.0000.0186', '23.05.2012', 'Delete system domains from at_settingpos.');

INSERT INTO fin_versioninfo
  VALUES (156, '0000.0001.0000.0187', '31.05.2012', 'Correct gd_ai_goodgroup_protect trigger.');

INSERT INTO fin_versioninfo
  VALUES (157, '0000.0001.0000.0188', '18.07.2012', 'Correct ac_companyaccount triggers.');
  
INSERT INTO fin_versioninfo
  VALUES (158, '0000.0001.0000.0189', '26.09.2012', 'Change way of reports being called from Explorer tree.');  

INSERT INTO fin_versioninfo
  VALUES (159, '0000.0001.0000.0190', '17.10.2012', 'Delete InvCardForm params from userstorage.');
  
INSERT INTO fin_versioninfo
  VALUES (160, '0000.0001.0000.0191', '19.10.2012', 'Corrected inv_bu_movement trigger.');

INSERT INTO fin_versioninfo
  VALUES (161, '0000.0001.0000.0192', '29.10.2012', 'Trigger AC_AIU_ACCOUNT_CHECKALIAS modified.');

INSERT INTO fin_versioninfo
  VALUES (162, '0000.0001.0000.0193', '14.11.2012', 'Delete cbAnalytic from script.');

INSERT INTO fin_versioninfo
  VALUES (163, '0000.0001.0000.0194', '11.04.2013', 'Namespace tables added.');

INSERT INTO fin_versioninfo
  VALUES (164, '0000.0001.0000.0195', '06.05.2013', 'Issue 2846.');

INSERT INTO fin_versioninfo
  VALUES (165, '0000.0001.0000.0196', '08.05.2013', 'Issue 2688.');

INSERT INTO fin_versioninfo
  VALUES (166, '0000.0001.0000.0197', '11.05.2013', 'Added unique constraint on xid, dbid fields to gd_ruid table.');

INSERT INTO fin_versioninfo
  VALUES (167, '0000.0001.0000.0198', '14.05.2013', 'Drop FK to gd_ruid in at_object.');

INSERT INTO fin_versioninfo
  VALUES (168, '0000.0001.0000.0199', '16.05.2013', 'Move subobjects along with a head object.');

INSERT INTO fin_versioninfo
  VALUES (169, '0000.0001.0000.0200', '17.05.2013', 'Added MODIFIED field to AT_OBJECT.');

INSERT INTO fin_versioninfo
  VALUES (170, '0000.0001.0000.0201', '17.05.2013', 'Constraint on at_object changed.');

INSERT INTO fin_versioninfo
  VALUES (171, '0000.0001.0000.0202', '18.05.2013', 'Added unique constraint on xid, dbid fields to gd_ruid table. Attempt #2.');

INSERT INTO fin_versioninfo
  VALUES (172, '0000.0001.0000.0203', '19.05.2013', 'Curr_modified field added to at_object.');

INSERT INTO fin_versioninfo
  VALUES (173, '0000.0001.0000.0204', '20.05.2013', 'Missed editiondate fields added.');

INSERT INTO fin_versioninfo
  VALUES (174, '0000.0001.0000.0205', '05.06.2013', 'Corrections for NS triggers.');

INSERT INTO fin_versioninfo
  VALUES (175, '0000.0001.0000.0206', '08.06.2013', 'Add missing edition date fields #2.');

INSERT INTO fin_versioninfo
  VALUES (176, '0000.0001.0000.0207', '13.06.2013', 'Added trigger to at_object.');

INSERT INTO fin_versioninfo
  VALUES (177, '0000.0001.0000.0208', '14.06.2013', 'Revert last changes.');

INSERT INTO fin_versioninfo
  VALUES (178, '0000.0001.0000.0209', '10.08.2013', 'Added check for account activity.');

INSERT INTO fin_versioninfo
  VALUES (179, '0000.0001.0000.0210', '11.08.2013', 'Added check for account activity #2.');

INSERT INTO fin_versioninfo
  VALUES (180, '0000.0001.0000.0211', '19.08.2013', 'gd_object_dependencies table added.');

INSERT INTO fin_versioninfo
  VALUES (181, '0000.0001.0000.0212', '20.08.2013', 'Issue 1041.');

INSERT INTO fin_versioninfo
  VALUES (182, '0000.0001.0000.0213', '22.08.2013', 'Issue 3218.');

INSERT INTO fin_versioninfo
  VALUES (183, '0000.0001.0000.0214', '31.08.2013', 'Added NS sync tables.');

INSERT INTO fin_versioninfo
  VALUES (184, '0000.0001.0000.0215', '02.09.2013', 'Generator added.');

INSERT INTO fin_versioninfo
  VALUES (185, '0000.0001.0000.0216', '08.09.2013', 'Drop constraint AT_FK_NAMESPACE_SYNC_NSK.');

INSERT INTO fin_versioninfo
  VALUES (186, '0000.0001.0000.0217', '10.09.2013', 'Drop constraint AT_FK_NAMESPACE_SYNC_NSK. Attempt #2.');

INSERT INTO fin_versioninfo
  VALUES (187, '0000.0001.0000.0218', '12.09.2013', 'Modified check constraint on GD_RUID.');

INSERT INTO fin_versioninfo
  VALUES (188, '0000.0001.0000.0219', '14.09.2013', 'Second attempt to drop constraint AT_FK_NAMESPACE_SYNC_NSK.');

INSERT INTO fin_versioninfo
  VALUES (189, '0000.0001.0000.0220', '16.09.2013', 'Change PK on gd_object_dependencies.');

INSERT INTO fin_versioninfo
  VALUES (190, '0000.0001.0000.0221', '23.09.2013', 'Added missed indices to at_namespace tables.');

INSERT INTO fin_versioninfo
  VALUES (191, '0000.0001.0000.0222', '18.10.2013', 'Delete cbAnalytic from Acc_BuildAcctCard.');

INSERT INTO fin_versioninfo
  VALUES (192, '0000.0001.0000.0223', '11.11.2013', 'Change FK for AC_LEDGER_ACCOUNTS.');

INSERT INTO fin_versioninfo
  VALUES (193, '0000.0001.0000.0224', '12.11.2013', 'Corrected triggers for EVT_OBJECT.');

INSERT INTO fin_versioninfo
  VALUES (194, '0000.0001.0000.0225', '26.11.2013', 'RUIDs for gd_storage_data objects.');

INSERT INTO fin_versioninfo
  VALUES (195, '0000.0001.0000.0226', '27.11.2013', 'Add Triggers command into the Explorer tree.');

INSERT INTO fin_versioninfo
  VALUES (196, '0000.0001.0000.0227', '29.11.2013', 'Field changed added to at_namespace.');

INSERT INTO fin_versioninfo
  VALUES (197, '0000.0001.0000.0228', '13.12.2013', 'Help folders added.');

INSERT INTO fin_versioninfo
  VALUES (198, '0000.0001.0000.0229', '12.01.2014', 'Correct old gd_documenttype structure.');

INSERT INTO fin_versioninfo
  VALUES (199, '0000.0001.0000.0230', '10.02.2014', 'New triggers for AC_ENTRY, AC_RECORD.');

INSERT INTO fin_versioninfo
  VALUES (200, '0000.0001.0000.0231', '11.02.2014', 'Restrictions for document date.');

INSERT INTO fin_versioninfo
  VALUES (201, '0000.0001.0000.0232', '24.02.2014', 'Some entry queries have been corrected.');

INSERT INTO fin_versioninfo
  VALUES (202, '0000.0001.0000.0233', '03.03.2014', 'Issue 3323.');

INSERT INTO fin_versioninfo
  VALUES (203, '0000.0001.0000.0234', '05.03.2014', 'Issue 3323. Attempt #2.');
  
INSERT INTO fin_versioninfo
  VALUES (204, '0000.0001.0000.0235', '11.03.2014', 'Issue 3301.');

INSERT INTO fin_versioninfo
  VALUES (205, '0000.0001.0000.0236', '17.03.2014', 'Issue 3330.');

INSERT INTO fin_versioninfo
  VALUES (206, '0000.0001.0000.0237', '17.03.2014', 'Issue 3330. #2.');

INSERT INTO fin_versioninfo
  VALUES (207, '0000.0001.0000.0238', '17.03.2014', 'Triggers for protection of system storage folders.');

INSERT INTO fin_versioninfo
  VALUES (208, '0000.0001.0000.0239', '31.03.2014', 'Introducing AC_INCORRECT_RECORD GTT.');

INSERT INTO fin_versioninfo
  VALUES (209, '0000.0001.0000.0240', '31.03.2014', 'AC_TC_RECORD.');

INSERT INTO fin_versioninfo
  VALUES (210, '0000.0001.0000.0241', '03.04.2014', 'Get back "incorrect" field for ac_record.');

INSERT INTO fin_versioninfo
  VALUES (211, '0000.0001.0000.0242', '04.04.2014', 'Missed grant for AC_INCORRECT_RECORD.');

INSERT INTO fin_versioninfo
  VALUES (212, '0000.0001.0000.0243', '29.04.2014', 'Issue 3373.');

INSERT INTO fin_versioninfo
  VALUES (213, '0000.0001.0000.0244', '22.05.2014', 'Document class can not include a folder.');

INSERT INTO fin_versioninfo
  VALUES (214, '0000.0001.0000.0245', '16.06.2014', 'Add GD_WEBLOG, GD_WEBLOGDATA tables.');

INSERT INTO fin_versioninfo
  VALUES (215, '0000.0001.0000.0246', '02.09.2014', 'gd_x_currrate_fordate index added.');

INSERT INTO fin_versioninfo
  VALUES (216, '0000.0001.0000.0247', '03.09.2014', 'Added command for TgdcCheckConstraint.');

INSERT INTO fin_versioninfo
  VALUES (217, '0000.0001.0000.0248', '06.09.2014', 'MD5 field added to namespace table.');
  
INSERT INTO fin_versioninfo
  VALUES (218, '0000.0001.0000.0249', '28.04.2015', 'Add GD_AUTOTASK, GD_AUTOTASK_LOG tables.');

INSERT INTO fin_versioninfo
  VALUES (219, '0000.0001.0000.0250', '05.06.2015', 'Added COMPUTER field to GD_AUTOTASK.');
  
INSERT INTO fin_versioninfo
  VALUES (220, '0000.0001.0000.0251', '05.06.2015', 'Added PULSE field to GD_AUTOTASK.');
  
INSERT INTO fin_versioninfo
  VALUES (221, '0000.0001.0000.0252', '25.06.2015', 'Added GD_SMTP table.');
  
INSERT INTO fin_versioninfo
  VALUES (222, '0000.0001.0000.0253', '22.07.2015', 'Modified GD_AUTOTASK and GD_SMTP tables.');
  
INSERT INTO fin_versioninfo
  VALUES (223, '0000.0001.0000.0254', '03.08.2015', 'Modified GD_AUTOTASK and GD_SMTP tables. Attempt #2');  
  
INSERT INTO fin_versioninfo
  VALUES (224, '0000.0001.0000.0255', '09.08.2015', 'SMTP servers command has been added to the Explorer.');  

INSERT INTO fin_versioninfo
  VALUES (225, '0000.0001.0000.0256', '17.08.2015', 'Adjust some db fields.');  

INSERT INTO fin_versioninfo
  VALUES (226, '0000.0001.0000.0257', '20.08.2015', 'Check constraint expanded.');  
  
INSERT INTO fin_versioninfo
  VALUES (227, '0000.0001.0000.0258', '31.08.2015', 'GD_DOCUMENTTYPE_OPTION');  
  
INSERT INTO fin_versioninfo
  VALUES (228, '0000.0001.0000.0259', '02.09.2015', 'Correction for GD_DOCUMENTTYPE_OPTION');  
  
INSERT INTO fin_versioninfo
  VALUES (229, '0000.0001.0000.0260', '04.09.2015', 'Correction for GD_DOCUMENTTYPE_OPTION #2');  

INSERT INTO fin_versioninfo
  VALUES (230, '0000.0001.0000.0261', '01.10.2015', 'Correction for GD_DOCUMENTTYPE_OPTION #3');  
  
INSERT INTO fin_versioninfo
  VALUES (231, '0000.0001.0000.0262', '20.10.2015', 'Client address is added to GD_JOURNAL.');  

INSERT INTO fin_versioninfo
  VALUES (232, '0000.0001.0000.0263', '23.10.2015', 'Edition date to GD_DOCUMENTTYPE_OPTION.');  
  
INSERT INTO fin_versioninfo
  VALUES (233, '0000.0001.0000.0264', '09.11.2015', 'XLSX type added.'); 
  
INSERT INTO fin_versioninfo
  VALUES (234, '0000.0001.0000.0265', '14.11.2015', 'Added Reload auto task.');   

INSERT INTO fin_versioninfo
  VALUES (235, '0000.0001.0000.0266', '27.11.2015', 'Added seqid field to gd_object_dependencies table.');   
  
INSERT INTO fin_versioninfo
  VALUES (236, '0000.0001.0000.0267', '02.12.2015', 'https://github.com/GoldenSoftwareLtd/GedeminSalary/issues/208');   
  
INSERT INTO fin_versioninfo
  VALUES (237, '0000.0001.0000.0268', '20.12.2015', 'Delete a record from GD_RUID when deleting AT_NAMESPACE.');   
  
INSERT INTO fin_versioninfo
  VALUES (238, '0000.0001.0000.0269', '21.12.2015', 'Some fixes for CHANGED flag of AT_OBJECT.');   
  
INSERT INTO fin_versioninfo
  VALUES (239, '0000.0001.0000.0270', '29.12.2015', 'AT_OBJECT triggers.');     
  
INSERT INTO fin_versioninfo
  VALUES (240, '0000.0001.0000.0271', '02.01.2016', 'Add edition date field to TgdcSimpleTable.');     
  
INSERT INTO fin_versioninfo
  VALUES (241, '0000.0001.0000.0272', '09.01.2016', 'Second try. Now with triggers disabled.');     
  
INSERT INTO fin_versioninfo
  VALUES (242, '0000.0001.0000.0273', '17.01.2016', 'Nullify objects in at_relation_fields.');     
  
INSERT INTO fin_versioninfo
  VALUES (243, '0000.0001.0000.0274', '24.01.2016', 'Issue when RUIDs of DT differ from GD_RUID record.');     
  
INSERT INTO fin_versioninfo
  VALUES (244, '0000.0001.0000.0275', '28.01.2016', 'Trigger to prevent namespace cyclic dependencies.');     
  
INSERT INTO fin_versioninfo
  VALUES (245, '0000.0001.0000.0276', '12.02.2016', 'Fixed minor bugs.');     
  
INSERT INTO fin_versioninfo
  VALUES (246, '0000.0001.0000.0277', '11.03.2016', 'Fixed minor bugs.');  

INSERT INTO fin_versioninfo
  VALUES (247, '0000.0001.0000.0278', '21.03.2016', 'Added WEB_RELAY table.');  
  
INSERT INTO fin_versioninfo
  VALUES (248, '0000.0001.0000.0279', '11.04.2016', 'Fixed WEB_RELAY table.');  
  
INSERT INTO fin_versioninfo
  VALUES (249, '0000.0001.0000.0280', '12.04.2016', 'GD_EMPLOYEE table added.');    
  
INSERT INTO fin_versioninfo
  VALUES (250, '0000.0001.0000.0281', '12.04.2016', 'Correction.');    
  
INSERT INTO fin_versioninfo
  VALUES (251, '0000.0001.0000.0282', '13.04.2016', 'Rights for GD_EMPLOYEE.');    
  
INSERT INTO fin_versioninfo
  VALUES (252, '0000.0001.0000.0283', '13.04.2016', 'at_aiu_namespace_link fixed.');    
  
INSERT INTO fin_versioninfo
  VALUES (253, '0000.0001.0000.0284', '13.04.2016', 'at_aiu_namespace_link fixed #2.');    
  
COMMIT;

CREATE UNIQUE DESC INDEX fin_x_versioninfo_id
  ON fin_versioninfo (id);

COMMIT;

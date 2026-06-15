/* example_ref_table.sql
 *
 * Example reference/lookup table: one row per code value, with a display
 * sort order and an active flag instead of hard deletes.
 *
 * Why it exists:
 *   - Lookup data lives in its own ID range: AUTO_INCREMENT starts at
 *     202100, inside the 10001+ band Fn_Do_Scrub_Ref_Id_Value accepts and
 *     well clear of the 1000000001+ data-table range.
 *   - Ref_Rec_Active retires entries without breaking rows that still
 *     reference them; Ref_Rec_Sort lets display order change without code
 *     changes.
 *
 * Notes:
 *   - Audit timestamps rely on column defaults here - a low-churn lookup
 *     table does not need the trigger treatment example_data_table gets.
 *   - Adjust the `mysql_db` schema name to your target database.
 *
 * See also: example_data_table for the audited data-table pattern.
 */

CREATE TABLE `mysql_db`.`example_ref_table` (
  `Ref_Rec_Id` INT(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique key value ID used to identify each individual record in this table.' ,
  `Ref_Rec_Code` VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'Short code value for this reference entry.' ,
  `Ref_Rec_Desc` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'Display description for this reference entry.' ,
  `Ref_Rec_Sort` SMALLINT UNSIGNED DEFAULT '10110' COMMENT 'The order to display items/records to the user.',
  `Ref_Rec_Active` tinyint unsigned DEFAULT '1' COMMENT '1=this ref record is active; else it is not',
  `Modified_UTC_DateTime` DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) COMMENT 'The UTC DateTime the record was modified.',
  `Created_UTC_DateTime` DATETIME(6) NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT 'The UTC DateTime the record was inserted/saved.' ,
  `Created_UTC_Date` DATE NULL DEFAULT NULL COMMENT 'The UTC Date the record was inserted/saved.  Created_UTC_DateTime is the source.' ,
  `Created_UTC_Time` TIME(6) NULL DEFAULT NULL COMMENT 'The UTC Time the record was inserted/saved.  Created_UTC_DateTime is the source.' ,
  PRIMARY KEY (`Ref_Rec_Id`),
  UNIQUE KEY `Ref_Rec_Id_Index` (`Ref_Rec_Id`) USING BTREE,
  KEY `Created_UTC_DateTime_Index` (`Created_UTC_DateTime`) USING BTREE,
  KEY `Ref_Rec_Sort_Index` (`Ref_Rec_Sort`) USING BTREE,
  KEY `Ref_Rec_Active_Index` (`Ref_Rec_Active`) USING BTREE,
  KEY `Ref_Rec_Code_Index` (`Ref_Rec_Code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=202100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Example reference table: one record for each lookup code value.';

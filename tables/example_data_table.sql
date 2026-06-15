/* example_data_table.sql
 *
 * Example data table showing the house pattern for record tables: an
 * auto-increment ID in the data range, a couple of placeholder attribute
 * columns, and UTC audit timestamps maintained by the BEFORE INSERT/UPDATE
 * triggers below.
 *
 * Why it exists:
 *   - The AUTO_INCREMENT start (1000000001) is the floor of the range
 *     Fn_Do_Scrub_Data_Id_Value validates against, so scrubbed IDs and real
 *     rows can never disagree about what a data ID looks like.
 *   - Created/Modified are stamped in UTC by triggers rather than trusted
 *     from the client; Created_UTC_Date and Created_UTC_Time are split out
 *     of the datetime so date-only queries can use a narrow index.
 *
 * Notes:
 *   - Adjust the `mysql_db` schema name to your target database.
 *
 * See also: example_ref_table for the lookup-table pattern.
 */

CREATE TABLE `mysql_db`.`example_data_table`  (
  `Example_Data_Id_Value` INT(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique key value ID used to identify each individual record in this table.' ,
  `Example_Varchar_Field` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Example string attribute.' ,
  `Example_Yes_No_Flag` TINYINT unsigned DEFAULT '0' COMMENT '1=Yes, 0=No' ,
  `Modified_UTC_DateTime` DATETIME(6) NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT 'The UTC DateTime the record was modified.' ,
  `Created_UTC_DateTime` DATETIME(6) NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT 'The UTC DateTime the record was inserted/saved.' ,
  `Created_UTC_Date` DATE NULL DEFAULT NULL COMMENT 'The UTC Date the record was inserted/saved.  Created_UTC_DateTime is the source.' ,
  `Created_UTC_Time` TIME(6) NULL DEFAULT NULL COMMENT 'The UTC Time the record was inserted/saved.  Created_UTC_DateTime is the source.' ,
  PRIMARY KEY (`Example_Data_Id_Value`) ,
  UNIQUE KEY `Example_Data_Id_Value_Index` (`Example_Data_Id_Value`) USING BTREE ,
  KEY `Created_UTC_DateTime_Index` (`Created_UTC_DateTime`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1000000001 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Example data table demonstrating audit-column triggers.';

-- -----------------------------------------------------------------------------
-- example_data_table_before_insert_trigger
-- Fires:      BEFORE INSERT ON example_data_table
-- Effect:     Stamps Created_UTC_DateTime with UTC_TIMESTAMP(6) and derives
--             Created_UTC_Date and Created_UTC_Time from it.
-- -----------------------------------------------------------------------------

CREATE DEFINER=`admin`@`%` TRIGGER `example_data_table_before_insert_trigger` BEFORE INSERT ON `example_data_table` FOR EACH ROW BEGIN

SET NEW.Created_UTC_DateTime = UTC_TIMESTAMP(6) ;

SET NEW.Created_UTC_Date = CAST(NEW.Created_UTC_DateTime AS DATE) ;

SET NEW.Created_UTC_Time = CAST(NEW.Created_UTC_DateTime AS TIME) ;

END;

-- -----------------------------------------------------------------------------
-- example_data_table_before_update_trigger
-- Fires:      BEFORE UPDATE ON example_data_table
-- Effect:     Stamps Modified_UTC_DateTime with UTC_TIMESTAMP(6).
-- -----------------------------------------------------------------------------

CREATE DEFINER=`admin`@`%` TRIGGER `example_data_table_before_update_trigger` BEFORE UPDATE ON `example_data_table` FOR EACH ROW BEGIN

SET NEW.Modified_UTC_DateTime = UTC_TIMESTAMP(6) ;

END;
/* Fn_Do_Scrub_Data_Id_Value.sql
 *
 * Validates a data-record ID and rejects anything that could be silently
 * misread by MySQL casting rules: digits only, inside the data-table
 * auto-increment range (1000000001-4294967295). Anything else returns NULL.
 *
 * Why it exists:
 *   IDs arrive as strings inside JSON args. A plain CAST would happily wrap,
 *   truncate, or zero out garbage; this refuses such values instead, so a bad
 *   ID surfaces as a structured error at the API layer rather than as a query
 *   against the wrong row.
 *
 * Example:
 *   SELECT Fn_Do_Scrub_Data_Id_Value('1000000001');  -- '1000000001'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Scrub_Data_Id_Value`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Scrub_Data_Id_Value`(v_ID_Val VARCHAR(20)) RETURNS varchar(20) CHARSET utf8mb4
BEGIN

DECLARE v_Min_Id_Value INT UNSIGNED DEFAULT '1000000001' ;
DECLARE v_Max_Id_Value INT UNSIGNED DEFAULT '4294967295' ;

DECLARE v_ID_Val_Unsigned BIGINT UNSIGNED DEFAULT NULL ;

IF (IFNULL(TRIM(v_ID_Val),'') = '') THEN
      RETURN NULL ;
END IF;

IF (TRIM(v_ID_Val) NOT REGEXP '^[0-9]{1,10}$') THEN -- digits only; rejects signs, decimals, and values too long to be in range (no silent CAST wrap/truncation)
      RETURN NULL ;
END IF;

SET v_ID_Val_Unsigned = CAST(TRIM(v_ID_Val) AS UNSIGNED) ;

IF (v_ID_Val_Unsigned BETWEEN v_Min_Id_Value AND v_Max_Id_Value) THEN
      RETURN CAST(v_ID_Val_Unsigned AS CHAR) ;
ELSE
      RETURN NULL ;
END IF;

END

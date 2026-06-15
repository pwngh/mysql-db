/* Fn_Do_Scrub_DateTime_Value.sql
 *
 * Validates a datetime string and returns it in the internal
 * 'YYYY-MM-DD hh:mm:ss[.ffffff]' form, or NULL when it is not a real
 * datetime. Zero dates are rejected; date-only input gains a midnight time.
 *
 * Why it exists:
 *   Same role as Fn_Do_Scrub_Date_Value one level down in precision: the
 *   single entry gate for datetimes, so the datetime display formatters
 *   never see junk strings or zero dates.
 *
 * Notes:
 *   - Microsecond precision is detected per value, so '...19:33:19' and
 *     '...19:33:19.123456' both round-trip without padding or loss.
 *   - Input is truncated to 30 characters before validation.
 *
 * Used by: the Fn_Do_Format_DateTime_* display functions.
 *
 * Example:
 *   SELECT Fn_Do_Scrub_DateTime_Value('2024-03-13 19:33:19');  -- '2024-03-13 19:33:19'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Scrub_DateTime_Value`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Scrub_DateTime_Value`(v_DateTime_Param VARCHAR(80)) RETURNS varchar(30) CHARSET utf8mb4
BEGIN

DECLARE v_DateTime VARCHAR(80) DEFAULT LEFT(TRIM(v_DateTime_Param), 30) ;
DECLARE v_DateTime_6 TINYINT UNSIGNED DEFAULT IF((INSTR(v_DateTime, '.') > 0) OR (CHAR_LENGTH(v_DateTime) > 20), '1', '0') ;

SET v_DateTime = (CASE WHEN (IFNULL(v_DateTime_6,'0') = '1') AND (IFNULL(v_DateTime,'0000-00-00 00:00:00.000000') = '0000-00-00 00:00:00.000000') THEN NULL
                       WHEN (IFNULL(v_DateTime_6,'0') = '1') AND (IFNULL(TRIM(v_DateTime),'0000-00-00 00:00:00.000000') = '0000-00-00 00:00:00.000000') THEN NULL
                       WHEN (IFNULL(v_DateTime_6,'0') = '0') AND (IFNULL(v_DateTime,'0000-00-00 00:00:00') = '0000-00-00 00:00:00') THEN NULL
                       WHEN (IFNULL(v_DateTime_6,'0') = '0') AND (IFNULL(TRIM(v_DateTime),'0000-00-00 00:00:00') = '0000-00-00 00:00:00') THEN NULL
                       ELSE v_DateTime END) ;

IF (DAYNAME(v_DateTime) IS NULL) THEN
      RETURN NULL ;
END IF;


IF (IFNULL(v_DateTime_6,'0') = '1') AND (DAYNAME(CAST(v_DateTime AS DATETIME(6))) IS NULL) THEN
      RETURN NULL ;
END IF;

IF (IFNULL(v_DateTime_6,'0') = '1') THEN
      RETURN CAST(v_DateTime AS DATETIME(6)) ;
END IF;


IF (DAYNAME(CAST(v_DateTime AS DATETIME)) IS NULL) THEN
      RETURN NULL ;
END IF;

RETURN CAST(v_DateTime AS DATETIME) ;

END

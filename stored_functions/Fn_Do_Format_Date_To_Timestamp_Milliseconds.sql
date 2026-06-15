/* Fn_Do_Format_Date_To_Timestamp_Milliseconds.sql
 *
 * Converts a date to a Unix epoch timestamp in milliseconds, taken at
 * midnight in the session time zone. NULL when the input is not a valid
 * date.
 *
 * Why it exists:
 *   JavaScript charting libraries and API clients want epoch milliseconds,
 *   not date strings. Converting in the DB layer keeps that contract next
 *   to the other display conversions instead of half in the application.
 *
 * Notes:
 *   - The result depends on the session time zone, because the date is
 *     interpreted as local midnight before conversion.
 *
 * Example:
 *   SELECT Fn_Do_Format_Date_To_Timestamp_Milliseconds('2024-03-13');  -- '1710288000000' (UTC session)
 */

DROP FUNCTION IF EXISTS `Fn_Do_Format_Date_To_Timestamp_Milliseconds`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Format_Date_To_Timestamp_Milliseconds`(v_Date VARCHAR(80)) RETURNS varchar(80) CHARSET utf8mb4
BEGIN

SET v_Date = (SELECT Fn_Do_Scrub_Date_Value(v_Date)) ;

IF (DAYNAME(v_Date) IS NULL) THEN
      RETURN NULL ;
END IF;

RETURN (SELECT UNIX_TIMESTAMP(CAST(v_Date AS DATE)) * 1000) ;

END

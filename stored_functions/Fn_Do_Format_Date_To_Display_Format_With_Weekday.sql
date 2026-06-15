/* Fn_Do_Format_Date_To_Display_Format_With_Weekday.sql
 *
 * Formats a date with its weekday abbreviation: '2021-02-09' becomes
 * 'Tue, 2-9-2021'. NULL when the input is not a valid date.
 *
 * Why it exists:
 *   The date half of the standard weekday display family - the
 *   Fn_Do_Format_DateTime_Standard_Display_To_Min/_To_Sec functions are the
 *   datetime versions. Formatting in the DB layer keeps the weekday
 *   convention identical across every consumer.
 *
 * Example:
 *   SELECT Fn_Do_Format_Date_To_Display_Format_With_Weekday('2021-02-09');  -- 'Tue, 2-9-2021'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Format_Date_To_Display_Format_With_Weekday`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Format_Date_To_Display_Format_With_Weekday`(v_Date VARCHAR(80)) RETURNS varchar(80) CHARSET utf8mb4
BEGIN

SET v_Date = (SELECT Fn_Do_Scrub_Date_Value(v_Date)) ;

IF (DAYNAME(v_Date) IS NULL) THEN
      RETURN NULL ;
END IF;

RETURN DATE_FORMAT(CAST(v_Date AS DATE), '%a, %c-%e-%Y') ;

END

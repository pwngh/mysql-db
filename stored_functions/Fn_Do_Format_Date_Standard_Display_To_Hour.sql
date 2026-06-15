/* Fn_Do_Format_Date_Standard_Display_To_Hour.sql
 *
 * Formats a datetime as 'DD-MON-YY' plus a compact hour: '13-MAR-24 7p'
 * ('a' = am, 'p' = pm). NULL when the input is not a valid datetime.
 *
 * Why it exists:
 *   The compact-date display with just enough time resolution for activity
 *   lists and dashboards. Lives in the DB layer with the other standard
 *   formats so the single-letter am/pm convention stays consistent
 *   everywhere it appears. Input is scrubbed through
 *   Fn_Do_Scrub_DateTime_Value first.
 *
 * Example:
 *   SELECT Fn_Do_Format_Date_Standard_Display_To_Hour('2024-03-13 19:33:19');  -- '13-MAR-24 7p'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Format_Date_Standard_Display_To_Hour`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Format_Date_Standard_Display_To_Hour`(v_Date VARCHAR(80)) RETURNS varchar(80) CHARSET utf8mb4
BEGIN

SET v_Date = (SELECT Fn_Do_Scrub_DateTime_Value(v_Date)) ;

IF (DAYNAME(v_Date) IS NULL) THEN
      RETURN NULL ;
END IF;

RETURN REPLACE(REPLACE(UPPER(DATE_FORMAT(CAST(v_Date AS DATETIME ), '%e-%b-%y %l%p')), 'AM', 'a'), 'PM', 'p') ;

END

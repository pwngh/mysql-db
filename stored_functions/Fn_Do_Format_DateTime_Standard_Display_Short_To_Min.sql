/* Fn_Do_Format_DateTime_Standard_Display_Short_To_Min.sql
 *
 * Formats a datetime as the short minute-level display:
 * '2024-03-13 19:33:19' becomes 'Mar 13, 2024, 7:33 pm'. NULL when the
 * input is not a valid datetime.
 *
 * Why it exists:
 *   The compact member of the standard datetime display family, for places
 *   where the weekday would be noise. The short As-of and time-zone-prefix
 *   builders compose on top of it.
 *
 * Used by: Fn_Do_As_Of_Display_String_Value_Min,
 *   Fn_Do_Format_DateTime_Time_Zone_Prefix_Display_To_Min.
 *
 * Example:
 *   SELECT Fn_Do_Format_DateTime_Standard_Display_Short_To_Min('2024-03-13 19:33:19');  -- 'Mar 13, 2024, 7:33 pm'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Format_DateTime_Standard_Display_Short_To_Min`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Format_DateTime_Standard_Display_Short_To_Min`(v_DateTime VARCHAR(80)) RETURNS varchar(80) CHARSET utf8mb4
BEGIN

SET v_DateTime = (SELECT Fn_Do_Scrub_DateTime_Value(v_DateTime)) ;

IF (DAYNAME(v_DateTime) IS NULL) THEN
      RETURN NULL ;
END IF;

RETURN REPLACE(REPLACE(DATE_FORMAT(CAST(v_DateTime AS DATETIME), '%b %e, %Y, %l:%i %p'), 'AM', 'am'), 'PM', 'pm') ;

END

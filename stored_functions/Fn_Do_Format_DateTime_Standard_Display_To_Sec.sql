/* Fn_Do_Format_DateTime_Standard_Display_To_Sec.sql
 *
 * Formats a datetime as the weekday second-level display:
 * '2024-03-13 19:33:19' becomes 'Wed, 3-13-2024, 7:33:19 pm'. NULL when the
 * input is not a valid datetime.
 *
 * Why it exists:
 *   The most precise of the standard datetime displays. The JSON API
 *   pattern uses it to stamp Execution_CT_DateTime_Display in every result
 *   and error payload, where second precision earns its keep.
 *
 * Example:
 *   SELECT Fn_Do_Format_DateTime_Standard_Display_To_Sec('2024-03-13 19:33:19');  -- 'Wed, 3-13-2024, 7:33:19 pm'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Format_DateTime_Standard_Display_To_Sec`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Format_DateTime_Standard_Display_To_Sec`(v_DateTime VARCHAR(80)) RETURNS varchar(80) CHARSET utf8mb4
BEGIN

SET v_DateTime = (SELECT Fn_Do_Scrub_DateTime_Value(v_DateTime)) ;

IF (DAYNAME(v_DateTime) IS NULL) THEN
      RETURN NULL ;
END IF;

RETURN REPLACE(REPLACE(DATE_FORMAT(CAST(v_DateTime AS DATETIME), '%a, %c-%e-%Y, %l:%i:%s %p'), 'AM', 'am'), 'PM', 'pm') ;

END

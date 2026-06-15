/* Fn_Do_Format_DateTime_Standard_Display_To_Min.sql
 *
 * Formats a datetime as the weekday minute-level display:
 * '2021-02-09 15:07:41' becomes 'Tue, 2-9-2021, 3:07 pm'. NULL when the
 * input is not a valid datetime.
 *
 * Why it exists:
 *   The standard "full" datetime display, defined in the DB layer so every
 *   consumer renders it the same. Input runs through
 *   Fn_Do_Scrub_DateTime_Value first; only real datetimes get formatted.
 *
 * Relationships:
 *   - Used by: Fn_Do_As_Of_Display_String_Value
 *   - See also: the _To_Sec variant when seconds matter, _Short_To_Min when
 *     the weekday does not
 *
 * Example:
 *   SELECT Fn_Do_Format_DateTime_Standard_Display_To_Min('2021-02-09 15:07:41');  -- 'Tue, 2-9-2021, 3:07 pm'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Format_DateTime_Standard_Display_To_Min`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Format_DateTime_Standard_Display_To_Min`(v_DateTime VARCHAR(80)) RETURNS varchar(80) CHARSET utf8mb4
BEGIN

SET v_DateTime = (SELECT Fn_Do_Scrub_DateTime_Value(v_DateTime)) ;

IF (DAYNAME(v_DateTime) IS NULL) THEN
      RETURN NULL ;
END IF;

RETURN REPLACE(REPLACE(DATE_FORMAT(CAST(v_DateTime AS DATETIME), '%a, %c-%e-%Y, %l:%i %p'), 'AM', 'am'), 'PM', 'pm') ;

END

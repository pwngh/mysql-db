/* Fn_Do_Get_Elapsed_Micro_Time.sql
 *
 * Builds an elapsed-time display string (via SEC_TO_TIME) between two
 * DATETIME(6) values. A NULL or invalid endpoint is replaced with "now"
 * (UTC), so passing (start, NULL) measures time since start.
 *
 * Why it exists:
 *   Every JSON API response carries an Elapsed_Time field, so slow queries
 *   are visible from the client side without server profiling. This builds
 *   that value; the never-NULL contract keeps metadata assembly simple.
 *
 * Used by: Fn_Get_Page_Data / App_Get_Page_Data (execution metadata).
 *
 * Example:
 *   SELECT Fn_Do_Get_Elapsed_Micro_Time(v_Start_UTC_DateTime, NULL);  -- elapsed since start
 */

DROP FUNCTION IF EXISTS `Fn_Do_Get_Elapsed_Micro_Time`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Get_Elapsed_Micro_Time`(v_DateTime_1 DATETIME(6), v_DateTime_2 DATETIME(6)) RETURNS varchar(20) CHARSET utf8mb4
BEGIN

DECLARE v_Seconds DECIMAL(16,6) DEFAULT NULL ;

SET v_DateTime_1 = IF((DAYNAME(v_DateTime_1) IS NULL), UTC_TIMESTAMP(6), v_DateTime_1) ;

SET v_DateTime_2 = IF((DAYNAME(v_DateTime_2) IS NULL), UTC_TIMESTAMP(6), v_DateTime_2) ;

SET v_Seconds = (ABS(TIMESTAMPDIFF(MICROSECOND, v_DateTime_1, v_DateTime_2)) / 1000000) ;

RETURN SEC_TO_TIME(v_Seconds) ;

END

/* Fn_Do_Get_CT_DateTime.sql
 *
 * Returns "now" in US Central Time as 'YYYY-MM-DD hh:mm:ss'.
 *
 * Why it exists:
 *   Storage is UTC; display defaults to US Central (the same default
 *   Fn_Do_Scrub_Time_Zone_Value applies). The JSON API metadata stamps
 *   execution time in CT, and this is the one place that conversion is
 *   written down.
 *
 * Notes:
 *   - Needs the MySQL time-zone tables loaded (CONVERT_TZ with named zones).
 *
 * Example:
 *   SELECT Fn_Do_Get_CT_DateTime();  -- '2024-03-13 14:33:19'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Get_CT_DateTime`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Get_CT_DateTime`() RETURNS varchar(80) CHARSET utf8mb4
BEGIN

RETURN CAST(CONVERT_TZ(UTC_TIMESTAMP, 'UTC', 'America/Chicago') AS DATETIME) ;

END

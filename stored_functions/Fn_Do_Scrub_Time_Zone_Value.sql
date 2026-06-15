/* Fn_Do_Scrub_Time_Zone_Value.sql
 *
 * Maps common US time-zone spellings ('CST', 'ET', 'Pacific', ...) to the
 * IANA zone names CONVERT_TZ actually understands. Empty input defaults to
 * 'America/Chicago'.
 *
 * Why it exists:
 *   Users and upstream systems send zone abbreviations; MySQL's time-zone
 *   tables want canonical names. Centralizing the alias map means every
 *   zone-aware display function accepts the same loose inputs, and the
 *   system-wide default (US Central) is set in exactly one place.
 *
 * Notes:
 *   - Unrecognized values pass through trimmed rather than returning NULL:
 *     a valid IANA name missing from the alias map should still reach
 *     CONVERT_TZ.
 *
 * Used by: the As-of display builders and
 *   Fn_Do_Format_DateTime_Time_Zone_Prefix_Display_To_Min.
 *
 * Example:
 *   SELECT Fn_Do_Scrub_Time_Zone_Value('ET');  -- 'America/New_York'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Scrub_Time_Zone_Value`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Scrub_Time_Zone_Value`(v_Time_Zone VARCHAR(80)) RETURNS varchar(80) CHARSET utf8mb4
BEGIN

RETURN (CASE WHEN (IFNULL(TRIM(v_Time_Zone),'') = '') THEN 'America/Chicago'
             WHEN (IFNULL(TRIM(v_Time_Zone),'') IN ('America/Anguilla','Puerto_Rico','AST')) THEN 'America/Anguilla'
             WHEN (IFNULL(TRIM(v_Time_Zone),'') IN ('America/New_York','Eastern','EST','EDT','ET')) THEN 'America/New_York'
             WHEN (IFNULL(TRIM(v_Time_Zone),'') IN ('America/Chicago','Central','CST','CDT','CT')) THEN 'America/Chicago'
             WHEN (IFNULL(TRIM(v_Time_Zone),'') IN ('America/Denver','Mountain','MST','MDT','MT')) THEN 'America/Denver'
             WHEN (IFNULL(TRIM(v_Time_Zone),'') IN ('America/Los_Angeles','Pacific','PST','PDT','PT')) THEN 'America/Los_Angeles'
             WHEN (IFNULL(TRIM(v_Time_Zone),'') IN ('America/Anchorage','Alaska','AKST','AKDT')) THEN 'America/Anchorage'
             WHEN (IFNULL(TRIM(v_Time_Zone),'') IN ('Pacific/Honolulu','Hawaii','HST','HAST','HADT')) THEN 'Pacific/Honolulu'
             ELSE TRIM(v_Time_Zone) END) ;

END

/* Fn_Do_Scrub_Mac_Address_Value.sql
 *
 * Trims a MAC-address string; NULL when empty. The address format itself is
 * not validated - this is a storage scrub, not a syntax check.
 *
 * Why it exists:
 *   Same reasoning as Fn_Do_Scrub_IP_Address_Value: every inbound value goes
 *   through a named scrub at the boundary, and the dedicated function gives
 *   stricter validation a place to live if it is ever required.
 *
 * Example:
 *   SELECT Fn_Do_Scrub_Mac_Address_Value(' 00:1A:2B:3C:4D:5E ');  -- '00:1A:2B:3C:4D:5E'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Scrub_Mac_Address_Value`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Scrub_Mac_Address_Value`(v_Str VARCHAR(80)) RETURNS varchar(80) CHARSET utf8mb4
BEGIN

RETURN (CASE WHEN (v_Str IS NULL) THEN NULL
             WHEN (TRIM(TRIM(v_Str)) = '') THEN NULL
             ELSE TRIM(TRIM(v_Str))
             END) ;

END

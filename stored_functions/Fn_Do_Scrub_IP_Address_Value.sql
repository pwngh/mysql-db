/* Fn_Do_Scrub_IP_Address_Value.sql
 *
 * Trims an IP-address string; NULL when empty. The address format itself is
 * not validated - this is a storage scrub, not a syntax check.
 *
 * Why it exists:
 *   Keeps IP handling on the same path as every other inbound value: one
 *   named scrub call at the boundary. Naming the intent at the call site
 *   also gives format validation an obvious home if it is needed later.
 *
 * See also: Fn_Do_Scrub_Mac_Address_Value, the same contract for MACs.
 *
 * Example:
 *   SELECT Fn_Do_Scrub_IP_Address_Value(' 10.0.0.1 ');  -- '10.0.0.1'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Scrub_IP_Address_Value`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Scrub_IP_Address_Value`(v_Str VARCHAR(255)) RETURNS varchar(255) CHARSET utf8mb4
BEGIN

RETURN (CASE WHEN (v_Str IS NULL) THEN NULL
             WHEN (TRIM(TRIM(v_Str)) = '') THEN NULL
             ELSE TRIM(TRIM(v_Str))
             END) ;

END

/* Fn_Do_Get_Random_Process_Key.sql
 *
 * Generates a random integer key (10000-4294967295) for tagging a process
 * run, so rows and log entries written by one batch can be grouped and
 * traced together.
 *
 * Why it exists:
 *   Batch and queue procedures need a cheap correlation ID that fits in an
 *   INT UNSIGNED column. RAND() is good enough for tracing; this is not -
 *   and does not need to be - a uniqueness guarantee or a security token.
 *
 * Example:
 *   SELECT Fn_Do_Get_Random_Process_Key();  -- '2847261940'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Get_Random_Process_Key`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Get_Random_Process_Key`() RETURNS varchar(20) CHARSET utf8mb4
BEGIN

DECLARE v_Key_Min INT UNSIGNED DEFAULT '10000' ;
DECLARE v_Key_Max INT UNSIGNED DEFAULT '4294967295' ;

RETURN FLOOR(v_Key_Min + (RAND() * (v_Key_Max - v_Key_Min))) ;

END

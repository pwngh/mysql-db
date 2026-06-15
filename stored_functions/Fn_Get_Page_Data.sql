/* Fn_Get_Page_Data.sql
 *
 * Example of the core JSON API pattern: one JSON argument in, one JSON
 * document out. This is the template to copy when adding a real Fn_Get_*
 * data function.
 *
 * What this component does in the system:
 *   - Reads each expected argument out of v_Args_Json
 *     (Fn_Do_Get_JSON_Element_Value) and scrubs it
 *     (here, Fn_Do_Scrub_Data_Id_Value on v_User_Account_Id)
 *   - Runs the page query inside a retry loop that absorbs deadlocks (1213)
 *     and lock-wait timeouts (1205) with a growing sleep, up to 10 attempts
 *   - Returns the page data as JSON, passed through Fn_Do_Scrub_JSON_Object
 *     on the way out
 *
 * Why it exists:
 *   The MySQL functions act as the shared backend API: the application
 *   sends a JSON request and receives either result JSON or a structured
 *   error object (Query_Name, Database_Name, execution timestamp,
 *   Elapsed_Time, Query_Error_Comment) - never a raw SQL error. Validation
 *   failures and transient locking are handled inside the DB layer, so
 *   every client gets the same behavior without duplicating it.
 *
 * Example:
 *   SELECT Fn_Get_Page_Data(JSON_OBJECT('v_User_Account_Id', '1000000001'));
 */

DROP FUNCTION IF EXISTS `Fn_Get_Page_Data`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Get_Page_Data`(v_Args_Json JSON) RETURNS json
BEGIN
DECLARE v_This_Procedure_Name VARCHAR(80) DEFAULT 'Fn_Get_Page_Data' ;
DECLARE v_Start_UTC_DateTime DATETIME(6) DEFAULT UTC_TIMESTAMP(6) ;

DECLARE v_User_Account_Id INT UNSIGNED DEFAULT IFNULL((SELECT Fn_Do_Scrub_Data_Id_Value(Fn_Do_Get_JSON_Element_Value(v_Args_Json, '$.v_User_Account_Id'))),'') ;
-- ----------------------------
DECLARE v_Return_Json JSON DEFAULT NULL ;
DECLARE v_Query_Error_Comment VARCHAR(255) DEFAULT NULL ;
-- ----------------------------
DECLARE v_Max_Tries SMALLINT UNSIGNED DEFAULT '10' ;
DECLARE v_Attempts SMALLINT UNSIGNED DEFAULT '0' ;
DECLARE v_Error_Cnt SMALLINT UNSIGNED DEFAULT '0' ;
-- ----------------------------
DECLARE CONTINUE HANDLER FOR 1213 SET v_Error_Cnt = v_Error_Cnt + 1 ; -- 1213 = Deadlock found when trying to get lock, Exit and try again
DECLARE CONTINUE HANDLER FOR 1205 SET v_Error_Cnt = v_Error_Cnt + 1 ; -- 1205 = Lock wait timeout exceeded; try restarting transaction


IF (IFNULL(v_User_Account_Id,'0') = '0') THEN
      SET v_Query_Error_Comment = CONCAT('v_User_Account_Id is empty and invalid.') ;
      RETURN JSON_OBJECT('Query_Name', IFNULL(v_This_Procedure_Name,'') ,
                         'Database_Name', IFNULL((SELECT DATABASE()),'') ,
                         'Execution_CT_DateTime_Display', IFNULL((SELECT Fn_Do_Format_DateTime_Standard_Display_To_Sec(Fn_Do_Get_CT_DateTime())),'') ,
                         'Elapsed_Time', IFNULL((SELECT Fn_Do_Get_Elapsed_Micro_Time(v_Start_UTC_DateTime, NULL)),'') ,
                         'Query_Error_Comment', IFNULL(v_Query_Error_Comment,'')) ;
END IF;


SET v_Max_Tries = 10 ;  SET v_Attempts = 0 ;  SET v_Error_Cnt = 0 ; -- set the number of Max_Tries appropriate for this loop after which we will quit trying
error_retry_901: WHILE (v_Attempts < v_Max_Tries) AND ((v_Error_Cnt > 0) OR (v_Attempts = 0)) DO -- if v_Error_Cnt > 0 means we had one or more errors the last loop
      SET v_Attempts = v_Attempts + 1 ;  SET v_Error_Cnt = 0 ; -- keep track of our Attempts to avoid an infinite loop -- reset Error_Cnt each loop so we can know if we get any errors (each error will cause to increment value)
      IF (v_Attempts > 1) THEN  DO SLEEP(0.1 + (v_Attempts-2));  END IF; -- add a small delay before retrying, except on our first try

      -- select and return data to be shown on the page
      SET v_Return_Json = (SELECT JSON_OBJECT('v_Field_Name_1', IFNULL('v_Field_Value_1','') ,
                                              'v_Field_Name_2', IFNULL('v_Field_Value_2','') ,
                                              'v_Field_Name_3', IFNULL('v_Field_Value_3',''))) ;

END WHILE error_retry_901;


IF (IFNULL(v_Query_Error_Comment,'') != '') THEN
      RETURN JSON_OBJECT('Query_Name', IFNULL(v_This_Procedure_Name,'') ,
                         'Database_Name', IFNULL((SELECT DATABASE()),'') ,
                         'Execution_CT_DateTime_Display', IFNULL((SELECT Fn_Do_Format_DateTime_Standard_Display_To_Sec(Fn_Do_Get_CT_DateTime())),'') ,
                         'Elapsed_Time', IFNULL((SELECT Fn_Do_Get_Elapsed_Micro_Time(v_Start_UTC_DateTime, NULL)),'') ,
                         'Query_Error_Comment', IFNULL(v_Query_Error_Comment,'')) ;
END IF;



RETURN (SELECT Fn_Do_Scrub_JSON_Object(v_Return_Json)) ;


END
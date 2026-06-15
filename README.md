# @pwngh/mysql-db

A reusable library of MySQL 8.0+ stored functions, procedures, triggers, example schemas, and scheduled events. Distributed as plain SQL with one database object per file.

## Execution model

All scripts are designed to be **idempotent and safe to re-run**:

- Objects are created using `DROP ... IF EXISTS` followed by `CREATE`
- Re-executing is safe and functions as a lightweight upgrade mechanism
- Routine bodies contain semicolons; use a client that supports multi-statement execution (e.g. `MySQL Workbench`, `DataGrip`) or a delimiter-safe CLI wrapper

## Environment requirements

The scripts assume a standard MySQL 8.0+ environment. Some features rely on global server configuration or system tables that may not be enabled by default.

- **Definers (security context for routines)**
  - All routines, triggers, and events are created with `DEFINER='admin'@'%'`
  - This defines the execution security context for database objects
  - If your server uses stricter user policies, change or remove the definer to match

- **Database schema name**
  - The scripts use `mysql_db` as a placeholder schema
  - This is intentional to make the library portable across environments
  - Replace it before deployment

- **Binary logging restrictions**
  - MySQL may block function creation under binary logging in certain configurations
  - If this occurs, enable trusted function creation:

    ```sql
    SET GLOBAL log_bin_trust_function_creators = 1;
    ```
  
  - This relaxes safety checks for deterministic functions

- **Time zone support**
  - Functions using `CONVERT_TZ()` depend on MySQL time zone tables
  - Without them, conversions will return `NULL`
  - These tables must be loaded into the server for accurate timezone handling

- **Event scheduler**
  - Scheduled events require the MySQL event scheduler to be enabled
  - Without it, event definitions will exist but will not execute

    ```sql
    SET GLOBAL event_scheduler = ON;
    ```


## Functions

All functions follow the `Fn_Do_*` naming convention and are grouped by responsibility.


### Input scrubbing & validation

Type-safe normalization for all primitive inputs (IDs, strings, numbers, dates, network values).

| Function | Purpose |
| --- | --- |
| `Fn_Do_Scrub_Data_Id_Value` | Validate a data-record ID |
| `Fn_Do_Scrub_Ref_Id_Value` | Validate a reference-record ID |
| `Fn_Do_Scrub_Boolean_Value` | Normalize a boolean to `'1'`/`'0'` |
| `Fn_Do_Scrub_Date_Value` | Validate a `DATE` |
| `Fn_Do_Scrub_DateTime_Value` | Validate a `DATETIME` |
| `Fn_Do_Scrub_Decimal_Value` | Clean to a `DECIMAL(9,3)` |
| `Fn_Do_Scrub_Decimal_Money_Value` | Clean to a money `DECIMAL(8,2)` |
| `Fn_Do_Scrub_Integer_Value` | Clean to an integer |
| `Fn_Do_Scrub_String_Value` | Trim a string (`NULL` if empty) |
| `Fn_Do_Scrub_Text_Value` | Trim text (`NULL` if empty) |
| `Fn_Do_Scrub_IP_Address_Value` | Trim an IP-address string |
| `Fn_Do_Scrub_Mac_Address_Value` | Trim a MAC-address string |
| `Fn_Do_Scrub_Time_Zone_Value` | Map a zone alias to an IANA name |

### JSON utilities

Safe extraction and validation of JSON payloads.

| Function | Purpose |
| --- | --- |
| `Fn_Do_Get_JSON_Element_Value` | Read an element value by key |
| `Fn_Do_Scrub_JSON_Object` | Validate and normalize a JSON object |

### Date & time formatting

Standardized display and conversion utilities.

| Function | Purpose |
| --- | --- |
| `Fn_Do_Format_DateTime_Standard_Display_To_Sec` | Weekday datetime, to the second |
| `Fn_Do_Format_DateTime_Standard_Display_To_Min` | Weekday datetime, to the minute |
| `Fn_Do_Format_DateTime_Standard_Display_Short_To_Min` | Short datetime, to the minute |
| `Fn_Do_Format_Date_Standard_Display` | Date as `DD-MON-YY` |
| `Fn_Do_Format_Date_Standard_Display_To_Hour` | Date as `DD-MON-YY` with hour |
| `Fn_Do_Format_Date_To_Display_Format_With_Weekday` | Date with weekday |
| `Fn_Do_Format_Date_To_Timestamp_Milliseconds` | Date to epoch milliseconds |
| `Fn_Do_Convert_Date_Format_From_Display_To_Internal` | Parse a display date to `YYYY-MM-DD` |
| `Fn_Do_As_Of_Display_String_Value` | "As of:" report header |
| `Fn_Do_As_Of_Display_String_Value_Min` | Short "As of:" report header |
| `Fn_Do_Format_DateTime_Time_Zone_Prefix_Display_To_Min` | Render a UTC datetime in a target zone |

### Number & currency formatting

Display-safe numeric transformations.

| Function | Purpose |
| --- | --- |
| `Fn_Do_Format_Number_To_Currency_Display` | Currency with cents (`$1,234.50`) |
| `Fn_Do_Format_Number_To_Currency_Display_Short` | Whole-dollar currency (`$1,235`) |
| `Fn_Do_Format_Number_Wrap_With_Parenthesis` | Wrap a value in parentheses |
| `Fn_Do_Convert_To_Yes_No` | Boolean token to `Yes`/`No` |

### Text utilities

Normalization and cleanup helpers.

| Function | Purpose |
| --- | --- |
| `Fn_Do_Titlecase_Text` | Title-case text |
| `Fn_Do_Remove_Duplicate_Spaces_From_Text` | Collapse repeated spaces |
| `Fn_Do_Remove_Str_List_Delimiters` | Strip list-delimiter characters |

### Process utilities

Runtime and execution helpers.

| Function | Purpose |
| --- | --- |
| `Fn_Do_Get_CT_DateTime` | Current US Central datetime |
| `Fn_Do_Get_Elapsed_Micro_Time` | Elapsed time between two timestamps |
| `Fn_Do_Get_Random_Process_Key` | Random correlation/tracing key |

## The page-data pattern

The `Fn_Get_Page_Data` / `App_Get_Page_Data` pair serves as the template for a JSON-backed endpoint. To create a new endpoint, copy the pair and replace the example query with your own business logic.

- `Fn_Get_Page_Data(JSON)` is the implementation function. It accepts a single JSON document, extracts and validates its inputs, executes the query within an automatic retry loop for deadlocks and lock wait timeouts using linear backoff, and returns either a result document or a structured error object.

- `App_Get_Page_Data(JSON)` is the public wrapper procedure. Clients invoke this procedure with CALL; it returns the function's result JSON together with execution metadata, including the query name, database name, Central timestamp, elapsed execution time, and the original input arguments.

#### Example:

```sql
CALL App_Get_Page_Data(JSON_OBJECT('v_User_Account_Id', '1000000001'));
```

## License

MIT — see [LICENSE](LICENSE). Copyright (c) 2026 Preston Neal.

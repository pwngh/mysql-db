# @pwngh/mysql-db

A reusable library of MySQL 8.0+ stored functions, procedures, triggers, example schemas, and scheduled events. Distributed as plain SQL with one database object per file.

## Execution model

All scripts are designed to be **idempotent**:

- Objects are created using `DROP ... IF EXISTS` followed by `CREATE`
- Safe to re-run for upgrades or redeployment
- No manual migration tracking required

Routine bodies contain semicolons. Use a SQL client that supports multi-statement execution like `MySQL Workbench`, `Navicat for MySQL`, or `DataGrip`, or a CLI wrapper when using `mysql`.

## Deployment requirements

The scripts assume a standard MySQL 8.0+ environment and may require configuration adjustments.

**Definers**
- All routines, triggers, and events use `DEFINER='admin'@'%'`
- Modify or remove to match your server users

**Database name**
- Example DDL uses `mysql_db`
- Replace with your target schema

**Binary logging**
- Function creation may require:

  ```sql
  SET GLOBAL log_bin_trust_function_creators = 1;
  ```

**Time zone support**
  - `CONVERT_TZ()` requires MySQL time zone tables to be loaded

**Event scheduler**

- Required for scheduled events:

  ```sql
  SET GLOBAL event_scheduler = ON;
  ```


## Installation

Apply folders to your database in dependency order:

1. `stored_functions/`
2. `tables/`
3. `stored_procedures/`
4. `events/`

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

# Economic Entries Period Configuration Guide

This guide explains how to configure the period/year settings for synchronizing e-conomic entries.

## Configuration Options

### 1. Demo Data Mode (Recommended for Testing)
**Use Case**: Testing with e-conomic demo data from 2022

**Configuration**:
- ✅ Enable "Use Demo Data Year"
- Set "Demo Data Year" to `2022`

**Result**:
- API URL: `https://restapi.e-conomic.com/accounting-years/2022/entries?demo=true`

### 2. Last N Years Mode
**Use Case**: Sync the last 3 years of data

**Configuration**:
- ❌ Disable "Use Demo Data Year"
- Set "Entries Sync Years Count" to `3`

**Result (if current year is 2024)**:
- Years: 2022, 2023, 2024
- API URLs:
  - `https://restapi.e-conomic.com/accounting-years/2022/entries`
  - `https://restapi.e-conomic.com/accounting-years/2023/entries`
  - `https://restapi.e-conomic.com/accounting-years/2024/entries`

### 3. Specific Year Range Mode
**Use Case**: Sync data from 2020 to 2023

**Configuration**:
- ❌ Disable "Use Demo Data Year"
- Set "Entries Sync Years Count" to `0`
- Set "Entries Sync From Year" to `2020`
- Set "Entries Sync To Year" to `2023`

**Result**:
- Years: 2020, 2021, 2022, 2023
- API URLs:
  - `https://restapi.e-conomic.com/accounting-years/2020/entries`
  - `https://restapi.e-conomic.com/accounting-years/2021/entries`
  - `https://restapi.e-conomic.com/accounting-years/2022/entries`
  - `https://restapi.e-conomic.com/accounting-years/2023/entries`

### 4. Current Year Only
**Use Case**: Sync only current year data

**Configuration**:
- ❌ Disable "Use Demo Data Year"
- Set "Entries Sync Years Count" to `1`

**Result (if current year is 2024)**:
- Years: 2024
- API URL: `https://restapi.e-conomic.com/accounting-years/2024/entries`

### 5. Custom Filter Mode (Advanced)
**Use Case**: Complex filtering requirements

**Configuration**:
- ❌ Disable "Use Demo Data Year"
- Set other year fields to `0`
- Set "Entries Sync Period Filter" to custom filter

**Example Custom Filters**:
- `2022|2024` (skip 2023)
- `2020|2021|2022` (specific years)
- Custom e-conomic API filter syntax

## Testing Your Configuration

1. Open **Economic Setup** page
2. Configure your desired period settings
3. Click **Test Period Configuration** action
4. Review the test results showing:
   - Years that will be synchronized
   - API filter that will be generated
   - Example URL for entries API

## Configuration Methods (For Developers)

The Economic Setup table provides these methods for integration:

### `GetAccountingYearsToSync()` 
Returns a list of years to synchronize based on current configuration.

```al
var
    EconomicSetup: Record "Economic Setup";
    YearsList: List of [Integer];
begin
    EconomicSetup.Get();
    YearsList := EconomicSetup.GetAccountingYearsToSync();
    // Use YearsList for processing
end;
```

### `GetEntriesAPIUrls(BaseUrl)`
Returns a list of complete URLs for all years to be synchronized.

```al
var
    EconomicSetup: Record "Economic Setup";
    UrlsList: List of [Text];
    Url: Text;
begin
    EconomicSetup.Get();
    UrlsList := EconomicSetup.GetEntriesAPIUrls('https://restapi.e-conomic.com');
    
    foreach Url in UrlsList do begin
        // Make API call to each URL
        // Url = "https://restapi.e-conomic.com/accounting-years/2022/entries?demo=true"
    end;
end;
```

### `GetEntriesAPIUrlForYear(BaseUrl, Year)`
Returns URL for a specific year.

```al
var
    EconomicSetup: Record "Economic Setup";
    Url: Text;
begin
    EconomicSetup.Get();
    Url := EconomicSetup.GetEntriesAPIUrlForYear('https://restapi.e-conomic.com', 2022);
    // Url = "https://restapi.e-conomic.com/accounting-years/2022/entries?demo=true"
end;
```

### Legacy Methods (Deprecated)
The following methods use the old filter-based approach and are maintained for compatibility:
- `GetEntriesAPIFilter()` - Returns filter string (deprecated)
- `GetEntriesAPIUrlWithFilter()` - Returns URL with filter parameter (deprecated)

## Validation

The system validates period configuration:
- Demo mode requires a valid demo year
- Advanced mode requires at least one of: years count, from/to years, or custom filter
- From year cannot be greater than to year
- All values must be within reasonable ranges (2000-9999)

## Integration with HTTP Requests

When making HTTP requests to e-conomic entries API, use the new URL generation methods:

```al
procedure CallEconomicEntriesAPI()
var
    EconomicSetup: Record "Economic Setup";
    HttpClient: HttpClient;
    HttpRequestMessage: HttpRequestMessage;
    HttpResponseMessage: HttpResponseMessage;
    UrlsList: List of [Text];
    Url: Text;
begin
    EconomicSetup.Get();
    
    // Get all URLs for configured years
    UrlsList := EconomicSetup.GetEntriesAPIUrls('https://restapi.e-conomic.com');
    
    // Make HTTP request for each year
    foreach Url in UrlsList do begin
        HttpRequestMessage.SetRequestUri(Url);
        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        
        // Process response for this year...
        ProcessEntriesResponse(HttpResponseMessage);
    end;
end;
```

### Single Year Example:
```al
procedure CallEconomicEntriesAPIForYear(Year: Integer)
var
    EconomicSetup: Record "Economic Setup";
    HttpClient: HttpClient;
    HttpRequestMessage: HttpRequestMessage;
    HttpResponseMessage: HttpResponseMessage;
    Url: Text;
begin
    EconomicSetup.Get();
    
    // Get URL for specific year
    Url := EconomicSetup.GetEntriesAPIUrlForYear('https://restapi.e-conomic.com', Year);
    // Results in: https://restapi.e-conomic.com/accounting-years/2022/entries?demo=true
    
    HttpRequestMessage.SetRequestUri(Url);
    HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
    
    // Process response...
end;
```

This ensures that the HTTP requests use the correct e-conomic API structure with `/accounting-years/{year}/entries` paths and automatically include the `?demo=true` parameter when using demo data.

## Best Practices

1. **Start with Demo Mode** - Use 2022 demo data for initial testing
2. **Test Configuration** - Always use the test action to verify your settings
3. **Consider Performance** - Limit year ranges for large datasets
4. **Document Custom Filters** - If using custom filters, document the syntax for your team
5. **Regular Updates** - Update year ranges periodically for ongoing synchronization

---

*This configuration system ensures flexible period management while maintaining compatibility with e-conomic API requirements.*
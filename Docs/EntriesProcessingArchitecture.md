# Economic Entries Processing Architecture

This document describes the multi-stage architecture for processing e-conomic entries into Business Central General Journal Lines.

## Overview

The entries processing system uses a three-stage approach:
1. **Landing Stage** - Store raw e-conomic API data
2. **Processing Stage** - Transform and validate for Business Central
3. **Journal Creation** - Create and post General Journal Lines

## Architecture Components

### 1. Economic Entries Landing Table (51020)
**Purpose**: Store raw e-conomic entries data exactly as received from API

**Key Features**:
- Complete field mapping from e-conomic schema
- JSON storage for full API response
- Processing status tracking
- Designed for large datasets

**Key Fields**:
- Entry No. (Auto-increment primary key)
- Economic Entry Number (from e-conomic)
- Account Number (e-conomic account)
- Amount & Amount in Base Currency
- Posting Date, Due Date, Document Date
- Entry Text, Entry Type
- Voucher Number
- Customer/Supplier references
- VAT information
- Project data
- Raw JSON Data storage

### 2. Economic Entry Processing Table (51021)
**Purpose**: Transform landing data into Business Central-ready format

**Key Features**:
- Business Central field mapping
- Validation logic with error tracking
- Journal line creation capabilities
- Status tracking for processing pipeline

**Key Fields**:
- Landing Entry No. (Reference to landing table)
- BC Journal Template/Batch
- BC Account Type/No.
- Amount & Amount (LCY)
- Validation Status & Error
- Processing timestamps

**Key Methods**:
- `ValidateEntry()` - Comprehensive validation
- `CreateJournalLines()` - Generate journal lines
- `GetMappedBCAccount()` - Account mapping resolution
- `CreateFromLandingRecord()` - Transform from landing data

### 3. Enhanced Economic Setup Table (51000)
**Purpose**: Configuration for entries processing

**New Fields**:
- Default GL Account No. (fallback for unmapped accounts)
- Entries Journal Template
- Auto Create Journal Batches
- Auto Post Journals
- Max Entries Per Batch
- Use Date Prefix in Doc No.
- Default Balancing Account configuration

**Period Configuration Fields**:
- Use Demo Data Year (for testing with 2022 data)
- Demo Data Year (specific year for demo/testing)
- Entries Sync From Year (start year for synchronization)
- Entries Sync To Year (end year for synchronization)
- Entries Sync Years Count (number of years to sync from current)
- Entries Sync Period Filter (custom API filter for advanced users)

**Period Configuration Methods**:
- `GetAccountingYearsToSync()` - Returns list of years to synchronize
- `GetAccountingYearFilter()` - Returns API filter string for years
- `GetCurrentSyncYear()` - Returns current year for sync operations
- `ValidatePeriodConfiguration()` - Validates period setup

### 4. Enhanced Economic GL Account Mapping Table (51001)
**Purpose**: Map e-conomic accounts to Business Central G/L accounts

**Enhanced Methods**:
- `GetMappedAccount()` - Account resolution with fallback
- `CreateMappingFromEconomicAccount()` - Auto-create mappings
- `ValidateMapping()` - Validate account mappings

## Processing Workflow

### Stage 1: Data Landing
1. Call e-conomic API to retrieve entries
2. Store raw JSON response in Landing Table
3. Parse and map individual fields
4. Set processing status to "New"

### Stage 2: Data Processing
1. Create Processing records from Landing records
2. Map e-conomic accounts to BC G/L accounts
3. Validate all data for BC compatibility
4. Set validation status based on results

### Stage 3: Journal Creation
1. Create separate journal batches by posting date
2. Generate General Journal Lines from validated processing records
3. Apply account mappings and balancing logic
4. Optionally auto-post journals

## Account Mapping Strategy

### Mapping Resolution (Priority Order):
1. **Direct Mapping** - Specific mapping in GL Account Mapping table
2. **Default Account** - Fallback to setup default G/L account
3. **Error** - No mapping available, validation fails

### Mapping Features:
- Support for all e-conomic account types
- Fallback to default account configuration
- Usage statistics tracking
- Active/inactive mapping control

## Date-Based Journal Separation

**Challenge**: e-conomic may have same voucher numbers across different posting dates  
**Solution**: Create separate journal batches by posting date

**Implementation**:
- Batch naming: `ECONOMIC-YYYY-MM-DD`
- Document numbering: Optional date prefix (`20240315-VOUCHERxxx`)
- Maximum entries per batch configurable

## Error Handling & Validation

### Validation Checks:
- G/L Account existence and posting capability
- Customer/Vendor mapping verification
- Currency validation
- Amount validation (non-zero)
- Required field validation

### Error Recovery:
- Clear error descriptions in validation
- Ability to re-validate after corrections
- Skip invalid entries option
- Detailed processing logs

## Configuration Options

### Setup Options:
- **Auto Create Journal Batches** - Automatically create batches by date
- **Auto Post Journals** - Automatically post after creation
- **Max Entries Per Batch** - Batch size limits
- **Use Date Prefix** - Document number formatting
- **Default Accounts** - Fallback account configuration

### Period Configuration Options:
- **Demo Data Mode** - Use specific year (e.g., 2022) for testing/demo
- **Years Count Mode** - Sync X number of years from current year
- **Specific Years Mode** - Define exact from/to year range
- **Custom Filter Mode** - Advanced users can specify custom API filters

### Period Configuration Examples:
1. **Demo/Testing**: Enable "Use Demo Data Year" and set to 2022
2. **Last 3 Years**: Set "Entries Sync Years Count" to 3
3. **Specific Range**: Set "From Year" to 2020 and "To Year" to 2023
4. **Current Year Only**: Set "Years Count" to 1 or From/To to current year
5. **Custom Filter**: Use advanced filter syntax for complex scenarios

### HTTP Request Integration:
The setup configuration generates appropriate URLs for e-conomic API calls:
- Demo mode: `https://restapi.e-conomic.com/accounting-years/2022/entries?demo=true`
- Multiple years: Separate API calls for each year (e.g., `/accounting-years/2023/entries`, `/accounting-years/2024/entries`)
- Single year: `https://restapi.e-conomic.com/accounting-years/2024/entries`
- Each request uses the proper e-conomic API structure with accounting-years path

### Performance Considerations:
- Batch processing for large datasets
- Progress tracking for long operations
- Configurable batch sizes
- Background processing support

## Next Steps Implementation

### High Priority:
1. **Data Processor Enhancement** - Extend EconomicDataProcessor codeunit for entries
2. **Management Pages** - Create user interfaces for monitoring/managing
3. **API Integration** - Implement e-conomic entries API calls
4. **Testing** - Comprehensive testing with sample data

### Medium Priority:
1. **Advanced Mapping** - Customer/vendor account handling
2. **VAT Processing** - VAT posting group mapping
3. **Project Integration** - Dimension handling for projects
4. **Performance Optimization** - Large dataset handling

### Future Enhancements:
1. **Automated Scheduling** - Scheduled entry imports
2. **Conflict Resolution** - Duplicate entry handling
3. **Advanced Reporting** - Processing statistics and monitoring
4. **Integration Events** - Custom processing hooks

## Implementation Status

✅ **Completed**:
- Landing table with full e-conomic schema mapping
- Processing table with BC transformation logic
- Enhanced setup configuration
- Enhanced GL account mapping with fallback
- Basic validation and journal creation methods

🔄 **In Progress**:
- Data processor methods for entry handling

⏳ **Pending**:
- Management codeunit implementation
- User interface pages
- API integration methods
- Comprehensive testing

---

*This architecture supports the user requirements for:*
- *Multi-stage processing with separate journals by posting date*
- *Account mapping with fallback to default accounts*
- *Large dataset handling with configurable batch processing*
- *Comprehensive validation and error handling*
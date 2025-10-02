# e-conomic to Business Central Migration Extension Specification

## 1. Overview
This extension facilitates one-time data migration from e-conomic to Business Central, providing a structured and validated approach to transferring business data.

## 2. Architecture Decisions
Based on strategic analysis, the following key decisions shape the architecture:

### 2.1 Authentication
- Implementation: OAuth 2.0 with refresh tokens
- Storage: Encrypted in Business Central database
- Scope: Read-only access to e-conomic data

### 2.2 Migration Approach
- Type: Full dataset migration
- Validation: Pre-migration validation with detailed reporting
- Processing: Interactive processing with progress indication
- Frequency: One-time migration with option to restart

## 3. Data Model

### 3.1 Setup Tables
```AL
table 50100 "Economic Migration Setup"
{
    // OAuth configuration
    // API endpoints
    // Migration settings
    // Status tracking
}

table 50101 "Economic Field Mapping"
{
    // Configurable field mappings
    // Transformation rules
    // Validation rules
}

table 50102 "Economic Migration Log"
{
    // Detailed logging
    // Error tracking
    // Success/failure statistics
}
```

### 3.2 Migration Data Tables
```AL
table 50110 "Economic Customer Stage"
table 50111 "Economic Vendor Stage"
table 50112 "Economic GL Account Mapping"
{
    fields
    {
        field(1; "Economic Account No."; Code[20])
        {
            Caption = 'Account No.';
            NotBlank = true;
        }
        field(2; "Economic Account Name"; Text[100])
        {
            Caption = 'Name';
        }
        field(3; "BC Account No."; Code[20])
        {
            Caption = 'Mapped To Account No.';
            TableRelation = "G/L Account"."No.";
            
            trigger OnValidate()
            begin
                CalcFields("BC Account Name");
            end;
        }
        field(4; "BC Account Name"; Text[100])
        {
            Caption = 'Mapped Name';
            FieldClass = FlowField;
            CalcFormula = lookup("G/L Account".Name where("No." = field("BC Account No.")));
            Editable = false;
        }
        field(5; "Entry Count"; Integer)
        {
            Caption = 'Entries';
            FieldClass = FlowField;
            CalcFormula = count("Economic Entry Stage" where("Account No." = field("Economic Account No.")));
            Editable = false;
        }
        field(6; "Migration Status"; Option)
        {
            Caption = 'Status';
            OptionMembers = "Not Started","In Progress","Completed","Error";
            OptionCaption = 'Not Started,In Progress,Completed,Error';
        }
    }

    keys
    {
        key(Key1; "Economic Account No.")
        {
            Clustered = true;
        }
        key(Key2; "BC Account No.") { }
    }
}

table 50113 "Economic Entry Stage"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = "Economic GL Account Mapping"."Economic Account No.";
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(4; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Account No.") { }
    }
}

table 50114 "Economic Item Stage"

## 4. UI Components

### 4.1 Role Center (ID: 50100)
- Migration overview
- Progress tracking
- Quick actions
- Migration statistics

### 4.2 Setup Pages
- Migration Setup Card (ID: 50100)
- Field Mapping Worksheet (ID: 50101)
- Migration Log List (ID: 50102)

### 4.3 Migration Pages
- Customer Migration Worksheet (ID: 50110)
- Vendor Migration Worksheet (ID: 50111)
- GL Account Migration Worksheet (ID: 50112)
- Item Migration Worksheet (ID: 50113)
- Journal Migration Worksheet (ID: 50114)

## 5. Integration Points

### 5.1 e-conomic API Endpoints
- Customers: `/customers`
- Products: `/products`
- Accounts: `/accounts`
- Journals: `/journals`
- Entries: `/entries`

### 5.2 Business Central Integration
- Customer Management
- Vendor Management
- Chart of Accounts
- Item Master
- Journal Entries

## 6. Workflows

### 6.1 Setup Process
1. Install extension
2. Configure OAuth credentials
3. Set up field mappings
4. Configure migration parameters

### 6.2 Migration Process
1. Pre-migration validation
2. Data extraction from e-conomic
3. Staging data review
4. Final migration to BC tables
5. Reconciliation reporting

### 6.3 Error Handling
- Detailed error logging
- Continue-with-logging approach
- Error classification and reporting
- Retry mechanisms for failed records

## 7. Security Considerations
- OAuth token encryption
- API rate limiting
- Data validation
- Error logging (excluding sensitive data)

## 8. Performance Considerations
- Batch size optimization
- Progress tracking
- Timeout handling
- Resource consumption monitoring

## 9. Testing Strategy
- Full dataset testing in sandbox
- Data validation testing
- Error handling scenarios
- Performance testing
- Security testing

## 10. Dependencies
- Business Central version: 22.0
- Minimum platform version: 11.0
- Required permissions:
  - e-conomic API access
  - BC table permissions
  - OAuth configuration permissions
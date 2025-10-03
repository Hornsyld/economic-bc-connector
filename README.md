# Business Central e-conomic Integration

This repository contains an AL extension for Microsoft Dynamics 365 Business Central that enables seamless integration with e-conomic accounting software. The extension provides comprehensive data migration and synchronization capabilities between Business Central and e-conomic.

## Features

- ✅ **API Integration Framework** - Complete OAuth 2.0 authentication and HTTP client
- ✅ **Economic Setup Configuration** - Centralized configuration management
- ✅ **Customer & Vendor Management** - Full customer and vendor import with rich data mapping
- ✅ **Bank Account Integration** - Automatic vendor bank account creation
- ✅ **Data Processing Architecture** - Specialized codeunits for efficient data handling
- ✅ **Progress Tracking** - Real-time progress dialogs with record counting
- ✅ **Integration Logging** - Comprehensive audit trail and error tracking
- ✅ **G/L Account Mapping** - Chart of accounts synchronization
- ✅ **Role Center Dashboard** - Dedicated workspace with activity monitoring
- 🚧 **Advanced Data Validation** (Planned)
- 🚧 **Posting Group Automation** (Planned)

## Key Capabilities

### Customer & Vendor Integration
- **Direct Number Mapping**: e-conomic numbers used directly as Business Central keys
- **Rich Data Import**: Complete contact information, addresses, financial details
- **Bank Account Creation**: Automatic vendor bank account setup with full details
- **Progress Tracking**: Multi-stage progress dialogs with real-time updates
- **Comprehensive Mapping**: All relevant e-conomic supplier/customer data captured

### Architecture Highlights
- **Best Practice Design**: Separated codeunits following AL development guidelines
- **Specialized Data Processing**: Dedicated `EconomicDataProcessor` for JSON handling
- **HTTP Client Excellence**: Robust API communication with proper error handling
- **Simplified Data Model**: Clean, efficient table structures without redundant fields

## Prerequisites

- Microsoft Dynamics 365 Business Central (2022 Wave 2 or later)
- e-conomic Subscription with API Access
- API Credentials from e-conomic (OAuth 2.0)

## Installation

1. Download the `.app` file from the latest release
2. Install the extension in your Business Central environment
3. Configure the e-conomic setup page with your API credentials

## Configuration

### Initial Setup
1. Open the **e-conomic Setup** page in Business Central
2. Enter your **API Key** and **Agreement Grant Token**
3. Configure the **API Endpoint** (production or demo)
4. Test the connection using the **"Test Connection"** action

### Customer & Vendor Import
1. Navigate to **e-conomic Customer Mapping** or **e-conomic Vendor Mapping**
2. Use **"Get Customers"** or **"Get Vendors"** to import from e-conomic
3. Review the imported data with rich details (contact info, addresses, financial data)
4. Use **"Create All Unsynced"** to create Business Central records with full bank account setup

## Usage

### Customer Management
- **Import Process**: Retrieve customers from e-conomic with complete profiles
- **Data Mapping**: Automatic mapping of contact details, addresses, and business information
- **Batch Creation**: Create multiple customers with progress tracking

### Vendor Management  
- **Rich Import**: Import vendors with comprehensive e-conomic supplier data
- **Bank Account Integration**: Automatic creation of vendor bank accounts
- **Financial Data**: Currency codes, payment terms, VAT zones, and corporate IDs
- **Contact Management**: Full contact information and sales person assignments

### Integration Monitoring
- **Real-time Logs**: Detailed integration activity tracking
- **Progress Dialogs**: Visual feedback during data processing
- **Error Handling**: Comprehensive error logging and recovery options
- **Role Center**: Dedicated dashboard for monitoring all activities

## Object Overview

| Object Type | Object ID | Name | Description |
|------------|-----------|------|-------------|
| **Tables** |
| Table | 51000 | Economic Setup | API credentials and configuration settings |
| Table | 51001 | Economic GL Account Mapping | Maps BC accounts to e-conomic accounts |
| Table | 51002 | Economic Integration Log | Comprehensive integration activity logs |
| Table | 51003 | Economic Country Mapping | e-conomic to BC country/region mappings |
| Table | 51004 | Economic Customer Mapping | Customer data mapping and sync status |
| Table | 51012 | Economic Vendor Mapping | Vendor data mapping with rich e-conomic fields |
| Table | 51009 | Economic Activities Cue | Role center statistics and counters |
| **Pages** |
| Page | 51000 | Economic Setup | Main configuration interface |
| Page | 51001 | Economic GL Account Mapping | Account mapping management |
| Page | 51002 | Economic Integration Log | Integration activity viewer |
| Page | 51003 | Economic Country Mapping | Country mapping management |
| Page | 51010 | Economic Customer Mapping | Customer import and creation |
| Page | 51011 | Economic Vendor Mapping | Vendor import with bank account creation |
| Page | 51005 | Economic Role Center | Main dashboard and workspace |
| Page | 51006 | Economic Customer Overview | Customer migration status |
| Page | 51007 | Economic Vendor Overview | Vendor migration status |
| **Codeunits** |
| Codeunit | 51000 | Economic Management | Main business logic and API coordination |
| Codeunit | 51003 | Economic Data Processor | Specialized JSON processing and data mapping |
| **Enums** |
| Enum | 51000 | Economic Sync Status | Synchronization state tracking |
| Enum | 51010 | Economic Request Type | API request classification |

## Technical Highlights

### Architecture Excellence
- **Separation of Concerns**: Dedicated codeunits for business logic vs. data processing
- **Best Practice Design**: Follows Microsoft AL development guidelines
- **Clean Data Model**: Simplified tables with direct number mapping (no redundant fields)
- **Comprehensive Logging**: Full audit trail with request/response tracking

### Data Processing Features
- **Rich JSON Mapping**: Extracts comprehensive data from e-conomic APIs
- **Progress Dialogs**: Real-time feedback during multi-record operations
- **Direct Number Mapping**: e-conomic numbers used directly as Business Central keys
- **Bank Account Integration**: Automatic vendor bank account creation with full details

### API Integration
- **OAuth 2.0 Authentication**: Secure API access with token management
- **Robust HTTP Client**: Proper error handling and content-type management
- **Rate Limiting Compliance**: Respectful API usage patterns
- **Comprehensive Error Handling**: Detailed logging and recovery mechanisms

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

This is an open-source project. While we strive to address issues, there is no guaranteed support. Please open an issue on GitHub if you encounter any problems.

## Development Status

This project is in **active development** with major architectural improvements completed in October 2025:

### ✅ Completed Features
- **Core Infrastructure**: Complete API framework with OAuth 2.0
- **Customer Management**: Full customer import with rich data mapping
- **Vendor Management**: Complete vendor import with automatic bank account creation
- **Data Architecture**: Specialized processing codeunits and clean data models
- **Progress Tracking**: Multi-stage progress dialogs with record counting
- **Integration Logging**: Comprehensive audit trail and error tracking
- **Role Center**: Dedicated workspace with activity monitoring

### 🚧 In Development
- **Advanced Validation**: Enhanced data validation and business rule enforcement
- **Posting Group Automation**: Automatic posting group assignments
- **Bulk Operations**: Enhanced batch processing capabilities
- **Data Comparison**: Tools for comparing e-conomic vs. Business Central data

### 📋 Planned Features
- **Item Management**: Product/service synchronization
- **Document Integration**: Invoice and order synchronization
- **Advanced Reporting**: Migration and sync status reports
- **Automated Scheduling**: Scheduled synchronization jobs

## Recent Updates (October 2025)

### Major Architectural Improvements
- **✅ Codeunit Separation**: Split monolithic code into specialized processing units
- **✅ Data Model Simplification**: Removed redundant fields, direct number mapping
- **✅ Enhanced Vendor Processing**: Rich e-conomic supplier data with bank account creation
- **✅ Progress Enhancement**: Multi-stage progress dialogs with user feedback
- **✅ HTTP Client Fixes**: Resolved Content-Type and authentication issues

### Data Model Enhancements
- **Vendor Mapping**: 20+ fields capturing comprehensive e-conomic supplier data
- **Bank Account Integration**: Automatic vendor bank account creation with full details
- **Direct Number Mapping**: e-conomic numbers used directly as Business Central keys
- **Clean Field Structure**: Removed redundant "Economic [Entity] Number" fields

## Acknowledgments

- Thanks to e-conomic for providing their API
- Business Central community for feedback and contributions
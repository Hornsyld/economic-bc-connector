# Business Central e-conomic Integration

This repository contains an AL extension for Microsoft Dynamics 365 Business Central that enables seamless integration with e-conomic accounting software. The extension allows for synchronization of general ledger accounts and journal entries between Business Central and e-conomic.

## Features

- ✅ API Integration Framework
- ✅ Economic Setup Configuration
- ✅ G/L Account Mapping
- ✅ Integration Logging
- 🚧 Journal Entry Creation (In Progress)
- 🚧 Error Handling and Validation
- 🚧 Demo Mode for Testing

## Prerequisites

- Microsoft Dynamics 365 Business Central (2022 Wave 2 or later)
- e-conomic Subscription with API Access
- API Credentials from e-conomic

## Installation

1. Download the `.app` file from the latest release
2. Install the extension in your Business Central environment
3. Configure the e-conomic setup page with your API credentials

## Configuration

1. Open the e-conomic Setup page in Business Central
2. Enter your API Key and Agreement Grant Token
3. Configure default settings for synchronization
4. Map your G/L accounts between Business Central and e-conomic

## Usage

### Setting Up the Integration

1. Navigate to the e-conomic Setup page
2. Configure your API credentials
3. Test the connection using the "Test Connection" action

### Synchronizing Accounts

1. Open the e-conomic G/L Account Mapping page
2. Use the "Get Accounts" action to fetch accounts from e-conomic
3. Map the accounts to your Business Central G/L accounts

### Viewing Integration Logs

The integration maintains detailed logs of all operations. You can view these in the e-conomic Integration Log page.

## Object Overview

| Object Type | Object ID | Name | Description |
|------------|-----------|------|-------------|
| Table | 51000 | Economic Setup | Stores API credentials and settings |
| Table | 51001 | Economic GL Account Mapping | Maps BC accounts to e-conomic accounts |
| Table | 51002 | Economic Integration Log | Stores integration activity logs |
| Page | 51000 | Economic Setup | Setup page for configuration |
| Page | 51001 | Economic GL Account Mapping | Manage account mappings |
| Page | 51002 | Economic Integration Log | View integration logs |
| Codeunit | 51000 | Economic Management | Main integration logic |

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

This project is currently in active development. Features are being added and improved regularly. Check the [Issues](../../issues) page for current development status and planned features.

## Acknowledgments

- Thanks to e-conomic for providing their API
- Business Central community for feedback and contributions
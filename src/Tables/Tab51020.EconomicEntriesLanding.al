table 51020 "Economic Entries Landing"
{
    Caption = 'Economic Entries Landing';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Economic Entry Number"; Integer)
        {
            Caption = 'Economic Entry Number';
            Description = 'Original entry number from e-conomic';
        }
        field(3; "Accounting Year"; Integer)
        {
            Caption = 'Accounting Year';
            Description = 'The accounting year this entry belongs to';
        }
        field(10; "Account Number"; Integer)
        {
            Caption = 'Account Number';
            Description = 'e-conomic account number';
        }
        field(11; Amount; Decimal)
        {
            Caption = 'Amount';
            DecimalPlaces = 2 : 5;
            Description = 'The total entry amount';
        }
        field(12; "Amount in Base Currency"; Decimal)
        {
            Caption = 'Amount in Base Currency';
            DecimalPlaces = 2 : 5;
            Description = 'The total entry amount in base currency';
        }
        field(13; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Description = 'The ISO 4217 currency code of the entry';
        }
        field(14; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            Description = 'Entry issue date';
        }
        field(15; "Due Date"; Date)
        {
            Caption = 'Due Date';
            Description = 'The date the invoice is due for payment';
        }
        field(16; "Entry Text"; Text[255])
        {
            Caption = 'Entry Text';
            Description = 'A short description about the entry';
        }
        field(17; "Entry Type"; Text[50])
        {
            Caption = 'Entry Type';
            Description = 'The type of entry (customerInvoice, supplierPayment, etc.)';
        }
        field(18; "Voucher Number"; Integer)
        {
            Caption = 'Voucher Number';
            Description = 'The identifier of the voucher this entry belongs to';
        }
        field(19; "Document Date"; Date)
        {
            Caption = 'Document Date';
            Description = 'Document date if applicable';
        }
        field(20; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            Description = 'External document number if applicable';
        }

        // Customer/Vendor Information
        field(30; "Customer Number"; Integer)
        {
            Caption = 'Customer Number';
            Description = 'e-conomic customer number if applicable';
        }
        field(31; "Supplier Number"; Integer)
        {
            Caption = 'Supplier Number';
            Description = 'e-conomic supplier number if applicable';
        }
        field(32; "Supplier Invoice Number"; Text[50])
        {
            Caption = 'Supplier Invoice Number';
            Description = 'A unique identifier of the supplier invoice';
        }

        // VAT Information
        field(40; "VAT Code"; Code[10])
        {
            Caption = 'VAT Code';
            Description = 'The unique identifier of the vat account';
        }
        field(41; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DecimalPlaces = 2 : 5;
            Description = 'VAT amount if applicable';
        }
        field(42; "VAT Base Amount"; Decimal)
        {
            Caption = 'VAT Base Amount';
            DecimalPlaces = 2 : 5;
            Description = 'VAT base amount if applicable';
        }

        // Project Information
        field(50; "Project Number"; Integer)
        {
            Caption = 'Project Number';
            Description = 'e-conomic project number if applicable';
        }

        // Quantities and Units
        field(60; "Quantity 1"; Decimal)
        {
            Caption = 'Quantity 1';
            DecimalPlaces = 2 : 5;
            Description = 'First quantity field (requires dimension module)';
        }
        field(61; "Quantity 2"; Decimal)
        {
            Caption = 'Quantity 2';
            DecimalPlaces = 2 : 5;
            Description = 'Second quantity field (requires dimension module)';
        }
        field(62; "Unit 1 Number"; Integer)
        {
            Caption = 'Unit 1 Number';
            Description = 'The unique identifier of the first unit';
        }
        field(63; "Unit 2 Number"; Integer)
        {
            Caption = 'Unit 2 Number';
            Description = 'The unique identifier of the second unit';
        }

        // Booking Information
        field(70; "Booked Invoice Number"; Integer)
        {
            Caption = 'Booked Invoice Number';
            Description = 'A unique identifier of the booked invoice';
        }
        field(71; "Invoice Number"; Integer)
        {
            Caption = 'Invoice Number';
            Description = 'Unique identifier for reminders and invoices';
        }
        field(72; Remainder; Decimal)
        {
            Caption = 'Remainder';
            DecimalPlaces = 2 : 5;
            Description = 'The remainder on the entry';
        }
        field(73; "Remainder in Base Currency"; Decimal)
        {
            Caption = 'Remainder in Base Currency';
            DecimalPlaces = 2 : 5;
            Description = 'The remainder in base currency on the entry';
        }

        // Cost Type and Departmental Distribution
        field(80; "Cost Type Number"; Integer)
        {
            Caption = 'Cost Type Number';
            Description = 'The unique identifier of cost type';
        }
        field(81; "Departmental Distribution No."; Integer)
        {
            Caption = 'Departmental Distribution No.';
            Description = 'A unique identifier of the departmental distribution';
        }

        // Processing Information
        field(90; "Import Date Time"; DateTime)
        {
            Caption = 'Import Date Time';
            Description = 'When this record was imported from e-conomic';
        }
        field(91; "Import Session ID"; Guid)
        {
            Caption = 'Import Session ID';
            Description = 'Unique identifier for the import session';
        }
        field(92; "Processing Status"; Enum "Economic Sync Status")
        {
            Caption = 'Processing Status';
            Description = 'Current processing status of this entry';
        }
        field(93; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            Description = 'Error message if processing failed';
        }
        field(94; "Created Journal Lines"; Boolean)
        {
            Caption = 'Created Journal Lines';
            Description = 'Indicates if journal lines have been created for this entry';
        }
        field(95; "Posted"; Boolean)
        {
            Caption = 'Posted';
            Description = 'Indicates if this entry has been posted in Business Central';
        }

        // Raw JSON Data
        field(100; "Raw JSON Data"; Blob)
        {
            Caption = 'Raw JSON Data';
            Description = 'Complete raw JSON data from e-conomic API';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(EconomicEntry; "Economic Entry Number", "Accounting Year")
        {
        }
        key(VoucherDate; "Voucher Number", "Posting Date")
        {
        }
        key(Processing; "Processing Status", "Import Session ID")
        {
        }
        key(Account; "Account Number", "Posting Date")
        {
        }
    }

    trigger OnInsert()
    begin
        "Import Date Time" := CurrentDateTime;
        if IsNullGuid("Import Session ID") then
            "Import Session ID" := CreateGuid();
        if "Processing Status" = "Processing Status"::New then
            "Processing Status" := "Processing Status"::New;
    end;

    procedure SetRawJSONData(JSONText: Text)
    var
        OutStream: OutStream;
    begin
        "Raw JSON Data".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(JSONText);
    end;

    procedure GetRawJSONData(): Text
    var
        InStream: InStream;
        JSONText: Text;
    begin
        CalcFields("Raw JSON Data");
        if not "Raw JSON Data".HasValue then
            exit('');

        "Raw JSON Data".CreateInStream(InStream, TextEncoding::UTF8);
        InStream.ReadText(JSONText);
        exit(JSONText);
    end;

    procedure GetUniqueVoucherDocumentNo(): Code[20]
    begin
        // Create unique document number combining voucher and date
        exit(Format("Posting Date", 0, '<Year4><Month,2><Day,2>') + '-' + Format("Voucher Number"));
    end;

    procedure HasCustomerOrVendor(): Boolean
    begin
        exit(("Customer Number" <> 0) or ("Supplier Number" <> 0));
    end;

    procedure GetAccountTypeText(): Text[20]
    begin
        case "Entry Type" of
            'customerInvoice', 'customerPayment':
                exit('Customer');
            'supplierInvoice', 'supplierPayment':
                exit('Vendor');
            'financeVoucher', 'systemEntry', 'manualDebtorInvoice':
                exit('G/L Account');
            else
                exit('G/L Account');
        end;
    end;
}
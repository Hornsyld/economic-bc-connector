enum 51010 "Economic Request Type"
{
    Caption = 'Economic Request Type';
    Extensible = true;

    value(0; Undefined)
    {
        Caption = 'Undefined';
    }
    value(1; Customer)
    {
        Caption = 'Customer';
    }
    value(2; Vendor)
    {
        Caption = 'Vendor';
    }
    value(3; Account)
    {
        Caption = 'Account';
    }
    value(4; VATCode)
    {
        Caption = 'VAT Code';
    }
    value(5; PaymentTerms)
    {
        Caption = 'Payment Terms';
    }
    value(6; Invoice)
    {
        Caption = 'Invoice';
    }
    value(7; CreditMemo)
    {
        Caption = 'Credit Memo';
    }
    value(8; Journal)
    {
        Caption = 'Journal';
    }
}
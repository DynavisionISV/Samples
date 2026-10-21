tableextension 50003 DYN20ReportDocumentLine extends "ESCA Report Document Line" // 71096667
{
    fields
    {
        field(50002; "DYN Item Reference"; Code[50])
        {
            AllowInCustomizations = Never;
            Caption = 'Item Reference Barcode';
            ToolTip = 'Specifies the value of the Item Reference Barcode field.';
        }
    }
}
tableextension 50006 DYN24ReportDocumentLine extends "ESCA Report Document Line" // 71096667
{
    fields
    {
        field(50003; "DYN Original Qty"; Decimal)
        {
            AllowInCustomizations = Never;
            Caption = 'Original Quantity';
            ToolTip = 'Specifies the value of the Original Quantity field.';
        }
    }
}
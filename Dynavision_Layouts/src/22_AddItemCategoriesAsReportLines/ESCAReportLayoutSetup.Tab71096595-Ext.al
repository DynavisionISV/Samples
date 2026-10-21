tableextension 50001 DYN22ReportLayoutSetup extends "ESCA Report Layout Setup" // 71096595
{
    fields
    {
        field(50000; "DYN Print Quote Categories"; Boolean)
        {
            AllowInCustomizations = AsReadWrite;
            Caption = 'Print Sales Quote Categories';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the value of the Print Sales Quote Categories field.';
        }
    }
}
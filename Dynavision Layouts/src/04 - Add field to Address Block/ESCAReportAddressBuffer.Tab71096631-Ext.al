tableextension 50005 DYN04ReportAddressBuffer extends "ESCA Report Address Buffer" // 71096631
{
    fields
    {
        field(50000; "DYN RPR"; Text[150])
        {
            AllowInCustomizations = Never;
            Caption = 'RPR';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the value of the RPR field.';
        }
    }
}
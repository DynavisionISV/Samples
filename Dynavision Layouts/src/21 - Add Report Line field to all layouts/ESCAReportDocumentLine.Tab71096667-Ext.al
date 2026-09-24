tableextension 50002 DYN21ReportDocumentLine extends "ESCA Report Document Line" // 71096667
{
    fields
    {
        field(50001; "DYN Location Code"; Code[10])
        {
            AllowInCustomizations = Never;
            Caption = 'Location Code';
            ToolTip = 'Specifies the value of the Location Code field.';
        }
    }
}
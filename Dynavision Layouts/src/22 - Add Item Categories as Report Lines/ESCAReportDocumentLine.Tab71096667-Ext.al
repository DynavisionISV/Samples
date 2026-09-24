tableextension 50000 DYN22ReportDocumentLine extends "ESCA Report Document Line" // 71096667
{
    fields
    {
        field(50000; "DYN Parent Item Category"; Code[20])
        {
            AllowInCustomizations = Never;
            Caption = 'Parent Item Category';
            ToolTip = 'Specifies the value of the Parent Item Category field.';
        }
    }

    internal procedure SetCategorySortingValue()
    begin
        "Sorting Value" := PadStr("DYN Parent Item Category", 20, ' ') + PadStr("Item Category Code", 20, ' ') + PadStr("Item No.", 20, ' ');
    end;
}
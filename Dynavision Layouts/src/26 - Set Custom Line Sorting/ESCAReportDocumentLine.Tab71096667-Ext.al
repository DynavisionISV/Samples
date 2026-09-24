tableextension 50007 DYN26ReportDocumentLine extends "ESCA Report Document Line" // 71096667
{
    fields
    {
        field(50004; "DYN Shelf No."; Code[20])
        {
            AllowInCustomizations = Never;
            Caption = 'Shelf Number';
            ToolTip = 'Specifies the value of the Shelf Number field.';
        }
    }

    internal procedure SetTransferSortingValue()
    begin
        "Sorting Value" := PadStr("DYN Shelf No.", 20, ' ') + PadStr("Item No.", 20, ' ');
    end;
}
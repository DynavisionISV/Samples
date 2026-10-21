reportextension 50003 DYN20SalesOrder extends "ESCR Sales Order" // 71097276
{
    dataset
    {
        modify(Line)
        {
            trigger OnAfterAfterGetRecord()
            var
                ItemReference: Record "Item Reference";
            begin
                // When the line is skipped in the OnAfterGetRecord, we still get into this trigger.
                // https://github.com/microsoft/AL/issues/7039
                // So we need to check if the line is skipped and exit if it is.
                if ReportDocumentLine."Source SystemId" <> Line.SystemId then
                    exit;

                ReportDocumentLine."DYN Item Reference" := '';

                ItemReference.Reset();
                ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
                ItemReference.SetRange("Item No.", Line."No.");
                ItemReference.SetRange("Unit of Measure", Line."Unit of Measure Code");
                if ItemReference.FindFirst() then
                    ReportDocumentLine."DYN Item Reference" := ItemReference."Reference No.";

                ReportDocumentLine.Modify(false);
            end;
        }
    }
}
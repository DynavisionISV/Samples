reportextension 50004 DYN23SalesOrder extends "ESCR Sales Order" // 71097276
{
    dataset
    {
        modify(ReportDocumentLine)
        {
            trigger OnBeforePostDataItem()
            begin
                // Add condition based on customer, ...
                GroupReportDocumentLines();
            end;
        }
    }

    local procedure GroupReportDocumentLines()
    var
        TempReportDocumentLineCopy, TempReportDocumentLineParent : Record "ESCA Report Document Line" temporary;
    begin
        TempReportDocumentLineCopy.Copy(ReportDocumentLine, true);
        TempReportDocumentLineParent.Copy(ReportDocumentLine, true);

        TempReportDocumentLineCopy.SetCurrentKey("Item No.", "Unit of Measure Code", "Variant Code", "Unit Price / Cost");
        TempReportDocumentLineCopy.SetFilter("Item No.", '<>%1', '');
        if TempReportDocumentLineCopy.FindSet() then
            repeat
                if (TempReportDocumentLineParent."Item No." <> TempReportDocumentLineCopy."Item No.") or
                   (TempReportDocumentLineParent."Unit of Measure Code" <> TempReportDocumentLineCopy."Unit of Measure Code") or
                   (TempReportDocumentLineParent."Variant Code" <> TempReportDocumentLineCopy."Variant Code") or
                     (TempReportDocumentLineParent."Unit Price / Cost" <> TempReportDocumentLineCopy."Unit Price / Cost") then begin
                    TempReportDocumentLineParent := TempReportDocumentLineCopy;

                    TempReportDocumentLineCopy.Quantity := GetTotalQuantity(TempReportDocumentLineCopy);
                    TempReportDocumentLineCopy."Line Amount" := TempReportDocumentLineCopy.Quantity * TempReportDocumentLineCopy."Unit Price / Cost"; // Rounding, discounts, ...
                    TempReportDocumentLineCopy.Modify();
                end else
                    DeleteLinesForGroup(TempReportDocumentLineCopy);

            until TempReportDocumentLineCopy.Next() = 0;
    end;

    local procedure GetTotalQuantity(var TempReportDocumentLine: Record "ESCA Report Document Line" temporary): Decimal
    var
        TempReportDocumentLineCopy: Record "ESCA Report Document Line" temporary;
    begin
        TempReportDocumentLineCopy.Copy(TempReportDocumentLine, true);

        TempReportDocumentLineCopy.Reset();
        TempReportDocumentLineCopy.SetRange("Item No.", TempReportDocumentLine."Item No.");
        TempReportDocumentLineCopy.SetRange("Unit of Measure Code", TempReportDocumentLine."Unit of Measure Code");
        TempReportDocumentLineCopy.SetRange("Variant Code", TempReportDocumentLine."Variant Code");
        TempReportDocumentLineCopy.SetRange("Unit Price / Cost", TempReportDocumentLine."Unit Price / Cost");
        TempReportDocumentLineCopy.CalcSums(Quantity);

        exit(TempReportDocumentLineCopy.Quantity);
    end;

    local procedure DeleteLinesForGroup(var TempReportDocumentLine: Record "ESCA Report Document Line" temporary)
    var
        TempReportDocumentLineCopy: Record "ESCA Report Document Line" temporary;
    begin
        TempReportDocumentLineCopy.Copy(TempReportDocumentLine, true);

        TempReportDocumentLineCopy.Reset();
        TempReportDocumentLineCopy.SetRange("Group", TempReportDocumentLine."Group");
        if not TempReportDocumentLineCopy.IsEmpty() then
            TempReportDocumentLineCopy.DeleteAll();
    end;
}
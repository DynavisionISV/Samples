reportextension 50006 DYN25WarehouseShipment extends "ESCR Warehouse Shipment" // 71097288
{
    dataset
    {
        modify(Line)
        {
            trigger OnAfterPreDataItem()
            var
                FirstLine: Record "Warehouse Shipment Line";
                PurchaseHeader: Record "Purchase Header";
                SalesHeader: Record "Sales Header";
            begin
                FirstLine.Reset();
                FirstLine.SetRange("No.", Document."No.");
                if not FirstLine.FindFirst() then
                    exit;

                case FirstLine."Source Type" of
                    Database::"Purchase Line":
                        begin
                            PurchaseHeader.SetLoadFields("ESCR Purchaser Name");
                            PurchaseHeader.SetAutoCalcFields("ESCR Purchaser Name");
                            if PurchaseHeader.Get(FirstLine."Source Subtype", FirstLine."Source No.") then
                                ReportLayout.AddTextLine(ReportDocumentLine, TextConstant.ReturnTextConstant('DYN_PURCHASER', LanguageCode) + PurchaseHeader."ESCR Purchaser Name", LineSorting)
                            else
                                exit;
                        end;
                    Database::"Sales Line":
                        begin
                            SalesHeader.SetLoadFields("ESCR Salesperson Name");
                            SalesHeader.SetAutoCalcFields("ESCR Salesperson Name");
                            if SalesHeader.Get(FirstLine."Source Subtype", FirstLine."Source No.") then
                                ReportLayout.AddTextLine(ReportDocumentLine, TextConstant.ReturnTextConstant('DYN_SALESPERSON', LanguageCode) + SalesHeader."ESCR SalesPerson Name", LineSorting)
                            else
                                exit;
                        end;
                    else
                        exit;
                end;
            end;
        }
    }
}
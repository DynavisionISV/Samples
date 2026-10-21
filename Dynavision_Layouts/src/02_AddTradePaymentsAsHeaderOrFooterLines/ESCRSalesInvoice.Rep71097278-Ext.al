reportextension 50000 DYN02SalesInvoice extends "ESCR Sales Invoice" // 71097278
{
    dataset
    {
        modify(CopyLoop)
        {
            trigger OnAfterAfterGetRecord()
            begin
                if ReportLayoutSetup."Print Payment Method" = ReportLayoutSetup."Print Payment Method"::Header then
                    AddPaymentInformation(Document."No.", HeaderText)
                else
                    if ReportLayoutSetup."Print Payment Method" = ReportLayoutSetup."Print Payment Method"::Footer then
                        AddPaymentInformation(Document."No.", FooterText);
            end;
        }
    }

    local procedure AddPaymentInformation(DocumentNo: Code[20]; var TextList: List of [Text])
    var
        PaymentPerDoc: Record "ESCB Payment Meth. Per Doc.";
        PaymentMethod: Record "Payment Method";
        PaymentCode: Code[10];
        Amount: Decimal;
        PaymentDictionary: Dictionary of [Code[10], Decimal];
    begin
        PaymentPerDoc.Reset();
        PaymentPerDoc.SetRange("Posted Document No.", DocumentNo);
        PaymentPerDoc.SetRange("Source Table", Database::"Sales Header");
        if PaymentPerDoc.FindSet() then begin
            repeat
                if PaymentDictionary.ContainsKey(PaymentPerDoc."Payment Method Code") then begin
                    PaymentDictionary.Get(PaymentPerDoc."Payment Method Code", Amount);
                    Amount := Amount + PaymentPerDoc.Amount;
                    PaymentDictionary.Set(PaymentPerDoc."Payment Method Code", Amount);
                end
                else
                    PaymentDictionary.Add(PaymentPerDoc."Payment Method Code", PaymentPerDoc.Amount);
            until PaymentPerDoc.Next() = 0;

            if PaymentDictionary.Count > 0 then
                foreach PaymentCode in PaymentDictionary.Keys do begin
                    PaymentDictionary.Get(PaymentCode, Amount);
                    PaymentMethod.Get(PaymentCode);

                    TextList.Add(StrSubstNo('%1 (%2)', PaymentMethod.Description, ReportLayout.FormatPriceWithCurrency(Amount, false, CurrencySignTotal)));
                end;
        end;
    end;
}
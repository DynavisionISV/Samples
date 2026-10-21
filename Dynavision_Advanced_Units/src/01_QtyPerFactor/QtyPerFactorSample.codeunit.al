codeunit 50600 "DYN QtyPer Factor Sample"
{
    // Manual event subscribers used by ESCU QtyPer Factor Tests to simulate a partner customization.
    //
    // Scenario supported (joint / waste allowance on sales and purchase lines):
    // Item master stores the theoretical conversion (e.g. 100 bricks per m² for a 20×5 cm brick).
    // Mortar joints mean fewer bricks fit in one m², so invoicing qty in m² must increase for the same piece count.
    // A real PTE would store Joint Allowance % on the document line (or setup) and return that value here.
    // This sample always returns 26% — Scenario B (1 cm joints on all sides → area factor 1.26).
    //
    // Host applies: EffectiveQtyPer = QtyPer / (1 + CustomPercentage / 100)
    // Example: 900 pcs → 11.34 m² instead of 9.00 m²; derived line factor 0.0126 survives quantity changes.
    //
    // Same pattern on "ESCU Inv. Unit Worksheet Mgt." for requisition lines when needed.

    Access = Internal;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCU Invoicing Unit Sales", OnGetCustomPercentageForQtyPer, '', false, false)]
    local procedure OnGetCustomPercentageForQtyPerSales(SalesLine: Record "Sales Line"; var CustomPercentage: Decimal)
    begin
        CustomPercentage := 26;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCU Invoicing Unit Purchase", OnGetCustomPercentageForQtyPer, '', false, false)]
    local procedure OnGetCustomPercentageForQtyPerPurchase(PurchaseLine: Record "Purchase Line"; var CustomPercentage: Decimal)
    begin
        CustomPercentage := 26;
    end;

    /*
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCU Invoicing Unit Sales", OnGetCustomPercentageForQtyPer, '', true, true)]
    local procedure OnGetCustomPercentageForQtyPer(SalesLine: Record "Sales Line"; var CustomPercentage: Decimal)
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
        Item: Record Item;
    begin
        if SalesLine.Type <> SalesLine.Type::Item then
            exit;
        if SalesLine."No." = '' then
            exit;
        if (SalesLine."ESCU Head Joint" = 0) and (SalesLine."ESCU Bed Joint" = 0) then
            exit;

        Item.SetLoadFields("Base Unit of Measure");
        if not Item.Get(SalesLine."No.") then
            exit;
        if Item."Base Unit of Measure" = '' then
            exit;
        if not ItemUnitofMeasure.Get(Item."No.", Item."Base Unit of Measure") then
            exit;
        if (ItemUnitofMeasure.Length = 0) or (ItemUnitofMeasure.Height = 0) then
            exit;

        CustomPercentage :=
            ((ItemUnitofMeasure.Length + SalesLine."ESCU Head Joint") * (ItemUnitofMeasure.Height + SalesLine."ESCU Bed Joint")) /
            (ItemUnitofMeasure.Length * ItemUnitofMeasure.Height);
        CustomPercentage := (CustomPercentage - 1) * 100;
    end;
    */
}
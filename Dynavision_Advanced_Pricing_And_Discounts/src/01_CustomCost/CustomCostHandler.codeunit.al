codeunit 50400 "DYN Custom Cost Handler"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    // Fields:
    // The Custom Cost field and Cost Source fields are using ApplicationArea = ESCPCustomCost
    // ESCPAdvancedPricingSetup."Custom Cost" --> set to true if they need to be visible.
    // Use ESCPCustomCost if you need to 'mask' / apply the same visibility for your own features etc.

    // Custom Cost Calculation
    // Formula: NewCustomCost := BaseCost * CostFactor + FixedCostAddition
    // PTEs can extend this logic with item-specific, vendor-specific, or variant-specific rules.

    local procedure CalculateCustomCost(BaseCost: Decimal; var NewCustomCost: Decimal)
    var
        Setup: Record "DYN Custom Cost Setup";
    begin
        if BaseCost = 0 then
            exit;
        Setup.GetRecordOnce();
        if not Setup.Active then
            exit;

        if (Setup."Cost Factor" = 0) and (Setup."Fixed Cost Addition" = 0) then
            exit;
        NewCustomCost := BaseCost * Setup."Cost Factor" + Setup."Fixed Cost Addition";
    end;

    // Event Subscribers
    // Subscribe to all Custom Cost events from Dynavision Advanced Pricing.
    // Each event provides the current base cost and a var parameter for the new custom cost.

    [EventSubscriber(ObjectType::Table, Database::"Price List Line", ESCPOnUpdateCustomCostOnBeforeCopyBaseCostToCustomCost, '', false, false)]
    local procedure PriceListLine_OnBeforeCopyBaseCostToCustomCost(PriceListLine: Record "Price List Line"; var NewCustomCost: Decimal)
    begin
        CalculateCustomCost(PriceListLine."ESCP Cost Per Base UOM (LCY)", NewCustomCost);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price Worksheet Line", ESCPOnUpdateCustomCostOnBeforeCopyBaseCostToCustomCost, '', false, false)]
    local procedure PriceWorksheetLine_OnBeforeCopyBaseCostToCustomCost(PriceWorksheetLine: Record "Price Worksheet Line"; var NewCustomCost: Decimal)
    begin
        CalculateCustomCost(PriceWorksheetLine."ESCP Cost Per Base UOM (LCY)", NewCustomCost);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCP Pricing BaseUOM LCY Mgt.", OnUpdateCustomCostOnBeforeCopyBaseCostToCustomCost, '', false, false)]
    local procedure BaseUOMMgt_OnBeforeCopyBaseCostToCustomCost(var PriceListLine: Record "Price List Line"; RequestedCalcDate: Date; var NewCustomCost: Decimal)
    begin
        CalculateCustomCost(PriceListLine."ESCP Cost Per Base UOM (LCY)", NewCustomCost);
    end;

    [EventSubscriber(ObjectType::Table, Database::"ESCP Purchase Price Selection", OnAfterGetCustomCostPerBaseUOM, '', false, false)]
    local procedure PurchasePriceSelection_OnAfterGetCustomCostPerBaseUOM(PurchasePriceSelection: Record "ESCP Purchase Price Selection"; var CustomCostPerBaseUOMLCYExclVAT: Decimal)
    begin
        CalculateCustomCost(PurchasePriceSelection."Cost Per Base UOM (LCY)", CustomCostPerBaseUOMLCYExclVAT);
    end;

    // Custom Cost Setup events
    // Use when your users will always use the custom cost field on their setup records.
    // Make sure you're setting this only for the allowed "Pricing Lookup Method"
    local procedure SetCostSourceAccordingToSetup(Variant: Variant; PricingLookupMethod: Enum "ESCP Adv. Price Lookup Method"; var DefaultCostSource: Enum "ESCP Cost Source")
    var
        Setup: Record "DYN Custom Cost Setup";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        Setup.GetRecordOnce();
        if not Setup.Active then
            exit;

        if not DataTypeManagement.GetRecordRef(Variant, RecRef) then
            exit;

        case RecRef.Number() of
            Database::"ESCP Purchase Price Form.Templ", Database::"ESCP Purchase Price Formula":
                if (PricingLookupMethod in [PricingLookupMethod::"From Selection", PricingLookupMethod::Lowest, PricingLookupMethod::Highest]) then
                    DefaultCostSource := Setup."Purch. Price Form. Cost Source";

            Database::"ESCP Margin Cost Definition":
                if (PricingLookupMethod in [PricingLookupMethod::Lowest, PricingLookupMethod::Highest]) then
                    DefaultCostSource := Setup."Margin Cost Source";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"ESCP Purchase Price Form.Templ", OnBeforeSetDefaultCostSource, '', false, false)]
    local procedure ESCPPurchasePriceFormTempl_OnBeforeSetDefaultCostSource(Rec: Record "ESCP Purchase Price Form.Templ"; var DefaultCostSource: Enum "ESCP Cost Source")
    begin
        // If some customer logic applies to the Rec then:
        SetCostSourceAccordingToSetup(Rec, Rec."Pricing Lookup Method", DefaultCostSource);
    end;

    [EventSubscriber(ObjectType::Table, Database::"ESCP Purchase Price Formula", OnBeforeSetDefaultCostSource, '', false, false)]
    local procedure ESCPPurchasePriceFormula_OnBeforeSetDefaultCostSource(Rec: Record "ESCP Purchase Price Formula"; var DefaultCostSource: Enum "ESCP Cost Source")
    begin
        // If some customer logic applies to the Rec then:
        SetCostSourceAccordingToSetup(Rec, Rec."Pricing Lookup Method", DefaultCostSource);
    end;

    [EventSubscriber(ObjectType::Table, Database::"ESCP Margin Cost Definition", OnBeforeSetDefaultCostSource, '', false, false)]
    local procedure ESCPMarginCostDefinition_OnBeforeSetDefaultCostSource(Rec: Record "ESCP Margin Cost Definition"; var DefaultCostSource: Enum "ESCP Cost Source")
    begin
        // If some customer logic applies to the Rec then:
        SetCostSourceAccordingToSetup(Rec, Rec."Pricing Lookup Method", DefaultCostSource);
    end;
}
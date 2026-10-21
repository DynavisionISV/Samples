codeunit 50401 "DYN Margin Calc. Events"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    // Dynavision Advanced Pricing & Discounts — Custom Price Factor Type Reference PTE
    //
    // This codeunit demonstrates how a Per-Tenant Extension (PTE) implements a custom
    // "ESCP Price Factor Type" enum value ("PTE Margin from Item UoM") and integrates
    // with Dynavision Advanced Pricing calculation reports and document margin status.
    //
    // Key Architectural Pattern — Dedicated PTE Setup Table:
    // ---------------------------------------------------------------------------------
    // The standard table "ESCP Item Price Margin" has a primary key of:
    //   ("Item No.", "Variant Code", "Price Margin Code")
    // It does not include a "Unit of Measure Code" field. Therefore, storing per-unit-of-measure
    // margin parameters (such as targeted margin % or margin threshold %) directly in standard
    // margin tables is not possible without creating separate price margin codes per UoM
    // (which still does not provide line UoM context on margin calculation pages).
    //
    // To solve this cleanly, this sample introduces a dedicated PTE table:
    //   "PTE Item UoM Margin Setup" (PK: "Item No.", "Unit of Measure Code")
    // containing:
    //   - "Targeted Margin %" — used during batch price calculation
    //   - "Threshold %"       — used for green/red margin status indication on documents
    //
    // Integration Points Demonstrated:
    // ---------------------------------------------------------------------------------
    // 1. Setup & Formula Validation:
    //    Allowing margin formulas & targeted margin on custom price factor types, and
    //    clearing/resetting incompatible fields during setup.
    // 2. Advanced Price Calculation (Report "ESCP Adv. Price Calculation"):
    //    Verifying formulas and calculating selling prices per Unit of Measure using the
    //    ItemUnitofMeasure parameter on OnAdjustPriceAccordingToPriceFactorElseCase.
    // 3. Document Margin Status & Threshold Overrides (OnBeforeSetMarginStatus):
    //    Overriding the margin status threshold dynamically per Unit of Measure on
    //    Sales Lines, Price List Lines, Price Worksheet Lines, and the simulation page.
    //
    // Execution Lifecycle Order:
    // ---------------------------------------------------------------------------------
    // Phase 1: Setup & Formula Validation (when user edits price formulas or templates in UI)
    //   1. OnValidatePriceFactorTypeElseCase (Table "ESCP Calculation Price Formula")
    //   2. OnValidatePriceFactorTypeElseCase (Table "ESCP Calc. Price Formula Templ")
    //   3. OnErrorIfTypeDoesNotSupportMarginFormulasElseCase (Table "ESCP Calculation Price Formula")
    //   4. OnErrorIfTypeDoesNotSupportMarginFormulasElseCase (Table "ESCP Calc. Price Formula Templ")
    //   5. OnBeforeCreateCalcPriceFormulaFromTemplate (Table "ESCP Calc. Price Formula Templ")
    //   6. OnAfterCreateCalcPriceFormulaFromTemplate (Table "ESCP Calc. Price Formula Templ")
    //
    // Phase 2: Price Calculation (when report "ESCP Adv. Price Calculation" runs)
    //   7. OnSetAndVerifyPriceFormulaElseCase (Report "ESCP Adv. Price Calculation")
    //   8. OnAdjustPriceAccordingToPriceFactorElseCase (Report "ESCP Adv. Price Calculation")
    //   9. OnAfterAdjustPriceAccordingToPriceFactor (Report "ESCP Adv. Price Calculation")
    //  10. OnGenerateTempPriceWorksheetLineForUnitOfMeasureOnBeforeModify (Report "ESCP Adv. Price Calculation")
    //
    // Phase 3: Margin Status & Threshold Overrides (when lines/documents are calculated)
    //  11. OnBeforeSetMarginStatus (Codeunit "ESCP Sales Line Margin Mgt.")
    //  12. OnBeforeSetMarginStatus (Codeunit "ESCP PriceListLine Margin Mgt.")
    //  13. OnBeforeSetMarginStatus (Codeunit "ESCP PriceWrkShLine Margin Mgt")
    //  14. OnBeforeSetMarginStatus (Page "ESCP Calc. Item Price Margins")

    // Phase 1: Setup and Formula Validation

    #region EventSubscriber Table "ESCP Calculation Price Formula" OnValidatePriceFactorTypeElseCase
    // Event: OnValidatePriceFactorTypeElseCase on Table "ESCP Calculation Price Formula"
    // Status: Existing event
    //
    // General Purpose:
    //   Called when the "Price Factor Type" field is validated on a Calculation Price Formula
    //   and hits the 'else' branch of the standard case statement (i.e. custom enum values).
    //   Use this to clear or initialize custom/incompatible fields when switching types.
    //
    // Important Validation Rule:
    //   Field "Multiply Coefficient" has an OnValidate trigger that enforces:
    //   if "Multiply Coefficient" <> 1 then TestField("Price Factor Type", "Price Factor Type"::Coefficient);
    //   Therefore, resetting the coefficient for non-coefficient types must validate to 1 (not 0).
    //
    // Partner Use Case:
    //   When a user switches to or from a custom price factor type, use this trigger to clear or reset
    //   any custom fields added via table extensions and ensure standard fields remain valid.
    //
    // Sample Implementation:
    //   When our custom type ("PTE Margin from Item UoM") is selected, ensure "Multiply Coefficient" is set to 1.
    [EventSubscriber(ObjectType::Table, Database::"ESCP Calculation Price Formula", OnValidatePriceFactorTypeElseCase, '', false, false)]
    local procedure ESCPCalculationPriceFormula_OnValidatePriceFactorTypeElseCase(var Rec: Record "ESCP Calculation Price Formula"; xRec: Record "ESCP Calculation Price Formula")
    begin
        if Rec."Price Factor Type" <> Rec."Price Factor Type"::"DYN Margin from Item UoM" then
            exit;

        // "Multiply Coefficient" requires Price Factor Type = Coefficient unless value is 1
        if Rec."Multiply Coefficient" <> 1 then
            Rec.Validate("Multiply Coefficient", 1);
    end;
    #endregion EventSubscriber Table "ESCP Calculation Price Formula" OnValidatePriceFactorTypeElseCase

    #region EventSubscriber Table "ESCP Calc. Price Formula Templ" OnValidatePriceFactorTypeElseCase
    // Event: OnValidatePriceFactorTypeElseCase on Table "ESCP Calc. Price Formula Templ"
    // Status: Existing event
    //
    // General Purpose:
    //   Identical to the formula validation event above, but triggered on the template table
    //   ("ESCP Calc. Price Formula Templ") when setting up calculation formula templates.
    //
    // Important Validation Rule:
    //   Like the live formula table, validating "Multiply Coefficient" to any value other than 1
    //   requires "Price Factor Type" = Coefficient. Reset to 1 for custom types.
    //
    // Partner Use Case:
    //   Applies identical cleanup/validation logic on formula templates to keep template configuration
    //   consistent with live formulas.
    //
    // Sample Implementation:
    //   Applies the same reset logic on the template record.
    [EventSubscriber(ObjectType::Table, Database::"ESCP Calc. Price Formula Templ", OnValidatePriceFactorTypeElseCase, '', false, false)]
    local procedure ESCPCalcPriceFormulaTempl_OnValidatePriceFactorTypeElseCase(var Rec: Record "ESCP Calc. Price Formula Templ"; xRec: Record "ESCP Calc. Price Formula Templ")
    begin
        if Rec."Price Factor Type" <> Rec."Price Factor Type"::"DYN Margin from Item UoM" then
            exit;

        if Rec."Multiply Coefficient" <> 1 then
            Rec.Validate("Multiply Coefficient", 1);
    end;
    #endregion EventSubscriber Table "ESCP Calc. Price Formula Templ" OnValidatePriceFactorTypeElseCase

    #region EventSubscriber Table "ESCP Calculation Price Formula" OnErrorIfTypeDoesNotSupportMarginFormulasElseCase
    // Event: OnErrorIfTypeDoesNotSupportMarginFormulasElseCase on Table "ESCP Calculation Price Formula"
    // Status: Existing event
    //
    // General Purpose:
    //   By default, Dynavision throws an error when a user selects a Margin Calculation Formula
    //   or enters a Targeted Margin on a formula record whose Price Factor Type is not
    //   "Margin Calculation Formula" or "Item Margin Calc.Formula".
    //   This event allows custom price factor types that rely on margin formulas and targeted margins
    //   to suppress that error by setting SkipError := true.
    //
    // App Extensibility Detail:
    //   In Dynavision Advanced Pricing, both the "Margin Calculation Formula" OnValidate trigger and
    //   the "Targeted Margin" OnValidate trigger call this event in their else branches.
    //   Setting SkipError := true enables BOTH fields for your custom price factor type.
    //
    // Partner Use Case:
    //   If your custom calculation type uses a Margin Calculation Formula or targeted margin %
    //   (e.g., retrieving an item margin or calculating price from cost + margin), set SkipError := true.
    //
    // Sample Implementation:
    //   Our custom type ("PTE Margin from Item UoM") also uses margin formulas and targeted margins to compute selling prices,
    //   so we set SkipError := true to permit assigning a Margin Calculation Formula and Targeted Margin.
    [EventSubscriber(ObjectType::Table, Database::"ESCP Calculation Price Formula", OnErrorIfTypeDoesNotSupportMarginFormulasElseCase, '', false, false)]
    local procedure ESCPCalculationPriceFormula_OnErrorIfTypeDoesNotSupportMarginFormulasElseCase(Rec: Record "ESCP Calculation Price Formula"; var SkipError: Boolean)
    begin
        if Rec."Price Factor Type" = Rec."Price Factor Type"::"DYN Margin from Item UoM" then
            SkipError := true;
    end;
    #endregion EventSubscriber Table "ESCP Calculation Price Formula" OnErrorIfTypeDoesNotSupportMarginFormulasElseCase

    #region EventSubscriber Table "ESCP Calc. Price Formula Templ" OnErrorIfTypeDoesNotSupportMarginFormulasElseCase
    // Event: OnErrorIfTypeDoesNotSupportMarginFormulasElseCase on Table "ESCP Calc. Price Formula Templ"
    // Status: Existing event
    //
    // General Purpose:
    //   Same error suppression as above, but for the template table ("ESCP Calc. Price Formula Templ").
    //   Suppresses validation errors for both "Margin Calculation Formula" and "Targeted Margin"
    //   on calculation price formula templates.
    //
    // Partner Use Case:
    //   Suppresses the same error on formula templates so users can select margin formulas when defining templates.
    //
    // Sample Implementation:
    //   Suppresses the error for "PTE Margin from Item UoM" on templates.
    [EventSubscriber(ObjectType::Table, Database::"ESCP Calc. Price Formula Templ", OnErrorIfTypeDoesNotSupportMarginFormulasElseCase, '', false, false)]
    local procedure ESCPCalcPriceFormulaTempl_OnErrorIfTypeDoesNotSupportMarginFormulasElseCase(Rec: Record "ESCP Calc. Price Formula Templ"; var SkipError: Boolean)
    begin
        if Rec."Price Factor Type" = Rec."Price Factor Type"::"DYN Margin from Item UoM" then
            SkipError := true;
    end;
    #endregion EventSubscriber Table "ESCP Calc. Price Formula Templ" OnErrorIfTypeDoesNotSupportMarginFormulasElseCase

    #region EventSubscriber Table "ESCP Calc. Price Formula Templ" OnBeforeCreateCalcPriceFormulaFromTemplate
    // Event: OnBeforeCreateCalcPriceFormulaFromTemplate on Table "ESCP Calc. Price Formula Templ"
    // Status: Existing event
    //
    // General Purpose:
    //   Fires before standard logic instantiates a Calculation Price Formula from a template.
    //   Allows a PTE to take complete control of formula creation by setting Handled := true,
    //   bypassing the standard DoCreateCalcPriceFormulaFromTemplate logic.
    //
    // Partner Use Case:
    //   If custom creation logic is needed (e.g. creating multiple formula records or conditionally
    //   generating formula steps), implement it here and set Handled := true.
    //
    // Sample Implementation:
    //   Checks if the template uses our custom type. If standard creation is sufficient,
    //   leave Handled := false so standard fields are populated automatically, and use
    //   OnAfterCreateCalcPriceFormulaFromTemplate to transfer any custom fields.
    [EventSubscriber(ObjectType::Table, Database::"ESCP Calc. Price Formula Templ", OnBeforeCreateCalcPriceFormulaFromTemplate, '', false, false)]
    local procedure ESCPCalcPriceFormulaTempl_OnBeforeCreateCalcPriceFormulaFromTemplate(var CalcPriceFormulaTempl: Record "ESCP Calc. Price Formula Templ"; AdvPriceCalculationCode: Code[20]; PurchasePriceFormulaCode: Code[20]; var CurrentCalculationPriceFormula: Record "ESCP Calculation Price Formula"; var CurrentSuffix: Integer; var Handled: Boolean)
    begin
        if CalcPriceFormulaTempl."Price Factor Type" <> CalcPriceFormulaTempl."Price Factor Type"::"DYN Margin from Item UoM" then
            exit;

        // Leave Handled := false to allow standard template creation to execute.
        // Set Handled := true only if your extension completely replaces the standard creation routine.
    end;
    #endregion EventSubscriber Table "ESCP Calc. Price Formula Templ" OnBeforeCreateCalcPriceFormulaFromTemplate

    #region EventSubscriber Table "ESCP Calc. Price Formula Templ" OnAfterCreateCalcPriceFormulaFromTemplate
    // Event: OnAfterCreateCalcPriceFormulaFromTemplate on Table "ESCP Calc. Price Formula Templ"
    // Status: Existing event
    //
    // General Purpose:
    //   Fires after a new Calculation Price Formula has been instantiated from a template.
    //   Use this to transfer custom table extension fields from the template record to the live formula record.
    //
    // Partner Use Case:
    //   When custom table extension fields exist on both the template and live formula tables,
    //   copy the custom field values from CalcPriceFormulaTempl to CurrentCalculationPriceFormula
    //   and call CurrentCalculationPriceFormula.Modify(true).
    //
    // Sample Implementation:
    //   Inspects the Price Factor Type. When custom fields are added to both tables via table extensions,
    //   copy them here and persist the changes.
    [EventSubscriber(ObjectType::Table, Database::"ESCP Calc. Price Formula Templ", OnAfterCreateCalcPriceFormulaFromTemplate, '', false, false)]
    local procedure ESCPCalcPriceFormulaTempl_OnAfterCreateCalcPriceFormulaFromTemplate(var CalcPriceFormulaTempl: Record "ESCP Calc. Price Formula Templ"; AdvPriceCalculationCode: Code[20]; PurchasePriceFormulaCode: Code[20]; var CurrentCalculationPriceFormula: Record "ESCP Calculation Price Formula"; var CurrentSuffix: Integer)
    begin
        if CurrentCalculationPriceFormula."Price Factor Type" <> CurrentCalculationPriceFormula."Price Factor Type"::"DYN Margin from Item UoM" then
            exit;

        // If table extensions are added to both tables, map custom fields here:
        // CurrentCalculationPriceFormula."Custom Field" := CalcPriceFormulaTempl."Custom Field";
        // CurrentCalculationPriceFormula.Modify(true);
    end;
    #endregion EventSubscriber Table "ESCP Calc. Price Formula Templ" OnAfterCreateCalcPriceFormulaFromTemplate

    // Phase 2: Price Calculation (Report "ESCP Adv. Price Calculation")

    #region EventSubscriber Report "ESCP Adv. Price Calculation" OnSetAndVerifyPriceFormulaElseCase
    // Event: OnSetAndVerifyPriceFormulaElseCase on Report "ESCP Adv. Price Calculation"
    // Status: Existing event
    //
    // General Purpose:
    //   Called before price calculation begins to verify that a valid price formula text exists
    //   and can be evaluated. If Result := false, the report will skip calculation for the line.
    //
    // Partner Use Case:
    //   Validates that the price formula can be resolved and parsed before batch calculation begins.
    //   Placeholders can be replaced with dummy test values (cost=100, margin=25) to test evaluation
    //   via "ESCA Evaluate Expression". If syntax is valid, sets Result := true.
    //
    // Sample Implementation:
    //   Retrieves the price formula from the assigned Margin Calculation Formula and validates it.
    [EventSubscriber(ObjectType::Report, Report::"ESCP Adv. Price Calculation", OnSetAndVerifyPriceFormulaElseCase, '', false, false)]
    local procedure ESCPAdvPriceCalculation_OnSetAndVerifyPriceFormulaElseCase(var PriceFormula: Text; CalculationPriceFormula: Record "ESCP Calculation Price Formula"; AdvancedPricingSetup: Record "ESCP Advanced Pricing Setup"; var Result: Boolean)
    var
        MarginCalcFormula: Record "ESCP Margin Calc. Formula";
        DummyFormula: Text;
        TestPrice: Decimal;
    begin
        if CalculationPriceFormula."Price Factor Type" <> CalculationPriceFormula."Price Factor Type"::"DYN Margin from Item UoM" then
            exit;

        if CalculationPriceFormula."Margin Calculation Formula" = '' then begin
            Result := false;
            exit;
        end;

        if not MarginCalcFormula.Get(CalculationPriceFormula."Margin Calculation Formula") then begin
            Result := false;
            exit;
        end;

        PriceFormula := MarginCalcFormula."Price Formula";
        if PriceFormula = '' then begin
            Result := false;
            exit;
        end;

        // Test-evaluate the formula with dummy values to verify syntax
        DummyFormula := MarginCalculationHelper.ReturnTransformedFormula(
            PriceFormula,
            AdvancedPricingSetup."Margin Cost Calc. Placeholder", 100,
            AdvancedPricingSetup."Calculated Margin Placeholder", 25);

        Result := EvaluateExpression.TryEvaluate(DummyFormula, TestPrice);
    end;
    #endregion EventSubscriber Report "ESCP Adv. Price Calculation" OnSetAndVerifyPriceFormulaElseCase

    #region EventSubscriber Report "ESCP Adv. Price Calculation" OnAdjustPriceAccordingToPriceFactorElseCase
    // Event: OnAdjustPriceAccordingToPriceFactorElseCase on Report "ESCP Adv. Price Calculation"
    // Status: Existing event — includes `ItemUnitofMeasure: Record "Item Unit of Measure"` parameter!
    //
    // General Purpose:
    //   The core price adjustment event. Receives the base cost in `var PriceToAdjust`, the price formula,
    //   the calculation formula setup, current item number, and the active Item Unit of Measure.
    //   The subscriber calculates the new selling price and sets `var PriceFactorSuccess := true`.
    //   If calculation fails, sets `PriceFactorSuccess := false` and provides explanation in `var ReasonTxt: Text`.
    //
    // Partner Use Case:
    //   The main calculation routine for custom price factor types. Receives the base price/cost,
    //   formula text, and active unit of measure context. Calculate the target selling price,
    //   assign PriceToAdjust, and set PriceFactorSuccess := true. If calculation is not possible,
    //   set PriceFactorSuccess := false and populate ReasonTxt.
    //
    // Sample Implementation:
    //   1. Checks if the price factor type is "PTE Margin from Item UoM".
    //   2. Uses the passed `ItemUnitofMeasure` parameter to look up per-UoM setup in "PTE Item UoM Margin Setup".
    //   3. If found, uses the per-UoM "Targeted Margin %"; otherwise falls back to CalculationPriceFormula."Targeted Margin".
    //   4. Calculates the selling price from base cost and targeted margin using the price formula.
    //   5. Sets PriceFactorSuccess := true on success, or sets ReasonTxt on failure.
    [EventSubscriber(ObjectType::Report, Report::"ESCP Adv. Price Calculation", OnAdjustPriceAccordingToPriceFactorElseCase, '', false, false)]
    local procedure ESCPAdvPriceCalculation_OnAdjustPriceAccordingToPriceFactorElseCase(var PriceToAdjust: Decimal; PriceFormula: Text; CalculationPriceFormula: Record "ESCP Calculation Price Formula"; AdvancedPricingSetup: Record "ESCP Advanced Pricing Setup"; CurrentItemNo: Code[20]; var PriceFactorSuccess: Boolean; var ReasonTxt: Text; ItemUnitofMeasure: Record "Item Unit of Measure")
    var
        ItemUoMMarginSetup: Record "DYN Item UoM Margin Setup";
        TargetedMargin: Decimal;
        EvaluatedPrice: Decimal;
        FinalFormula: Text;
    begin
        if CalculationPriceFormula."Price Factor Type" <> CalculationPriceFormula."Price Factor Type"::"DYN Margin from Item UoM" then
            exit;

        PriceFactorSuccess := false;

        // Step 1: Determine targeted margin — check per-UoM setup first, fallback to formula setup
        if ItemUoMMarginSetup.Get(CurrentItemNo, ItemUnitofMeasure.Code) and (ItemUoMMarginSetup."Targeted Margin Percentage" <> 0) then
            TargetedMargin := ItemUoMMarginSetup."Targeted Margin Percentage"
        else
            TargetedMargin := CalculationPriceFormula."Targeted Margin";

        if TargetedMargin = 0 then begin
            ReasonTxt := 'No targeted margin defined on Item UoM or Calculation Price Formula.';
            exit;
        end;

        // Step 2: Transform price formula with base cost and targeted margin placeholders
        FinalFormula := MarginCalculationHelper.ReturnTransformedFormula(
            PriceFormula,
            AdvancedPricingSetup."Margin Cost Calc. Placeholder", PriceToAdjust,
            AdvancedPricingSetup."Calculated Margin Placeholder", TargetedMargin);

        // Step 3: Evaluate formula into the new selling price
        if not EvaluateExpression.TryEvaluate(FinalFormula, EvaluatedPrice) then begin
            ReasonTxt := 'Failed to evaluate price formula: ' + FinalFormula;
            exit;
        end;

        PriceToAdjust := EvaluatedPrice;
        PriceFactorSuccess := true;
    end;
    #endregion EventSubscriber Report "ESCP Adv. Price Calculation" OnAdjustPriceAccordingToPriceFactorElseCase

    #region EventSubscriber Report "ESCP Adv. Price Calculation" OnAfterAdjustPriceAccordingToPriceFactor
    // Event: OnAfterAdjustPriceAccordingToPriceFactor on Report "ESCP Adv. Price Calculation"
    // Status: Existing event
    //
    // General Purpose:
    //   A post-adjustment hook that fires for ALL price factor types (standard and custom)
    //   immediately after AdjustPriceAccordingToPriceFactor finishes.
    //   Provides full context: PriceToAdjust, CalculationPriceFormula, CurrentItemNo, ItemUnitofMeasure,
    //   PriceFactorSuccess, and ReasonTxt.
    //
    // Partner Use Case:
    //   - Enforcing global price floors or ceilings across price factor types
    //   - Applying secondary UoM-specific surcharges or packaging handling fees
    //   - Auditing, telemetry, or diagnostic logging of calculated prices
    //
    // Sample Implementation:
    //   Verifies calculation success and custom type, ready for custom post-calculation rules.
    [EventSubscriber(ObjectType::Report, Report::"ESCP Adv. Price Calculation", OnAfterAdjustPriceAccordingToPriceFactor, '', false, false)]
    local procedure ESCPAdvPriceCalculation_OnAfterAdjustPriceAccordingToPriceFactor(var PriceToAdjust: Decimal; CalculationPriceFormula: Record "ESCP Calculation Price Formula"; CurrentItemNo: Code[20]; ItemUnitofMeasure: Record "Item Unit of Measure"; var PriceFactorSuccess: Boolean; var ReasonTxt: Text)
    begin
        if CalculationPriceFormula."Price Factor Type" <> CalculationPriceFormula."Price Factor Type"::"DYN Margin from Item UoM" then
            exit;

        if not PriceFactorSuccess then
            exit;

        // Custom post-calculation logic: price rounding, surcharges, or minimum threshold validation
    end;
    #endregion EventSubscriber Report "ESCP Adv. Price Calculation" OnAfterAdjustPriceAccordingToPriceFactor

    #region EventSubscriber Report "ESCP Adv. Price Calculation" OnGenerateTempPriceWorksheetLineForUnitOfMeasureOnBeforeModify
    // Event: OnGenerateTempPriceWorksheetLineForUnitOfMeasureOnBeforeModify on Report "ESCP Adv. Price Calculation"
    // Status: Existing event
    //
    // General Purpose:
    //   Fires during worksheet generation in report "ESCP Adv. Price Calculation" (GeneratePriceWorksheetLines)
    //   for each Unit of Measure right before the temporary Price Worksheet Line is modified and committed.
    //   Provides: TempNewPriceWorksheetLine, Item, ItemUnitofMeasure, and CalculationPriceFormula.
    //
    // Partner Use Case:
    //   - Populating custom PTE fields on the temporary Price Worksheet Line
    //   - Overriding worksheet line description or notes with UoM-specific details
    //   - Applying custom line discounts or line flags prior to worksheet generation
    //
    // Sample Implementation:
    //   Filters by custom price factor type and provides access to the temporary worksheet line.
    [EventSubscriber(ObjectType::Report, Report::"ESCP Adv. Price Calculation", OnGenerateTempPriceWorksheetLineForUnitOfMeasureOnBeforeModify, '', false, false)]
    local procedure ESCPAdvPriceCalculation_OnGenerateTempPriceWorksheetLineForUnitOfMeasureOnBeforeModify(var TempNewPriceWorksheetLine: Record "Price Worksheet Line" temporary; Item: Record Item; ItemUnitofMeasure: Record "Item Unit of Measure"; CalculationPriceFormula: Record "ESCP Calculation Price Formula")
    begin
        if CalculationPriceFormula."Price Factor Type" <> CalculationPriceFormula."Price Factor Type"::"DYN Margin from Item UoM" then
            exit;

        // Custom logic before worksheet line is created: set custom fields or adjust worksheet line attributes
    end;
    #endregion EventSubscriber Report "ESCP Adv. Price Calculation" OnGenerateTempPriceWorksheetLineForUnitOfMeasureOnBeforeModify

    // Phase 3: Margin Status & Threshold Overrides (Green / Red indicator)
    //
    // Dynavision Advanced Pricing determines margin status (Sufficient / Insufficient)
    // by comparing the calculated margin percentage against a threshold.
    // The OnBeforeSetMarginStatus integration events support two extension patterns:
    //
    // Pattern A — Threshold Override (Recommended for UoM thresholds):
    //   Assign `Threshold := CustomThreshold;`. The standard comparison then runs:
    //   if CalculatedMargin >= Threshold then MarginStatus := Sufficient else MarginStatus := Insufficient.
    //
    // Pattern B — Full Status Override:
    //   Assign `MarginStatus := Enum::"ESCP Margin Status"::Sufficient;` and set `IsHandled := true;`.
    //   This bypasses standard threshold evaluation completely and directly enforces status.

    #region EventSubscriber Codeunit "ESCP Sales Line Margin Mgt." OnBeforeSetMarginStatus
    // Event: OnBeforeSetMarginStatus on Codeunit "ESCP Sales Line Margin Mgt."
    // Status: Existing event
    //
    // General Purpose:
    //   Fires during sales line margin calculation just before the margin status (Sufficient/Insufficient)
    //   is decided and validated on the Sales Line. Allows a PTE to:
    //   - Override `var Threshold: Decimal` to compare against a custom threshold (Pattern A: per Item UoM)
    //   - Or set `var MarginStatus: Enum "ESCP Margin Status"` and `var IsHandled := true` to take full control (Pattern B).
    //
    // Partner Use Case:
    //   Allows per-UoM, per-customer, or custom rule-based threshold comparison for sales lines.
    //
    // Sample Implementation:
    //   Looks up the per-UoM threshold in "PTE Item UoM Margin Setup".
    //   If defined, overrides the Threshold parameter so the standard comparison uses the UoM-specific threshold.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCP Sales Line Margin Mgt.", OnBeforeSetMarginStatus, '', false, false)]
    local procedure SalesLineMarginMgt_OnBeforeSetMarginStatus(var SalesLine: Record "Sales Line"; PriceMargin: Record "ESCP Price Margin"; CalculatedMargin: Decimal; var Threshold: Decimal; var MarginStatus: Enum "ESCP Margin Status"; var IsHandled: Boolean)
    var
        UoMThreshold: Decimal;
    begin
        if SalesLine.Type <> SalesLine.Type::Item then
            exit;

        if FindUoMThreshold(SalesLine."No.", SalesLine."Unit of Measure Code", UoMThreshold) then
            Threshold := UoMThreshold;
    end;
    #endregion EventSubscriber Codeunit "ESCP Sales Line Margin Mgt." OnBeforeSetMarginStatus

    #region EventSubscriber Codeunit "ESCP PriceListLine Margin Mgt." OnBeforeSetMarginStatus
    // Event: OnBeforeSetMarginStatus on Codeunit "ESCP PriceListLine Margin Mgt."
    // Status: Existing event
    //
    // General Purpose:
    //   Same threshold override capability during margin calculation on Price List Lines.
    //   Supports Pattern A (threshold override) and Pattern B (full status override via IsHandled).
    //
    // Partner Use Case:
    //   Overrides threshold or status when maintaining price list lines.
    //
    // Sample Implementation:
    //   Retrieves Item No. from PriceListLine."Asset No." and overrides Threshold if a UoM setup exists.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCP PriceListLine Margin Mgt.", OnBeforeSetMarginStatus, '', false, false)]
    local procedure PriceListLineMarginMgt_OnBeforeSetMarginStatus(var PriceListLine: Record "Price List Line"; PriceMargin: Record "ESCP Price Margin"; CalculatedMargin: Decimal; var Threshold: Decimal; var MarginStatus: Enum "ESCP Margin Status"; var IsHandled: Boolean)
    var
        UoMThreshold: Decimal;
    begin
        if PriceListLine."Asset Type" <> PriceListLine."Asset Type"::Item then
            exit;

        if FindUoMThreshold(PriceListLine."Asset No.", PriceListLine."Unit of Measure Code", UoMThreshold) then
            Threshold := UoMThreshold;
    end;
    #endregion EventSubscriber Codeunit "ESCP PriceListLine Margin Mgt." OnBeforeSetMarginStatus

    #region EventSubscriber Codeunit "ESCP PriceWrkShLine Margin Mgt" OnBeforeSetMarginStatus
    // Event: OnBeforeSetMarginStatus on Codeunit "ESCP PriceWrkShLine Margin Mgt"
    // Status: Existing event
    //
    // General Purpose:
    //   Same threshold override capability during margin calculation on Price Worksheet Lines.
    //   Supports Pattern A (threshold override) and Pattern B (full status override via IsHandled).
    //
    // Partner Use Case:
    //   Overrides threshold or status when calculating price worksheet lines.
    //
    // Sample Implementation:
    //   Retrieves Item No. from PriceWorksheetLine."Asset No." and overrides Threshold if a UoM setup exists.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCP PriceWrkShLine Margin Mgt", OnBeforeSetMarginStatus, '', false, false)]
    local procedure PriceWrkShLineMarginMgt_OnBeforeSetMarginStatus(var PriceWorksheetLine: Record "Price Worksheet Line"; PriceMargin: Record "ESCP Price Margin"; CalculatedMargin: Decimal; var Threshold: Decimal; var MarginStatus: Enum "ESCP Margin Status"; var IsHandled: Boolean)
    var
        UoMThreshold: Decimal;
    begin
        if PriceWorksheetLine."Asset Type" <> PriceWorksheetLine."Asset Type"::Item then
            exit;

        if FindUoMThreshold(PriceWorksheetLine."Asset No.", PriceWorksheetLine."Unit of Measure Code", UoMThreshold) then
            Threshold := UoMThreshold;
    end;
    #endregion EventSubscriber Codeunit "ESCP PriceWrkShLine Margin Mgt" OnBeforeSetMarginStatus

    #region EventSubscriber Page "ESCP Calc. Item Price Margins" OnBeforeSetMarginStatus
    // Event: OnBeforeSetMarginStatus on Page "ESCP Calc. Item Price Margins"
    // Status: Existing event
    //
    // General Purpose:
    //   Threshold and status override hook in the Item Price Margin calculation & simulation page
    //   ("ESCP Calc. Item Price Margins").
    //   Ensures the green/red status shown in simulation can align with document line behavior.
    //   Supports Pattern A (threshold override) and Pattern B (full status override via IsHandled).
    //
    // Extensibility & Architectural Note:
    //   The table "ESCP Item Price Margin" has primary key ("Item No.", "Variant Code", "Price Margin Code")
    //   and does NOT contain a "Unit of Measure Code" field. The simulation page evaluates the margin
    //   for the base item/variant setup without line UoM context.
    //
    //   Because of this, per-UoM thresholds cannot be resolved directly from ItemPriceMargin.
    //   Partners have several options depending on requirements:
    //   - Coarse Default: Look up the Item's "Base Unit of Measure" in "PTE Item UoM Margin Setup" (demonstrated below).
    //   - Default Threshold: Leave Threshold untouched to keep PriceMargin.Threshold.
    //   - Direct Status Override (Pattern B): Evaluate custom logic and assign MarginStatus directly with IsHandled := true.
    //   - Custom Simulation: Build dedicated PTE actions or pages if full multi-UoM simulation is required.
    //
    // Sample Implementation:
    //   Retrieves the Item's Base Unit of Measure as a default proxy to look up the threshold in "PTE Item UoM Margin Setup".
    [EventSubscriber(ObjectType::Page, Page::"ESCP Calc. Item Price Margins", OnBeforeSetMarginStatus, '', false, false)]
    local procedure CalcItemPriceMargins_OnBeforeSetMarginStatus(ItemPriceMargin: Record "ESCP Item Price Margin"; PriceMargin: Record "ESCP Price Margin"; CalculatedMargin: Decimal; var Threshold: Decimal; var MarginStatus: Enum "ESCP Margin Status"; var IsHandled: Boolean)
    var
        Item: Record Item;
        UoMThreshold: Decimal;
    begin
        if not Item.Get(ItemPriceMargin."Item No.") then
            exit;

        if FindUoMThreshold(Item."No.", Item."Base Unit of Measure", UoMThreshold) then
            Threshold := UoMThreshold;
    end;
    #endregion EventSubscriber Page "ESCP Calc. Item Price Margins" OnBeforeSetMarginStatus

    // Helper Procedures

    #region FindUoMThreshold
    local procedure FindUoMThreshold(ItemNo: Code[20]; UoMCode: Code[10]; var Threshold: Decimal): Boolean
    var
        ItemUoMMarginSetup: Record "DYN Item UoM Margin Setup";
    begin
        if (ItemNo = '') or (UoMCode = '') then
            exit(false);

        if ItemUoMMarginSetup.Get(ItemNo, UoMCode) and (ItemUoMMarginSetup."Threshold Percentage" <> 0) then begin
            Threshold := ItemUoMMarginSetup."Threshold Percentage";
            exit(true);
        end;

        exit(false);
    end;
    #endregion FindUoMThreshold

    var
        EvaluateExpression: Codeunit "ESCA Evaluate Expression";
        MarginCalculationHelper: Codeunit "ESCP Margin Calculation Helper";
}

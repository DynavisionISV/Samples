# Samples - Dynavision Advanced Pricing & Discounts

This folder contains individual samples that extend Dynavision Advanced Pricing & Discounts.

## Pricing Samples

### 01 - Custom Cost

**Overview**

This sample demonstrates how to extend Dynavision Advanced Pricing & Discounts with a custom cost calculation, and how to default the cost source used on margin cost definitions and purchase price formulas.

**Use Case**

The cost stored on a price line is not always the cost a company wants to base its prices on. A company may want to add overhead (for example 15%) or a fixed handling fee per unit to the base cost, and use that **Custom Cost** as the basis for purchase price formulas and margin calculations.

**What It Does**

1. Adds the **Custom Cost Setup** page (`DYN Custom Cost Setup`, page 50400) with:
    - **Active** to switch the custom cost calculation on or off.
    - **Cost Factor** and **Fixed Cost Addition** to define the calculation.
    - **Margin Cost Source** and **Purch. Price Form. Cost Source** to define the default cost source.
2. Calculates the custom cost as `NewCustomCost := BaseCost * Cost Factor + Fixed Cost Addition`. Nothing is calculated when the base cost is `0`, the setup is not active, or both the factor and the fixed addition are `0`.
3. Subscribes to the Custom Cost events of Dynavision Advanced Pricing so the calculation is applied everywhere the custom cost is determined:
    - `ESCPOnUpdateCustomCostOnBeforeCopyBaseCostToCustomCost` on **Price List Line** and **Price Worksheet Line**.
    - `OnUpdateCustomCostOnBeforeCopyBaseCostToCustomCost` on codeunit `ESCP Pricing BaseUOM LCY Mgt.`.
    - `OnAfterGetCustomCostPerBaseUOM` on `ESCP Purchase Price Selection`.
4. Sets the default cost source on new records through `OnBeforeSetDefaultCostSource`:
    - **Purchase price formulas and templates** use the **Purch. Price Form. Cost Source**, only for the lookup methods *From Selection*, *Lowest* and *Highest*.
    - **Margin cost definitions** use the **Margin Cost Source**, only for the lookup methods *Lowest* and *Highest*.

### 02 - Margin From Item UoM

**Overview**

This sample demonstrates how to add a custom **Price Factor Type** that calculates selling prices from a targeted margin that is defined **per item and unit of measure**, and how to use a margin threshold per unit of measure for the margin status (green / red) on documents and price lines.

**Use Case**

The same item is often sold in several units of measure (for example piece, box and pallet), each with its own margin target. The standard margin tables (`ESCP Item Price Margin`) have no **Unit of Measure Code** in their primary key, so a different targeted margin or threshold per unit of measure cannot be stored there. The sample adds a dedicated setup table to solve this.

**What It Does**

1. Adds a table and list page to maintain the margin per item and unit of measure:
    - Table 50401 `DYN Item UoM Margin Setup` with primary key **Item No.** and **Unit of Measure Code**.
    - Page 50401 `DYN Item UoM Margin Setup List`.
    - **Targeted Margin %** is used when calculating selling prices.
    - **Threshold %** is used for the green / red margin status.
2. Extends the enum `ESCP Price Factor Type` with the value **Margin from Item UoM** (`DYN Margin from Item UoM`).
3. **Setup and formula validation** (when formulas and templates are maintained):
    - Resets **Multiply Coefficient** to `1` when the new type is selected, because any other value requires the type *Coefficient*. This is done for both **Calculation Price Formula** and **Calc. Price Formula Templ**.
    - Suppresses the error for **Margin Calculation Formula** and **Targeted Margin** on formulas and templates, so they can be used with the new type.
    - Contains hooks before and after creating a calculation price formula from a template, to copy custom fields when needed.
4. **Price calculation** (report `ESCP Adv. Price Calculation`):
    - Verifies that the price formula of the assigned Margin Calculation Formula can be evaluated, by test-evaluating it with dummy values.
    - Calculates the selling price per unit of measure. The **Targeted Margin %** of the item and unit of measure is used, with a fallback to the **Targeted Margin** of the calculation price formula. When no margin is found or the formula can not be evaluated, the reason is reported back.
    - Contains hooks after the adjustment and before the temporary price worksheet line is modified, to add custom rules or fields.
5. **Margin status** (`OnBeforeSetMarginStatus`): overrides the threshold with the **Threshold %** of the item and unit of measure on:
    - Sales lines
    - Price list lines
    - Price worksheet lines
    - The item price margin simulation page (`ESCP Calc. Item Price Margins`)

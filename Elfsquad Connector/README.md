# Samples - Elfsquad Connector

This folder contains individual samples that extend the Elfsquad Connector.

## Elfsquad Samples

Both samples are started from the **Sync Setup** page (`ESCY Sync Setup`), where an action is added for each sample.

### 01 - Sample Import To Buffer

**Overview**

This sample demonstrates how to import custom Elfsquad data into your own buffer tables, by creating the required sync setups and mappings from code, and how to use the imported data when a sales quote is created from a quotation buffer.

**Use Case**

An Elfsquad quotation contains extra **properties** that are not part of the standard quotation import. These properties and their values must be retrieved from Elfsquad, stored in custom tables, shown to the user on the quotation buffer, and be available when the sales quote is created.

**What It Does**

1. Adds two buffer tables:
    - Table 50501 `DYN Quotation Buffer Property` with the property **Id**, **Name** and **Type**.
    - Table 50500 `DYN Quot. Buffer Prop. Value` with the **Quotation Id**, **Property Id** and a value field for each type (text, decimal, boolean, date and blob). The property name and type are flow fields. `GetValueAsText` returns the value as text according to the type of the property.
2. Adds the **Create Sample Import To Buffer** action on the Sync Setup page. It runs `Execute` on codeunit `DYN Sample Import To Buffer`, which creates two sync setups and opens them:
    - `BUFFPROP` retrieves the properties from `/data/1/QuotationProperties` with the operation **GetFilter**.
    - `BUFFPROPVAL` retrieves the values from `/data/1/QuotationPropertyValues`, filtered on the quotation id (`?$filter=entityId eq [%1]`).
3. Creates the sync mappings of both sync setups, mapping the API fields (for example `description`, `type`, `entityId`, `entityPropertyId` and `id`) to the fields of the buffer tables. The setups and mappings are only created when they do not exist yet.
4. Adds the **Quotation Property Value** calculated value (`DYN Quotation Property Value`), a new value of the enum `ESCY Calculated Value` that implements the interface `ESCY Calculated Value`. It is used for the `value` field, as the destination field depends on the type of the property:
    - Number: **Value Decimal**
    - Toggle: **Value Boolean**
    - Date: **Value Date**
    - MultiLine and Html: **Value Blob**
    - Other types: **Value Text**

    Only pull is supported, push is not.
5. Subscribes to `OnAfterExecuteProcessor` on codeunit `ESCY Sync Setup Management`. When the processor **Import Quotation Details** has run for a quotation buffer, the properties and then the property values of that quotation are retrieved by running the two sync setups. An error is returned when one of them fails.
6. Extends the **Quotation Buffer List** with a **Has Properties** field that replaces the standard one. Drilling down opens the **Properties** page (`DYN Quot. Buffer Prop. List`) with the name and value of each property.
7. Subscribes to `OnCreateSalesQuoteOnBeforeShowResult` on codeunit `ESCZ Import Quotation`, where the imported properties of the quotation can be processed when the sales quote is created.

### 02 - Sample Sync Mapping

**Overview**

This sample demonstrates how to add a custom sync mapping to an existing sync setup of the Elfsquad Connector.

**Use Case**

An Elfsquad API contains an extra field that is not part of the standard mapping, and the value must be mapped to a field in Business Central. For example, a field on the item exported to Elfsquad must be filled with the **Description 2** of the item.

**What It Does**

1. Adds the **Create Custom Sync Mapping** action on the Sync Setup page. It runs `Execute` on codeunit `DYN Sample Sync Mapping`.
2. Gets the existing sync setup `ELF_EXP_ITEM_1` and adds a mapping for the API field `apiExampleField` to the field **Description 2** on the Item table. The mapping is only created when the API field does not exist yet on the sync setup.
3. Opens the sync mappings of the sync setup, so the result can be reviewed.

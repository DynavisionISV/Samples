# Samples - Dynavision Layouts

This folder contains individual samples that extend Dynavision Layouts.

## Report Document Samples

### 01 - Hide Payment information

**Overview**

This sample demonstrates how to extend Dynavision Layouts to hide payment information on the layout.

**Use Case**

Extend the **ESCR Sales Invoice** report to suppress the display of payment-related amounts on the printed invoice. This is useful when you want to show the invoice details without exposing payment tracking information.

**What It Does**

1. **Clears paid amount fields** to prevent them from displaying on the layout
2. **Removes remaining balance information** from the invoice output
3. **Simplifies the invoice presentation** by hiding payment tracking details

### 02 - Add Trade Payments as Header or Footer Lines

**Overview**

This sample demonstrates how to extend Dynavision Layouts to add header or footer text lines.

**Use Case**

Extend the **ESCR Sales Invoice** report to dynamically add payment method information to the layout. The payment information is pulled from the **Dynavision Trade** module's payment data and formatted for display on the report.

**What It Does**

1. **Captures payment method details** from posted sales documents
2. **Aggregates payments by method** when multiple payment methods are used for a single document
3. **Formats and displays** payment information dynamically in either the header or footer of the invoice layout

### 03 - Overrule Report Header Text Constant

**Overview**

This sample demonstrates how to extend Dynavision Layouts to dynamically override the header text constant based on document properties.

**Use Case**

Extend the **ESCR Sales Invoice** report to display the correct header label for the amount column. Depending on whether the invoice includes VAT in prices, the header should display either "Amount Including VAT" or "Amount Excluding VAT".

**What It Does**

1. **Intercepts header column creation** before the column is added to the report layout
2. **Evaluates invoice properties** to determine pricing configuration (prices including or excluding VAT)
3. **Dynamically selects** the appropriate text constant name for the header
4. **Overrides the default header** with the correct amount label based on the document configuration

### 04 - Add Field to Address Block

**Overview**

This sample demonstrates how to extend Dynavision Layouts to include custom company information fields in the report address block.

**Use Case**

Extend the **ESCR Sales Invoice** report to display additional company information (such as an RPR registration number) in the address block of the invoice. This allows organizations to include custom company identifiers or regulatory information in their report layouts without modifying the core reporting infrastructure.

**What It Does**

1. **Adds a custom field** to the Company Information master data
2. **Exposes the field** in the Company Information page for user maintenance
3. **Extends the address buffer** to capture the custom field value
4. **Populates the field** automatically when address data is retrieved for reports

### 05 - Hide Prices on Warehouse Layout

**Overview**

This sample demonstrates how to extend Dynavision Layouts to suppress price information on warehouse shipment reports.

**Use Case**

Extend the **ESCR Warehouse Reports** to hide all price information on warehouse shipment documents.

**What It Does**

1. **Intercepts the price display default** before the report is generated
2. **Overrides the print prices setting** to always suppress price information
3. **Prevents price information** from appearing on warehouse-related shipment documents
4. **Marks the event as handled** to prevent default behavior from running

## Report Document Line Samples

### 20 - Add Report Line Field to Specific Layout

**Overview**

This sample demonstrates how to extend Dynavision Layouts to add and populate a custom report line field for a specific layout.

**Use Case**

Add an **Item Reference Barcode** field to sales order report lines so this value can be shown in the Sales Order layout. This is useful when a field should be available for a targeted report scenario without applying the same logic to all layouts.

**What It Does**

1. **Adds a custom field** to the report document line table
2. **Populates the field per line** during report dataset processing
3. **Looks up barcode references** from the Item Reference table using item and unit of measure
4. **Applies the data only for this layout extension**

### 21 - Add Report Line Field to All Layouts

**Overview**

This sample demonstrates how to extend Dynavision Layouts to add a custom field to the report document line that becomes available across all layouts automatically.

**Use Case**

Add the **Location Code** field to report lines so it can be used in any report layout. Instead of extending individual reports, this sample uses an event-driven approach to populate the field centrally for all reports that use the Dynavision Layout framework.

**What It Does**

1. **Adds a custom field** to the report document line table
2. **Subscribes to the line creation event** to populate the field automatically
3. **Extracts location information** from the source document (Sales, Purchase, or Warehouse Shipment)
4. **Makes the field available** to all layouts without additional report-specific code

### 22 - Add Item Categories as Report Lines

**Overview**

This sample demonstrates how to extend Dynavision Layouts to insert item category headers and subheaders into the report lines.

**Use Case**

Enable more readable **ESCR Sales Quote** layouts by grouping items under their category and subcategory. This is useful when a sales quote contains many lines and you want the layout to clearly separate items by category without changing the underlying document data.

**What It Does**

1. **Inserts category headers** ahead of item lines
2. **Inserts subcategory headers** for item categories under a parent category
3. **Sorts lines by category and subcategory** so items are grouped logically
4. **Allows configuration in setup** so the grouping can be enabled or disabled

### 23 - Group Document Lines

**Overview**

This sample demonstrates how to group document lines in a Dynavision layout before the report dataset is rendered.

**Use Case**

Extend the **ESCR Sales Order** report to consolidate duplicate sales lines that share the same item, unit of measure, variant, and unit price. This reduces clutter in the layout and shows a single summarized line per group.

**What It Does**

1. **Copies** the report document lines into temporary records for processing
2. **Groups** lines by item, unit of measure, variant, and unit price
3. **Summarizes** quantities and recalculates line amounts for each group
4. **Removes** the remaining duplicate lines from the dataset

### 24 - Add Custom Report Text Line

**Overview**

This sample demonstrates how to extend Dynavision Layouts to add custom text lines to report document lines.

**Use Case**

Extend the **ESCR Warehouse Shipment** report to show contextual messages on lines with no stock or partial stock. This helps warehouse and logistics teams understand fulfillment status directly on the document without opening other screens.

**What It Does**

1. **Adds a custom field** to report document lines to track the original quantity
2. **Reads the original quantity** from Warehouse Shipment Line records
3. **Compares quantities** to determine stock availability
4. **Inserts custom text lines** into the report layout when stock is missing or partial

### 25 - Add First Custom Report Text Line

**Overview**

This sample demonstrates how to extend Dynavision Layouts to add a custom text line as the first line of report document lines.

**Use Case**

Extend the **ESCR Warehouse Shipment** report to display the responsible salesperson or purchaser at the beginning of the document lines. This provides immediate context about who is handling the transaction, making it easier for warehouse personnel to route questions or issues to the correct person.

**What It Does**

1. **Identifies the source document type** (Purchase or Sales) from the first shipment line
2. **Retrieves the responsible person** from the source document header
3. **Inserts a text line** at the beginning of the report lines showing the person's name
4. **Formats the text** with appropriate labels based on document type (Salesperson vs Purchaser)

### 26 - Set Custom Line Sorting

**Overview**

This sample demonstrates how to extend Dynavision Layouts to customize the sorting order of report document lines.

**Use Case**

Extend the **ESCR Transfer Order** report to sort document lines by shelf number and then by item number. This enables warehouse personnel to process transfers in the most efficient physical order, reducing walk time and improving picking accuracy.

**What It Does**

1. **Adds a custom field** to store the item's shelf location
2. **Retrieves shelf numbers** from the Item master data for each line
3. **Builds a custom sorting value** by concatenating shelf number and item number
4. **Applies the sorting** to control the order in which lines appear on the printed report

## Report Version Samples

### 40 - Print Custom Layout Version

**Overview**

This sample demonstrates how to add a custom print action on the Sales Order page that prints with a specific Dynavision layout version.

**Use Case**

Add a dedicated action to the **Sales Order** page to print the **ESCR Sales Order** report with a predefined layout version. This is useful when users need a predictable output variant without manually changing report setup.

**What It Does**

1. **Adds a Print action group** after the standard order confirmation action
2. **Adds a custom action** named "Print Custom Version"
3. **Sets report layout version 1** in the report datastore before running the report
4. **Runs the ESCR Sales Order report** for the current filtered record
5. **Clears the layout version override** after printing to avoid side effects

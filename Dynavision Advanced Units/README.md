# Samples - Dynavision Advanced Units

This folder contains individual samples that extend Dynavision Advanced Units.

## Unit Samples

### 01 - Qty Per Factor

**Overview**

This sample demonstrates how to extend Dynavision Advanced Units to adjust the **Qty. per** conversion between the base unit of measure and the invoicing unit of measure with a custom percentage, for example to include a joint or waste allowance.

**Use Case**

The item master stores the theoretical conversion between units. For example, 100 bricks per m² for a brick of 20 × 5 cm. Mortar joints mean fewer bricks fit in one m², so for the same number of pieces the invoiced quantity in m² must be higher. The allowance depends on the situation, such as the joint size, so it can not be stored as a fixed conversion on the item.

**What It Does**

1. Subscribes to the event `OnGetCustomPercentageForQtyPer` on:
    - Codeunit `ESCU Invoicing Unit Sales`, for sales lines.
    - Codeunit `ESCU Invoicing Unit Purchase`, for purchase lines.
2. Returns a custom percentage of `26` on both events. This represents 1 cm joints on all sides, which gives an area factor of 1.26 for a brick of 20 × 5 cm.
3. Advanced Units then applies the percentage as `EffectiveQtyPer = QtyPer / (1 + CustomPercentage / 100)`.
    - Example: 900 pieces result in 11.34 m² instead of 9.00 m².
    - The derived line factor (0.0126) is preserved when the quantity is changed.

**Notes**

- The event subscribers are **manual** (`EventSubscriberInstance = Manual`). They are used by the Advanced Units tests to simulate a partner customization, and are only active when bound explicitly.
- The sample always returns a fixed percentage. In a real extension, store the percentage (for example **Joint Allowance %**) on the document line or in a setup table, and return that value in the event.
- The codeunit contains a commented example that calculates the percentage from the length and height of the base unit of measure and a head and bed joint stored on the sales line:
    - `CustomPercentage := ((Length + Head Joint) * (Height + Bed Joint)) / (Length * Height)`, converted to a percentage.
    - The head and bed joint fields are not part of this sample and need to be added by your own extension.
- The same pattern can be applied on `ESCU Inv. Unit Worksheet Mgt.` for requisition lines.

# Samples - Dynavision Advanced Promotions

This folder contains individual samples that extend Dynavision Advanced Promotions.

## Promotion Samples

### 01 - Disable Instant Promotions

**Overview**

This sample demonstrates how to extend Dynavision Advanced Promotions to disable instant promotions.

**Use Case**

Web shop integrations create sales orders with lines, although instant promotions are not calculated immediately. Instead, instant promotion calculation must be included as part of the 'Check for Promotions' function.

**What It Does**

1. Adds a **Web Order** boolean on Sales Header
2. Setting `DisableInstantPromotions` to `true` only affects **line-entry** instant calculation. 
**Check for Promotions** will include delayed instant promotions when the flag is `true`.

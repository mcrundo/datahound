# DataHound — Entity Relationship Diagram

```mermaid
erDiagram
    regions {
        bigint id PK
        string abbreviation "not null"
        string country_code "not null, default: US"
        decimal tax_rate "decimal(5,2), not null"
        datetime created_at
        datetime updated_at
    }

    customers {
        bigint id PK
        string name "not null, unique"
        bigint region_id FK "not null"
        datetime created_at
        datetime updated_at
    }

    suppliers {
        bigint id PK
        string name "not null, unique"
        datetime created_at
        datetime updated_at
    }

    quotes {
        bigint id PK
        bigint customer_id FK "not null"
        bigint supplier_id FK "not null"
        decimal rate "decimal(8,6), not null"
        boolean tax_included "not null"
        decimal normalized_rate "decimal(8,6), not null"
        datetime created_at
        datetime updated_at
    }

    regions ||--o{ customers : "has many"
    customers ||--o{ quotes : "has many"
    suppliers ||--o{ quotes : "has many"
```

## Constraints

| Table | Constraint | Type |
|-------|-----------|------|
| regions | `[abbreviation, country_code]` | Composite unique index |
| customers | `name` | Unique index |
| customers | `region_id → regions.id` | Foreign key |
| suppliers | `name` | Unique index |
| quotes | `[customer_id, supplier_id]` | Composite unique index |
| quotes | `customer_id → customers.id` | Foreign key |
| quotes | `supplier_id → suppliers.id` | Foreign key |

## Normalization Notes

- **3NF**: `tax_rate` lives on `regions`, not `customers`, eliminating the transitive dependency (customer → region → tax_rate)
- **`normalized_rate`**: Pre-tax rate computed on import. For tax-included quotes: `rate / (1 + tax_rate / 100.0)`. For tax-excluded: `rate` as-is. Enables apples-to-apples comparison across all quotes.
- **`country_code`**: ISO 3166-1 alpha-2. Ensures region abbreviations are unambiguous across countries.

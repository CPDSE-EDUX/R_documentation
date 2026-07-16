# Example datasets

Teaching data for the R documentation site. The running story is a QC lab
working with **ibuprofen 400 mg tablets**: weigh them, dissolve them, titrate
the drug, and build a UV calibration curve.

Design rule: **one defect per file.** There are four clean experiments, and
each "messy" file reuses one of them with exactly one thing wrong, so a reader
learns the data once and then only has to learn the defect.

## Clean datasets

| File | Columns | What it is |
|------|---------|------------|
| `tablet_weights.csv` | `tablet_id, batch, weight_mg` | Individual tablets weighed off the line, 3 batches (A/B/C), target ~500 mg. |
| `dissolution.csv` | `tablet_id, time_min, pct_dissolved` | 6 tablets in dissolution fluid; % of drug released climbs toward 100% (first-order). |
| `titration.csv` | `sample_id, volume_ml, pH` | Acid–base titration of extracted ibuprofen (weak acid, pKa 4.91) with 0.100 M NaOH. 3 replicate samples with equivalence points at 24.5 / 25.0 / 25.5 mL. |
| `calibration.csv` | `conc_ug_ml, absorbance` | Ibuprofen UV calibration (Beer–Lambert). Absorbance rises linearly with concentration (R² ≈ 0.9999). |

## Defect variants (one defect each)

Each file is one of the clean datasets above with a single realistic problem,
matched to the function it's meant to teach.

| File | Based on | The one defect | Teaches |
|------|----------|----------------|---------|
| `dissolution_dk.csv` | dissolution | `;` separator, comma decimals (Danish export) | `read_csv2()` |
| `titration_missing.csv` | titration (sample B) | mixed NA codes: `N/A`, `-`, blank | `read_csv(na = ...)` |
| `weights_units.csv` | weights | numbers stored as text (`"506.3 mg"`) | `parse_number()`, type coercion |
| `weights_duplicates.csv` | weights | 2 whole rows logged twice (tablets 5 and 18) | `distinct()` |
| `batches_messy.csv` | weights | inconsistent batch labels (`A` / `a` / `Batch A` / ` A`) | `str_trim()`, `str_to_upper()`, factors |
| `weights_export.csv` | weights | **two** defects: 4 metadata lines on top **and** mixed NA codes (`""`, `NA`, `N/A`, `-`) | `read_csv(skip = 4, na = ...)` |

> Note on `batches_messy.csv`: `str_trim()` + `str_to_upper()` fix the
> case/whitespace variants, but `"Batch A"` still needs a `str_remove()` /
> prefix step to fully collapse to `A`. That's intentional messiness.
>
> Note on `weights_export.csv`: this is the deliberate exception to the
> one-defect rule — it stacks a metadata block and missing values so you can
> show `skip =` and `na =` together in one read.

## Excel workbooks

| File | Shape | Teaches |
|------|-------|---------|
| `lab_results.xlsx` | 5 sheets: `Weights`, `Dissolution`, `Titration`, `Calibration` (all clean) + `Weights (missing)` | `read_excel(sheet = ...)`; the last sheet also demos `read_excel(na = ...)` |
| `lab_results_titled.xlsx` | 1 sheet: the Weights data with a 3-row title block above the header (header on row 4) | `read_excel(skip = 3)` |

The `Weights (missing)` sheet is the `Weights` data with four balance readings
gone, written with mixed NA codes (`N/A`, `-`, `ND`, and a blank cell), so
`weight_mg` comes in as text until you clear them:

```r
read_excel("data/lab_results.xlsx",
           sheet = "Weights (missing)",
           na = c("", "N/A", "-", "ND"))
```

## Regenerating

Everything except the two legacy files below is produced by two scripts that
live in this folder:

- `generate_datasets.R` — writes all CSVs (seeded, reproducible; titration pH
  is solved exactly from the charge balance).
- `build_xlsx.py` — reads the clean CSVs and assembles the two `.xlsx` files
  (requires `openpyxl`).

Run the R script first, then the Python script — both write into this folder
regardless of the working directory:

```sh
Rscript data/generate_datasets.R
python  data/build_xlsx.py
```

## Legacy files (not part of the set above)

- `capsules.csv` — earlier example data (data-handling was migrated to
  `tablet_weights.csv` in July 2026).
- `dissolution_data_raw.csv` — earlier raw-format example.

No site page reads these anymore; they are kept in the repo only and can be
deleted once nothing external depends on them.

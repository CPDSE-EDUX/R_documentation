# Generate example datasets for the R teaching site.
# One defect per file. Four clean experiments (weights, dissolution,
# titration, calibration); each defect file reuses one of them.
# Story: ibuprofen 400 mg tablets -> weigh, dissolve, titrate, UV-calibrate.

set.seed(42)

# write next to this script (the data/ folder), whatever the working dir is
.args <- commandArgs(trailingOnly = FALSE)
.file <- sub("^--file=", "", .args[grep("^--file=", .args)])
out <- if (length(.file)) dirname(normalizePath(.file)) else "data"

# ------------------------------------------------------------------
# 1. tablet_weights.csv  (clean spine)
#    Whole-tablet weights off the line, 3 batches, target ~500 mg.
# ------------------------------------------------------------------
batches <- c("A", "B", "C")
per_batch <- 8
n <- length(batches) * per_batch

batch <- rep(batches, each = per_batch)
# small batch-to-batch offset, tight within-batch spread
batch_mean <- c(A = 500.5, B = 499.0, C = 501.5)
weight <- round(rnorm(n, mean = batch_mean[batch], sd = 4.2), 1)

weights <- data.frame(
  tablet_id = seq_len(n),
  batch     = batch,
  weight_mg = weight,
  stringsAsFactors = FALSE
)

# one-decimal string form, reused by every tablet-weight file
wfmt <- formatC(weights$weight_mg, format = "f", digits = 1)

writeLines(
  c("tablet_id,batch,weight_mg",
    paste(weights$tablet_id, weights$batch, wfmt, sep = ",")),
  file.path(out, "tablet_weights.csv")
)

# ------------------------------------------------------------------
# 2. titration.csv  (clean; acid-base titration of a drug)
#    Titrate extracted ibuprofen (weak acid, pKa 4.91) with 0.100 M
#    NaOH. Three replicate samples with slightly different amounts of
#    drug -> slightly different equivalence points. pH vs volume.
# ------------------------------------------------------------------
pKa <- 4.91
Ka  <- 10^(-pKa)
Kw  <- 1e-14
Cb  <- 0.100          # NaOH titrant concentration (mol/L)
Va  <- 25.0           # aliquot volume (mL)

# per-sample analytical drug concentration (mol/L) -> Veq = Ca*Va/Cb
Ca_sample <- c(A = 0.098, B = 0.100, C = 0.102)

vols <- c(0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 23, 24,
          24.5, 25, 25.5, 26, 27, 28, 30, 32, 34, 36, 38, 40)

# exact pH from charge balance:
#   Cb*Vb/V + h = Kw/h + Ca_t*Ka/(Ka + h)
ph_at <- function(Vb, Ca) {
  V    <- Va + Vb
  Cat  <- Ca * Va / V          # diluted analytical acid conc
  Na   <- Cb * Vb / V          # sodium (from titrant)
  f <- function(h) Na + h - Kw / h - Cat * Ka / (Ka + h)
  h <- uniroot(f, lower = 1e-14, upper = 1, tol = 1e-16)$root
  -log10(h)
}

tit_list <- lapply(names(Ca_sample), function(s) {
  ph <- vapply(vols, ph_at, numeric(1), Ca = Ca_sample[[s]])
  ph <- round(ph + rnorm(length(ph), 0, 0.03), 2)   # meter noise
  data.frame(sample_id = s, volume_ml = vols, pH = ph,
             stringsAsFactors = FALSE)
})
titration <- do.call(rbind, tit_list)

write.csv(titration, file.path(out, "titration.csv"),
          row.names = FALSE, quote = FALSE)

# ------------------------------------------------------------------
# 3. dissolution.csv  (clean; drug release over time)
#    Six tablets in dissolution fluid; % of drug released climbs
#    toward 100% following first-order kinetics. pct vs time.
# ------------------------------------------------------------------
diss_times <- c(5, 10, 15, 20, 30, 45, 60)
n_tab <- 6
set.seed(123)
k_tab <- runif(n_tab, 0.070, 0.095)          # per-tablet release rate

diss_list <- lapply(seq_len(n_tab), function(i) {
  pct <- 100 * (1 - exp(-k_tab[i] * diss_times))
  pct <- pmin(round(pct + rnorm(length(diss_times), 0, 1.2), 1), 100)
  data.frame(tablet_id = i, time_min = diss_times, pct_dissolved = pct,
             stringsAsFactors = FALSE)
})
dissolution <- do.call(rbind, diss_list)
dfmt <- formatC(dissolution$pct_dissolved, format = "f", digits = 1)

writeLines(
  c("tablet_id,time_min,pct_dissolved",
    paste(dissolution$tablet_id, dissolution$time_min, dfmt, sep = ",")),
  file.path(out, "dissolution.csv")
)

# ------------------------------------------------------------------
# 4. calibration.csv  (clean; Beer-Lambert straight line)
#    Ibuprofen UV calibration at 222 nm. Absorbance ~ concentration.
# ------------------------------------------------------------------
conc <- c(0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20)
slope <- 0.0447          # AU per ug/mL
intercept <- 0.004
absorbance <- round(intercept + slope * conc +
                    rnorm(length(conc), 0, 0.004), 3)
absorbance[conc == 0] <- 0.000   # instrument zeroed on the blank

writeLines(
  c("conc_ug_ml,absorbance",
    paste(conc, formatC(absorbance, format = "f", digits = 3), sep = ",")),
  file.path(out, "calibration.csv")
)

# ------------------------------------------------------------------
# Defect variants (one defect each) -- spread across the experiments
# ------------------------------------------------------------------

# 5. dissolution_dk.csv  -> dissolution data; ';' sep, comma decimals
#    (same numbers as dissolution.csv, as a Danish instrument exports them)
writeLines(
  c("tablet_id;time_min;pct_dissolved",
    paste(dissolution$tablet_id, dissolution$time_min,
          sub("\\.", ",", dfmt), sep = ";")),
  file.path(out, "dissolution_dk.csv")
)

# 6. titration_missing.csv  -> one titration run; mixed NA codes
#    (sample B from titration.csv, with three pH readings not recorded)
runB   <- titration[titration$sample_id == "B", c("volume_ml", "pH")]
phfmt  <- formatC(runB$pH, format = "f", digits = 2)
phfmt[c(5, 15, 22)] <- c("N/A", "-", "")   # three different "missing" styles
writeLines(
  c("volume_ml,pH",
    paste(runB$volume_ml, phfmt, sep = ",")),
  file.path(out, "titration_missing.csv")
)

# 7. weights_units.csv  -> numbers stored as text ("501.3 mg")
writeLines(
  c("tablet_id,batch,weight_mg",
    paste(weights$tablet_id, weights$batch,
          paste0(wfmt, " mg"), sep = ",")),
  file.path(out, "weights_units.csv")
)

# 8. weights_duplicates.csv  -> two whole rows logged twice
dup_idx <- c(seq_len(n), 5, 18)           # tablets 5 and 18 duplicated
writeLines(
  c("tablet_id,batch,weight_mg",
    paste(weights$tablet_id[dup_idx], weights$batch[dup_idx],
          wfmt[dup_idx], sep = ",")),
  file.path(out, "weights_duplicates.csv")
)

# 9. batches_messy.csv  -> inconsistent batch labels
styles <- list(
  A = c("A", "a", "Batch A", " A", "A "),
  B = c("B", "b", "Batch B", "B ", " b"),
  C = c("C", "c", "Batch C", " C", "c ")
)
set.seed(7)
messy_batch <- vapply(weights$batch, function(b) sample(styles[[b]], 1), character(1))
writeLines(
  c("tablet_id,batch,weight_mg",
    paste(weights$tablet_id, messy_batch, wfmt, sep = ",")),
  file.path(out, "batches_messy.csv")
)

# 10. weights_export.csv  -> metadata block on top AND mixed NA codes
#     Straight off the balance: four header lines, then the table with some
#     readings missing. Needs read_csv(skip = 4, na = c("","NA","N/A","-")).
meta <- c("Balance export - ibuprofen 400 mg tablets",
          "Instrument: Mettler XPR205",
          "Operator: L. Sorensen",
          "Exported: 2026-07-14")
miss2 <- wfmt
miss2[c(4, 9, 15, 22)] <- c("", "NA", "N/A", "-")   # four missing styles
writeLines(
  c(meta,
    "tablet_id,batch,weight_mg",
    paste(weights$tablet_id, weights$batch, miss2, sep = ",")),
  file.path(out, "weights_export.csv")
)

cat("Wrote CSVs to", normalizePath(out), "\n")
cat("Titration equivalence points (mL):",
    paste(names(Ca_sample), round(Ca_sample * Va / Cb, 2), sep = "="), "\n")

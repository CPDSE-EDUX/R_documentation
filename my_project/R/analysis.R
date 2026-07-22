# Example analysis for the "Setting Up an R Project" tutorial.
# It reads the tablet weight data, summarises it by batch, saves the
# summary to output/, and saves a plot to figures/.
#
# How to run: open my_project.Rproj in RStudio, open this file, and click
# "Source" (or select all and press Ctrl+Enter / Cmd+Enter).
#
# This script needs the tidyverse. Install it once with:
#   install.packages("tidyverse")

library(tidyverse)

# Make sure the output folders exist (they are created if missing)
dir.create("output",  showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)

# 1. Read the raw data using a project-relative path
tablets <- read_csv("data/tablet_weights.csv")

# 2. Summarise average tablet weight per batch
batch_summary <- tablets %>%
  group_by(batch) %>%
  summarise(
    n       = n(),
    mean_mg = mean(weight_mg),
    sd_mg   = sd(weight_mg)
  )

print(batch_summary)

# 3. Save the summary table to output/
write_csv(batch_summary, "output/batch_summary.csv")

# 4. Plot the weight distribution per batch and save to figures/
weight_plot <- ggplot(tablets, aes(x = batch, y = weight_mg)) +
  geom_boxplot(fill = "steelblue") +
  labs(
    x     = "Batch",
    y     = "Tablet weight (mg)",
    title = "Tablet weight by batch"
  ) +
  theme_classic()

ggsave("figures/weight_by_batch.png", weight_plot, width = 6, height = 4, dpi = 150)

cat("Done! See output/batch_summary.csv and figures/weight_by_batch.png\n")

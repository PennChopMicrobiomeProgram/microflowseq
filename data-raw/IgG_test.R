library(tidyverse)
library(dplyr)
library(tidyr)

# IgG_test.txt and IgM_test.txt are CSV/TSV files that have the following columns:
# Taxa	SampleID	props	SubjectID	Analysis4	Population	Name	SNV	fraction
# An example row:
# Firmicutes Blautia 00a96fbd0ac34bfd245f9c24f8737f7d	IDAHO027	0.000899949133309856	F2-2	Pos_Stool	IgM+IgG-	Firmicutes Blautia	00a96fbd0ac34bfd245f9c24f8737f7d	0.322
igg <- read_delim("data-raw/IgG_test.txt")

iggParseASVProps <- function (df, sid) {
  df %>%
    filter(SubjectID == sid) %>%
    spread(Population, props) %>%
    select(-one_of(c("SampleID", "SubjectID", "Analysis4", "Name", "SNV", "fraction"))) %>%
    group_by(Taxa) %>%
    fill(`IgA-IgM-IgG-`, `IgG+IgM-`, `IgG+IgM+`, `IgM+IgG-`, .direction = 'up') %>%
    filter(!is.na(`IgM+IgG-`))
}

parseFracs <- function (df, sid) {
  df <- df %>%
    filter(SubjectID == sid) %>%
    spread(Population, props) %>%
    select(-one_of(c("SampleID", "SubjectID", "Analysis4", "Name", "SNV"))) %>%
    group_by(Taxa)
  df[1:4,][["fraction"]]
}

iggASVProps <- iggParseASVProps(igg, "F1-1")
iggFracs <- parseFracs(igg, "F1-1")

usethis::use_data(iggASVProps, overwrite = TRUE)
usethis::use_data(iggFracs, overwrite = TRUE)

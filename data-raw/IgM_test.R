library(tidyverse)
library(dplyr)
library(tidyr)

# IgG_test.txt and IgM_test.txt are CSV/TSV files that have the following columns:
# Taxa	SampleID	props	SubjectID	Analysis4	Population	Name	SNV	fraction
# An example row:
# Firmicutes Blautia 00a96fbd0ac34bfd245f9c24f8737f7d	IDAHO027	0.000899949133309856	F2-2	Pos_Stool	IgM+IgG-	Firmicutes Blautia	00a96fbd0ac34bfd245f9c24f8737f7d	0.322
igm <- read_delim("data-raw/IgM_test.txt")

igmParseASVProps <- function (df, sid) {
  df %>%
    filter(SubjectID == sid) %>%
    spread(Population, props) %>%
    select(-one_of(c("SampleID", "SubjectID", "Analysis4", "Name", "SNV", "fraction"))) %>%
    group_by(Taxa) %>%
    fill(`IgA-IgM-IgG-`, `IgA+IgM-`, `IgM+IgA-`, `IgM+IgA+`, .direction = 'up') %>%
    filter(!is.na(`IgA+IgM-`))
}

parseFracs <- function (df, sid) {
  df <- df %>%
    filter(SubjectID == sid) %>%
    spread(Population, props) %>%
    select(-one_of(c("SampleID", "SubjectID", "Analysis4", "Name", "SNV"))) %>%
    group_by(Taxa)
  df[1:4,][["fraction"]]
}

igmASVProps <- igmParseASVProps(igm, "F1-1")
igmFracs <- parseFracs(igm, "F1-1")

usethis::use_data(igmASVProps, overwrite = TRUE)
usethis::use_data(igmFracs, overwrite = TRUE)

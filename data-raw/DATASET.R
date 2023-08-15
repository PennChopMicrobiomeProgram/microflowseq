library('tidyverse')

# IgG_test.txt and IgM_test.txt are CSV/TSV files that have the following columns:
# Taxa	SampleID	props	SubjectID	Analysis4	Population	Name	SNV	fraction
# An example row:
# Firmicutes Blautia 00a96fbd0ac34bfd245f9c24f8737f7d	IDAHO027	0.000899949133309856	F2-2	Pos_Stool	IgM+IgG-	Firmicutes Blautia	00a96fbd0ac34bfd245f9c24f8737f7d	0.322
igg <- read_delim("IgG_test.txt")
igm <- read_delim("IgM_test.txt")

usethis::use_data(igg, overwrite = TRUE)
usethis::use_data(igm, overwrite = TRUE)

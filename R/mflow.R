renormalize <- function (x, total = 1) {
  total * x / sum(x)
}

#' Probability of an ASV appearing in each channel from mFLOW-Seq
#'
#' This is the function you would use for data in long format, operating on one
#' specimen and one ASV at a time
#'
#' @param asv_proportions Proportion of ASVs in sample
#' @param fraction_abundances Total abundance for each mFLOW channel
#' @return A vector of probabilities that the ASV was tagged in each channel.
#' @export
#'
mflow_probability <- function (asv_proportions, fraction_abundances) {
  renormalize(asv_proportions * fraction_abundances)
}

#' mFLOW-Seq probabilities for ASV data in matrix or data frame format
#'
#' @param asv_matrix Proportion of ASVs in each sample. ASVs should be in rows,
#'   the mFLOW-Seq channels should be in columns. The whole matrix should
#'   correspond to one specimen that was sorted and sequenced.
#' @param fraction_abundances Total abundance for each mFLOW channel
#' @return A matrix of probabilities that each ASV was tagged in each channel.
#' @export
#'
mflow_apply <- function (asv_matrix, fraction_abundances) {
  t(apply(asv_matrix, 1, mflow_probability, fraction_abundances))
}

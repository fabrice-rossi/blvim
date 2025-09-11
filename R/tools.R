positions_as_df <- function(positions, prefix) {
  pos_df <- as.data.frame(positions)
  if (is.null(colnames(positions))) {
    names(pos_df) <- c("x", "y", "z")[seq_len(ncol(pos_df))]
  }
  if (!is.null(prefix)) {
    names(pos_df) <- paste(prefix, names(pos_df), sep = "_")
  }
  pos_df
}

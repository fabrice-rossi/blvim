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

combine_df <- function(my_df, val, val_name) {
  if (length(my_df) > 1) {
    final_sizes <- sapply(my_df, nrow)
    final_nrow <- sum(final_sizes)
    final_df <- as.data.frame(lapply(my_df[[1]], function(x) rep(x, length.out = final_nrow)))
    final_df[[val_name]] <- rep(val, times = final_sizes)
    start_idx <- final_sizes[1]
    for (k in 2:length(my_df)) {
      next_idx <- start_idx + final_sizes[k]
      final_df[(start_idx + 1):next_idx, seq_len(ncol(my_df[[k]]))] <- my_df[[k]]
      start_idx <- next_idx
    }
  } else {
    final_df <- my_df[[1]]
    final_df[[val_name]] <- val
  }
  final_df
}

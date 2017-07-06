
#' Call phreeqc
#'
#' This function is a wrapper around \link[phreeqc]{phrRunString} and
#' \link[phreeqc]{phrGetSelectedOutput}. The database is reloaded by default,
#' because saved options lead to occasionally confusing output.
#'
#' @param ... A character vector(s) of inputs.
#' @param db A database to use (see \link{use_db}). Use NA for the default,
#'   and NULL to skip (re)loading the database.
#' @param quiet Use TRUE to see the full output provided by PHREEQC. This is
#'   useful to find the species that are considered before adding a
#'   \link{selected_output}
#'
#' @return A data.frame with the first \link{selected_output}
#' @export
#'
#' @examples
#' phreeqc(phreeqc::ex2)
#'
phreeqc <- function(..., db = NA, quiet = TRUE) {
  # concatenate the input
  input_list <- list(...)
  input <- c(unlist(input_list))

  # verify input is a string
  if(!is.character(input)) stop("'input' must be an atomic character vector")

  # the default is to reset the database every call
  # this results in much cleaner behaviour (options are not saved)

  # NA means use the current default
  if(identical(db, NA)) {
    use_db(db_state$current_db, save = FALSE)
  } else if(!is.null(db)) {
    # call use_db_ ...
    match.fun(paste0("use_db_", db))(save = FALSE)
  }

  # capture string output as a tempfile
  out_filename <- tempfile()[1]
  phreeqc::phrSetOutputFileName(out_filename)
  phreeqc::phrSetOutputFileOn(TRUE)

  # call phreeqc
  phreeqc::phrRunString(input)
  # return selected output
  output <- phreeqc::phrGetSelectedOutput()

  # if not in quiet mode, message the output
  if(!quiet) {
    cat(paste(c(readLines(out_filename), "\n"), collapse = "\n"))
    unlink(out_filename)
  }

  # if zero-length output, the user did not specify any selected_output
  if(length(output) == 0) {
    message("Specify at least one selected_output() to retreive results as a data.frame")
    return(NULL)
  }

  # we return just one data frame or NULL
 if(is.vector(output) && is.list(output)) {
    if(length(output) > 1) {
      message("More than one selected_output returned; returning the first one")
    }

    # always just return the first element
    output[[1]]
  } else {
    stop("Unknown output type: ", class(output)[1])
  }
}

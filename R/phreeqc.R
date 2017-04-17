
#' Call phreeqc
#'
#' This function is a wrapper around \link[phreeqc]{phrRunString} and
#' \link[phreeqc]{phrGetSelectedOutput}. The database is reloaded by default,
#' because saved options lead to occasionally confusing output.
#'
#' @param ... A character vector(s) of inputs.
#' @param db A database to use (see \link{use_db}). Use NA for the default,
#'   and NULL to skip (re)loading the database.
#'
#' @return A data.frame with the first \link{selected_output}
#' @export
#'
#' @examples
#' phreeqc(phreeqc::ex2)
#'
phreeqc <- function(..., db = NA) {
  # concatenate the input
  input <- c(...)

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

  # call phreeqc
  phreeqc::phrRunString(input)
  # return output
  output <- phreeqc::phrGetSelectedOutput()

  # if zero-length output, the user did not specify any selected_output
  if(length(output) == 0) {
    message("Zero-length output. Did you specify at least one selected_output()?")
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

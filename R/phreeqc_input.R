
#' Create input sections for phreeqc
#'
#' @param type The keyword name to use (e.g. SOLUTION)
#' @param number,.number Number of the component
#' @param name,.name Name of the component
#' @param components,... Key/value pairs corresponding to lines of input
#' @param x,y An object created by phreeqc_input
#'
#' @return A character vector with an element for each line
#' @export
#'
#' @examples
#' # pure water solution
#' solution(pH=7, temp=25)
#'
phreeqc_input <- function(type, number = NA, name = "", components = list()) {
  # check type input
  if(!is.character(type) || (length(type) != 1)) {
    stop("'type' must be a character vector of length 1")
  }

  # check name input
  name <- as.character(name)
  if(!is.character(name) || (length(name) != 1)) {
    stop("'name' must be a character vector of length 1")
  }

  # check number input
  number <- as.integer(number)
  if(!is.integer(number) || (length(number) != 1)) {
    stop("'number' must be a numeric vector of length 1")
  }

  # number or name as "NA" means don't include
  if(is.na(number)) {
    number <- ""
  }

  if(is.na(name)) {
    name <- ""
  }

  # check for non-atomics
  lapply(components, function(val) {
    if(!is.atomic(val)) stop("Only atomic vectors are allowed in phreeqc_input")
  })

  # make sure names(components) is not null
  if(is.null(names(components))) {
    names(components) <- rep("", length(components))
  }

  # create header line, removing "" strings
  header <- c(type, number, name)
  header <- header[nchar(header) > 0]

  # paste args together
  lines <- c(
    paste(header, collapse = " "),
    paste0("    ", vapply(seq_along(components), function(i) {
      vals <- c(names(components)[i], phreeqc_escape_values(components[[i]]))
      # remove zero-length strings
      vals <- vals[nchar(vals) > 0]
      # paste values together
      paste(vals, collapse = "    ")
    }, character(1)))
  )

  # give custom class to character vector output
  as.phreeqc_input(lines)
}

#' @rdname phreeqc_input
#' @export
solution <- function(.number = 1, .name = "", ...) {
  phreeqc_input("SOLUTION", number = .number, name = .name, components = list(...))
}

#' @rdname phreeqc_input
#' @export
selected_output <- function(.number = 1, ...) {
  # names for SELECTED_OUTPUT are preceeded by a "-"
  components = list(...)
  if(length(components) > 0) {
    names(components) <- paste0("-", names(components))
  }

  # values of "TRUE" should be just the name, values of "FALSE" should be omitted
  # values of NA should be "", NULL doesn't make sense
  components <- lapply(components, function(val) {
    if(identical(val, TRUE)) {
      "true"
    } else if(identical(val, FALSE)) {
      "false"
    } else if(identical(val, NA)) {
      ""
    } else if(is.null(val)) {
      stop("value of NULL is ambiguous in call to selected_output")
    } else {
      val
    }
  })

  # remove NULL values
  components <- components[!vapply(components, is.null, logical(1))]

  # call phreeqc_input
  phreeqc_input("SELECTED_OUTPUT", number = .number, name = "", components = components)
}

#' @rdname phreeqc_input
#' @export
equilibrium_phases <- function(.number = 1, .name = NA, ...) {
  phreeqc_input("EQUILIBRIUM_PHASES", number = .number, name = .name, components = list(...))
}

#' @rdname phreeqc_input
#' @export
print.phreeqc_input <- function(x, ...) {
  cat(paste(x, collapse = "\n"))
  invisible(x)
}

#' @rdname phreeqc_input
#' @export
is.phreeqc_input <- function(x) {
  inherits(x, "phreeqc_input")
}

#' @rdname phreeqc_input
#' @export
as.phreeqc_input <- function(x) {
  structure(as.character(x), class = c("phreeqc_input", "character"))
}

#' @rdname phreeqc_input
#' @export
`+.phreeqc_input` <- function(x, y) {
  if(!is.phreeqc_input(y)) stop("Cannot add non-phreeqc_input to phreeqc_input")
  as.phreeqc_input(c(x, y))
}

# phreeqc needs quotes backslash escaped
phreeqc_escape_values <- function(vals) {
  gsub('"', '\\"', as.character(vals), fixed = TRUE)
}

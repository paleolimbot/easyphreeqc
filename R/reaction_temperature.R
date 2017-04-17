
#' Specify a reaction temperature gradient
#'
#' @param .number The number of the gradient
#' @param low The low temperature (degrees C)
#' @param high The high temperature (degrees C)
#' @param steps The number of steps to use between low and high
#'
#' @return A character vector summarising the input
#' @export
#'
#' @examples
#' reaction_temperature(low = 25, high = 75, steps = 51)
#'
#' # example 2 from the manual
#' phreeqc(solution(), # pure water
#'         equilibrium_phases(Gypsum = c(0, 1), Anhydrite = c(0, 1)),
#'         reaction_temperature(low = 25, high = 50, steps = 10),
#'         selected_output(temperature = TRUE, si = c("Gypsum", "Anhydrite")))
#'
reaction_temperature <- function(.number = 1, low = 0, high = 100, steps = 100) {
  phreeqc_input("REACTION_TEMPERATURE", number = .number,
                components = list(sprintf("%f %f in %d steps", low, high, steps)))
}

#' Load the system prompt
#'
load_system_prompt <- function() {
    #TODO remove warning
    system_prompt <- readLines(system.file("R/system_prompt.txt"))
    paste(system_prompt, collapse="\n")
}

#' capture history, output to a string
#' Note this only works on Unix-like systems
#'
string_history <- function() {
    file1 <- tempfile("Rrawhist")
    savehistory(file1)
    rawhist <- readLines(file1)
    unlink(file1)
    paste(rawhist, collapse="\n")
}

#' Explain an S3 object in plain English, using an LLM
#' 
#' @param x an object to be explained
#' @param var_desc a list of string descriptions (ideally including units) for each variable
#' @param datagen a brief description of the process that generated the data
#' @param send_history boolean whether to pull and send R command history for context
#' @param ... extra arguments
#'
#' @import openai
#'
aiexplain <- function(x, var_desc = "", datagen = "", send_history = TRUE, ...) {

    #TODO add check for OpenAI key being set 

    if (send_history) {
        command_history <- paste(c("Prior command history:", string_history()), collapse=" ")
    } else {
        command_history <- "(Prior command history not included)"
    }

    system_prompt <- load_system_prompt()

    var_desc <- paste(var_desc, collapse="\n")

    if (datagen != "") {
        datagen <- paste(c("Here is an explanation of how this data was collected.", datagen), collapse = " ")
    }

    messages <- list(list("role" = "system",
                          "content" = system_prompt),
                    list("role" = "user",
                          "content" = "What conclusions can we draw from the following R output? Do NOT list a summary of key results, instead provide ONLY a simple explanation of the underlying data and an interpretation of the results. Whenever possible, use percentages instead of raw numbers (e.g. 80% instead of 0.8). If the information I give you is inconsistent, instead explain the inconsistency and STOP."),
                     list("role" = "user",
                          "content" = paste(capture.output(x), collapse="\n")),
                     list("role" = "user",
                          "content" = paste(capture.output(summary(x)), collapse="\n")),
                     list("role" = "user", 
                          "content" = datagen),
                     list("role" = "user", 
                          "content" = var_desc),
                     list("role" = "user",
                          "content" = command_history))

    out <- create_chat_completion(model='gpt-4',
                                  temperature=0,
                                  max_tokens=2048,
                                  messages=messages)
    out$choices$message.content
}

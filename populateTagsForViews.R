## This is where I need to make make a script to tag all the older
## posts with biocviews and with the names of the packages that they
## refer too.

## For tagging, I should be able to do it like this:
## http://docs.biostars.org/en/latest/manage.html#command-line-tagging

## Basically I need a command like this:
## workon biostar
## source live/deploy.env
## python manage.py patch --tag "regexp:tag1,tag2,tag3"

## So my use case should look more like this
## python manage.py patch --tag "<foo>:<foo>"
## Where <foo> is the tag in question.



## So we will start with a vector of things to tag.  Read that in from
## biocviews and from the list of package names.

## views = c('bob', 'sue', 'anna')
library(biocViews)

getAllBiocTerms <- function(){
    .parseDot <- function(dot)
    {
        dot <- sub(" *; *$", "", dot[grepl("^[[:space:][:alpha:]]+->", dot)])
        unique(unlist(strsplit(dot, " *-> *")))
    }
    
    biocViewdotfile <- system.file("dot","biocViewsVocab.dot",
                                   package="biocViews")

    if(!file.exists(biocViewdotfile))
        stop("Package biocViews not found.")
    
    dot <- readLines(biocViewdotfile)
    
    software <- dot[seq(grep("BiocViews -> Software", dot),
                        grep("BiocViews -> AnnotationData", dot) - 1)]
    annotation <- dot[seq(grep("BiocViews -> AnnotationData", dot),
                          grep("BiocViews -> ExperimentData", dot) - 1)]
    expt <- dot[seq(grep("BiocViews -> ExperimentData", dot),
                    length(dot),1)]
    
    software <- .parseDot(software)
    expt <- .parseDot(expt)
    annotation <- .parseDot(annotation)
    ## return the unique list
    unique(c(software,expt,annotation))
}
## Then call it
views <- getAllBiocTerms()

## Remove "_" from views; -> species should not normally have an underscore
views <- gsub("_", " ", views)

## For everything that is not a 'db0' or 'cdf', require a white space
## at the front...
views <- paste0("(?<= )", views)
views[views %in% paste0('(?<= )','db0')] <- 'db0'
views[views %in% paste0('(?<= )','cdf')] <- 'cdf'

## And for the package names, I have another helper function from my
## other package that lists all the package names too...


library(BiocContributions)




getAllPackageNamesEver <- function(path='~/proj/Rpacks/'){
    files <- BiocContributions:::.makeManifestNames(path)
    .getNames <- function(file){
        res <- scan(file, what="character",skip=1, quiet=TRUE)
        res[!grepl('Package:', res)]
    }
    unique(unlist(lapply(files, .getNames)))    
}
## Then get package names for every package ever in the manifest.
packageNames <- getAllPackageNamesEver()

## For everything in this list, require a starting whitespace
packageNames <- paste0('(?<= )', packageNames)

## Then combine both lists (for 1270 tags!)
names <- c(views, packageNames)
## Then make into commands for executing the tagging script.
## This has been edited especially to prevent tagging when the string
## is followed by an underscore.
## commands = paste0("python manage.py patch --tag '", names,'(?!_):',names,"'")
## The above works OK but I need 1) a black list so that we are not
## tagging stuff like 'software' and 2) I need to insist that there is
## always a white space at the beggining of a word.

blackList <- c("(?<= )Software","(?<= )ag", "(?<= )Technology",
               "(?<= )HELP" , "(?<= )les" ) ##, "(?<= )GENE.E", "(?<= )SIM",
               ## "(?<= )ROC", "(?<= )BUS", "(?<= )GeneR")

names <- names[!(names %in% blackList)]
cleanNames <- gsub('\\(\\?<= \\)','',names)

commands = paste0("python manage.py patch --tag '",
                  names,'(?=[ ,.]):', cleanNames,"'")


length(commands)

.system <- function(command){
    message(command)
    system(command)
}




res <- lapply(commands, .system)

table(unlist(res))


## Test example that worked
## python manage.py patch --tag "Biobase:Biobase"

## OK that works but it raises a problem since the most common thing
## are cases where someone has called Sessioninfo().  So I need to
## change the regular expression part so that it looks more like this:
##  python manage.py patch --tag "AnnotationDbi :AnnotationDbi"
## That way the cases where it is Biobase_ (Sessioninfo) will not be matched.
## But even better is to do it more like this (uses negative lookahead)
##  python manage.py patch --tag "AnnotationHub(?!_):AnnotationHub"

## used this site to make sure the expression is correct :)
## http://www.pythonregex.com/

## Had some small troubles with command line not liking some characters...
## secret is you have to use single quotes like so:
## python manage.py patch --tag 'biobase(?!_):biobase'




## GOOD NEWS: this python tool does not appear to double tag the database.



##################################
## ON habu just do this:
load('commands.Rda')
## And then:
.system <- function(command){
    message(command)
    system(command)
}

## test
res <- lapply(commands[1], .system)
## Looks A-OK


res <- lapply(commands, .system)

table(unlist(res))

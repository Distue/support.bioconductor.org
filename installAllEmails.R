## script to just run through all the email files.
## BEFORE you can import you may want to delete existing files:
## ./biostar.sh delete
## and if you did that, then you MUST init the DB
## ./biostar.sh init

## work from here:
## cd /mnt/cpb_anno/mcarlson/BioconductorEmailRepos/unpacked/

## Next I need to sort by DATE
## This won't work since it assumes that the date the file arrived at
## my FS is the right one :P
## details = file.info(list.files(pattern="*.txt"))
## gives nice data.frame (which can be sorted)

baseDir <- '/mnt/cpb_anno/mcarlson/BioconductorEmailRepos/unpacked/'
files <-  dir(baseDir)

.getDateObj <- function(str){
    shrtStr <- sub(".txt","",str)
    dateInfo <- unlist(strsplit(shrtStr, split="-"))
    year <- dateInfo[1]
    month <- dateInfo[2]
    ## convert month name to number
    months <- 1:12
    names(months) <- month.name
    monthNum <- months[names(months) %in% month]
    ## make a date String
    dateStr <- paste0(year,"-",monthNum,"-01") ## day doesn't matter here
    ## then use like:
    as.POSIXct(dateStr, "America/Seattle")
}

## extract the dates from our strings
lst <- lapply(files, .getDateObj)
names(lst) <- files
res <- unlist(lst)
## Then finally we can sort them...
res <- sort(res)
## and now the names will be in the right order
sortedFiles <- names(res)

## ## then we want to make a huge cat (IN ORDER)
## ## EG:  cat january.txt february.txt march.txt > all.txt
## cmd <- paste0('cat ', paste0(sortedFiles, collapse=" "), ' > all.txt')
## system(cmd)



###################################################################
## The following code is just if we want to iterate and load each one
## in turn from R (turns out we probably don't)???  - Right now this is the only thing that works...

## base dir
## baseDir <- '/mnt/cpb_anno/mcarlson/BioconductorEmailRepos/unpacked/'

## I want to do this over and over...
## python manage.py import_mbox -f 2014-January.txt

## files <- dir(baseDir)

## just 2013
filePaths <- paste0(baseDir, sortedFiles[133:144])
## just 2014
filePaths <- paste0(baseDir, sortedFiles[145:150])

## all the stuff
filePaths <- paste0(baseDir, sortedFiles)



commands <- paste0('python manage.py import_mbox -f ', filePaths)

## Shave off that 'all.txt' command
## commands <- commands[1:(length(commands)-1)]

length(commands)

.system <- function(command){
    message(command)
    system(command)
}


## lapply(commands[1:10], .system)



res <- lapply(commands, .system)

## make sure they all loaded:
table(unlist(res))



## I think the problem with the 'big cat' is that I basically lose
## everything after the 1st non-working month.  So I have to work out
## why some months don't import...


## then just run em all..
## lapply(commands[1:50], .system)

## lapply(commands[51:100], .system)

## IN this set I had TROUBLE with these files:
## Fixed now?
## /mnt/cpb_anno/mcarlson/BioconductorEmailRepos/unpacked/2007-October.txt
## /mnt/cpb_anno/mcarlson/BioconductorEmailRepos/unpacked/2010-February.txt

## still borked:
## /mnt/cpb_anno/mcarlson/BioconductorEmailRepos/unpacked/2008-May.txt
## TypeError: decode() argument 1 must be string, not None




## lapply(commands[101:146], .system)
## IN this set I had TROUBLE with these files:

## Fixed list:
## /mnt/cpb_anno/mcarlson/BioconductorEmailRepos/unpacked/2010-March.txt
## /mnt/cpb_anno/mcarlson/BioconductorEmailRepos/unpacked/2010-November.txt
## /mnt/cpb_anno/mcarlson/BioconductorEmailRepos/unpacked/2011-April.txt
## /mnt/cpb_anno/mcarlson/BioconductorEmailRepos/unpacked/2011-August.txt
## /mnt/cpb_anno/mcarlson/BioconductorEmailRepos/unpacked/2013-January.txt


## Still broken:
## /mnt/cpb_anno/mcarlson/BioconductorEmailRepos/unpacked/2011-March.txt
##   File "/home/mcarlson/tasks/forkBiostars/biostar-central/biostar/server/management/commands/import_mbox.py", line 211, in unpack_message
##     body = body.decode(charset).encode('utf-8')
## TypeError: decode() argument 1 must be string, not None

## /mnt/cpb_anno/mcarlson/BioconductorEmailRepos/unpacked/2012-August.txt
##   File "/home/mcarlson/tasks/forkBiostars/biostar-central/biostar/server/management/commands/import_mbox.py", line 211, in unpack_message
##     body = body.decode(charset).encode('utf-8')
## TypeError: decode() argument 1 must be string, not None

## /mnt/cpb_anno/mcarlson/BioconductorEmailRepos/unpacked/2013-October.txt
##   File "/home/mcarlson/tasks/forkBiostars/biostar-central/biostar/server/management/commands/import_mbox.py", line 211, in unpack_message
##     body = body.decode(charset).encode('utf-8')
## TypeError: decode() argument 1 must be string, not None



##################################################################
 ## THESE TWO: looks different from the rest.
## /mnt/cpb_anno/mcarlson/BioconductorEmailRepos/unpacked/2012-June.txt
##   File "/home/mcarlson/virt_env/biostar/local/lib/python2.7/site-packages/django/db/backends/util.py", line 53, in execute
##     return self.cursor.execute(sql, params)
## django.db.utils.DataError: value too long for type character varying(200)

 ## And this one also looks like that:
## /mnt/cpb_anno/mcarlson/BioconductorEmailRepos/unpacked/2012-March.txt
##   File "/home/mcarlson/virt_env/biostar/local/lib/python2.7/site-packages/django/db/backends/util.py", line 53, in execute
##     return self.cursor.execute(sql, params)
## django.db.utils.DataError: value too long for type character varying(200)




## Ok since the latest bug fixes, now the only one that no longer loads is May 2005 (probably not a deal breaker).


## It does this:

## INFO --- creating Answer:  how to dat cel files
## Traceback (most recent call last):
##   File "manage.py", line 9, in <module>
##     execute_from_command_line(sys.argv)
##   File "/home/mcarlson/virt_env/biostar/local/lib/python2.7/site-packages/django/core/management/__init__.py", line 399, in execute_from_command_line
##     utility.execute()
##   File "/home/mcarlson/virt_env/biostar/local/lib/python2.7/site-packages/django/core/management/__init__.py", line 392, in execute
##     self.fetch_command(subcommand).run_from_argv(self.argv)
##   File "/home/mcarlson/virt_env/biostar/local/lib/python2.7/site-packages/django/core/management/base.py", line 242, in run_from_argv
##     self.execute(*args, **options.__dict__)
##   File "/home/mcarlson/virt_env/biostar/local/lib/python2.7/site-packages/django/core/management/base.py", line 285, in execute
##     output = self.handle(*args, **options)
##   File "/home/mcarlson/tasks/forkBiostars/biostar-central/biostar/server/management/commands/import_mbox.py", line 53, in handle
##     parse_mboxx(fname, limit=limit, tag_val=tags)
##   File "/home/mcarlson/tasks/forkBiostars/biostar-central/biostar/server/management/commands/import_mbox.py", line 270, in parse_mboxx
##     for b in rows:
##   File "/home/mcarlson/tasks/forkBiostars/biostar-central/biostar/server/management/commands/import_mbox.py", line 213, in unpack_message
##     body = body.decode(charset).encode('utf-8')
## UnicodeDecodeError: 'euc_jp' codec can't decode bytes in position 12-13: illegal multibyte sequence

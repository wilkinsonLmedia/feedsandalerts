library(pacman)
p_load(tidyverse, magrittr, tidyRSS, blastula, cronR)

#set up path
cmd <- cron_rscript("/Users/sophiewill/Documents/Data Projects/feedsandalerts/code/01-setting-up-RSS.R")

# #cron docs https://cran.r-project.org/web/packages/cronR/cronR.pdf
# #test cron
# cron_add(command = cmd, frequency = 'daily', at = "10:21", id = "test1",
         # description = "testing cron")
# #then remove it
# cron_clear(ask = TRUE, user = "")
# #and check it's gone
# cron_ls()

#add actual schedule
cron_add(command = cmd, frequency = 'daily', at = "07:00", id = "Daily FedReg",
         description = "Sending daily federal register for my agencies")
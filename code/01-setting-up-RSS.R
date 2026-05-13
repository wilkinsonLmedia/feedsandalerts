library(pacman)
p_load(tidyverse, magrittr, tidyRSS, blastula, cronR, knitr)

#set today
today <- as.Date(Sys.Date())

#### helper function to make a md table ####
make_md_list <- function(df) {
  if (nrow(df) == 0) return("_No updates for today._")
  
  df %>%
    mutate(
      #creating a cleaner bulleted list with extra lines
      bullet = glue::glue("* **{item_title}**\n  Published: {item_pub_date} | [View Document]({item_link})\n _{item_description}_\n\n")
    ) %>%
    pull(bullet) %>%
    paste(collapse = "\n") #cmbine all bullets into one long string
}

##### get registers #####
#Justice
justice_fed_register <- tidyfeed("https://www.federalregister.gov/api/v1/documents.rss?conditions%5Bagencies%5D%5B%5D=justice-department") %>%
  filter(feed_pub_date >= today | item_pub_date >= today) %>% #only items posted or put in the feed today
  select(item_pub_date, feed_pub_date, item_title, item_link, item_description) %>% #just which columns I'm interested in
  # filter(str_detect(item_description, regex("technology|artificial intelligence", ignore_case = TRUE))) %>% #get only key words
  make_md_list()

#GSA
gsa_fed_register <- tidyfeed("https://www.federalregister.gov/api/v1/documents.rss?conditions%5Bagencies%5D%5B%5D=general-services-administration") %>% 
  filter(feed_pub_date >= today | item_pub_date >= today) %>% #only items posted or put in the feed today
  select(item_pub_date, feed_pub_date, item_title, item_link, item_description) %>% #just which columns I'm interested in 
  make_md_list()

###### set up email #####
email <- compose_email(
  body = md(glue::glue(
    "# **Morning federal register updates for {today}**:
    
    ## GSA
    {gsa_fed_register}
    
    ## Justice
    {justice_fed_register}
    
    -----
    _This is an automated message sent at 7:00 a.m. {today} from KSW's Work Laptop_"
  ))
)

#check that there is a password via smtp
#set up creds here https://myaccount.google.com/u/1/apppasswords and put in renviron
#usethis::edit_r_environ() if not set up
smtp_password <- Sys.getenv("SMTP_PASSWORD")

# #send email
email %>%  smtp_send(
  to = "sophie.will@fedscoop.com",
  from = "ksophiewill@gmail.com",
  subject = "Morning Fed Register Updates Today",
  credentials = creds_envvar(
    user = "ksophiewill@gmail.com",
    pass_envvar = "SMTP_PASSWORD",
    provider = "gmail"
  )
)

NSFC <- function(items, StartYear, EndYear, Abstract = T){
    if(!require(rvest)) install.packages("rvest")
    if(!require(magrittr)) install.packages("magrittr")
    if(!require(stringr)) install.packages("stringr")
    library(rvest)
    library(magrittr)
    library(stringr)
    index <- 0
    AllResult <- c()
    for(j in items){
        index <- index + 1
        if(index == 20){
            Sys.sleep(600)
            index <- 0
        }
        url <- paste0("http://fund.sciencenet.cn/search/smallSubject?subject=", j, 
                      "&yearStart=", StartYear, "&yearEnd=", EndYear, 
                      "&submit=list&page=1")
        webpage <- read_html(url)
        Recorde <- html_nodes(webpage, ".blue") %>% html_text()
        AllRes <- as.numeric(Recorde[1])
        AllPage <- ceiling(AllRes/10)
        result <- c()
        
        for(i in 1:AllPage){
            index <- index + 1
            if(index == 20){
                Sys.sleep(600)
                index <- 0
            }
            url <- paste0("http://fund.sciencenet.cn/search/smallSubject?subject=", j, 
                          "&yearStart=", StartYear, "&yearEnd=", EndYear, 
                          "&submit=list&page=", i)
            webpage <- read_html(url)
            title_html <- html_nodes(webpage, "#resultLst a")
            title_data <- html_text(title_html)
            author_data <- html_nodes(webpage,'.author i') %>% html_text()
            institution_data <- html_nodes(webpage, ".author+ span i") %>% html_text()
            type_data <- html_nodes(webpage, "span+ i") %>% html_text()
            Year_data <- html_nodes(webpage, ".ico span b") %>% html_text()
            Funding_data <- html_nodes(webpage, ".ico+ p b") %>% html_text()
            KeyWord_data <- html_nodes(webpage, ".ico+ p i") %>% html_text()
            ProNum_data <- html_nodes(webpage, "i+ b") %>% html_text()
            ### 提取摘要
            Detail_url <- str_extract(title_html, 
                                      "http://fund.sciencenet.cn/project/[0-9]+")
            if(Abstract == F){
                result1 <- data.frame(ID = ProNum_data,title = title_data, author = author_data,
                                      institution = institution_data, type = type_data,
                                      year = Year_data, Funding = Funding_data,
                                      KeyWord = KeyWord_data, Abstract_url = Detail_url
                )
            }else{
                Abstract <- c()
                for(s in 1:length(Detail_url)){
                    if(KeyWord_data[s] == ""){
                        Abstract <- c(Abstract, "")
                    }else{
                        index <- index + 1
                        if(index == 20){
                            Sys.sleep(600)
                            index <- 0
                        }
                        AbstractAlone <- read_html(Detail_url[s]) %>% 
                            html_nodes('#t3 tr:nth-child(1) td') %>% html_text(trim = T)
                        Abstract <- c(Abstract, AbstractAlone)
                    }
                    
                }
                result1 <- data.frame(ID = ProNum_data,title = title_data, author = author_data,
                                      institution = institution_data, type = type_data,
                                      year = Year_data, Funding = Funding_data,
                                      KeyWord = KeyWord_data, Abstract = Abstract
                )
            }
            result <- rbind(result, result1)
        }
        result11 <- cbind(data.frame(Category = rep(j, AllRes)),
                          result)
        result11 <- result11[,c(2, 1, 7, 3:6,8:10)]
        AllResult <- rbind(AllResult, result11)
        
    }
    return(AllResult)
}
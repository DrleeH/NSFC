ExtractNSFC <- function(url, Abstract = T, index = 0){
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
    quietExtract <- quietly(str_extract)
    Detail_url <- quietExtract(title_html, 
                               "http://fund.sciencenet.cn/project/[0-9]+")
    Detail_url <- Detail_url$result
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
                if(index >= 20){
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
    ress <- list(result1 = result1, index = index)
    return(ress)
}
NSFC <- function(items, StartYear, EndYear, Abstract = T,
                 ProjectId = NULL){
    if(!require(rvest)) install.packages("rvest")
    if(!require(magrittr)) install.packages("magrittr")
    if(!require(stringr)) install.packages("stringr")
    if(!require(purrr)) install.packages("purrr")
    library(purrr)
    library(rvest)
    library(magrittr)
    library(stringr)
    index <- 0
    AllResult <- c()
    ### loop in items 
    for(j in items){
        index <- index + 1
        if(index >= 20){
            Sys.sleep(600)
            index <- 0
        }
        if(is.null(ProjectId)){
            ProjectId <- c("面上项目", "青年科学基金项目", 
                           "地区科学基金项目", "国际(地区)合作与交流项目",
                           "专项基金项目", "重点项目", "联合基金项目", 
                           "重大研究计划", "应急管理项目", "国家情况杰出基因项目", 
                           "重大项目", "海外及港澳学者合作研究基金", "国家基础科学人才培养基金",
                           "创新研究群体项目", "海外或港、澳青年学者合作研究基金", 
                           "国家重大科研仪器研制项目", "国家重大科研仪器设备研制专项",
                           "创新研究群体科学基金", "科学中心项目", "其他")
        }
        resultP <- c()
        ### loop in ProjectId
        for(p in ProjectId){
            index <- index + 1
            if(index > 20){
                Sys.sleep(600)
                index <- 0
            }
            url <- paste0("http://fund.sciencenet.cn/search/smallSubject?subject=", j, 
                          "&yearStart=", StartYear, "&yearEnd=", EndYear, "&filter%5Bcategory%5D%5B%5D=", p,
                          "&submit=list&page=1")
            webpage <- read_html(url)
            Recorde <- html_nodes(webpage, ".blue") %>% html_text()
            AllRes <- as.numeric(Recorde[1])
            if(AllRes == 0) next
            AllPage <- ceiling(AllRes/10)
            ###  if Search Page num is more than 20, download result in target years separately
            if(AllPage > 20){
                resultY <- c()
                ### loop in each year
                for(y in StartYear:EndYear){
                    if(index >= 20){
                        Sys.sleep(600)
                        index <- 0
                    }
                    url <- paste0("http://fund.sciencenet.cn/search/smallSubject?subject=", j, 
                                  "&yearStart=", y, "&yearEnd=", y, "&filter%5Bcategory%5D%5B%5D=", p,
                                  "&submit=list&page=1")
                    webpage <- read_html(url)
                    Recorde <- html_nodes(webpage, ".blue") %>% html_text()
                    AllRes <- as.numeric(Recorde[1])
                    AllPage <- ceiling(AllRes/10)
                    resultPa <- c()
                    if(AllPage > 20){
                        warning(paste0(y, " of ",j, " ",p," search result is ", AllRes, ". Only can download 200 results."))
                        AllPage <- 20
                        AllRes <- 200
                    }
                    for(i in 1:AllPage){
                        index <- index + 1
                        if(index >= 20){
                            Sys.sleep(600)
                            index <- 0
                        }
                        url <- paste0("http://fund.sciencenet.cn/search/smallSubject?subject=", j, 
                                      "&yearStart=", y, "&yearEnd=", y, "&filter%5Bcategory%5D%5B%5D=", p,
                                      "&submit=list&page=", i)
                        result <- ExtractNSFC(url = url, Abstract = Abstract, index = index)
                        index <- result$index
                        result <- result$result1
                        result11 <- cbind(data.frame(Category = rep(j, nrow(result))),
                                          result)
                        result11 <- result11[,c(2, 1, 7, 3:6,8:10)]
                        resultPa <- rbind(resultPa, result11)
                    }
                    resultY <- rbind(resultY, resultPa)
                }
                resultP <- rbind(resultP, resultY)
            }else{
                resultPa <- c()
                for(i in 1:AllPage){
                    index <- index + 1
                    if(index >= 20){
                        Sys.sleep(600)
                        index <- 0
                    }
                    url <- paste0("http://fund.sciencenet.cn/search/smallSubject?subject=", j, 
                                  "&yearStart=", StartYear, "&yearEnd=", EndYear, "&filter%5Bcategory%5D%5B%5D=", p,
                                  "&submit=list&page=", i)
                    result <- ExtractNSFC(url = url, Abstract = Abstract, index = index)
                    index <- result$index
                    result <- result$result1
                    result11 <- cbind(data.frame(Category = rep(j, nrow(result))),
                                      result)
                    result11 <- result11[,c(2, 1, 7, 3:6,8:10)]
                    resultPa <- rbind(resultPa, result11)
                }
                resultP <- rbind(resultP, resultPa)
            }
        }
        AllResult <- rbind(AllResult, resultP)
    }
    return(AllResult)
}
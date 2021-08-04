##instalar pacotes
#install.packages("jsonlite")
#install.packages("httr")
#install.packages("rvest")
#install.packages("dplyr")

#carregar pacotes
library(httr)
library(XML)
library(xml2)
library(dplyr)
#library(tidyverse)
#library(methods)
#library(XML2R)
#library(jsonlite)
#library(rvest)

#base da API
base <- "http://telemetriaws1.ana.gov.br/ServiceANA.asmx/"

#parametros
#operacao
oper <- "ListaEstacoesTelemetricas"
status_est <- 0 #0-Ativo ou 1-Manutenção
origem <- 0 #0-Todas, 1-ANA/INPE, 2-ANA/SIVAM, 3-RES_CONJ_03, 4-CotaOnline, 5-Projetos Especiais

#chamada
call1 <- paste0(base,oper,"?statusEstacoes=",status_est,"&origem=",origem)
call1
#BROWSE(call1)
resp_api <- GET(call1) #type = "basic"

#acessando o status da requisicao
status_code(resp_api)
http_status(resp_api)

#acessando dados
#content(resp_api, "text")
str(content(resp_api, "parsed"))
headers(resp_api)

#detectar sistema de codificacao
stringi::stri_enc_detect(content(resp_api, "raw"))

#converter os cacteres brutos em dados entendiveis
conteudo <- content(resp_api, type="text/xml", encoding = "utf-8")

#escrevendo arquivo xml
#bin <- content(resp_api, "raw")
#writeBin(bin, "myfile.xml")

dt1 <- xmlParse(conteudo)
#dt2 <- xmlRoot(dt1)
dt2 <- xmlToList(dt1)


df <- data.frame(
  "Nome da Estação" = xml_text(xml_find_all(conteudo, xpath = "//NomeEstacao/text()")),
  "Código" = xml_double(xml_find_all(conteudo, xpath = "//CodEstacao/text()"))
  #"Bacia" = xml_text(xml_find_all(conteudo, xpath = "//Bacia/text()")),
  #"SubBacia" = xml_text(xml_find_all(conteudo, xpath = "//SubBacia/text()")),
  #"Operadora" = xml_text(xml_find_all(conteudo, xpath = "//Operadora/text()")),
  #"Responsável" = xml_text(xml_find_all(conteudo, xpath = "//Responsavel/text()")),
  #"Município-UF" = xml_text(xml_find_all(conteudo, xpath = "//Municipio-UF/text()"))
  #"Latitude" = xml_text(xml_find_all(conteudo, xpath = "//Latitude/text()")),
  #"Longitude" = xml_text(xml_find_all(conteudo, xpath = "//Longitude/text()")),
  #"Altitude" = xml_text(xml_find_all(conteudo, xpath = "//Altitude/text()")),
  #"Código do Rio" = xml_text(xml_find_all(conteudo, xpath = "//CodRio/text()")),
  #"Nome do Rio" = xml_text(xml_find_all(conteudo, xpath = "//NomeRio/text()")),
  #"Origem" = xml_text(xml_find_all(conteudo, xpath = "//Origem/text()")),
  #"Status Estação" = xml_text(xml_find_all(conteudo, xpath = "//StatusEstacao/text()"))
  )




max_len = length(dt2$diffgram$Estacoes)


mtr1 <- matrix(data = NA, nrow = max_len, ncol = 14)
mtr1[1,1] <- dt2$diffgram$Estacoes$Table

for (i in 1:max_len) {
  mtr1[i,1] <- dt2$diffgram$Estacoes$Table[i]
}

str(conteudo[3])



# bind the data.frames built in the iterator together
dt3 <-
  bind_rows(lapply(xml_find_all(conteudo, "//Estacoes"), function(x) {
  
  # extract the attributes from the parent tag as a data.frame
  parent <- data.frame(as.list(xml_attrs(x)), stringsAsFactors=FALSE)
  
  # make a data.frame out of the attributes of the kids
  kids <- bind_rows(lapply(xml_children(x), function(x) as.list(xml_attrs(x))))
  
  # combine them
  #cbind.data.frame(parent, kids, stringsAsFactors=FALSE)
  
}))

x <- xml_find_all(conteudo, "//Table",  ns = xml_ns(conteudo))
parent <- data.frame(as.list(xml_attrs(x)), stringsAsFactors=FALSE)
kids <- bind_rows(lapply(xml_children(x), function(x) as.list(xml_attrs(x))))
?bind_rows()

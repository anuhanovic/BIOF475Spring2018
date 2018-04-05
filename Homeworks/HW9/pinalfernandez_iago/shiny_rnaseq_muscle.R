#Load and install libraries
if (!require("shiny")) {
  install.packages("shiny", dependencies = TRUE)
  library(shiny)
}
if (!require("plyr")) {
  install.packages("plyr", dependencies = TRUE)
  library(plyr)
}
if (!require("beeswarm")) {
  install.packages("beeswarm", dependencies = TRUE)
  library(beeswarm)
}
if (!require("psych")) {
  install.packages("psych", dependencies = TRUE)
  library(psych)
}
if (!require("gplots")) {
  install.packages("gplots", dependencies = TRUE)
  library(gplots)
}

# #Generate dataframes
# df <- read.csv("rnaseq_merged_dataset.csv")
# df<-subset(df, ACCESSION != "D0_1")
# delete <- names(df) %in% c("X", "DX", "ACCESSION")
# genes<-names(df[!delete])
# normal_mean <- colMeans(subset(df, DX=="NT")[genes])
# 
# #Normalization and log2 fold-change of HMSMM
# HSMM<-subset(df, DX=="HSMM")
# D0_mean <- colMeans(subset(df, ACCESSION == "D0_2")[genes])
# HSMM[genes] <- log2(sweep(HSMM[genes], 2, D0_mean, `/`))
# HSMM$DX <- revalue(HSMM$ACCESSION, c("D0_2" = "Day0",
#                                      "D1_1" = "Day1",
#                                      "D1_2" = "Day1",
#                                      "D2_1" = "Day2",
#                                      "D2_2" = "Day2",
#                                      "D3_1" = "Day3",
#                                      "D3_2" = "Day3",
#                                      "D4_1" = "Day4",
#                                      "D4_2" = "Day4",
#                                      "D5_1" = "Day5",
#                                      "D5_2" = "Day5",
#                                      "D6_1" = "Day6",
#                                      "D6_2" = "Day6"))
# HSMM$DX <- droplevels(HSMM$DX)
# 
# #Normalization and log2 fold-change of the rest of the samples
# df[genes] <- log2(sweep(df[genes], 2, normal_mean, `/`))
# 
# Myositis<-subset(df, !(DX %in% c("HSMM", "PmScl", "KU", "SSc")))
# Myositis$DX <- revalue(Myositis$DX, c("HMGCR" = "IMNM",
#                                       "SRP" = "IMNM",
#                                       "Jo1" = "AS",
#                                       "PL7" = "AS",
#                                       "PL12" = "AS",
#                                       "Mi2" = "DM",
#                                       "NXP2" = "DM",
#                                       "TIF1" = "DM",
#                                       "MDA5" = "DM"))
# Myositis$DX <- factor(Myositis$DX, levels = c("NT", "AS", "DM", "IMNM", "IBM"))
# Myositis <- Myositis[order(Myositis$DX),]
# 
# Autoantibodies<-subset(df, !(DX %in% c("HSMM", "SSc", "KU", "MDA5", "PL7", "PL12", "IBM")))
# Autoantibodies$DX<-droplevels(Autoantibodies$DX)
# Autoantibodies$DX <- factor(Autoantibodies$DX, levels = c("NT", "PmScl", "Jo1", "TIF1", "NXP2", "Mi2", "SRP", "HMGCR"))
# Autoantibodies <- Autoantibodies[order(Autoantibodies$DX),]
# 
# Disease<-subset(df, !(DX %in% c("HSMM", "PmScl", "KU")))
# Disease$DX <- revalue(Disease$DX, c("HMGCR" = "Myositis",
#                                     "SRP" = "Myositis",
#                                     "Jo1" = "Myositis",
#                                     "PL7" = "Myositis",
#                                     "PL12" = "Myositis",
#                                     "Mi2" = "Myositis",
#                                     "NXP2" = "Myositis",
#                                     "TIF1" = "Myositis",
#                                     "MDA5" = "Myositis",
#                                     "IBM" = "Myositis"))
# Disease$DX <- factor(Disease$DX, levels = c("NT", "Myositis", "SSc"))
# Disease <- Disease[order(Disease$DX),]
# 
# rm(df, D0_mean, normal_mean)
# 
# save(genes, HSMM, Myositis, Autoantibodies, Disease, file = "df.RData")

ui<-fluidPage(
  titlePanel(title="RNAseq muscle biopsies"),
  sidebarLayout(
    sidebarPanel(
      selectInput("group", "Select group of interest", choices = c('Disease', 'Myositis', 'Autoantibodies', 'HSMM'), multiple = FALSE),
      selectizeInput("gene", "Select gene of interest", choices = NULL, multiple = TRUE),
      br(),
      h4("Instructions"),
      p("1.- Select the grouping category"),
      p("2- Select the gene or group of genes"),
      br(),
      h4("Expected output"),
      p("-In pane 1 you will see the box plot of your gene or the heatmap of your set of genes"),
      p("-Pane 2 will show the PCA analysis of your group of interest"),
      p("-Pane 3 will display the raw data of the gene or genes you selected for each grouping category"),
      p("-Finally, pane 4 will report the summary statistics of your gene or set of genes by grouping category")
    ),
    mainPanel(
      tabsetPanel(type="tab",
        tabPanel("Plot",
         textOutput(outputId="nogene"),
         plotOutput(outputId="myplot"),
         downloadButton(outputId="downplot",
                        label="Download the plot")
        ),
        tabPanel("PCA",
         plotOutput(outputId="mypca"),
         downloadButton(outputId="downpca",
                        label="Download the PCA data")
        ),
        tabPanel("Raw Data",
         textOutput(outputId="noraw"),
         dataTableOutput("raw_data"),
         downloadButton(outputId="downraw",
                         label="Download the raw data")
        ),
        tabPanel("Summary",
         textOutput(outputId="nosum"),
         dataTableOutput("summary"),
         downloadButton( outputId="downsum",
                         label="Download the summary" )
        )
      )
    )
  )
)

server<-function(input,output,session){
  
  load("df.RData")
  
  updateSelectizeInput(session, "gene", choices=genes, server = TRUE)
  
  df <- reactive({
    x <- get(input$group)
  })
  
  output$nogene <- renderText({
    if(length(input$gene) < 1){
      "Please, select a valid gene"
    }
  })
  
  output$myplot <- renderPlot({
      if(length(input$gene) == 1){
        df <- df()
        boxplot(as.formula(paste('df$',input$gene,'~','df$DX')),data=df, main=input$gene, outline = FALSE, ylab ="log2(FPKM fold-change)")
        beeswarm(as.formula(paste('df$',input$gene,'~','df$DX')),data=df, add = TRUE)
      }
      else if(length(input$gene) > 1){
        df <- df()
        gene_matrix <- as.matrix(df[, unlist(strsplit(input$gene, split=" "))])
        gene_matrix[is.infinite(gene_matrix)] <- NA
        gene_matrix <- as.matrix(aggregate(gene_matrix, by = list(df[, "DX"]), mean, na.action=na.pass, na.rm=TRUE)[,unlist(strsplit(input$gene, split=" "))])
        rownames(gene_matrix)=unique(df[, "DX"])
        heatmap.2(gene_matrix, na.rm = TRUE, density.info="none", trace="none", cexRow=1, cexCol=0.7, Rowv=FALSE, dendrogram = "column")
      }
    })
  
  output$downplot <- downloadHandler(
    filename = function() { paste(gsub(", ", "_", toString(input$gene)), "_by_", input$group, '.png', sep='')},
    content = function(file) {
      if(length(input$gene) == 1){
        png(file)
        df <- df()
        boxplot(as.formula(paste('df$',input$gene,'~','df$DX')),data=df, main=input$gene, outline = FALSE, ylab ="log2(FPKM fold-change)")
        beeswarm(as.formula(paste('df$',input$gene,'~','df$DX')),data=df, add = TRUE)
        dev.off()
      }
      else if(length(input$gene) > 1){
        png(file)
        df <- df()
        gene_matrix <- as.matrix(df[, unlist(strsplit(input$gene, split=" "))])
        gene_matrix[is.infinite(gene_matrix)] <- NA
        gene_matrix <- as.matrix(aggregate(gene_matrix, by = list(df[, "DX"]), mean, na.action=na.pass, na.rm=TRUE)[,unlist(strsplit(input$gene, split=" "))])
        rownames(gene_matrix)=unique(df[, "DX"])
        heatmap.2(gene_matrix, na.rm = TRUE, density.info="none", trace="none", cexRow=1, cexCol=0.7, Rowv=FALSE, dendrogram = "column")
        dev.off()
      }
    }
  )
  
  output$mypca <- renderPlot({
    df <- df()
    finite_cols <- df[sapply(df, is.numeric)]
    finite_cols <- finite_cols[colSums(is.na(finite_cols)) == 0]
    finite_cols <- finite_cols[colSums(sapply(finite_cols, is.infinite)) == 0]
    PCA_RNA <- prcomp(finite_cols, scale = TRUE)
    plot(PCA_RNA$x[,1:2], col=df$DX, main=paste("Principal component analysis by", input$group))
    legend("right", legend = unique(df$DX), col=unique(df$DX), ncol = 1, pch=20)
  })
  
  output$downpca <- downloadHandler(
    filename = function() { paste(input$group, '_pca.png', sep='') },
    content = function(file) {
      png(file)
      df <- df()
      finite_cols <- df[sapply(df, is.numeric)]
      finite_cols <- finite_cols[colSums(is.na(finite_cols)) == 0]
      finite_cols <- finite_cols[colSums(sapply(finite_cols, is.infinite)) == 0]
      PCA_RNA <- prcomp(finite_cols, scale = TRUE)
      plot(PCA_RNA$x[,1:2], col=df$DX, main=paste("Principal component analysis by", input$group))
      legend("right", legend = unique(df$DX), col=unique(df$DX), ncol = 1, pch=20)
      dev.off()
    })
  
  output$noraw <- renderText({
    if(length(input$gene) < 1){
      "No gene to show results"
    }})
  
  output$raw_data <- renderDataTable({
    if(length(input$gene) > 0){
      df <- df()
      df[,c(unlist(strsplit(input$gene, split=" ")), "DX")]
    }})
  
  output$downraw<-downloadHandler(
    filename = function() { paste(gsub(", ", "_", toString(input$gene)), "_by_", input$group, '.csv', sep='') },
    content=function(file){
      df <- df()
      var_list <- df[,c(unlist(strsplit(input$gene, split=" ")), "DX")]
      write.csv(var_list, file)
    }
  )
  
  output$nosum <- renderText({
    if(length(input$gene) < 1){
      "No gene to show results"
    }})
  
  output$summary <- renderDataTable({
    if(length(input$gene) > 0){
      df <- df()
      describeBy(df[,unlist(strsplit(input$gene, split=" "))], df$DX, mat = TRUE)
    }})
  
  output$downsum <- downloadHandler(
    filename = function() {paste(gsub(", ", "_", toString(input$gene)), "_by_", input$group, '_summ.csv', sep='') },
    content=function(file){
      df <- df()
      summ_table <- describeBy(df[,unlist(strsplit(input$gene, split=" "))], df$DX, mat = TRUE)
      write.csv(summ_table, file)
    }
  )
} 

shinyApp(ui=ui,server=server)
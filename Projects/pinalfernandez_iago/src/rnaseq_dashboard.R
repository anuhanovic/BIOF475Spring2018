#Load and install libraries
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

packages <- c("shiny", "plyr", "beeswarm", "psych", "gplots", "dplyr")
ipak(packages)

# #Generate dataframes
df <- read.csv("gene_counts.csv", row.names = 1)
df <- log2(df+1)
df <- as.data.frame(t(df))

# Generate HSMM, disease group, myositis group and autoantibody group dataframes
samples <- gsub( "_.*$", "", row.names(df) )
genes <- colnames(df)
HSMM<-subset(df, samples=="HSMM")
Myositis<-subset(df)
Disease<-subset(df)
Autoantibodies<-subset(df)

# Set appropriate DX column for each dataframe and filter based on this DX
HSMM$DX <- paste0("Day", substr(row.names(HSMM), 7, 7))

Myositis$DX <- gsub( "_.*$", "", row.names(Myositis) )
Myositis$DX <- recode(Myositis$DX, SRP='IMNM', 
                                   HMGCR='IMNM', 
                                   Jo1 = "AS",
                                   Mi2 = "DM",
                                   NXP2 = "DM",
                                   TIF1 = "DM",
                                   MDA5 = "DM")
Myositis <- subset(Myositis, Myositis$DX %in% c("NT", "IMNM", "AS", "DM", "IMNM", "IBM") )

Disease$DX <- gsub( "_.*$", "", row.names(Disease) )
Disease$DX <- recode(Disease$DX, SRP='Myositis', 
                                  HMGCR='Myositis', 
                                  Jo1 = "Myositis",
                                  Mi2 = "Myositis",
                                  NXP2 = "Myositis",
                                  TIF1 = "Myositis",
                                  MDA5 = "Myositis",
                                  IBM = "Myositis")
Disease <- subset(Disease, Disease$DX %in% c("NT", "Myositis", "SSc") )

Autoantibodies$DX <- gsub( "_.*$", "", row.names(Autoantibodies) )
Autoantibodies <- subset(Autoantibodies, Autoantibodies$DX %in% c("NT", "PmScl", "Jo1", "TIF1", "NXP2", "Mi2", "MDA5", "SRP", "HMGCR") )

save(genes, HSMM, Myositis, Autoantibodies, Disease, file = "df.RData")

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
    cols_var_0 <- names(finite_cols) %in% c(names(finite_cols[, sapply(finite_cols, function(v) length(unique(v))>1)]))
    finite_cols <- finite_cols[cols_var_0]
    PCA_RNA <- prcomp(finite_cols, scale = TRUE)
    plot(PCA_RNA$x[,1:2], col=as.factor(df$DX), main=paste("Principal component analysis by", input$group))
    legend("right", legend = unique(df$DX), col=unique(as.factor(df$DX)), ncol = 1, pch=20)
  })
  
  output$downpca <- downloadHandler(
    filename = function() { paste(input$group, '_pca.png', sep='') },
    content = function(file) {
      png(file)
      df <- df()
      finite_cols <- df[sapply(df, is.numeric)]
      finite_cols <- finite_cols[colSums(is.na(finite_cols)) == 0]
      finite_cols <- finite_cols[colSums(sapply(finite_cols, is.infinite)) == 0]
      cols_var_0 <- names(finite_cols) %in% c(names(finite_cols[, sapply(finite_cols, function(v) var(v, na.rm=TRUE)==0)]))
      finite_cols <- finite_cols[!cols_var_0]
      PCA_RNA <- prcomp(finite_cols, scale = TRUE)
      plot(PCA_RNA$x[,1:2], col=as.factor(df$DX), main=paste("Principal component analysis by", input$group))
      legend("right", legend = unique(df$DX), col=unique(as.factor(df$DX)), ncol = 1, pch=20)
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
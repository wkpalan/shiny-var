library(DT)
library(shiny)


shinyServer(function(input, output, session) {
  observe({
    source("utils.R")    
    baseGenome <- isolate(input$baseGenome)
    updateSelectInput(session, 'baseGenome', choices = genomes,selected = baseGenome)
    updateSelectInput(session, "alignGenome", choices=setdiff(genomes,input$baseGenome))
    updateSelectizeInput(session, 'geneID', choices = genes[[input$baseGenome]], server = TRUE)
    updateSelectizeInput(session, 'effectType', choices = as.character(so_obo[["name"]]), server = TRUE)
  })
  
  locSNPs <- eventReactive(input$getLocSNPs, {
    source("filterSNPs.R")
    locus <- isolate(input$locus)
    baseGenome <- isolate(input$baseGenome)
    alignGenome <- isolate(input$alignGenome)
    if(locus == ""){
      gr <- "Please enter a valid locus"
    }else{
      gr <- getSNPs(baseGenome,alignGenome,locus)
    }
    gr
  })
  
  SNP_eff <- eventReactive(input$getGeneSNPs, {
    source("filterSNPs.R")
    geneID <- isolate(input$geneID)
    baseGenome <- isolate(input$baseGenome)
    alignGenome <- isolate(input$alignGenome)
    effects <- isolate(input$effectType)
    if(geneID == ""){
      gr <- "Please enter a valid gene ID"
    }else{
      gr <- getSNPEffects(geneID,baseGenome,alignGenome,effects)
    }
    gr
  })
  
  # Filter data based on selections
  output$genome_txt <- renderText({
    baseGenome <- isolate(input$baseGenome)
    paste("Genome Selected - ",baseGenome)
    # br()
    # if(geneID == ""){
    #   paste("Gene ID has not been selected")  
    # }else{
    #   paste("Gene ID selected is")
    #   bold(input$geneID)
    # }
  })
  
  output$geneID_txt <- renderText({
    geneID <- input$geneID
    if(geneID == ""){
        paste("Gene ID has not been selected")
      }else{
        paste("Gene ID selected is - ", input$geneID)
      }
  })
  
  output$SNPLocation <- renderDataTable(DT::datatable({
    out <- locSNPs()
    if(!"data.table" %in% class(out)){
      matrix(out,dimnames=list(c("1"),c("Results")))
    }else{
      out
    }
  }))
  
  output$SNPEffect <- renderDataTable(DT::datatable({
    out <- SNP_eff()
    if(!"data.table" %in% class(out)){
      matrix(out,dimnames=list(c("1"),c("Results")))
    }else{
      out
    }
  }))
  
  output$getRegionSeq <- downloadHandler(
    filename = "sequences.txt",
    content = function(file){
    	baseGenome <- isolate(input$baseGenome)
      write.table(getBedFasta(input$bed$datapath,baseGenome),file,row.names=F,sep = "\t",col.names = F,quote = F)
      }
  )
  output$bedExample <- downloadHandler(
    filename = "example.bed",
    content = function(file){
        file.copy("test/test.bed", file)
      }
  )
})

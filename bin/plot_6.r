#!/bin/R



#library(Rtsne)
#require("biomaRt")
#library(gplots)
#library(plotrix)






argv <- commandArgs(trailingOnly=T)

#RPKM <- read.csv(argv[2], header = T, sep = "\t") # RPKM.txt
#RPKM[is.na(RPKM)] <- 0

######################## original tsne plot ##########################

init_tsne <- read.csv(argv[3], header = T, sep = "\t") # tsne2_y.txt


groups_cl <- read.csv(argv[4], header = T, sep  ="\t") # groups.cl

pdf (file = "../result/basic_tsne.pdf") ###################### need change #########################

plot(init_tsne, col=as.character(groups_cl[,1]),pch=16)

dev.off()

######################### tsne plot #############################





















color.bar <- function(lut, min, max=-min, nticks=3, ticks=seq(min, max, len=nticks), title='') {
    scale = (length(lut)-1)/(max-min)
    
    plot(c(0,1), c(min,max), type='n', bty='n', xaxt='n', xlab='', yaxt='n', ylab='', main=title)
    axis(2, ticks, las=1)
    
    
    for (i in 1:(length(lut)-1)) {
        
        y = (i-1)/scale + min
        rect(0,y,10,y+1/scale, col=lut[i], border=NA)
    }
}

mgsub <- function(pattern, replacement, x, ...) {
    if (length(pattern)!=length(replacement)) {
        stop("pattern and replacement do not have the same length.")
    }
    result <- x
    for (i in 1:length(pattern)) {
        result <- gsub(pattern[i], replacement[i], result, ...)
        
    }
    
    result
}


#keys <- as.character(rownames(RPKM))

if (argv[1] == "Human")
{
    
    annotations <- read.csv("../lib/human_annotations.txt", header = T, sep	="\t")
    #match_index <- match(annotations[,1], keys)
    genes_title <- read.csv("../lib/genes_title_human.txt", header = T, sep	="\t")
}

if (argv[1] == "Mouse")
{
    annotations <- read.csv("../lib/mouse_annotations.txt", header = T, sep	="\t")
    #match_index <- match(annotations[,1], keys)
    genes_title <- read.csv("../lib/genes_title_mouse.txt", header = T, sep	="\t")
}

if (argv[1] == "Rat")
{
    
    annotations <- read.csv("../lib/rat_annotations.txt", header = T, sep ="\t")
    #match_index <- match(annotations[,1], keys)
    genes_title <- read.csv("../lib/genes_title_rat.txt", header = T, sep	="\t")
}

if (argv[1] == "Macaca")
{    
    annotations <- read.csv("../lib/macaca_annotations.txt", header = T, sep ="\t")
    #match_index <- match(annotations[,1], keys)
    genes_title <- read.csv("../lib/genes_title_macaca.txt", header = T, sep	="\t")
}


cc <- colorRampPalette(c("yellow","red","black"))
convert.to.color <- function(x,colscale,col.range = NULL){
    x.range <- range(na.omit(x))
    by=0.1
    if (is.null(col.range)){
        
        col.range <- seq(x.range[1],x.range[2],by=by)
    }
    
    col.def <- colscale(length(col.range))
    col.idx <- round((x-x.range[1])/by)+1
    
    col.idx[col.idx > length(col.range)] <- length(col.range)
    cols <- col.def[col.idx]
    return(list(cols=cols,col.def=col.def,col.range=col.range))
    
}

candidate_genes <- mgsub("-","_",read.csv("../source/marker_genes.txt", header = F, sep = "\t")[,1]) # ../source/marker_genes.txt ###################### need change #########################

match_index <- match(toupper(candidate_genes), toupper(mgsub("-","_",annotations[,3])))

annotations[match_index[which(!is.na(match_index))],1] -> candidate_genes_ensembl

match_index_2 <- match(candidate_genes_ensembl, annotations[,1]) # annotations coordinate

match_index_3 <- match(candidate_genes_ensembl, genes_title[,1]) # rpkm matrix coordinate
















grep_string <- paste("sed -n ", sep="")

for (i in 1:length(match_index_3))
{
	
	grep_string <- paste(grep_string, " -e ", match_index_3[i] + 1,"p", sep = "")	
}

grep_string <- paste(grep_string, " ", argv[2], " > ../result/temp_rpkm.txt", sep = "") ###################### need change #########################

system(sprintf("%s", grep_string))

x <- read.csv("../result/temp_rpkm.txt", header = F, sep = "\t")###################### need change #########################
RPKM <- x[, 2:ncol(x)]
rownames(RPKM) <- make.names(x[,1], unique = T)


wrong_genes <- c()
for (i in 1:length(candidate_genes_ensembl))
{
    
    
    if (candidate_genes_ensembl[i] %in% rownames(RPKM))
    {
        filename = paste("../result/",annotations[match_index_2[i],3], '_marker_tsne.pdf', sep = "") ###################### need change #########################
        pdf (file= filename)
        par(mar=c(1,1,1,1))
        bla.cl <- convert.to.color(unlist(RPKM[as.character(candidate_genes_ensembl[i]),]),cc)
        par(fig=c(0,0.87,0.07,0.94))
        plot(init_tsne,col=bla.cl$cols,pch=16, main = annotations[match_index_2[i],3])
        par(fig=c(0.91,1,0.03,0.97), new=TRUE)
        color.bar(colorRampPalette(c("yellow","red","black"))(100), as.integer(min(unlist(RPKM[as.character(candidate_genes_ensembl[i]),]))), as.integer(max(unlist(RPKM[as.character(candidate_genes_ensembl[i]),]))))
        dev.off()
    }else
    {
        wrong_genes <- c(wrong_genes, candidate_genes[i])
        print ("Wrong gene name !!!")
    }
    
    
}


if (sum(is.na(match_index)) >= 2)
{
   
    a = "The genes listed as below are NOT corrected, pleae search the corresponding Gene Symbols in ensembl database."
    
    out = file('../result/wrong_genes.txt', 'w') ###################### need change #########################
    
    write.table(a, out, col.names = F, row.names = F, quote = F, sep = "\t")
    
    out_2 = file('../result/wrong_genes.txt', 'a') ###################### need change #########################
            
    write.table(candidate_genes[which(is.na(match_index))], out_2, col.names = F, row.names = F, quote = F, sep = "\t")
       
}else if (sum(is.na(match_index)) == 1)
{
    
    a = "The gene listed as below is NOT corrected, pleae search the corresponding Gene Symbol in ensembl database."
    
    out = file('../result/wrong_genes.txt', 'w') ###################### need change #########################
    
    write.table(a, out, col.names = F, row.names = F, quote = F, sep = "\t")
        
    out_2 = file('../result/wrong_genes.txt', 'a') ###################### need change #########################
    
    write.table(candidate_genes[which(is.na(match_index))], out_2, col.names = F, row.names = F, quote = F, sep = "\t")
    
}else if (sum(is.na(match_index)) == 0)
{
    a = "The gene listed as below is corrected, everything is all right!"
    
    out = file('../result/wrong_genes.txt', 'w') ###################### need change #########################
    
    write.table(a, out, col.names = F, row.names = F, quote = F, sep = "\t")
    
    print ("everything is all right!")
}

############################# Cluster Dendrogram ##############################


color_cluster <- c( "black", "red", "green3", "blue","cyan", "magenta",  "yellow", "grey", "brown", "purple",  "pink",  "navy", "gold", "orange", "orangered",  "blueviolet", "beige", "deepskyblue", "darkgreen", "darkmagenta","bisque","maroon",  "turquoise", "chartreuse",   "violet",  "plum", "antiquewhite1","antiquewhite2","antiquewhite3","antiquewhite4","aquamarine1","aquamarine2","aquamarine3","aquamarine4","azure1","azure2","azure3","azure4","bisque1","bisque2","bisque3","bisque4","blue1","blue2","blue3","blue4","brown1","brown2","brown3","brown4","burlywood1","burlywood2","burlywood3","burlywood4","cadetblue1","cadetblue2","cadetblue3","cadetblue4","chartreuse1","chartreuse2","chartreuse3","chartreuse4","chocolate1","chocolate2","chocolate3","chocolate4","coral1","coral2","coral3","coral4","cornsilk1","cornsilk2","cornsilk3","cornsilk4","cyan1","cyan2","cyan3","cyan4","darkgoldenrod1","darkgoldenrod2","darkgoldenrod3","darkgoldenrod4","darkolivegreen1","darkolivegreen2","darkolivegreen3","darkolivegreen4","darkorange1","darkorange2","darkorange3","darkorange4","darkorchid1","darkorchid2","darkorchid3","darkorchid4","darkseagreen1","darkseagreen2","darkseagreen3","darkseagreen4","darkslategray1","darkslategray2","darkslategray3","darkslategray4","deeppink1","deeppink2","deeppink3","deeppink4","deepskyblue1","deepskyblue2","deepskyblue3","deepskyblue4")

hc2 <- hclust(dist(init_tsne),method="ward.D2")
























colplot.clust <- function( hclust, lab=substr(hclust$labels,1,5), lab.col=rep(1,length(hclust$labels)), hang=0.1,symbol="",...){
    if (length(symbol)>1) {
        lab<-paste(symbol,lab,sep="  ")
    }
    y <- rep(hclust$height,2)
    x <- as.numeric(hclust$merge)
    y <- y[which(x<0)]
    x <- x[which(x<0)]
    x <- abs(x)
    y <- y[order(x)]
    x <- x[order(x)]
    plot( hclust, labels=FALSE, hang=hang, ... )
    text( x=x, y=y[hclust$order]-(max(hclust$height)*hang), labels=lab[hclust$order], col=lab.col[hclust$order], cex=.5, srt=90, adj=c(1,0.5), xpd=NA, ... )
    return (lab.col[hclust$order])
}


unique_num_cluster <- unique(colplot.clust(hc2,lab.col=as.character(groups_cl[,1])))

num_cluster <- length(unique(groups_cl[,1]))


print (unique_num_cluster)

#colnames(RPKM) <- NULL
col_cluster <- c()

for (i in 1: length(unique_num_cluster))
{
    
    assign(paste("group_",unique_num_cluster[i], sep = ""),which(groups_cl[,1] == unique_num_cluster[i]))
    
    col_cluster <- c(col_cluster, eval(as.name(paste("group_",unique_num_cluster[i], sep = ""))))
}



cluster_express_matrix <- RPKM[which(!is.na(rownames(RPKM))),col_cluster]


for (i in 1:length(unique_num_cluster))
{
    assign(paste("cluster_", unique_num_cluster[i], sep=""), RPKM[which(!is.na(rownames(RPKM))),eval(as.name(paste("group_",unique_num_cluster[i], sep = "")))])
}

############################# barplot ##############################


for (i in 1:length(candidate_genes_ensembl))
{
    
    if (candidate_genes_ensembl[i] %in% rownames(RPKM))
    {
        
        #par(mfrow=c(1,num_cluster))
        if (length(unique_num_cluster) < 10)
        {
            pdf( file = paste("../result/",annotations[match_index_2[i],3], "_marker_furtherspin.pdf", sep = ""),width = 10) ###################### need change #########################
            
        }else if (length(unique_num_cluster) >= 10)
        {
            
            pdf( file = paste("../result/",annotations[match_index_2[i],3], "_marker_furtherspin.pdf", sep = ""),width = length(unique_num_cluster)) ###################### need change #########################
        }
        





















        if (length(unique_num_cluster) == 2){
            
            
            layout(matrix(c(1,2, 3,4), nrow = 2, byrow=TRUE))
            
        }else if (length(unique_num_cluster) == 3){
            
            layout(matrix(c(1,1,2, 3,4,5), nrow = 2, byrow=TRUE))
            
        }else if (length(unique_num_cluster) %% 2 == 0){
            
            layout(matrix(c( replicate( as.integer(length(unique_num_cluster)/2), 1), replicate( as.integer(length(unique_num_cluster)/2), 2), seq(3, length(unique_num_cluster)+2)), nrow = 2, byrow=TRUE))
        
        } else if ((length(unique_num_cluster) %% 2 != 0))
        {
            layout(matrix(c( replicate( as.integer(length(unique_num_cluster)/2 + 1), 1), replicate( as.integer(length(unique_num_cluster)/2), 2), seq(3, length(unique_num_cluster)+2)), nrow = 2, byrow=TRUE))
        }
        
        colplot.clust(hc2,lab.col=as.character(groups_cl[,1]))
        
 
        plot(init_tsne, col=as.character(groups_cl[,1]),pch=16)
        
        MAX_lim <- max(cluster_express_matrix[as.character(candidate_genes_ensembl[i]),])
        
        barplot(data.matrix(eval(as.name(paste("cluster_", unique_num_cluster[1], sep="")))[as.character(candidate_genes_ensembl[i]),]), border = NA,  xlab = toupper(as.character(unique_num_cluster[1])), col.lab=as.character(unique_num_cluster[1]),  cex.lab=1, col=as.character(unique_num_cluster[1]),  ylim=c(0,MAX_lim), ann=F, xaxt="n")  # first histogram
        
                
        mtext("RPKM", side=2, line=3, col="black", cex=0.8)
        
        
        title(main = annotations[match_index_2[i],3], cex.main=1)
        
        for (j in 2:length(unique_num_cluster))
        {
            
            barplot(data.matrix(eval(as.name(paste("cluster_",unique_num_cluster[j], sep="")))[as.character(candidate_genes_ensembl[i]),]), border = NA, xlab = toupper(unique_num_cluster[j]), col.lab=unique_num_cluster[j], col=unique_num_cluster[j],  ylim=c(0,MAX_lim),  yaxt='n', ann=F, xaxt="n")  # first histogram
            
        }
        
        dev.off()
    }else
    {
        
        print ("Wrong gene names!!!")
        
    }
    
    
}

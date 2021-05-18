#!/usr/bin/env python




import os
import re
import sys


print sys.argv[1]
print sys.argv[2]
print sys.argv[3]
print sys.argv[4]


gene_string = open("../source/marker_genes_pre.txt",'r').readlines() ########### need change ############

genes_array = gene_string[0].split(",")

#print genes_array

out = open("../source/marker_genes.txt",'w') ########### need change ############


for i in xrange(len(genes_array)):

	#print genes_array[i].strip()

	print >> out, genes_array[i].strip()


out.close()

os.system("rm ../result/*") ########### need change ############

os.system("R --vanilla --no-save --args %s %s %s %s < plot_6.r >../source/temp.log" %(sys.argv[1],sys.argv[2], sys.argv[3], sys.argv[4])) ########### need change ############


os.system("open ../result/basic_tsne.pdf") ########### need change ############
print "It is done!!!"
os.system("open ../result/*_marker_tsne.pdf")
os.system("open ../result/*_marker_furtherspin.pdf")



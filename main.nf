#!/usr/bin/env nextflow
params.cutoff = 10 
process filterExp { 
	input:
	path expData
	val cutoff

	output:
	path 'expression_filtered.txt'
	
	script: 
	"""
	#!/usr/bin/env Rscript
	data = read.table("$expData", as.is = TRUE, header = TRUE, row.names = 1, sep = '\\t')
	keep = rowMeans(data) >= $cutoff
	filtered = data[keep,]
	write.table(filtered,"expression_filtered.txt", sep = '\\t')
	"""
}

process boxplot {
	input: 
	path expData
	
	output:
	path "boxplot.pdf"

	script: 
	"""
	#!/usr/bin/env Rscript
	data = read.table("$expData", header = TRUE, sep =  '\\t')
	pdf("boxplot.pdf")
	boxplot(data)
	dev.off()
"""
}



workflow { 
	inputfile = Channel.fromPath (params.input) 
	filtered_data = filterExp(inputfile, params.cutoff) 
	boxplot(filtered_data)
}

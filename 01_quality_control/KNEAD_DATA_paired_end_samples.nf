//KneadData Process: Raw metagenomic samples read trimming and host DNA contaminants removal

process KNEADDATA_PAIRED {
    container 'oras://community.wave.seqera.io/library/fastqc_kneaddata:6da40eafcbed9703'

    input:
    tuple path(read1), path(read2)
    path host_dna_index

    output:
    tuple path("kneaddataOutputPairedEnd/*kneaddata_paired_1.fastq"), path("kneaddataOutputPairedEnd/*kneaddata_paired_2.fastq"), emit: kneaddata_trimmed
    path "kneaddataOutputPairedEnd/*_kneaddata.log", emit: kneaddata_log
    path "kneaddataOutputPairedEnd/fastqc/*_fastqc.html", emit: kneaddata_fastqc
    path "${ read1.simpleName }_read_count_table.tsv", emit: count_table
    
    script:
    """
    tar -xvzf ${host_dna_index}

    kneaddata --input1 ${read1} \
              --input2 ${read2} \
              --reference-db demo_db \
              --output kneaddataOutputPairedEnd \
              --run-trim-repetitive \
              --run-fastqc-start \
              --run-fastqc-end \
              --trimmomatic-options "SLIDINGWINDOW:4:20 MINLEN:50"

    kneaddata_read_count_table --input kneaddataOutputPairedEnd --output ${ read1.simpleName }_read_count_table.tsv    
    """
}


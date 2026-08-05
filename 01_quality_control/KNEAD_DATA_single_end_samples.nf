//KneadData Process: Raw metagenomic samples read trimming and host DNA contaminants removal

process KNEADDATA_SINGLE {
    container 'oras://community.wave.seqera.io/library/fastqc_kneaddata:6da40eafcbed9703'

    input:
    path raw_fastq
    path host_dna_index

    output:
    path "kneaddataOutputSingleEnd/*_kneaddata.fastq", emit: kneaddata_trimmed
    path "kneaddataOutputSingleEnd/*_kneaddata.log", emit: kneaddata_log
    path "kneaddataOutputSingleEnd/fastqc/*_fastqc.html", emit: kneaddata_fastqc
    path "kneaddata_read_count_table.tsv", emit: kneaddata_count_table

    
    script:
    """
    tar -xvzf ${host_dna_index}

    kneaddata --unpaired ${raw_fastq} \
              --reference-db demo_db \
              --output kneaddataOutputSingleEnd \
              --run-trim-repetitive \
              --run-fastqc-start \
              --run-fastqc-end \
              --trimmomatic-options "SLIDINGWINDOW:4:20 MINLEN:50"    

    kneaddata_read_count_table --input kneaddataOutputSingleEnd --output kneaddata_read_count_table.tsv    
        
    """
}





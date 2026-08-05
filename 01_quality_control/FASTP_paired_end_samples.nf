#!/usr/bin/env nextflow

process FASTP_PE {
    container "${projectDir}/singularity_cache/fastp.sif"
               
    input:
    tuple path(read_1), path(read_2)

    output:
    tuple path("${read_1.simpleName}.trimmed.fastq.gz"),
          path("${read_2.simpleName}.trimmed.fastq.gz"), emit: trimmed
    path "fastp_${read_1.simpleName}.html", emit: html
    path "fastp_${read_1.simpleName}.json", emit: json

    script:
    """
    fastp --in1 ${read_1} \
          --in2 ${read_2} \
          --out1 ${read_1.simpleName}.trimmed.fastq.gz \
          --out2 ${read_2.simpleName}.trimmed.fastq.gz \
          --cut_window_size 4 \
          --cut_mean_quality 20 \
          --length_required 50 \
          --detect_adapter_for_pe \
          --trim_poly_g \
          --trim_poly_x \
          --low_complexity_filter \
          --html 'fastp_${read_1.simpleName}.html' \
          --json 'fastp_${read_1.simpleName}.json'                              
    """
}

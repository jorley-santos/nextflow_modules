#!/usr/bin/env nextflow

/*
 * Human DNA decontamination: Removindo reads that map to the human genome using BOWTIE 2
 * BOWTIE2 is used to align the reads to human genome.
 */

process HOST_DECONTAMINATION {
    // Bowtie 2 version 2.5.5 and Samtools version 1.24
    container "${projectDir}/singularity_cache/bowtie2.sif"

    // Slurm resource allocation per task attempt
    cpus { 8 * task.attempt }
    memory { 8.GB * task.attempt }
    time { 1.hour * task.attempt }
    
    // Error strategy
    errorStrategy { task.exitStatus in 137..140 ? 'retry' : 'terminate' }
    maxRetries 3

    input:
    tuple path(read_1),
          path(read_2)
       
    val human_genome_dir
    val genome_index

    output:
    tuple path("${prefix}_decontaminated_trimmed_R1.fastq.gz"),
          path("${prefix}_decontaminated_trimmed_R2.fastq.gz"), emit: decontaminated_trimmed_fastq
    path "${prefix}_bowtie2.log", emit: bowtie2_log
    
    script:
    // Chops "A57_S27_R2.trimmed.fastq.gz" into ["A57_S27", "_R2.trimmed.fastq.gz"]
    // [0] grabs the first item
    prefix = read_1.name.split('_R')[0]

    """ 
    bowtie2 \
      -x ${human_genome_dir}/${genome_index} \
      -1 ${read_1} \
      -2 ${read_2} \
      --very-sensitive-local \
      --un-conc-gz ${prefix}_decontaminated_trimmed_R%.fastq.gz \
      --threads ${task.cpus} \
      -S /dev/null \
      2> ${prefix}_bowtie2.log
    """
}

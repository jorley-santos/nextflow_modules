/*
 * The TAXONOMY process below executes Metaphlan 4 over quality 
   trimmed .fastq files to characterize the taxonomical composition
   of each paired end metagenome passes as input.
 */ 
process TAXONOMY {
    
    // MetaPlhan 4.2.5 version
    container "${projectDir}/singularity_cache/metaphlan4.sif"

    // Slurm resource allocation per task attempt
    cpus { 8 * task.attempt }
    memory { 16.GB * task.attempt }
    time { 2.hour * task.attempt }
    
    // Error strategy
    errorStrategy { task.exitStatus in 137..140 ? 'retry' : 'terminate' }
    maxRetries 3

    input:
    tuple path(read_1),
          path(read_2)
    tuple path(unmatched_read_1),
          path(unmatched_read_2)
    val metaphlan_db_dir
    val metaphlan_db_index

    output:
    //Metaphlan profile of taxonomical classification per sample
    path "${prefix}_profile.txt", emit: metaphlan_profile
    
    //Bowtie 2 output from the aligned reads
    path "${prefix}.bowtie2.bz2", emit: metaphlan_bowtie2_out
    
    //Samtools output from the aligned reads. Useful for Strainphlan.
    path "${prefix}.sam.bz2", emit: metaphlan_samtools_out

    script:
    // Splitting fastq file ID in the _L001 line
    prefix = read_1.name.split('_L001')[0]
    
    """
    metaphlan ${read_1},${read_2},${unmatched_read_1},${unmatched_read_2} \
    --mapout ${prefix}.bowtie2.bz2 \
    --db_dir ${metaphlan_db_dir} \
    --nproc ${task.cpus} \
    -s ${prefix}.sam.bz2 \
    --index ${metaphlan_db_index} \
    --input_type fastq \
    -o ${prefix}_profile.txt
    """
}
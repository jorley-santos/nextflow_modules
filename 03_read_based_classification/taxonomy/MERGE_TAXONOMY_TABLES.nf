/*
 * The MERGE_TAXONOMY_TABLES process unifies csv reports describing 
   the taxonomical profile of multiple .fastq files into a single
   count table.  
 */ 

process MERGE_TAXONOMY_TABLES {

  // MetaPlhan 4.2.5 version
    container "${projectDir}/singularity_cache/metaphlan4.sif"

    input:
    path taxonomy_reports
    val execution_run_date

    output:
    path "taxonomy_report_table_${execution_run_date}.txt" 

    script:
    """
    merge_metaphlan_tables.py ${taxonomy_reports} > "taxonomy_report_table_${execution_run_date}.txt"
    """

}
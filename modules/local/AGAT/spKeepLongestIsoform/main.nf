
process AGAT_spKeepLongestIsoform {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/agat:1.4.0--pl5321hdfd78af_0' :
        'biocontainers/agat:1.4.0--pl5321hdfd78af_0' }"

    input:
    tuple val(meta), path(gff)

    output:
    tuple val(meta), path("*.longest_isoforms.gff"), emit: output_gff
    tuple val(meta), path("*.log"), emit: log
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    agat_sp_keep_longest_isoform.pl \\
        --gff $gff \\
        --output ${prefix}.longest_isoforms.gff \\
        $args


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        agat: \$(agat_sp_keep_longest_isoform.pl --help | sed -n 's/.*(AGAT) - Version: \\(.*\\) .*/\\1/p')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.agat.gtf
    touch ${gff}.agat.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        agat: \$(agat_sp_keep_longest_isoform.pl --help | sed -n 's/.*(AGAT) - Version: \\(.*\\) .*/\\1/p')
    END_VERSIONS
    """
}

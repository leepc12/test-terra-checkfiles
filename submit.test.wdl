version 1.0

workflow submit {
    input {
        File file
        File validation_result_json
        String md5sum
        String igvf_key
        String igvf_secret
    }

    call submit_to_igvf {
        input:
            file = file,
            validation_result_json = validation_result_json,
            md5sum = md5sum,
            igvf_key = igvf_key,
            igvf_secret = igvf_secret,
    }

    output {
        File submit_result_json = submit_to_igvf.result_json
    }
}

task submit_to_igvf {
    input {
        File file
        File validation_result_json
        String md5sum
        # security issues
        # these will be exposed as plain string in metadata.json of the workflow
        String igvf_key
        String igvf_secret
    }

    command <<<
        #!/bin/bash
        set -e

        python submit.py \
            --file ~{file} \
            --md5sum ~{md5sum} \
            --validation-result-json ~{validation_result_json} \
            --output result.json \
    >>>

    output {
        File result_json = "result.json"
    }

    runtime {
        docker: "ubuntu:22.04"
        cpu: 1
        memory: "2 GB"
        disks: "local-disk 10 SSD"
    }
}

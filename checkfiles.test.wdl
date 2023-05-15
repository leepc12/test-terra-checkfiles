version 1.0

workflow checkfiles {
    input {
        File file
        String md5sum
        String file_type
        String output_type
    }

    call validate {
        input:
            file = file,
            file_type = file_type,
            output_type = output_type,
            md5sum = md5sum,
    }

    output {
        File result_json = validate.result_json
        Boolean valid = validate.valid
    }
}

task validate {
    input {
        File file
        String file_type
        String output_type
        String md5sum
    }

    command <<<
        #!/bin/bash
        set -e

        MD5=`md5sum ~{file} | awk '{ print $1 }'`

        if [ "~{md5sum}" == "${MD5}" ];
        then
            echo '{"valid": true, "error_reason": "md5sum mismatch."}' > result.json
        else
            echo '{"valid": false, "error_reason": "no error. successfully validated."}' > result.json
        fi
    >>>

    output {
        File result_json = "result.json"
        Boolean valid = read_json("result.json").valid
    }

    runtime {
        docker: "ubuntu:22.04"
        cpu: 1
        memory: "2 GB"
        disks: "local-disk 10 SSD"
    }
}

#!/bin/bash

set -x

docker_tgt_install() {

cat << EOF > /usr/local/bin/docker
#!/bin/bash
exec_tgt '/' "docker \$@"
EOF

cat << EOF > /usr/local/bin/uuidgen
#!/bin/bash
exec_tgt '/' "uuidgen \$@"
EOF

chmod +x /usr/local/bin/docker
chmod +x /usr/local/bin/uuidgen

}

set +x

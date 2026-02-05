cat <<EOF |  curl --data-binary @- http://192.168.100.5:30091/metrics/job/db_backup
db_backup_success 1
db_backup_duration_seconds 152.17
EOF

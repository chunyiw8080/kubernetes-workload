kubectl create configmap kafka-eagle-config \
-n logging \
--from-file=kafka_client_jaas.conf \
--from-file=system-config.properties
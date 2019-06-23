FROM confluentinc/cp-ksql-server:5.2.2

RUN mkdir /ksql
RUN curl http://central.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.3.1/jmx_prometheus_javaagent-0.3.1.jar > /ksql/jmx_prometheus_javaagent.jar
RUN pwd
COPY prometheus-config.yml /ksql/config.yml

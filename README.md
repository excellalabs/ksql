# Confluent KSQL Server
CI/CD pipeline for Confluent KSQL Server. This will deploy the server in a Fargate docker container.

## Tech Stack
  * Ruby
  * Cloudformation
  * Docker
  * Amazon Fargate
  * Amazon ECR
  * JMX Exporter
  * Confluent KSQL Server
  * Jenkins

# What is KSQL
Confluent KSQL is the streaming SQL engine that enables real-time data processing against Apache Kafka®. It provides an easy-to-use, yet powerful interactive SQL interface for stream processing on Kafka, without the need to write code in a programming language such as Java or Python. KSQL is scalable, elastic, fault-tolerant, and it supports a wide range of streaming operations, including data filtering, transformations, aggregations, joins, windowing, and sessionization.


# Use Cases
##### Streaming ETL
Apache Kafka is a popular choice for powering data pipelines. KSQL makes it simple to transform data within the pipeline, readying messages to cleanly land in another system.
##### Real-time Monitoring and Analytics
Track, understand, and manage infrastructure, applications, and data feeds by quickly building real-time dashboards, generating metrics, and creating custom alerts and messages.
##### Data exploration and discovery
Navigate and browse through your data in Kafka.
##### Anomaly detection
Identify patterns and spot anomalies in real-time data with millisecond latency, allowing you to properly surface out of the ordinary events and to handle fraudulent activities separately.
##### Sensor data and IoT
Understand and deliver sensor data how and where it needs to be.

# Terminology
##### KSQL Server
The KSQL server runs the engine that executes KSQL queries. This includes processing, reading, and writing data to and from the target Kafka cluster.

##### KSQL CLI
You can interactively write KSQL queries by using the KSQL command line interface (CLI). The KSQL CLI acts as a client to the KSQL server. For production scenarios you may also configure KSQL servers to run in non-interactive "headless" configuration, thereby preventing KSQL CLI access.

##### Stream
A stream is an unbounded sequence of structured data (“facts”). For example, we could have a stream of financial transactions such as “Alice sent $100 to Bob, then Charlie sent $50 to Bob”. Facts in a stream are immutable, which means new facts can be inserted to a stream, but existing facts can never be updated or deleted. Streams can be created from a Kafka topic or derived from an existing stream. A stream’s underlying data is durably stored (persisted) within a Kafka topic on the Kafka brokers.

##### Table 
A table is a view of a stream, or another table, and represents a collection of evolving facts. For example, we could have a table that contains the latest financial information such as “Bob’s current account balance is $150”. It is the equivalent of a traditional database table but enriched by streaming semantics such as windowing. Facts in a table are mutable, which means new facts can be inserted to the table, and existing facts can be updated or deleted. Tables can be created from a Kafka topic or derived from existing streams and tables. In both cases, a table’s underlying data is durably stored (persisted) within a Kafka topic on the Kafka brokers.

##### STRUCT 
In KSQL 5.0 and higher, you can read nested data, in Avro and JSON formats, by using the <span style="color:darkred">STRUCT</span> type in CREATE STREAM and CREATE TABLE statements. 

## Environment Variables
```sh
export KSQL_BOOTSTRAP_SERVERS=localhost:9092
export KSQL_HOST_NAME=ksql-server
export KSQL_LISTENERS=http://0.0.0.0:8088
export KSQL_CACHE_MAX_BYTES_BUFFERING=0
```

# Examples
Create stream from topic with schema
```
CREATE STREAM CDC_TRANSACTIONS (payload STRUCT<after STRUCT< \
  id BIGINT, \
  name VARCHAR, \
  credit_card_4 VARCHAR, \
  amount DOUBLE, \
  city VARCHAR, \
  STATE VARCHAR, \
  zip_code VARCHAR, \
  created_at BIGINT>>) \
WITH (KAFKA_TOPIC='dbserver1.public.transactions', VALUE_FORMAT='JSON');
```
Create Stream to flatten the data with schema:
```sql
CREATE STREAM FLATTENED_TRANSACTIONS AS \
  SELECT PAYLOAD->AFTER->ID AS id, \
         CAST(PAYLOAD->AFTER->ID AS STRING) AS transaction_id, \
           PAYLOAD->AFTER->NAME AS name, \
           PAYLOAD->AFTER->CREDIT_CARD_4 AS credit_card, \
           PAYLOAD->AFTER->AMOUNT AS amount, \
           PAYLOAD->AFTER->CITY AS city, \
           PAYLOAD->AFTER->STATE AS state, \
           PAYLOAD->AFTER->ZIP_CODE as zip_code, \
           PAYLOAD->AFTER->CREATED_AT AS created_at \
    FROM CDC_TRANSACTIONS \
PARTITION BY transaction_id;
```
Create stream from topic with NO schema:
```sql
CREATE STREAM CDC_TRANSACTIONS \
  (after STRUCT<id BIGINT, \
            name VARCHAR, \
                  credit_card VARCHAR, \
                  amount DOUBLE, \
                  city VARCHAR, \
                  STATE VARCHAR, \
                  zip_code VARCHAR, \
                  created_at BIGINT>) \
WITH (KAFKA_TOPIC='dbserver1.public.transactions', VALUE_FORMAT='JSON');
```
Create Stream to flatten the data with NO schema:
```sql
CREATE STREAM FLATTEN_TRANSACTIONS AS \
  SELECT CAST(AFTER->ID AS STRING) AS id, \
         AFTER->NAME AS name, \
           AFTER->CREDIT_CARD AS credit_card, \
           AFTER->AMOUNT AS amount, \
           AFTER->CITY AS city, \
           AFTER->STATE AS state, \
           AFTER->ZIP_CODE as zip_code, \
           AFTER->CREATED_AT AS created_at \
    FROM CDC_TRANSACTIONS \
PARTITION BY id;
```
Create fraud table:
```sql
CREATE TABLE POSSIBLE_FRAUD AS \
  SELECT name, credit_card, SUM(amount) AS total_amount, count(*) AS transaction_count \
    FROM FLATTEN_TRANSACTIONS \
    WINDOW TUMBLING (SIZE 5 SECONDS) \
    GROUP BY name, credit_card \
    HAVING count(*) >= 3;
```

FROM java:8u40
COPY target/income-predictor-vaadin-0.0.1-SNAPSHOT.jar app.jar
CMD java -Djava.security.egd=file:/dev/./urandom -jar -Xdebug app.jar

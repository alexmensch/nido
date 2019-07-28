FROM alexmensch/nido AS nido-api

COPY private-config.py /usr/local/var/nido.web-instance

ENV NIDOD_RPC_PORT=49152

EXPOSE 80

ENTRYPOINT ["gunicorn", "-b 0.0.0.0:80", "nido.web:create_app()"]



FROM alexmensch/nido AS nido-supervisor

ENV NIDO_BASE=/app \
    NIDOD_LOG_FILE=/app/log/nidod.log \
    NIDOD_RPC_PORT=49152 \
    NIDOD_MQTT_CLIENT_NAME=Nido \
    NIDOD_MQTT_PORT=1883

ENTRYPOINT ["python", "-m", "nido.supervisor"]



FROM arm32v6/eclipse-mosquitto AS nido-mqtt

COPY mosquitto.conf /mosquitto/config/mosquitto.conf

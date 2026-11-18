FROM docker:29.8.1-cli

RUN apk add --no-cache bash git openssl shellcheck

COPY setup.sh /bootstrap/setup.sh
COPY tests/setup.test.sh /tests/setup.test.sh

ENTRYPOINT ["bash", "/tests/setup.test.sh"]

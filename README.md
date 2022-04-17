# Setup

To build the container and create the volume which will host all the generated certificates:

```bash
docker build -t mkcert-issuer -f Dockerfile .
```

Once the container is published, this will not be needed.

# Use

To use the container

```shell
# Create the volume:
docker volume create --name mkcert-vol

# Generate the certificate (and the root certificate if its the first-run)
docker run \
    --rm \
    -v mkcert-vol:/root/.local/share/mkcert \
    mkcert-issuer \
    mkcert -cert-file your-domain.com-cert.pem -key-file your-domain.com-key.pem \
        your-domain.com test.your-domain.com *.your-domain.com your-other-domain.com
```

You'll need to trust the root certificate only once regardless of any updates to the used domains (and subsequently any generates certificates).

```shell
# Extract the root certificate from the mkcert volume
docker run --rm -v /tmp:/host:rw -v mkcert-vol:/vol -it alpine cp -r /vol/rootCA.pem /host/mkcert-root-ca.pem

# For macOS
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /tmp/mkcert-root-ca.pem

# For Linux (Debian)
sudo cp /tmp/mkcert-root-ca.pem /usr/local/share/ca-certificates/mkcert-root-ca.pem
sudo update-ca-certificates

# For Windows
certutil -addstore -f "ROOT" /tmp/mkcert-root-ca.pem
```

# Scripts

- `make build` builds the container image
- `make setup` builds the image and trusts the root CA certificate
- `make test` generates a certificate and brings up a simple web server at dev.localhost.com to verify it works

# Credits
- https://hub.docker.com/r/vishnunair/docker-mkcert/
- https://hub.docker.com/repository/docker/kklepper/mkcert_a
- https://manuals.gfi.com/en/kerio/connect/content/server-configuration/ssl-certificates/adding-trusted-root-certificates-to-the-server-1605.html

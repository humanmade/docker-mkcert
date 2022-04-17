build:
	@echo "\n== Building the container.."

	@docker volume create --name mkcert-vol
	@docker build -t mkcert-issuer -f Dockerfile .

setup: build
	@echo "\n== Generating the root certificate.."
	@docker run \
		--rm \
		-v mkcert-vol:/root/.local/share/mkcert \
		mkcert-issuer \
		mkcert -install

	@echo "\n== Trusting the certificate locally.."
	@docker run \
		-it \
		--rm \
		-v /tmp:/host:rw \
		-v mkcert-vol:/vol \
		alpine \
		cp -r /vol/rootCA.pem /host/mkcert-root-ca.pem
	@sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /tmp/mkcert-root-ca.pem


test:
	@docker rm -f mkcert-test >/dev/null 2>&1

	@echo "\n== Creating the certificate.."
	@docker run \
		--rm \
		-v mkcert-vol:/root/.local/share/mkcert \
		mkcert-issuer \
		mkcert \
			-cert-file cert.pem \
			-key-file key.pem \
			dev.localhost.com

	@echo "\n== Testing the certificate.."
	@docker build -f Dockerfile.test -t=mkcert-test .
	@docker run -d -p 8443:443 --name mkcert-test -v mkcert-vol:/tmp mkcert-test
	@sleep 3
	@curl --resolve dev.localhost.com:8443:127.0.0.1 https://dev.localhost.com:8443

	@echo "\n== Press any key to quit."
	@read

	@echo "\n== Removing the test container.."
	@docker rm -f mkcert-test

clean:
	@echo "\n== Cleaning.."
	@docker volume rm -f mkcert-vol

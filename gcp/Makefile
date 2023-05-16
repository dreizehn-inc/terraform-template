DEV_GCP_PROJECT_ID = ""
STG_GCP_PROJECT_ID = ""
PRD_GCP_PROJECT_ID = ""

DEV_PROJECT_PATH = environment/development
STG_PROJECT_PATH = environment/staging
PRD_PROJECT_PATH = environment/production

.PHONY: symlink-all
symlink-all: symlink-dev symlink-stg symlink-prd

.PHONY: symlink-dev
symlink-dev:
	cp misc/symlink.sh ${DEV_PROJECT_PATH}/ && \
	chmod +x ${DEV_PROJECT_PATH}/symlink.sh && \
	cd ${DEV_PROJECT_PATH} && \
	./symlink.sh && \
	cd ../.. && \
	rm ${DEV_PROJECT_PATH}/symlink.sh

.PHONY: symlink-stg
symlink-stg:
	cp misc/symlink.sh ${STG_PROJECT_PATH}/ && \
	chmod +x ${STG_PROJECT_PATH}/symlink.sh && \
	cd ${STG_PROJECT_PATH} && \
	./symlink.sh && \
	cd ../.. && \
	rm ${STG_PROJECT_PATH}/symlink.sh

.PHONY: symlink-prd
symlink-prd:
	cp misc/symlink.sh ${PRD_PROJECT_PATH}/ && \
	chmod +x ${PRD_PROJECT_PATH}/symlink.sh && \
	cd ${PRD_PROJECT_PATH} && \
	./symlink.sh && \
	cd ../.. && \
	rm ${PRD_PROJECT_PATH}/symlink.sh

.PHONY: tf-apply-dev
tf-apply-dev:
	cd ${DEV_PROJECT_PATH} && \
	direnv exec . \
		terraform apply

.PHONY: tf-apply-stg
tf-apply-stg:
	cd ${STG_PROJECT_PATH} && \
	direnv exec . \
		terraform apply

.PHONY: tf-apply-prd
tf-apply-prd:
	cd ${PRD_PROJECT_PATH} && \
	direnv exec . \
		terraform apply

.PHONY: encrypt-sops-dev
encrypt-sops-dev:
	cd ${DEV_PROJECT_PATH} && \
	direnv exec . \
		sops --input-type json \
			--encrypt \
			--gcp-kms projects/${DEV_GCP_PROJECT_ID}/locations/global/keyRings/dev-sops-key-ring/cryptoKeys/dev-sops-key \
			secrets/sops_secrets.json > secrets/sops_secrets_encrypted.json

.PHONY: decrypt-sops-dev
decrypt-sops-dev:
	cd ${DEV_PROJECT_PATH} && \
	direnv exec . \
		sops --input-type json \
			--decrypt \
			--gcp-kms projects/${DEV_GCP_PROJECT_ID}/locations/global/keyRings/dev-sops-key-ring/cryptoKeys/dev-sops-key \
			secrets/sops_secrets_encrypted.json > secrets/sops_secrets_decrypted.json

.PHONY: encrypt-sops-stg
encrypt-sops-stg:
	cd ${STG_PROJECT_PATH} && \
	direnv exec . \
		sops --input-type json \
			--encrypt \
			--gcp-kms projects/${STG_GCP_PROJECT_ID}/locations/global/keyRings/stg-sops-key-ring/cryptoKeys/stg-sops-key \
			secrets/sops_secrets.json > secrets/sops_secrets_encrypted.json

.PHONY: decrypt-sops-stg
decrypt-sops-stg:
	cd ${STG_PROJECT_PATH} && \
	direnv exec . \
		sops --input-type json \
			--decrypt \
			--gcp-kms projects/${STG_GCP_PROJECT_ID}/locations/global/keyRings/stg-sops-key-ring/cryptoKeys/stg-sops-key \
			secrets/sops_secrets_encrypted.json > secrets/sops_secrets_decrypted.json

.PHONY: encrypt-sops-prd
encrypt-sops-prd:
	cd ${PRD_PROJECT_PATH} && \
	direnv exec . \
		sops --input-type json \
			--encrypt \
			--gcp-kms projects/${PRD_GCP_PROJECT_ID}/locations/global/keyRings/prd-sops-key-ring/cryptoKeys/prd-sops-key \
			secrets/sops_secrets.json > secrets/sops_secrets_encrypted.json

.PHONY: decrypt-sops-prd
decrypt-sops-prd:
	cd ${PRD_PROJECT_PATH} && \
	direnv exec . \
		sops --input-type json \
			--decrypt \
			--gcp-kms projects/${PRD_GCP_PROJECT_ID}/locations/global/keyRings/prd-sops-key-ring/cryptoKeys/prd-sops-key \
			secrets/sops_secrets_encrypted.json > secrets/sops_secrets_decrypted.json
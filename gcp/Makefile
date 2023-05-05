
DEV_PROJECT_PATH = environment/development
STG_PROJECT_PATH = environment/staging
PRO_PROJECT_PATH = environment/production

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
	cp misc/symlink.sh ${PRO_PROJECT_PATH}/ && \
	chmod +x ${PRO_PROJECT_PATH}/symlink.sh && \
	cd ${PRO_PROJECT_PATH} && \
	./symlink.sh && \
	cd ../.. && \
	rm ${PRO_PROJECT_PATH}/symlink.sh
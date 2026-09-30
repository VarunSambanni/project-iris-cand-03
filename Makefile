COMPOSE = docker compose
PSQL = $(COMPOSE) exec -T db psql -v ON_ERROR_STOP=1 -U iris -d iris
MIGRATIONS = $(sort $(wildcard migrations/*.sql))

.PHONY: up down migrate seed promote evidence reset rebuild verify test

up:
	$(COMPOSE) up -d --wait

down:
	$(COMPOSE) down

migrate:
	@set -e; for file in $(MIGRATIONS); do \
		echo "Applying $$file"; \
		$(PSQL) < "$$file"; \
	done

seed:
	$(PSQL) < fixtures/seed.sql

promote:
	$(PSQL) < scripts/promote.sql

evidence:
	$(PSQL) < scripts/generate_evidence.sql

reset:
	$(PSQL) < scripts/reset.sql

rebuild: up reset migrate seed promote evidence

verify:
	$(PSQL) < verification/verify.sql

test:
	$(COMPOSE) build test
	$(COMPOSE) --profile test run --rm test

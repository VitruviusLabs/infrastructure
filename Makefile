
development.docker.create-authority:
	@bash ./development/scripts/create_authority.sh ||:

development.docker.initialise:
	@bash ./development/scripts/initialise.sh ||:

development.docker.start:
	@bash ./development/docker/scripts/up.sh ||:

development.docker.stop:
	@bash ./development/docker/scripts/down.sh ||:

development.docker.restart:
	@bash ./development/docker/scripts/restart.sh ||:
	
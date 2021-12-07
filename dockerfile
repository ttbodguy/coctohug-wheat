FROM raingggg/coctohug-body:develop
ARG CODE_BRANCH

# copy local files
COPY . /coctohug/

# set workdir
WORKDIR /chia-blockchain

# Install Chia (and forks), Plotman, Chiadog, Coctohug, etc
RUN \
	/usr/bin/bash /coctohug/chain_install.sh ${CODE_BRANCH}

WORKDIR /chia-blockchain

RUN \
	/usr/bin/bash /coctohug/coctohug_install.sh \
	&& rm -rf \
		/root/.cache \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

# Provide a colon-separated list of in-container paths to your mnemonic keys
ENV keys="/root/.coctohug/mnc.txt"  
# Provide a colon-separated list of in-container paths to your completed plots
ENV plots_dir="/plots"
# One of fullnode, farmer, harvester, plotter, farmer+plotter, harvester+plotter. Default is fullnode
ENV mode="fullnode" 
# If mode=harvester, required for host and port the harvester will your farmer
ENV farmer_address="null"

ENV PATH="${PATH}:/chia-blockchain/venv/bin"
ENV TZ=Etc/UTC
ENV FLASK_ENV=production
ENV XDG_CONFIG_HOME=/root/.chia

VOLUME [ "/id_rsa" ]

# Local network hostname of a Coctohug controller - localhost when standalone
ENV controller_address="localhost"
ENV controller_web_port=12630

ENV WEB_MODE="worker"
ENV worker_address="localhost"
ENV worker_web_port=12656
EXPOSE 12656

# full name of blockchain
ENV config_file="/coctohug/web/blockchain.json"
ENV blockchain="wheat"

# blockchain protocol port - forward at router
EXPOSE 21333

# blockchain farmer port - DO NOT forward at router
ENV farmer_port="21447"
EXPOSE 21447

WORKDIR /chia-blockchain
ENTRYPOINT ["bash", "./entrypoint.sh"]
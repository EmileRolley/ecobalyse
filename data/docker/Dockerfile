FROM jupyter/minimal-notebook:notebook-7.0.6

ENV BRIGHTWAY2_DIR /home/$NB_USER/data
ENV BRIGHTWAY2_DOCKER 1
ENV BRIGHTWAY2_OUTPUT_DIR /home/$NB_USER/output
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"

USER $NB_USER

RUN mkdir -p /home/$NB_USER/data \
    && mkdir -p /home/$NB_USER/notebooks \
    && mkdir -p /home/$NB_USER/output \
    && fix-permissions "/home/${NB_USER}/data" \
    && fix-permissions "/home/${NB_USER}/notebooks" \
    && fix-permissions "/home/${NB_USER}/output"

# keep in sync with requirements.txt
# allow to update the image if the source repo is updated
ADD https://api.github.com/repos/ccomb/brightway2-io/git/refs/tags/ccomb-3 bw2-io.json
ADD https://api.github.com/repos/brightway-lca/brightway2-parameters/git/refs/tags/1.1.0 bw2-parameters.json
ADD https://api.github.com/repos/brightway-lca/brightway2-data/git/refs/tags/4.0.DEV33 bw2-data.json
ADD https://api.github.com/repos/brightway-lca/brightway2-calc/git/refs/tags/2.0.DEV16 bw2-calc.json
ADD https://api.github.com/repos/brightway-lca/brightway2-analyzer/git/refs/tags/0.11.7 bw2-analyzer.json
ADD https://api.github.com/repos/brightway-lca/bw_projects/git/refs/tags/v2.1.0 bw_projects.json

COPY requirements.txt .

USER root
RUN apt update \
    && apt install -y gosu vim \
    && pip install -r /home/$NB_USER/requirements.txt \
    && rm /home/$NB_USER/requirements.txt \
    && if [ "$(dpkg --print-architecture)" = "amd64" ]; then pip install  pypardiso==0.4; ldconfig; fi;

COPY simapro-biosphere.json /opt/conda/lib/python3.11/site-packages/bw2io/data/
COPY entrypoint.sh /

VOLUME /home/$NB_USER
WORKDIR /home/$NB_USER/notebooks
ENTRYPOINT ["/entrypoint.sh"]

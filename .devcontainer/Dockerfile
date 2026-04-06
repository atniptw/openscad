FROM openscad/openscad:dev

# Add tools required by the VS Code Server (absent from the slim final stage)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

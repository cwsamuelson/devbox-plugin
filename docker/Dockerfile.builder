FROM gcc

# Installing your devbox project
RUN apt-get update \
 && apt-get -y upgrade \
 && apt-get -y install --no-install-recommends \
  cmake \
  doxygen \
  mkdocs \
  ninja-build \
  python-is-python3 \
  python3-pip \
  python3-venv \
 && python -m venv .venv \
 && . .venv/bin/activate \
 && python -m pip install \
  conan \
  mkdoxy \
 && git clone --depth=1 https://github.com/AFLplusplus/AFLplusplus.git afl \
 && cd afl \
 && make \
 && rm -rf /var/lib/apt/lists/*

COPY Dockerfile.builder .


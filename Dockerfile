FROM ubuntu:21.10

RUN ln -sf /usr/share/zoneinfo/America/Mexico_City /etc/localtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    tzdata \
    ca-certificates \
    python3-pip \
    python3-venv \
    curl \
    git \
    tar \
    software-properties-common \
    && echo "America/Mexico_City" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && echo 'LANG="en_US.UTF-8"'>/etc/default/locale \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ["requirements.txt", "/project/requirements.txt"]

RUN curl -O "https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.2-linux-x86_64.tar.gz"

RUN tar xf julia-1.7.2-linux-x86_64.tar.gz

RUN rm julia-1.7.2-linux-x86_64.tar.gz

RUN mv julia-1.7.2/ /opt/

RUN  ln -s /opt/julia-1.7.2/bin/julia /usr/local/bin/julia

WORKDIR /project

RUN pip install -r requirements.txt

COPY ["packages.jl", "/project/packages.jl"]

RUN julia packages.jl

COPY [".", "/project/"]

EXPOSE 80

CMD ["jupyter", "lab", "--ip='*'", "--allow-root", "--no-browser", "--port=80", "--NotebookApp.password=''", "--NotebookApp.token=''"]

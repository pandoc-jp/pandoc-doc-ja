

FROM sphinxdoc/sphinx

WORKDIR /root

# Pandocのバージョン
ENV PANDOC_VERSION=2.9.2.1

# Pandoc (コマンド実行用、latest)
# TODO: バイナリをダウンロードする (citeprocとかは不要)
# TODO: Debianのやつ
RUN apt-get install -y curl git && \
    curl -L -o pandoc.deb https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-amd64.deb && \
    dpkg -i pandoc.deb && \
    rm -f pandoc.deb

WORKDIR /docs

# Python (pip)
ADD requirements.txt ./
RUN pip install -r requirements.txt

CMD ["make", "ja-html"]

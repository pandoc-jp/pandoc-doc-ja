FROM sphinxdoc/sphinx

# インストール作業用ディレクトリ
WORKDIR /root

# Pandocのバージョン
ENV PANDOC_VERSION=2.18

# txコマンド (Transifex Client) のAPIトークン
# 【注意】ホスト側シェルの環境変数から渡すこと 
# 例: docker run -e TX_TOKEN ...
ENV TX_TOKEN ""

# インストール: curl, git, pandoc (本家からdebバイナリをダウンロード)
RUN apt-get update && \
    apt-get install -y curl git && \
    curl -L -o pandoc.deb https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-amd64.deb && \
    dpkg -i pandoc.deb && \
    rm -f pandoc.deb

# Transifex Client (new version)
RUN curl -o- https://raw.githubusercontent.com/transifex/cli/master/install.sh | bash

# Sphinxドキュメント用ディレクトリ
WORKDIR /docs

# Python (pip)
ADD requirements.txt ./
RUN pip install -r requirements.txt

# make ja-html: pandoc-jpサイトをビルド
# (これ以降はMakefileを参照)
CMD ["make", "ja-html"]

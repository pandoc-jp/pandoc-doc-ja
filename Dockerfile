FROM sphinxdoc/sphinx

WORKDIR /docs
ADD Pipfile Pipfile.lock ./

RUN pip3 install pipenv && \
    pipenv --python $(grep python_version Pipfile | perl -pe 's/python_version = "(3.8)"/$1/') && \
    pipenv install

CMD ["make", "ja-html"]

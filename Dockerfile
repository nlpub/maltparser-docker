FROM java:8-jre

MAINTAINER Dmitry Ustalov

RUN \
apt-get update && \
apt-get install -y -o Dpkg::Options::="--force-confold" build-essential unzip && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

RUN \
curl -O http://maltparser.org/dist/malt-1.5.tar.gz && \
tar xf malt-1.5.tar.gz -C / && \
mv malt-1.5 malt && \
rm malt-1.5.tar.gz

WORKDIR /malt

RUN \
mkdir treetagger && cd treetagger && \
curl \
-O 'http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/tree-tagger-linux-3.2.tar.gz' \
-O 'http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/tagger-scripts.tar.gz' \
-O 'http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/install-tagger.sh' \
-O 'http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/russian-par-linux-3.2-utf8.bin.gz' \
-O 'http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/english-par-linux-3.2-utf8.bin.gz' \
-O 'http://corpus.leeds.ac.uk/mocky/lemma-ru.tgz' \
-O 'http://corpus.leeds.ac.uk/tools/smallutils.pm' && \
sh install-tagger.sh && \
tar xf lemma-ru.tgz -C cmd && \
mv smallutils.pm cmd/ && \
ln -sf /malt/treetagger/cmd/utf8-tokenize.perl /malt/treetagger/cmd/utf8-tokenize.pl && \
rm *.gz *.tgz && \
sed -i "s#use lib('/corpora/tools'#use File::Basename;\nuse lib(dirname(\$0)#g" cmd/lemmatiser.pl

RUN \
mkdir cstlemma && cd cstlemma && \
curl -LO 'https://raw.githubusercontent.com/kuhumcst/cstlemma/master/doc/makecstlemma.bash' && \
bash makecstlemma.bash && \
cp cstlemma/src/cstlemma /malt/treetagger/cmd/

RUN \
curl \
-O 'http://corpus.leeds.ac.uk/mocky/russian-malt.tgz' \
-O 'http://corpus.leeds.ac.uk/mocky/rus-test.mco' && \
tar xfv russian-malt.tgz && \
sed -i 's#/corpora/tools#/malt#g' russian-malt.sh && \
sed -i 's#^MALT=.*#MALT=/malt#g' russian-malt.sh && \
sed -i "s#russian.par#russian-utf8.par#g" russian-malt.sh && \
sed -i 's#make-malt.pl#/malt/make-malt.pl#g' russian-malt.sh && \
sed -i 's#shake-malt.pl#/malt/shake-malt.pl#g' russian-malt.sh && \
sed -i 's/^#\$/$/g' russian-malt.sh && \
sed -i 's#tmpmalttex#$MALT/tmpmalttex#g' russian-malt.sh && \
rm russian-malt.tgz

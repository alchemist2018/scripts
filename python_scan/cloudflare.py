import urllib
from urllib.request import urlopen

fo = open('test.txt','r')

for line in fo.readlines():
    line = line.strip()
    url = 'http://' + str(line) + ':12345/cdn-cgi/trace'
    try:
        y = urlopen(url,timeout=0.2)
        print(url)
        fw = open('output.txt','a')
        fw.write(line + '\n')
        fw.close()
    except:
        print(line)
fo.close()
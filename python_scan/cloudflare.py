import requests
import json
fo = open('test.txt','r')

for line in fo.readlines():
    line = line.strip()
    url = 'http://' + str(line) + ':443'
    try:
        r = requests.get(url, timeout=0.2)
        content=str(r.headers)
        content= content.replace("'", '"')
        data = json.loads(content)
        if data["Server"] == "cloudflare":
            print(url)
            fw = open('output.txt','a')
            fw.write(url + '\n')
            fw.close()
        else:
            print(line)
    except:
        print(line)
fo.close()